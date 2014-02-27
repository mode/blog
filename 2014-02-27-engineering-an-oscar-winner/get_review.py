def get_review(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    try:
        review = js['review']['review']
        cutting_positions = js['review']['cuttingPositions']
        
        entry = (film_name,film_id,review,cutting_positions)
        
        return entry
    
    except:
        None