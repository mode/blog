def get_investments(company_json):
    j = company_json
    
    company_name = j['name']
    company_permalink = j['permalink']
    rounds = j['funding_rounds']
    
    invsmts = []
    
    for r in rounds:
        round_id = r['id']
        round_code = r['round_code']
        round_amount = r['raised_amount']
        round_currency_code = r['raised_currency_code']
        year = ifnull(r['funded_year'],1900)
        month = ifnull(r['funded_month'],01)
        day = ifnull(r['funded_day'],01)
        round_date = (str(year) + "-" + str(month) + "-" + str(day) + "T00:00:00Z")
        
        investments = r['investments']
        
        for i in investments:
            if i['company'] is None:
                if i['financial_org'] is None:
                    if i['person'] is None:
                        investor_entity = None
                        investor_name = None
                        investor_permalink = None
                    else:
                        investor_entity = "person"
                        first_name = i['person']['first_name']
                        last_name = i['person']['last_name']
                        investor_name = first_name + " " + last_name
                        investor_permalink = i['person']['permalink']
                else:
                    investor_entity = "financial_org"
                    investor_name = i['financial_org']['name']
                    investor_permalink = i['financial_org']['permalink']
            else:
                investor_entity = "company"
                investor_name = i['company']['name']
                investor_permalink = i['company']['permalink']
            
            extracted_at = datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ")
            
            invsmt = (company_name,company_permalink,round_id,round_code,round_amount,
                round_currency_code,round_date,investor_entity,investor_name,
                investor_permalink,extracted_at)
                
            invsmts.append(invsmt)
    
    return invsmts