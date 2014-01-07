import csv
import urllib2
import json
import sqlite3
import datetime
from bs4 import BeautifulSoup
from bs4 import NavigableString

## Get urls for date range
site = "http://www.bobborst.com/popculture/top-100-songs-of-the-year/?year="
years = [i + 1956 for i in xrange(58)]

entries = []
errors = []

## Splits artists with feat., ",", or, or and.
def split_artist(artist):
    
    if artist != artist.split(" feat. ")[0]:
        a = artist.split(" feat. ")
    
    elif artist != artist.split(", ")[0]:
        a = artist.split(", ")
    
    elif artist != artist.split(" or ")[0]:
        a = artist.split(" or ")
    
    else:
        a = artist.split(" and ")
    
    return a

## Loops over artists until fully split
def split_loop(artist_array):
    
    new_array = artist_array
    len_old = len(artist_array)
    len_new = 0
    
    while len_old != len_new:
        
        artist_array = new_array
        new_array = []
        
        for a in artist_array:
            new_artists = split_artist(a)
            for n in new_artists:
                new_array.append(n)
        
        len_new = len(new_array)
        len_old = len(artist_array)
    
    return new_array

## Read and write results to csv
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

## Script
for y in years:
    url = site + str(y)
    
    soup = BeautifulSoup(urllib2.urlopen(url).read())
    
    table = soup.find("table")
    rows = table.findAll("tr")
    
    ## Get cells of every table
    for r in rows[2:]:
        cell = r.findAll("td")
        
        rank = cell[0].string
        song = cell[2].string
        artist = cell[1].string
        artists = split_loop([artist])
        
        f = len(artist.split(" feat. "))
        
        ## If artist needs to be split, show prompt to ask how to split
        if len(artists) != 1 and len(artists) != f:
            print("--------------------")
            print(str(y) + " ---- " + str(rank))
            print("--------------------")
            print(artist)
            print(artists)
            selection = raw_input('Press 1 to take split, 2 to take old, 3 to pass')
            
            print(selection)
            if selection == "1":
                for a in artists:
                    entry = (y,rank,artist,a,song)
                    entries.append(entry)
            
            elif selection == "2":
                entry = (y,rank,artist,artist,song)
                entries.append(entry)
            
            else:
                entry = (y,rank,artist,song)
                errors.append(entry)
        
        ## Don't prompt on artists only needing to be split on "feat."
        elif len(artists) != 1 and len(artists) == f:
            for a in artists:
                entry = (y,rank,artist,a,song)
                entries.append(entry)
        
        else:
            entry = (y,rank,artist,artist,song)
            entries.append(entry)
