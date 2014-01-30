def create_dimension_relationships(cursor):
    cursor.execute('''CREATE TABLE dimension_relationships
        (   entity_name text,
            entity_permalink text,
            entity_type text,
            person_first_name text,
            person_last_name text,
            person_name text,
            person_permalink text,
            title text,
            is_past text,
            extracted_at text
            )''')