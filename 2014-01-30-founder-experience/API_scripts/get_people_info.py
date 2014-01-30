def get_people_info(json):
    j = json
    
    first_name = j['first_name']
    last_name = j['last_name']
    name = first_name + " " + last_name
    permalink = j['permalink']
    created_at = j['created_at']
    born_year = ifnull(j['born_year'],1900)
    born_month = ifnull(j['born_month'],01)
    born_day = ifnull(j['born_day'],01)
    born_date = (str(born_year) + "-" + str(born_month) + "-" +
        str(born_day) + "T00:00:00Z")
    
    extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
    
    row = (first_name,last_name,name,permalink,born_year,born_month,born_day,
            born_date,created_at,extracted_at)
    
    return row