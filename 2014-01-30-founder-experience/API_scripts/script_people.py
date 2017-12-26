import csv
import urllib2
import json
import sqlite3
import datetime

## Retrieves list of all companies
people = errors
errors = []
counter = 0

## Loop through people
for p in people:
    print(str(counter) + " - " + p)
    url = "http://api.crunchbase.com/v/1/person/" + p + ".js?api_key=**REMOVED**"
    req = urllib2.Request(url)
    
    ## Check for URL error
    try:
        j = urllib2.urlopen(req)
        
        ## Check for JSON exceptions
        try:            
            ## Look up company info
            js = json.load(j,strict=False)
            pl = get_people_info(js)
            dg = get_degrees(js)
            
            ## Write to DB
            conn = sqlite3.connect('crunchbase.db')
            cursor = conn.cursor()
            
            cursor.execute('INSERT INTO dimension_people VALUES (?,?,?,?,?,?,?,?,?,?)', pl)
            
            for d in dg:
                cursor.execute('INSERT INTO dimension_degrees VALUES (?,?,?,?,?,?,?,?,?,?)', d)
            
            conn.commit()
            conn.close()
            
        except Exception as Err:
            print("Exception")
            print(Err)
            errors.append(p)
            
    except urllib2.HTTPError as e:
        print("HTTP Error")
        print(p)
        errors.append(p)
    
    counter += 1
