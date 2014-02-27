def get_characteristics(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    characteristic_list = []
    try:
        characteristics = js['keywords'][0]['characteristics']
        
        if characteristics != None:
            for c in characteristics:
                char = c['keyword']
                char_id = c['id']
                weight = c['weight']
                
                entry = (film_name,film_id,char,char_id,weight)
                characteristic_list.append(entry)
    except:
        None
    
    return(characteristic_list)