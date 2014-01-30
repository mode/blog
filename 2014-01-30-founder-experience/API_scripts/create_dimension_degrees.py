def create_dimension_degrees(cursor):
    cursor.execute('''CREATE TABLE dimension_degrees
        (   person_permalink text,
            person_name text,
            degree_type text,
            subject text,
            institution text,
            graduated_year int,
            graduated_month int,
            graduated_day int,
            graduated_date text,
            extracted_at text
            )''')