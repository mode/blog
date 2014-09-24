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

main_url = "http://techcrunch.com/page/%i/"
table = []

for i in range(100):
    print i
    url = main_url % (i + 1)
    
    r = requests.get(url)
    soup = BeautifulSoup(r.text)
    titles = soup.findAll("h2", {"class":"post-title"})
    
    for t in titles:
        link = t.find("a")
        ref = link['href']
        start = len("http://techcrunch.com/")
        end = start + 10
        
        date = ref[start:end]
        
        entry = [ref,date]
        print entry
        table.append(entry)
        
write_to_csv("techcrunch_stories.csv",table)

def write_to_csv(csv_name,array):
    columns = len(array[0])
    rows = len(array)
    
    with open(csv_name, "wb") as test_file:
        file_writer = csv.writer(test_file)
        for i in range(rows):
            file_writer.writerow([array[i][j] for j in range(columns)])
        
        