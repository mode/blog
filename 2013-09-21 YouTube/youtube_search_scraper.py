###################
# File: youtube_search_scraper.py
# Description: Scrapes YouTube for most viewed videos for each search term. Can
#       be adjusted to include different numbers of results for each term.
# Author: Benn Stancil (@bennstancil, benn@modeanalytics.com)
###################


#################
##  Libraries  ##
#################

from bs4 import BeautifulSoup
from bs4 import NavigableString
from urllib2 import Request, urlopen, URLError
import re
import urllib2
import random
import csv
import json
import unicodedata
import datetime


################
##   Inputs   ##
################

terms = ['psy','justin bieber','jennifer lopez','eminem','lmfao','shakira','lady gaga','michel telo',
         'carly rae jepsen','adele','gotye','one direction','pitbull','macklemore','bruno mars','katy perry',
         'miley cyrus','nicki minaj','don omar','rihanna']
pages = 2


#################
##   Script    ##
#################

# Column Headers #
metrics = []
metrics.append(["extracted","term","title","views","length","upload","score","ratings","likes","dislikes"])

# Search Script #
for name in terms:
    
    # splits terms and creates search link #
    split_name = name.split( )
    search_link = "http://www.youtube.com/results?search_sort=video_view_count&search_query"
    
    for i in range(len(split_name)):
        if i == 0:
            search_link = search_link + "=" + split_name[i]
        else:
            search_link = search_link + "+" + split_name[i]
    
    # adds pagination #
    for i in range(pages):
        paged_link = search_link + "&page=" + str(i+6)
        
        print(paged_link)
        
        # finds videos from search results #
        search_result = BeautifulSoup(urllib2.urlopen(paged_link).read())
        links = search_result.find_all("a",class_="contains-addto")
        
        targets = []
        
        # creates target JSON links #
        for i in links:
            targets += ["https://gdata.youtube.com/feeds/api/videos/"+ str(i['href'])[9:] + "?v=2&alt=json"]
            current_day = datetime.date.today().strftime("%Y-%m-%d")
            
        # parses fields in JSON #
        for t in targets:    
            hdr = {'User-Agent': 'Mozilla/5.0'}
            req = urllib2.Request(t,headers=hdr)
            
            # HTTP request error handling
            try:
                response = urlopen(req)
            
            except URLError, e:
                
                if hasattr(e, 'reason'):
                    print 'We failed to reach a server.'
                    print 'Reason: ', e.reason
                    print(t)
                    
                elif hasattr(e, 'code'):
                    print 'The server couldn\'t fulfill the request.'
                    print 'Error code: ', e.code
                    print(t)
                    
            else:
                                
                j = urllib2.urlopen(req)
                js = json.load(j)
                
                title = js['entry']['title']['$t']
                ascii_title = unicodedata.normalize('NFKD', title).encode('ascii','ignore')
                views = js['entry']['yt$statistics']['viewCount']
                length = js['entry']['media$group']['yt$duration']['seconds']
                upload = js['entry']['published']['$t']
                
                # exlcudes rating results for videos that have ratings disabled #
                if js['entry']['yt$accessControl'][3]['permission'] != 'denied':    
                    score = js['entry']['gd$rating']['average']
                    ratings = js['entry']['gd$rating']['numRaters']
                    likes = js['entry']['yt$rating']['numLikes']
                    dislikes = js['entry']['yt$rating']['numDislikes']
                else:
                    score = ''
                    ratings = ''
                    likes = ''
                    dislikes = ''
                
                summary = [current_day,name,ascii_title,views,length,upload,score,ratings,likes,dislikes]
                
                # appends results to metrics table #
                metrics.append(summary)
                print(t)

# Writing To CSV #
columns = len(metrics[0])
rows = len(metrics)

with open('top_youtube_artists.csv', 'wb') as test_file:
    file_writer = csv.writer(test_file)
    for i in range(rows):
        file_writer.writerow([metrics[i][j] for j in range(columns)])
        