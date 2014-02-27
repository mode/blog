def get_info(js):
    
    cosmo_id = js['ids']['cosmoId']
    title = js['masterTitle']
    release_year = js['releaseYear']
    duration = js['duration']
    subcategory = js['subcategory']
    language = js['programLanguage']
    rating = ''
    ratings = js['parentalRatings']
    
    if ratings != None:
        for r in ratings:
            if r['ratingType'] == 'MPAA':
                rating = r['rating']
    
    entry = (cosmo_id,title,duration,subcategory,language,
                release_year,rating)
    
    return entry