def get_financial_org_info(company_json):
    j = company_json
    
    name = j['name']
    permalink = j['permalink']
    created_at = j['created_at']
    number_of_employees = j['number_of_employees']
    founded_year = ifnull(j['founded_year'],1900)
    founded_month = ifnull(j['founded_month'],1)
    founded_day = ifnull(j['founded_day'],1)
    founded_date = (str(founded_year) + "-" + str(founded_month) + "-" +
        str(founded_day) + "T00:00:00Z")
    investments = len(j['investments'])
    
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
    
    # total_fund_size
    total_fund = 0
    currencies = []
    for r in j['funds']:
        total_fund += ifnull(r['raised_amount'],0)
        currencies.append(r['raised_currency_code'])
    
    currency_count = len(list(set(currencies)))
    
    if currency_count != 1:
        total_money_raised = 0
    
    extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
    
    row = (name,permalink,created_at,number_of_employees,founded_year,
        founded_month,founded_day,founded_date,country_code,
        state_code,city,latitude,longitude,investments,total_fund,
        extracted_at)
    
    return row