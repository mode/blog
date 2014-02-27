def get_crew(js):
    
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    crew_list = []
    crew = js['crew']
    
    if crew != None:
        for c in crew:
            crew_name = c['name']
            crew_id = ''
            role = c['role']
            is_celebrity = c['isCelebrity']
            is_organization = c['isOrganization']
            sequence = c['sequence']
            
            url = c['nameUri']
            start_point = url.find('cosmoid')
            if start_point > 0:
                crew_id = url[start_point + 8:]
            
            entry = (film_name,film_id,crew_name,crew_id,role,
                        is_celebrity,is_organization,sequence)
            crew_list.append(entry)
    
    return crew_list