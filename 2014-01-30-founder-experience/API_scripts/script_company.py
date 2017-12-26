import csv
import urllib2
import json
import sqlite3
import datetime

## Create db - only necessary once
# create_db()

## Retrieves list of all companies
## Total retrieved: 195699
## Errors: 12
# Companies = get_all_companies()
companies = errors
errors = []
counter = 0

## Loop through companies
for c in companies:
    print(str(counter) + " - " + c)
    url = "http://api.crunchbase.com/v/1/company/" + c + ".js?api_key=**REMOVED**"
    req = urllib2.Request(url)
    
    ## Check for URL error
    try:
        j = urllib2.urlopen(req)
        
        ## Check for JSON exceptions
        try:            
            ## Look up company info
            js = json.load(j,strict=False)
            ci = get_company_info(js)
            rl = get_relationships(js)
            cm = get_competitors(js)
            fr = get_funding_rounds(js)
            iv = get_investments(js)
            aq = get_acquisition(js)
            
            ## Write to DB
            conn = sqlite3.connect('crunchbase.db')
            cursor = conn.cursor()
            
            cursor.execute('INSERT INTO dimension_companies VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', ci)
            
            for r in rl:
                cursor.execute('INSERT INTO dimension_relationships VALUES (?,?,?,?,?,?,?,?,?,?)', r)
            
            for c in cm:
                cursor.execute('INSERT INTO dimension_competitors VALUES (?,?,?,?,?)', c)
            
            for f in fr:
                cursor.execute('INSERT INTO dimension_funding_rounds VALUES (?,?,?,?,?,?,?,?,?,?,?,?)', f)
                
            for i in iv:
                cursor.execute('INSERT INTO dimension_investments VALUES (?,?,?,?,?,?,?,?,?,?,?)', i)
            
            if aq is None:
                dummy = None
            else:
                cursor.execute('INSERT INTO dimension_acquisitions VALUES (?,?,?,?,?,?,?,?,?,?,?,?)', aq)
            
            conn.commit()
            conn.close()
            
        except Exception as Err:
            print("Exception")
            print(Err)
            errors.append(c)
            
    except urllib2.HTTPError as e:
        print("HTTP Error")
        print(c)
        errors.append(c)
    
    counter += 1
