def create_dimension_people(cursor):
    cursor.execute('''CREATE TABLE dimension_people
        (   person_first_name text,
            person_last_name text,
            person_name text,
            person_permalink text,
            born_year int,
            born_month int,
            born_day int,
            born_date text,
            created_at text,
            extracted_at text
            )''')