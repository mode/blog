def get_related_to(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    related_list = []
    
    try:
        relateds = js['related']['relatedTo']
        if relateds != None:
            for r in relateds:
                title = r['title']
                cosmo_id = r['ids']['cosmoId']
                director_name = ''
                director_id = ''
                release_year = r['releaseYear']
                rating = r['rating']
                directors = r['directors']
                
                if directors != None:
                    director_id = directors[0]['id']
                    director_name = directors[0]['name']
                
                entry = (film_name,film_id,title,cosmo_id,release_year,rating,
                            director_name,director_id)
                related_list.append(entry)
    except:
        None
    
    return related_list
        



    