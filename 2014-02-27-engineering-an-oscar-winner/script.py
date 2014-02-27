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

key = [ROVI API KEY]
secret = [ROVI API SECRET]

## Make API signature
def make_sig(key,secret):
    ts = time.time()
    
    combine = key + secret + str(int(round(ts)))
    
    m = hashlib.md5()
    m.update(combine)
    sig = m.hexdigest()
    
    return sig

def rovi_video(k,s,req_type,video_id,id_type,print_url):
    sig = make_sig(k,s)
    
    url = 'http://api.rovicorp.com/data/v1.1/video/' + req_type + '?apikey=' + \
            key + '&sig=' + sig + '&' + id_type + '=' + video_id + '&titletype=1'
    
    if print_url == True:
        print(url)
    
    req = urllib2.Request(url)
    j = urllib2.urlopen(req)
    js = json.load(j)
    
    return js

def rovi_search(k,s,terms,include,print_url):
    sig = make_sig(k,s)
    
    url = 'http://api.rovicorp.com/search/v2.1/video/search?apikey=' + \
            key + '&sig=' + sig + '&query=' + terms + '&entitytype=movie&include=' + \
            include + '&format=json&size=1'
    
    if print_url == True:
        print(url)
    
    req = urllib2.Request(url)
    j = urllib2.urlopen(req)
    js = json.load(j)
    
    return js

## For searching for things that have no regular results
def amg_search(k,s,terms,include,print_url):
    sig = make_sig(k,s)
    
    url = 'http://api.rovicorp.com/search/v2.1/amgvideo/search?apikey=' + \
            key + '&sig=' + sig + '&query=' + terms + '&entitytype=movie&include=' + \
            include + '&format=json&size=1'
    
    if print_url == True:
        print(url)
    
    req = urllib2.Request(url)
    j = urllib2.urlopen(req)
    js = json.load(j)
    
    return js

## Functions for reading and writing CSVs
def write_to_csv(csv_name,array):
    columns = len(array[0])
    rows = len(array)
    
    with open(csv_name, "wb") as test_file:
        file_writer = csv.writer(test_file)
        for i in range(rows):
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

def strip_special(array,columns_with_string):
    new_table = []
    for i in array:
        new_row =[]
        for j in range(len(i)):
            if j in columns_with_string:
                if i[j] != None:
                    x = i[j].encode('utf-8').strip()
            else:
                x = i[j]
            new_row.append(x)
            
        new_table.append(new_row)
    
    return new_table

### Get full list of all oscar nominated films

soup = BeautifulSoup(open("./full_list.html"))
links = soup.findAll('a')

films = []

for l in links:
    target = l['href']
    id_location = target.find('FilmID=')
    
    if id_location != -1:
        
        name = l.contents[0]
        film_id = target[id_location + 7:]
        
        entry = (name,film_id)
        films.append(entry)

clean_films = strip_special(films,[0])
write_to_csv("full_list.csv",clean_films)


### Get full list of awards for all oscar films

# full_list = read_table("full_list.csv",True)
full_list = read_table("l_errors.csv",True)
errors = []

movie_list = []
cast_list = []
crew_list = []
award_list = []
keyword_list = []
characteristic_list = []
mood_list = []
related_list = []
similar_list = []
review_list = []
synopsis_list = []
theme_list = []
tone_list = []

pattern = re.compile('[\W_]+')

full_list = errors
errors = []

for f in full_list:
    film_name = f
    # film_name = f[0]
    print(film_name)
    
    z = pattern.sub(' ',film_name)
    clean_name = z.replace(" ","+")
    
    try: 
        js = rovi_search(key,secret,clean_name,'all',True)
        
        result = js['searchResponse']['results'][0]['video']
        
        ## Movie info
        info = get_info(result)
        movie_list.append(info)
        
        ## Cast
        cast = get_cast(result)
        if cast != None or len(cast) != 0:
            for x in cast:
                cast_list.append(x)
        
        ## Crew
        crew = get_crew(result)
        if crew != None or len(crew) != 0:
            for x in crew:
                crew_list.append(x)
        
        ## Awards
        awards = get_awards(result)
        if awards != None or len(awards) != 0:
            for x in awards:
                award_list.append(x)
        
        ## Keywords
        keywords = get_keywords(result)
        if keywords != None or len(keywords) != 0:
            for x in keywords:
                keyword_list.append(x)
        
        ## Characteristics
        characteristics = get_characteristics(result)
        if characteristics != None or len(characteristics) != 0:
            for x in characteristics:
                characteristic_list.append(x)
        
        ## Moods
        moods = get_moods(result)
        if moods != None or len(moods) != 0:
            for x in moods:
                mood_list.append(x)
        
        ## Related
        related = get_related_to(result)
        if related != None or len(related) != 0:
            for x in related:
                related_list.append(x)
        
        ## Similar
        similar = get_similar_to(result)
        if similar != None or len(similar) != 0:
            for x in similar:
                similar_list.append(x)
        
        ## Review
        review = get_review(result)
        review_list.append(review)
        
        ## Synopsis
        synopsis = get_synopsis(result)
        synopsis_list.append(synopsis)
        
        ## Themes
        themes = get_themes(result)
        if themes != None or len(themes) != 0:
            for x in themes:
                theme_list.append(x)
        
        ## Tones
        tones = get_tones(result)
        if tones != None or len(tones) != 0:
            for x in tones:
                tone_list.append(x)
    
    except Exception as e:
        print(str(e))
        errors.append(film_name)


## Writing to CSV

clean_movie_list = strip_special(movie_list,[1])
clean_cast_list = strip_special(cast_list,[1,2,4])
clean_crew_list = strip_special(crew_list,[1,2,4])
clean_award_list = strip_special(award_list,[1,3,4,6,10])
clean_keyword_list = strip_special(keyword_list,[1])
clean_characteristic_list = strip_special(characteristic_list,[1,2])
clean_mood_list = strip_special(mood_list,[1])
clean_related_list = strip_special(related_list,[1,2,6])
clean_similar_list = strip_special(similar_list,[1,2,6])
# clean_review_list = strip_special(review_list,[0,1,2,3])
clean_synopsis_list = strip_special(synopsis_list,[1,2])
clean_theme_list = strip_special(theme_list,[1])
clean_tone_list = strip_special(tone_list,[1])

write_to_csv("l3_movie.csv",clean_movie_list)
write_to_csv("l3_cast.csv",clean_cast_list)
write_to_csv("l3_crew.csv",clean_crew_list)
write_to_csv("l3_award.csv",clean_award_list)
write_to_csv("l3_keyword.csv",clean_keyword_list)
write_to_csv("l3_characteristic.csv",clean_characteristic_list)
write_to_csv("l3_mood.csv",clean_mood_list)
write_to_csv("l3_related.csv",clean_related_list)
write_to_csv("l3_similar.csv",clean_similar_list)
# write_to_csv("l_review.csv",clean_review_list)
write_to_csv("l3_synopsis.csv",clean_synopsis_list)
write_to_csv("l3_theme.csv",clean_theme_list)
write_to_csv("l3_tone.csv",clean_tone_list)

error_list = []
for e in errors:
    x = (e,0)
    error_list.append(x)

clean_error_list = strip_special(error_list,[0])
write_to_csv("errors.csv",clean_error_list)
