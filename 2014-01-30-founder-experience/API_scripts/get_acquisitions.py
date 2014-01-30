def get_acquisition(company_json):
    j = company_json
    
    company_name = j['name']
    company_permalink = j['permalink']
    a = j['acquisition']
    
    if a is None:
        acquisition = None
    else:
        acquiring_company =  a['acquiring_company']['name']
        acquiring_permalink = a['acquiring_company']['permalink']
        acquired_year = ifnull(a['acquired_year'],1900)
        acquired_month = ifnull(a['acquired_month'],1)
        acquired_day = ifnull(a['acquired_day'],1)
        acquired_date = (str(acquired_year) + "-" + str(acquired_month) + "-" + 
                        str(acquired_day) + "T00:00:00Z")
        price = a['price_amount']
        price_currency_code = a['price_currency_code']
        term_code = a['term_code']
        
        extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        acquisition = (company_name,company_permalink,acquiring_company,
                        acquiring_permalink,acquired_year,acquired_month,
                        acquired_day,acquired_date,price,price_currency_code,
                        term_code,extracted_at)
        
        return acquisition