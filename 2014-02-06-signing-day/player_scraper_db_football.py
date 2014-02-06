import csv
import urllib2
import json
import datetime
from bs4 import BeautifulSoup
from bs4 import NavigableString
from bs4 import Tag


## Loops through team list, gets links for all teams
team_table = []

url = "http://www.databasefootball.com/players/playerbycollege.htm"
soup = BeautifulSoup(urllib2.urlopen(url).read())

for font in soup.findAll('font', { "class":"bio" }):
    for l in font.findAll('a'):
        school = l.contents[0]
        link = "http://www.databasefootball.com/players/" + l['href']
        
        entry = (school,link)
        team_table.append(entry)

## Makes team table, writes to CSV
team_table = team_table[1:]

tt = strip_special(team_table,[0])
write_to_csv("teams.csv",tt)


## Uses school table to create list of all players
player_table = []

for t in team_table[975:]:
    school = t[0]
    url = t[1]
    i = 0
    
    print('---------------------')
    print(school)
    print('--')
    
    soup = BeautifulSoup(urllib2.urlopen(url).read())
    
    for font in soup.findAll("font", { "class":"bio" }):
        for a in font.findAll('a'):
            player = a.contents[0]
            link = a['href']
            if player != 'More Colleges':
                dates = a.nextSibling
                op = dates.find('(')
                cp = dates.find(')')
                begin = int(dates[op+1:op+5])
                end = int(dates[cp-4:cp])
                
                entry = (school,player,link,begin,end)
                print(entry)
                player_table.append(entry)
                i+=1

cp = strip_special(player_table,[0,1])

## Strip out funny formatting from website
new_cp = []
for p in cp:
    new = p[1].replace(",\xc2\xa0",", ")    
    entry = (p[0],new,p[2],p[3],p[4])
    new_cp.append(entry)

write_to_csv("all_nfl_players.csv",new_cp)


## Get player info
players = read_table("all_nfl_players.csv",True)
hometown_table = []
errors = []

for p in players:
    url = "http://www.databasefootball.com" + p[2]
    print(p[0] + " -- " + p[1] + " -- " + url)
    soup = BeautifulSoup(urllib2.urlopen(url).read())
    bio = soup.findAll("font", { "class":"bio" })
    fonts = bio[0].findAll("font")
    
    position = ''
    height = ''
    weight = ''
    born = ''
    high_school = ''
    
    try:
        for f in fonts:
            clean = ''.join(e for e in f.contents[0] if e.isalnum())
            clean = clean.lower()
            
            if clean == 'position':
                position = f.nextSibling.strip()
            elif clean == 'height':
                height = f.nextSibling.strip()
            elif clean == 'weight':
                weight = f.nextSibling.strip()
            elif clean == 'born':
                born = f.nextSibling.nextSibling.nextSibling.strip()
            elif clean == 'highschool':
                high_school = f.nextSibling.strip()
        
        sp = born.find(' in ')
        full_town = born[sp+4:].strip()
        
        if full_town[-3:] == 'USA':
            length = len(full_town)
            town_state = full_town[:length-5]
            t = town_state.split(',')
            town = t[0].strip()
            state = t[1].strip()
            country = 'USA'
        else:
            t = full_town.split(',')
            town = t[0].strip()
            state = ''
            country = t[1].strip()
        
        start_hs = high_school.find('(')
        end_hs = high_school.find(')')
        
        info = (p[0],p[1],p[3],p[4],position,height,weight,town,state,country,high_school)
        hometown_table.append(info)
        
    except Exception as e:
        print(e)
        entry = (p[0],p[3],url)
        errors.append(entry)
    

## CSV writing functions
def write_to_csv(csv_name,array):
    columns = len(array[0])
    rows = len(array)
    
    with open(csv_name, "wb") as test_file:
        file_writer = csv.writer(test_file)
        for i in range(rows):
            file_writer.writerow([array[i][j] for j in range(columns)])

def strip_special(array,columns_with_string):
    new_table = []
    for i in array:
        new_row =[]
        for j in range(len(i)):
            if j in columns_with_string:
                x = i[j].encode('utf-8').strip()
            else:
                x = i[j]
            new_row.append(x)
            
        new_table.append(new_row)
    
    return new_table

def read_table(csv_name,include_header):
    table = []
    
    with open(csv_name, 'Ub') as csvfile:
        f = csv.reader(csvfile, delimiter=',')
        firstline = True
        
        for row in f:
            if firstline == False or include_header == True:
                table.append(tuple(row))
            firstline = False
    
    return table