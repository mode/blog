def create_dimension_funds(cursor):
    cursor.execute('''CREATE TABLE dimension_funds
        (   fund_name text,
            financial_org_permalink text,
            financial_org_name text,
            funded_year real,
            funded_month real,
            funded_day real,
            funded_date text,
            raised_amount real,
            raised_currency_code text,
            extracted_at text
            )''')