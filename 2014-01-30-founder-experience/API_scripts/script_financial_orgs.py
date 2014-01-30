import csv
import urllib2
import json
import sqlite3
import datetime

## Retrieves list of all companies
# financial_orgs = get_all_financial_orgs()
financial_orgs = errors
errors = []
counter = 0

## Loop through financial orgs
for f in financial_orgs:
    print(str(counter) + " - " + f)
    url = "http://api.crunchbase.com/v/1/financial-organization/" + f + ".js?api_key=***REMOVED***"
    req = urllib2.Request(url)
    
    ## Check for URL error
    try:
        j = urllib2.urlopen(req)
        
        ## Check for JSON exceptions
        try:            
            ## Look up company info
            js = json.load(j,strict=False)
            fi = get_financial_org_info(js)
            rl = get_relationships_fin_org(js)
            fu = get_funds(js)
            
            ## Write to DB
            conn = sqlite3.connect('crunchbase.db')
            cursor = conn.cursor()
            
            cursor.execute('INSERT INTO dimension_financial_orgs VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', fi)
            
            for r in rl:
                cursor.execute('INSERT INTO dimension_relationships VALUES (?,?,?,?,?,?,?,?,?,?)', r)            
            
            for f in fu:
                cursor.execute('INSERT INTO dimension_funds VALUES (?,?,?,?,?,?,?,?,?,?)', f)
            
            conn.commit()
            conn.close()
            
        except Exception as Err:
            print("Exception")
            print(Err)
            errors.append(f)
            
    except urllib2.HTTPError as e:
        print("HTTP Error")
        print(f)
        errors.append(f)
    
    counter += 1