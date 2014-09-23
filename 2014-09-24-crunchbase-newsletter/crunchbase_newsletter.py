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

## Create date array
date_array = []
start_date = datetime.datetime(2014,3,17,0,0,0,0)
end_date = datetime.datetime(2014,9,22,0,0,0,0)

delta = datetime.timedelta(days=1)

## Loop over dates
while start_date <= end_date:
    date = start_date.strftime("%Y%m%d")
    date_array.append(str(date))
    start_date += delta

## Create table
full_table = []
full_head = ["company","amount_raised","denomination","amount","round_type","email_level","level_order","date"]
full_table.append(full_head)

full_investors = []
investor_head = ["investor","company","date"]
full_investors.append(investor_head)

for date in date_array:
    
    ts = date[0:4] + "-" + date[4:6] + "-" + date[6:8] + "T00:00:00Z"
    url = "http://static.crunchbase.com/daily/content_%s_web.html" % date
    
    try:
        
        r = requests.get(url)
        soup = BeautifulSoup(r.text)
        
        daily_date = get_date(soup)
        table_rounds = get_table_rounds(soup)
        top_mentions = get_top_mentions(soup)
        
        rounds = table_rounds[0]
        investors = table_rounds[1]
        
        for t in top_mentions:
            t = t + [ts]
            full_table.append(t)
        
        for r in rounds:
            r = r + [ts]
            full_table.append(r)
        
        for i in investors:
            for j in i:
                j = j + [ts]
                full_investors.append(j)
        
        print url
    
    except:
        print "ERROR --: " + url

clean_round = []
clean_investor = []

for f in full_table:
    c = filter(lambda x: x in string.printable, f[0])
    e = [c,f[1],f[2],f[3],f[4],f[5],f[6],f[7]]
    clean_round.append(e)

for i in full_investors:
    c = filter(lambda x: x in string.printable, i[0])
    e = [c,i[1],i[2]]
    clean_investor.append(e)

write_to_csv("crunchbase_newsletter_rounds.csv",clean_round)
write_to_csv("crunchbase_newsletter_investors.csv",clean_investor)

# python mode-python-importers/import.py --csv="~/Desktop/crunchbase_newsletter_rounds.csv" --name=crunchbase_newsletters_rounds --desc="Funding rounds in Crunchbase newsletters. Source: Crunchbase" --replace
# python mode-python-importers/import.py --csv="~/Desktop/crunchbase_newsletter_investors.csv" --name=crunchbase_newsletters_investors --desc="Investors from Crunchbase newsletters. Source: Crunchbase" --replace

def get_top_mentions(soup):
    top = []
    
    container = soup.find("table", {"id":"templateContainer"})
    top_table = container.find("table",{"class":"sharing"})
    paragraph_table = top_table.find("table")
    paragraphs = paragraph_table.findAll("p")
    
    position = 1
    
    for p in paragraphs:
        a = p.find("a")
        
        if a != None:
            company = a.string.strip()
            entry = [company,"","","","","top_stories",position]
            top.append(entry)
            
            position += 1
    
    return top

def get_date(soup):
    container = soup.find("table", {"id":"templateContainer"})
    top_table = container.find("table",{"class":"sharing"})
    top_row = top_table.find("tr")
    date = top_row.find("td").string.strip()
    
    return date

def get_table_rounds(soup):
    rounds = []
    investor_table = []
    
    container = soup.find("table", {"id":"templateContainer"})
    outer_funding_table = container.find("table",{"class":"fundingRounds"})
    funding_table = outer_funding_table.find("table",{"class":"fundingRounds"})
    
    rows = funding_table.findAll("tr",recursive=False)
    row_count = len(rows)
    
    ## Getting top rounds
    for idx,r in enumerate(rows[:row_count-2]):
        inner_table = r.find("table")
        data = get_l2_details(inner_table)
        
        entry = data[0]
        entry = entry + [idx+1]
        rounds.append(entry)
        
        investors = data[1]
        investor_table.append(investors)
    
    starting_position = len(rows[:row_count-2]) + 1
    
    l3_row = rows[row_count-1]
    l3_table = l3_row.find("table")
    
    l3_result = get_l3_details(l3_table,starting_position)
    rounds = rounds + l3_result
    
    return (rounds,investor_table)

def get_l2_details(table):
    rows = table.findAll("tr")
    
    company = rows[0].find("a").string.strip()
    
    funding_data = rows[2].find("table").find("td")
    round_size = funding_data.contents[0].string.strip()
    
    investors = get_investors(rows[len(rows)-1],company)
        
    funding_amount = clean_amount(round_size)
    amount = funding_amount[0]
    currency = funding_amount[1]
    
    funding_type = funding_data.find("span").string.strip()
    funding_type = funding_type[funding_type.find("/")+1:].strip()
    
    entry = [company,amount,currency,round_size,funding_type,"major_list"]
    
    return (entry,investors)

def get_investors(row,company):
    investor_list = []
    
    links = row.findAll("a")
    
    for l in links:
        address = l['href']
        
        rev = address[::-1]
        pos = rev.find("/")
        rev_name = rev[:pos]
        name = rev_name[::-1]
        
        investor_list.append([name,company])
    
    return investor_list

def get_l3_details(table,starting_position):
    l3_results = []
    
    rows = table.findAll("tr")
    position = starting_position
    
    for r in rows:
        cell = r.find("td")
        
        if cell.string != "Other Fundings":
            company = cell.find("a").string.strip()
            
            round_span = cell.find("span")
            
            funding_amount = clean_amount(round_span.string.strip())
            amount = funding_amount[0]
            currency = funding_amount[1]
            
            funding_type = round_span.next_sibling
            funding_type = funding_type[funding_type.find("/")+1:funding_type.find(")")].strip()
            
            entry = [company,amount,currency,round_span.string.strip(),funding_type,"minor_list",position]
            l3_results.append(entry)
            
            position +=1
    
    return l3_results


def clean_amount(string):
    if "unknown" in string:
        amount = ""
        currency = ""
    
    else:
        dollar = string.find("$")
        pound = string.find("GBP")
        euro = string.find("EUR")
        million = string.find("MM")
        thousand = string.find("K")
    
        if million != -1:
            amount = float(string[dollar+1:million]) * 1000000
        elif thousand != -1:
            amount = float(string[dollar+1:thousand]) * 1000
        else:
            amount = ""
        
        if dollar != -1:
            currency = "dollar"
        elif pound != -1:
            currency = "pound"
        elif euro != -1:
            currency = "euro"
        else: 
            currency = "other"
        
    return (amount,currency)

def write_to_csv(csv_name,array):
    columns = len(array[0])
    rows = len(array)
    
    with open(csv_name, "wb") as test_file:
        file_writer = csv.writer(test_file)
        for i in range(rows):
            file_writer.writerow([array[i][j] for j in range(columns)])