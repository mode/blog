def get_themes(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    theme_list = []
    themes = js['themes']
    
    if themes != None:
        for t in themes:
            theme = t['name']
            theme_id = t['id']
            weight = t['weight']
            
            entry = (film_name,film_id,theme,theme_id,weight)
            theme_list.append(entry)
    
    return(theme_list)