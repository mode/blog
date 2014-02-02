import csv
import urllib2
import json
import datetime
from bs4 import BeautifulSoup
from bs4 import NavigableString
from bs4 import Tag

## Set season and week lists
seasons = [2009,2010,2011,2012,2013]
weeks = []
games = []

penalties = []

## Generate lists
for w in range(20):
    weeks.append(w+1)
    w += 1

weeks = [21]
## Loop through seasons for game links
for s in seasons:
    ## Loop through weeks for games links
    for w in weeks:
        all_week_links = []
        url = "http://www.nflpenalties.com/week.php?week=" + str(w) + "&year=" + str(s)
        print(url)
        soup = BeautifulSoup(urllib2.urlopen(url).read())
        
        tables = soup.findAll('table')
        table = tables[1]
        a = table.findAll('a')
        
        ## Get all game links
        for l in a:
            ref = l['href']
            if ref.find('/game/') != -1:
                all_week_links.append(ref)
        
        ## Clean duplicates
        week_links = list(set(all_week_links))
        
        ## Parse link info, add week info, and append to table
        for l in week_links:
            link = l[6:]
            away = link.split('-at-')[0]
            home_date = link.split('-at-')[1]
            home = home_date[:len(home_date)-11]
            date = home_date[-10:]
            
            game_info = (link,s,w,away,home,date)
            games.append(game_info)

## Write to CSV
write_to_csv("game_table2.csv",games)

## Loop through games from list
errors = []

game_list = read_table("game_todo.csv",True)
for g in game_list:
    
    print(g[1] + " - " + g[2] + " --- " + g[0])
    
    url = "http://www.nflpenalties.com/game/" + g[0]
    soup = BeautifulSoup(urllib2.urlopen(url).read())
    
    for tr in soup.findAll('tr', { "class":"penalty" }):
        
        p = []
        
        for td in tr.findAll('td'):
            p.append(td.contents[0])
        
        quarter = int(p[1][1])
        minute = int(p[1][5:7])
        second = int(p[1][8:10])
        
        time = (900 * (quarter - 1)) + (60 * (15 - minute)) - second
        
        if p[4] == '50':
            location = 50
        elif p[0] == p[4][0:3]:
            location = 100 - int(p[4][-2:])
        else:
            location = int(p[4][-2:])
        
        down = int(p[2])
        distance = int(p[3])
        
        try:
        
            t = p[5].lower()
            
            if t.find('penalty on prior scrimmage play') == -1:
                start = t.find('penalty on')
                short = p[5][start:]
                parts = short.split(',')
                
                rm = parts[0].split('-')
                offender = rm[0][-3:].strip()
                
                if offender == p[0]:
                    offense = True
                else:
                    offense = False
                
                if t.find('declined') != -1:
                    note = 'declined'
                    yards = ''
                    call = parts[1].strip()
                elif t.find('offset') != -1:
                    note = 'offset'
                    yards = ''
                    call = parts[1].strip()
                elif t.find('enforced on kickoff') != -1:
                    note = 'on_kickoff'
                    yards = ''
                    call = 'Unsportsmanlike Conduct'
                else:
                    call = parts[1].strip()
                    note = ''
                    yards = int(parts[2].strip()[:2])
                
                penalty = (g[0],time,location,down,distance,offense,call,yards,note)
                
                penalties.append(penalty)
        
        except Exception as e:
            print(e)
            errors.append(p)

write_to_csv("add_pen.csv",penalties)