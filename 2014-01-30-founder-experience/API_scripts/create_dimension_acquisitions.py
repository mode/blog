def create_dimension_acquisitions(cursor):
    cursor.execute('''CREATE TABLE dimension_acquisitions
        (   company_name text,
            company_permalink text,
            acquiring_company text,
            acquiring_permalink text,
            acquired_year real,
            acquired_month real,
            acquired_day real,
            acquired_date text,
            price real,
            price_currency_code text,
            term_code text,
            extracted_at text
            )''')