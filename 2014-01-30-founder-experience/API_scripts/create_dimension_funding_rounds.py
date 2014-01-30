def create_dimension_funding_rounds(cursor):
    cursor.execute('''CREATE TABLE dimension_funding_rounds
        (   company_name text,
            company_permalink text,
            round_id real,
            round_code text,
            raised_amount real,
            raised_currency_code text,
            funded_year real,
            funded_month real,
            funded_day real,
            funded_date text,
            investor_count real,
            extracted_at text
            )''')