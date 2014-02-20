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

alp = BeautifulSoup(open("./alpine-skiing.html"))
bai = BeautifulSoup(open("./biathlon.html"))
bbs = BeautifulSoup(open("./bobsled.html"))
ccy = BeautifulSoup(open("./cross-country.html"))
crl = BeautifulSoup(open("./curling.html"))
fgs = BeautifulSoup(open("./figure-skating.html"))
fss = BeautifulSoup(open("./freestyle-skiing.html"))
hky = BeautifulSoup(open("./hockey.html"))
lge = BeautifulSoup(open("./luge.html"))
ndc = BeautifulSoup(open("./nordic-combined.html"))
sht = BeautifulSoup(open("./short-track.html"))
skl = BeautifulSoup(open("./skeleton.html"))
skj = BeautifulSoup(open("./ski-jumping.html"))
swb = BeautifulSoup(open("./snowboarding.html"))
ssk = BeautifulSoup(open("./speed-skating.html"))

lists = [alp,bai,bbs,ccy,crl,fgs,fss,hky,lge,ndc,sht,skl,skj,swb,ssk]
key = ['alp','bai','bbs','ccy','crl','fgs','fss','hky','lge','ndc','sht','skl','skj','swb','ssk']

all_athletes = []

for n in range(len(lists)):
    soup = lists[n]
    links = soup.findAll('a')
    
    link_list = []
    for l in links:
        ref = l['href']
        
        if ref.find('/en/athlete') != -1:
            link_list.append(ref)
    
    uniques = list(set(link_list))
    
    for u in uniques:
        all_athletes.append((u,key[n]))

athlete_table = []
errors = []

for n in range(len(all_athletes)):
    
    a = all_athletes[n]
    sport = a[1]
    url = 'http://www.sochi2014.com' + a[0]
    
    print(str(n) + "  -  " + a[1] + "  -  " + url)
    
    try:
        
        r = requests.get(url)
        
        soup = BeautifulSoup(r.text)
        
        name_span = soup.find('h2', {"itemprop":"name"})
        name = name_span.contents[0].title()
        
        country_span = soup.find('a', {"itemprop":"affiliation"})
        country = country_span.contents[0]
        
        bios = soup.findAll("div", { "class":"table chars" })
        spans = bios[0].findAll("span")
        
        for s in spans:
            clean = ''.join(e for e in s.contents[0] if e.isalnum())
            clean = clean.lower()
            
            if clean == 'gender':
                gender = s.nextSibling.strip()
            elif clean == 'height':
                ht = s.nextSibling.strip()
                v = ht.find('m')
                height = ht[:v].strip()
            elif clean == 'weight':
                wt = s.nextSibling.strip()
                v = wt.find('kg')
                weight= wt[:v].strip()
            elif clean == 'age':
                age = s.nextSibling.strip()
        
        entry = (name,sport,gender,country,height,weight,age)
        athlete_table.append(entry)
        
    except Exception as e:
        print(e)
        print(url)
        entry = (a[0],a[1])
        errors.append(entry)
