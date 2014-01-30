def get_competitors(company_json):
    j = company_json
    
    company_name = j['name']
    company_permalink = j['permalink']
    competitors = j['competitions']
    
    coms = []
    
    for c in competitors:
        competitor_name = c['competitor']['name']
        competitor_permalink = c['competitor']['permalink']
        
        extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        com = (company_name,company_permalink,competitor_name,competitor_permalink,
                extracted_at)
        
        coms.append(com)
        
    return coms