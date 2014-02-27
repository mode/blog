def get_cast(js):
    
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    cast_list = []
    cast = js['cast']
    
    if cast != None:
        for c in cast:
            actor_name = c['name']
            actor_id = ''
            role = c['role']
            is_celebrity = c['isCelebrity']
            is_organization = c['isOrganization']
            sequence = c['sequence']
            
            url = c['nameUri']
            start_point = url.find('cosmoid')
            if start_point > 0:
                actor_id = url[start_point + 8:]
            
            entry = (film_name,film_id,actor_name,actor_id,role,
                        is_celebrity,is_organization,sequence)
            cast_list.append(entry)
    
    return cast_list