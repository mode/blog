import csv
import urllib2
import json
import sqlite3
import datetime
from bs4 import BeautifulSoup
from bs4 import NavigableString

team_table = []

## Loops through team table, gets info for teams and roster links
url = "http://espn.go.com/college-football/teams"
soup = BeautifulSoup(urllib2.urlopen(url).read())

for division in soup.findAll("div", { "class":"span-2" })[0:2]:
    div_name = division.find("h4").contents[0]
    
    for conf in division.findAll("div", {"class":"mod-teams-list-medium"}):
        conf_name = conf.find("h4").contents[0]
        
        for teams in conf.findAll("li"):
            team_link = teams.find("h5")
            team_name = team_link.find("a").contents[0]
            
            links = teams.findAll("a")
            
            for l in links:
                if l.contents[0] == "Roster":
                    roster_link = "http://espn.go.com" + l['href']
                    
                    team_info = (div_name,conf_name,team_name,roster_link)
                    team_table.append(team_info)

write_to_csv("teams.csv",team_table)

## Gets players for all schools using player table
player_table = []

for t in team_table:
    
    team_url = t[3]
    print(t[2])
    team_soup = BeautifulSoup(urllib2.urlopen(team_url).read())
    
    school_name = team_soup.find("h2").contents[0].contents[0].contents[0]
    
    roster = team_soup.find("table", {"class":"tablehead"})
    rows = roster.findAll("tr")
    
    for player in rows:
        if player["class"][0] == "oddrow" or player["class"][0] == "evenrow":
            player_fields = player.findAll("td")
            
            name = player_fields[1].contents[0].contents[0]
            pos = player_fields[2].contents[0]
            
            ht = player_fields[3].contents[0]
            height = get_height(ht)
            
            weight = player_fields[4].contents[0]
            year = player_fields[5].contents[0]
            
            hometown = player_fields[6].contents[0]
            state = get_state(hometown).strip()
            
            player_info = (school_name,t[2],name,pos,height,weight,year,hometown,state)
            
            player_table.append(player_info)

pt = strip_special(player_table,[0,1,2])
write_to_csv("players_raw.csv",pt)

## Loops through towns and gets county

## Find distinct hometowns
hometowns = []

for r in players_table:
    town = r[7]
    
    hometowns.append(town)

distinct_towns = list(set(hometowns))


## Looks up each town
counties = []
errors = []

town_count = len(distinct_towns)

for i in range(town_count):
    
    h = distinct_towns[i]
    
    print(str(n) + " --- " + h)
    possible_counties = []
    
    clean = h.replace(", ","+")
    clean = clean.replace(" ","+")
    
    url = "http://maps.googleapis.com/maps/api/geocode/json?address=" + clean + "&sensor=false"
    try:
        req = urllib2.Request(url)
        j = urllib2.urlopen(req)
        js = json.load(j)
        
        results = js['results']
        
        for r in results:
            comp = r['address_components']
            for c in comp:
                if 'administrative_area_level_2' in c['types']:
                    county_long = c['long_name']
                    county_short = c['short_name']
                    
                    county = (h,county_long,county_short)
                    possible_counties.append(county)
        
        counties.append(possible_counties[0])
        
    except Exception as Err:
        print("Exception")
        print(Err)
        errors.append(h)
        
    time.sleep(5)

cc = strip_special(counties,(0,1,2))
write_to_csv("hometowns_complete.csv",cc)


## Read and write results to csv
def write_to_csv(csv_name,array):
    columns = len(array[0])
    rows = len(array)
    
    with open(csv_name, "wb") as test_file:
        file_writer = csv.writer(test_file)
        for i in range(rows):
            file_writer.writerow([array[i][j] for j in range(columns)])

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

def get_height(height):
    split = height.split('-')
    feet = int(split[0])
    inch = int(split[1])
    
    h = 12 * feet + inch
    return(h)

def get_state(hometown):
    split = hometown.split(',')
    
    if len(split) == 1:
        state = hometown
    
    else:
        state = split[1]
    
    return(state)
    
