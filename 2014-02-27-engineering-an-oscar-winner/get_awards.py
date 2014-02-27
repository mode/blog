def get_awards(js):
    info = get_info(js)
    film_name = info[0]
    film_id = info[1]
    
    award_list = []
    awards = js['awards']
    
    if awards != None:
        for a in awards:
            award_id = a['ids']['cosmoId']
            award_title = a['title']
            award_type = a['type']
            medium = a['medium']
            category = a['category']
            year = a['year']
            winner = a['isWinner']
            recipients = a['recipients']
            recipient_id = ''
            recipient_name = ''
            is_celebrity = ''
            is_organization = ''
            
            ## Loop through recepients
            if recipients != None:
                for r in recipients:
                    recipient_id = r['ids']['cosmoId']
                    recipient_name = r['fullName']
                    is_celebrity = r['isCelebrity']
                    is_organization = r['isOrganization']
                    
                    entry = (film_name,film_id,award_id,award_title,award_type,
                                medium,category,year,winner,recipient_id,recipient_name,
                                is_celebrity,is_organization)
                    
                    award_list.append(entry)
            
            else:
                entry = (film_name,film_id,award_id,award_title,award_type,
                            medium,category,year,winner,recipient_id,recipient_name,
                            is_celebrity,is_organization)
                
                award_list.append(entry)
    
    return award_list