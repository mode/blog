def create_dimension_companies(cursor):
    cursor.execute('''CREATE TABLE dimension_companies
        (   company_name text,
            company_permalink text,
            category_code text,
            created_at text,
            number_of_employees real,
            founded_year real,
            founded_month real,
            founded_day real,
            founded_date text,
            country_code text,
            state_code text,
            city text,
            latitude real,
            longitude real,
            funding_rounds real,
            total_money_raised real,
            total_money_raised_s text,
            exit text,
            extracted_at text
            )''')