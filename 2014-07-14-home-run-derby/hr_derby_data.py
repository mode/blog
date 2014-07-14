import requests
import urllib2
import time
import csv
import json
import hashlib
import re
import string
import json
import datetime
from bs4 import BeautifulSoup
from bs4 import NavigableString
from bs4 import Tag

h2014 = BeautifulSoup(open("./table_2014.html"))
h2013 = BeautifulSoup(open("./table_2013.html"))
h2012 = BeautifulSoup(open("./table_2012.html"))
h2011 = BeautifulSoup(open("./table_2011.html"))
h2010 = BeautifulSoup(open("./table_2010.html"))
h2009 = BeautifulSoup(open("./table_2009.html"))
h2008 = BeautifulSoup(open("./table_2008.html"))
h2007 = BeautifulSoup(open("./table_2007.html"))
h2006 = BeautifulSoup(open("./table_2006.html"))

lists = [h2014,h2013,h2012,h2011,h2010,h2009,h2008,h2007,h2006]

all_hrs = []
headers = ('date','hitter','hitter_team','pitcher','pitcher_team','inning','ballpark','hr_type',
            'distance','speed','elev_angle','horiz_angle','apex','parks')
all_hrs.append(headers)

for n in range(len(lists)):
    soup = lists[n]
    table = soup.find('table')
    hrs = table.findAll('tr')
    
    for hr in hrs[1:]:
        cells = hr.findAll('td')
        
        date = cells[0].get_text().strip()
        hitter = cells[3].get_text().strip()
        hitter_team = cells[4].get_text().strip()
        pitcher = cells[5].get_text().strip()
        pitcher_team = cells[6].get_text().strip()
        inning = int(cells[7].get_text().strip())
        ballpark = cells[8].get_text().strip()
        hr_type = cells[9].get_text().strip()
        dist = float(cells[10].get_text().strip())
        speed = float(cells[11].get_text().strip())
        elev_angle = float(cells[12].get_text().strip())
        horiz_angle = float(cells[13].get_text().strip())
        apex = float(cells[14].get_text().strip())
        parks = int(cells[15].get_text().strip())
        
        entry = (date,hitter,hitter_team,pitcher,pitcher_team,inning,ballpark,hr_type,
            dist,speed,elev_angle,horiz_angle,apex,parks)
        
        all_hrs.append(entry)

write_to_csv('home_runs.csv',all_hrs)


# Function for writing output to csv
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

# Strips special characters in hometowns
def strip_special(array,columns_with_string):
    new_table = []
    for i in array:
        new_row =[]
        for j in range(len(i)):
            if j in columns_with_string:
                if i[j] != None:
                    x = i[j].encode('utf-8').strip()
                else:
                    x = i[j]
            else:
                x = i[j]
            new_row.append(x)
            
        new_table.append(new_row)
    
    return new_table
