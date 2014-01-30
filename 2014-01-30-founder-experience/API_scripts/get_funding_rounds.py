def get_funding_rounds(company_json):
    j = company_json
    
    company_name = j['name']
    company_permalink = j['permalink']
    rounds = j['funding_rounds']
    
    rnds = []
    
    for r in rounds:
        round_id = r['id']
        round_code = r['round_code']
        raised_amount = r['raised_amount']
        raised_currency_code = r['raised_currency_code']
        funded_year = ifnull(r['funded_year'],1900)
        funded_month = ifnull(r['funded_month'],01)
        funded_day = ifnull(r['funded_day'],01)
        funded_date = (str(funded_year) + "-" + str(funded_month) + "-" +
            str(funded_day) + "T00:00:00Z")
        investor_count = len(r['investments'])
        
        extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        rnd = (company_name,company_permalink,round_id,round_code,raised_amount,
                raised_currency_code,funded_year,funded_month,funded_day,
                funded_date,investor_count,extracted_at)
        
        rnds.append(rnd)
        
    return rnds