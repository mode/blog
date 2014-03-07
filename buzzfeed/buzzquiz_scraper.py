#http://s3-ak.buzzfed.com/static/js/public/contribute/quiz.js?v=1353107470

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


question_table = []
answer_table = []
result_table = []

question_table.append(("quiz","url","question","title","image"))
answer_table.append(("quiz","url","question","description","result","image"))
result_table.append(("quiz","url","result","name","description","headline","image"))

link_table = read_table("links.csv",True)

urls = []


for l in link_table:
    urls.append(l[1])

## SOMTHING CHECKING DUPLICATES
####

url_errors = []

for url in urls:
    
    try:    
        print(url)
        r = requests.get(url)
        soup = BeautifulSoup(r.text)
        
        quiz = soup.find('h1',{"id":"post-title"}).string
        
        ## Get question set
        questions = soup.findAll('li',{"class":"quiz_question"})
        q_len = len(questions)
        
        for counter in range(q_len):
            
            q = questions[counter]
            
            ## Get question info and write to question table
            header = q.find('div',{"class":"quiz_question_header"})
            title_div = header.find('div',{"class":"headline-1"})
            
            title = title_div.content
            title_img_obj = header.find('img',{"class":"quiz_img"})
            
            if title_img_obj != None:
                title_img = title_img_obj['src']
            else:
                title_img = ""
            
            question_entry = (quiz,url,counter,title,title_img)
            question_table.append(question_entry)
            
            ## Loop through answers and write to answer table
            ols = q.findAll('ol')
            
            for ol in ols:
                lis = ol.findAll('li')
                
                for li in lis:
                    img = li.find('img')
                    
                    if img != None:
                        answer_img = img['src']
                    else:
                        answer_img = ""
                    
                    p_index = int(li['rel:personality_index'])
                    
                    desc = ""
                    desc_span1 = li.find('span',{"class":"quiz_answer_description"})
                    desc_span2 = li.find('span',{"class":"quiz_answer_text"})
                    
                    if desc_span1 != None:
                        desc = desc_span1.contents[0]
                    elif desc_span2 != None:
                        desc = desc_span2.contents[0]
                    
                    answer_entry = (quiz,url,counter,desc,p_index,answer_img)
                    answer_table.append(answer_entry)
        
        ## Loop through results and write to result table
        results = soup.find('div',{"class":"quiz_result_area"})
        result_list = results.findAll('li')
        
        r_len = len(result_list)
        
        for r in range(r_len):
            
            li = result_list[r]
            
            result_name = li['rel:name']
            result_desc = li['rel:description']
            
            headline_div = li.find('div',{"class":"headline-1"})
            result_headline = headline_div.contents[0]
            
            img_tag = li.find('img',{"class":"result_img"})
            
            if img_tag != None:
                result_img = img_tag['src']
            else:
                result_img = ""
            
            result_entry = (quiz,url,r,result_name,result_desc,result_headline,result_img)
            result_table.append(result_entry)
        
        print('succeed!')
        
    except Exception as e:
        print(e)
        print(url)
        url_errors.append((1,url))

clean_question = strip_special(question_table,[0,3])
clean_answer = strip_special(answer_table,[0,3])
clean_result = strip_special(result_table,[0,3,4,5])

write_to_csv('quiz_questions.csv',clean_question)
write_to_csv('quiz_answers.csv',clean_answer)
write_to_csv('quiz_results.csv',clean_result)
write_to_csv('errors.csv',url_errors)