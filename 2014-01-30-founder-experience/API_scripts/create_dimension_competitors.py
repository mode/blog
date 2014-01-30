def create_dimension_competitors(cursor):
    cursor.execute('''CREATE TABLE dimension_competitors
        (   company_name text,
            company_permalink text,
            competitor_name text,
            competitor_permalink text,
            extracted_at text
            )''')