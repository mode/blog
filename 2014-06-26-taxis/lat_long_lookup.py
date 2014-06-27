import requests
import urllib2
import csv
import json

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

def write_to_csv(csv_name,array):
    columns = len(array[0])
    rows = len(array)
    
    with open(csv_name, "wb") as test_file:
        file_writer = csv.writer(test_file)
        for i in range(rows):
            file_writer.writerow([array[i][j] for j in range(columns)])

api = "http://data.fcc.gov/api/block/find?format=json&latitude=%s&longitude=%s&showall=false&censusYear=2010"

output = []
errors = []

lls = read_table([LIST OF LAT LONG COORDINATES],True)
counter = 0

for ll in lls:
    
    print counter
    counter += 1
    
    try:
       url = api % (ll[0], ll[1])
       
       print url
       
       req = urllib2.Request(url)
       j = urllib2.urlopen(req)
       js = json.load(j)
       
       county = js['County']['name']
       county_code = js['County']['FIPS']
       block = js['Block']['FIPS']
       tract_code = block[5:11]
       tract_code_numeric = int(block)/100.
       
       row = [ll[0],ll[1],ll[2],county,county_code,block,tract_code,tract_code_numeric]
       output.append(row)
       
    except Exception as e:
       print e
       print url
       errors.append(ll)


clean_tracts = []

for t in output:
    row = [t[0],t[1],t[2],t[3],t[4],t[5],t[6],int(t[5][5:11])/100.]
    clean_tracts.append(row)

write_to_csv("tract_lookup_full.csv",clean_tracts)

    

    
