def get_synopsis(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    try:
        synopsis = js['synopsis']['synopsis']
        cutting_positions = js['synopsis']['cuttingPositions']
        
        entry = (film_name,film_id,synopsis,cutting_positions)
        
        return entry
    
    except:
        None