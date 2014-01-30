def create_dimension_financial_orgs(cursor):
    cursor.execute('''CREATE TABLE dimension_financial_orgs
        (   financial_org_name text,
            financial_org_permalink text,
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
            investments real,
            total_fund real,
            extracted_at text
            )''')