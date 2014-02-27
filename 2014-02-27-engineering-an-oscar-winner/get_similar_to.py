def get_similar_to(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    similar_list = []
    
    try:
        similars = js['related']['similarTo']
        
        if similars != None:
            for s in similars:
                title = s['title']
                cosmo_id = s['ids']['cosmoId']
                director_name = ''
                director_id = ''
                release_year = s['releaseYear']
                rating = s['rating']
                directors = s['directors']
                
                if directors != None:
                    director_id = directors[0]['id']
                    director_name = directors[0]['name']
                
                entry = (film_name,film_id,title,cosmo_id,release_year,rating,
                            director_name,director_id)
                similar_list.append(entry)
    
    except:
        None
    
    return similar_list