def get_company_info(company_json):
    j = company_json
    
    name = j['name']
    permalink = j['permalink']
    category_code = j['category_code']
    created_at = j['created_at']
    number_of_employees = j['number_of_employees']
    founded_year = ifnull(j['founded_year'],1900)
    founded_month = ifnull(j['founded_month'],01)
    founded_day = ifnull(j['founded_day'],01)
    founded_date = (str(founded_year) + "-" + str(founded_month) + "-" +
        str(founded_day) + "T00:00:00Z")
    funding_rounds = len(j['funding_rounds'])
    total_money_raised_s = j['total_money_raised']
    
    # info on location
    if len(j['offices']) > 0:
        country_code = j['offices'][0]['country_code']
        state_code = j['offices'][0]['state_code']
        city = j['offices'][0]['city']
        latitude = j['offices'][0]['latitude']
        longitude = j['offices'][0]['longitude']
    else:
        country_code = None
        state_code = None
        city = None
        latitude = None
        longitude = None
    
    # find total funding
    total_money_raised = 0
    currencies = []
    for r in j['funding_rounds']:
        total_money_raised += ifnull(r['raised_amount'],0)
        currencies.append(r['raised_currency_code'])
    
    currency_count = len(list(set(currencies)))
    
    if currency_count != 1:
        total_money_raised = 0
        
    # find exit
    if j['ipo'] is None:
        if j['acquisition'] is None:
            exit = 'no_exit'
        else:
            exit = 'acquired'
    else:
        exit = 'ipo'
    
    extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
    
    row = (name,permalink,category_code,created_at,number_of_employees,
    founded_year,founded_month,founded_day,founded_date,country_code,
    state_code,city,latitude,longitude,funding_rounds,total_money_raised,
    total_money_raised_s,exit,extracted_at)
    
    return row