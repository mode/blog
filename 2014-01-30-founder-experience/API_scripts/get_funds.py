def get_funds(json):
    j = json
    
    financial_org_name = j['name']
    financial_org_permalink = j['permalink']
    funds = j['funds']
    
    fds = []
    
    for f in funds:
        fund_name = f['name']
        funded_year = ifnull(f['funded_year'],1900)
        funded_month = ifnull(f['funded_month'],1)
        funded_day = ifnull(f['funded_day'],1)
        funded_date = (str(funded_year) + "-" + str(funded_month) + "-" +
            str(funded_day) + "T00:00:00Z")
        raised_amount = f['raised_amount']
        raised_currency_code = f['raised_currency_code']
        
        extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        fd = (fund_name,financial_org_permalink,financial_org_name,
                funded_year,funded_month,funded_day,funded_date,raised_amount,
                raised_currency_code,extracted_at)
        
        fds.append(fd)
        
    return fds