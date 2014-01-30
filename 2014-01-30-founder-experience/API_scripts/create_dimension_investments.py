def create_dimension_investments(cursor):
    cursor.execute('''CREATE TABLE dimension_investments
        (   company_name text,
            company_permalink text,
            round_id real,
            round_code text,
            round_amount real,
            round_currency_code text,
            round_date text,
            investor_entity text,
            investor_name text,
            investor_permalink text,
            extracted_at text
            )''')