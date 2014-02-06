import csv
import urllib2
import json
import datetime
import re
from bs4 import BeautifulSoup
from bs4 import NavigableString
from bs4 import Tag


## Loops through team list, gets links for all teams
player_table = []
current_player_table = []
errors =[]
alphabet = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
# url = "http://www.nfl.com/players/search?category=lastName&playerType=historical&d-447263-p="
url = "http://www.nfl.com/players/search?category=lastName&playerType=current&d-447263-p="

## Generate tables of all possible URLs
urls = []

for l in alphabet:
    for n in range(8):
        u1 = url + str(n+1)
        u2 = u1 + "&filter=" + l
        urls.append(u2)

## Loop over urls and get player info and links
for u in urls:
    print(u)
    try:
        soup = BeautifulSoup(urllib2.urlopen(u).read())
        table = soup.find('table', { "id":"result" })
        rows = table.findAll('tr')
        
        for r in range(len(rows)):
            if r != 0:
                cells = rows[r].findAll('td')
                # name = cells[0]('a')[0].contents[0]
                # link = cells[0]('a')[0]['href']
                name = cells[2]('a')[0].contents[0]
                link = cells[2]('a')[0]['href']
                # career = cells[2].contents[0]
                # start_career = career[0:4]
                # end_career = career[-4:]
                
                player_entry = (name,link)
                current_player_table.append(player_entry)
    
    except Exception as e:
        print(e)
        errors.append(u)

write_to_csv("current_player_urls_from_nfl.csv",current_player_table)

## Look up players in player list
player_bios = []
missing = []


players = read_table("to_look_up.csv",True)

## Get current player info
for p in players:
    ## Current players
    if p[2] == '1000':
        print(p[0] + " --- " + p[1])
        url = "http://www.nfl.com" + p[1]
        soup = BeautifulSoup(urllib2.urlopen(url).read())
        
        info = soup.find("div", { "class" : "player-info" })
        para = info.findAll('p')
        
        name = p[0]
        
        strongs = info.findAll('strong')
        if len(strongs) == 7:
        
            born = strongs[3].nextSibling.strip()
            college = strongs[4].nextSibling.strip()[1:].strip()
            experience = strongs[5].nextSibling.strip()
            
            if experience == ': Rookie':
                first_year = 2013
            else:
                number = re.search("\d", experience)
                first_year = 2014 - int(experience[number.start()])
            
            letter = re.search("[a-zA-Z]+",born)
            if letter == None:
                hometown = ''
                state = ''
            else:
                birthplace = born[letter.start():]
                splits = birthplace.split(',')
                if len(splits) == 2:
                    hometown = birthplace.split(',')[0].strip()
                    state = birthplace.split(',')[1].strip()
                else:
                    hometown = ''
                    state = ''
            
            player_info = (name,first_year,birthplace,hometown,state,college)
            player_bios.append(player_info)
        
        else:
            missing.append((p[0],p[1])) 
            print('missing!!')

write_to_csv("current_player_bios.csv",player_bios)



historic_player_bios = []

players = read_table("to_do.csv",True)
## Get historic player info
for p in players:
    ## historic players
    if p[2] != '1000':
        
        name = ''
        first_year = ''
        birthplace = ''
        hometown = ''
        state = ''
        college = ''
        
        print(p[0] + " --- " + p[1])
        url = "http://www.nfl.com" + p[1]
        soup = BeautifulSoup(urllib2.urlopen(url).read())
        
        info = soup.find("div", { "class" : "player-info" })
        para = info.findAll('p')
        
        name = p[0]
        
        strongs = info.findAll('strong')
        if len(strongs) == 6:
            
            born = strongs[3].nextSibling.strip()
            college = strongs[4].nextSibling.strip()[1:].strip()
            
            first_year = p[2]
            
            letter = re.search("[a-zA-Z]+",born)
            if letter != None:
                birthplace = born[letter.start():]
                splits = birthplace.split(',')
                if len(splits) == 2:
                    hometown = birthplace.split(',')[0].strip()
                    state = birthplace.split(',')[1].strip()
            
            player_info = (name,first_year,birthplace,hometown,state,college)
            historic_player_bios.append(player_info)
            
        else:
            missing.append((p[0],p[1])) 
            print('missing!!')

write_to_csv("historic_nfl_bios.csv",historic_player_bios)

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