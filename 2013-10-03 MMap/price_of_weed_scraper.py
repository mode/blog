###################
# File: price_of_weed_scraper.py
# Description: Scrapes www.priceofweed.com for all state transactions. Allows for 
#       adjustments to how far back you want to collect data.
# Author: Benn Stancil (@bennstancil, benn@modeanalytics.com)
###################


#################
##  Libraries  ##
#################

from bs4 import BeautifulSoup
from bs4 import NavigableString
from datetime import datetime
import re
import urllib2
import csv


################
##   Inputs   ##
################

date_until = datetime.strptime("2012-01-01",'%Y-%m-%d')

#################
##   Script    ##
#################

## Find all links for states
directory = "http://www.priceofweed.com/directory"
di = "http://www.priceofweed.com/prices/United-States.html"
soup = BeautifulSoup(urllib2.urlopen(di).read())
soup = BeautifulSoup(urllib2.urlopen(directory).read())
lists = soup.findAll("li")[0:52]

## Set data headers
data = []

## Loop over each state
for i in range(len(lists)):
    state_link = lists[i].find("a")["href"]
    state = lists[i].get_text()
    print(state)
    
    ## j is the page counter; x is a binary for when dates pass date_until input
    j = 0
    x = 0
    
    while x == 0:
        page_link = state_link + "?pg=" + str(j+1)
        print(page_link)
        state_soup = BeautifulSoup(urllib2.urlopen(page_link).read())
        rows = state_soup.findAll('table')[1].find_all("tr")
        
        ## Loop over each row in the table
        for row in rows:
            cells = row.find_all("td")
            loc = cells[0].get_text()
            p = cells[1].get_text()
            qt = cells[2].get_text()
            ql = cells[3].get_text()
            t = cells[4].get_text()
            
            ## Write rows to data table
            sub = [state,loc,p,qt,ql,t]
            data.append(sub)
            
            ## Find last date
            last_date = datetime.strptime(sub[5], '%B %d, %Y')
            print(last_date)
        
        ## Check if last date is after date_until, add to j for pagination
        if last_date < date_until:
            x = 1
        else:
            x = 0
            j += 1

# Writing To CSV #
columns = len(data[0])
rows = len(data)

with open('all_prices.csv', 'wb') as test_file:
    file_writer = csv.writer(test_file)
    for i in range(rows):
        file_writer.writerow([data[i][j] for j in range(columns)])