def get_keywords(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    keyword_list = []
    
    try:
        keywords = js['keywords'][0]['keywords']
        
        if keywords != None:
            for k in keywords:
                keyword = k['keyword']
                keyword_id = k['id']
                weight = k['weight']
                
                entry = (film_name,film_id,keyword,keyword_id,weight)
                keyword_list.append(entry)
    
    except:
        None
    
    return(keyword_list)