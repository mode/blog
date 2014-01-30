def get_relationships(company_json):
    j = company_json
    
    entity_name = j['name']
    entity_permalink = j['permalink']
    entity_type = "company"
    relationships = j['relationships']
    
    rels = []
    
    for r in relationships:
        person_first_name = r['person']['first_name']
        person_last_name = r['person']['last_name']
        person_name = person_first_name + " " + person_last_name
        person_permalink = r['person']['permalink']
        title = r['title']
        is_past = r['is_past']
        
        extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        rel = (entity_name,entity_permalink,entity_type,person_first_name,
                person_last_name,person_name,person_permalink,title,is_past,
                extracted_at)
        
        rels.append(rel)
        
    return rels