def get_tones(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    tone_list = []
    tones = js['tones']
    
    if tones != None:
        for t in tones:
            tone = t['name']
            tone_id = t['id']
            weight = t['weight']
            
            entry = (film_name,film_id,tone,tone_id,weight)
            tone_list.append(entry)
    
    return(tone_list)