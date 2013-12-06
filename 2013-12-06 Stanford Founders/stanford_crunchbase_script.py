import csv
import urllib2
import json

###########################################################################
## This searches crunchbase for "Stanford" and only returns people
###########################################################################

search = "http://api.crunchbase.com/v/1/search.js?query=stanford&entity=person&api_key=XXXX" ##Replace XXXX with CrunchBase API key

people_info = []

for i in range(300):
    page = i
    url = search + str(page)
    print(i)
    
    req = urllib2.Request(url)
    j = urllib2.urlopen(req)
    js = json.load(j)
    
    people = len(js['results'])
    for p in range(people):
        permalink = js['results'][p]['permalink']
        
        person_info = (permalink,'stanford')
        print(person_info)
        
        people_info.append(person_info)
        
write_to_csv('stanford_people.csv',people_info)

###########################################################################
## This takes the people from above, and looks each up. It returns a 
## dimension_relationships table and a dimension_degrees table
###########################################################################

dim_degrees = []
dim_relationships = []
errors = []
count = 0
people = read_table('stanford_people.csv',True)

for p in people:
    permalink = p[0]
    url = "http://api.crunchbase.com/v/1/person/" + permalink + ".js?api_key=XXXX" ##Replace XXXX with CrunchBase API key
    
    print(p[0])
    print(count)
    count += 1
    
    try:
        req = urllib2.Request(url)
        j = urllib2.urlopen(req)
        js = json.load(j)
        
        first_name = js['first_name']
        last_name = js['last_name']
        
        degrees = js['degrees']
        relationships = js['relationships']
        
        for d in degrees:
            degree_type = d['degree_type']
            subject = d['subject'] 
            institution = d['institution'] 
            graduated_year = d['graduated_year']
            deg = (permalink,first_name,last_name,degree_type,subject,institution,graduated_year)
            
            dim_degrees.append(deg)
        
        for r in relationships:
            is_past = r['is_past']
            title = r['title']
            firm_name = r['firm']['name']
            firm_permalink = r['firm']['permalink']
            
            rel = (permalink,first_name,last_name,is_past,title,firm_name,firm_permalink)
            
            dim_relationships.append(rel)
    
    except urllib2.HTTPError as e:
        
        print('is error!')
        errors.append((permalink,count))

write_to_csv('stanford_relationships.csv',dim_relationships)
write_to_csv('stanford_degrees.csv',dim_degrees)
write_to_csv('errors.csv',errors)


###########################################################################
## Some results retun special characters, this function strips those out
###########################################################################

def strip_special(array,columns_with_string):
    new_table = []
    for i in array:
        new_row =[]
        for j in range(len(i)):
            if j in columns_with_string:
                x = i[j].encode('utf-8').strip()
            else:
                x = i[j]
            new_row.append(x)
            
        new_table.append(new_row)
    
    return new_table


###########################################################################
## Functions to write array to CSV, and read from CSV
###########################################################################

def write_to_csv(csv_name,array):
    columns = len(array[0])
    rows = len(array)
    
    with open(csv_name, "wb") as test_file:
        file_writer = csv.writer(test_file)
        for i in range(rows):
            print(i)
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
