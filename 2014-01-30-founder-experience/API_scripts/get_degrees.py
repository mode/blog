def get_degrees(json):
    j = json
    
    first_name = j['first_name']
    last_name = j['last_name']
    name = first_name + " " + last_name
    permalink = j['permalink']
    degrees = j['degrees']
    
    degs = []
    
    for d in degrees:
        degree_type = d['degree_type']
        subject = d['subject']
        institution = d['institution']
        graduated_year = ifnull(j['graduated_year'],1900)
        graduated_month = ifnull(d['graduated_month'],1900)
        graduated_day = ifnull(d['graduated_day'],1900)
        graduated_date = (str(graduated_year) + "-" + str(graduated_month) + "-" +
            str(graduated_day) + "T00:00:00Z")
        
        extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        deg = (permalink,name,degree_type,subject,institution,
                graduated_year,graduated_month,graduated_day,graduated_date,
                extracted_at)
        
        degs.append(deg)
        
    return degs