def get_moods(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    mood_list = []
    moods = js['moods']
    
    if moods != None:
        for m in moods:
            mood = m['name']
            mood_id = m['id']
            weight = m['weight']
            
            entry = (film_name,film_id,mood,mood_id,weight)
            mood_list.append(entry)
    
    return(mood_list)