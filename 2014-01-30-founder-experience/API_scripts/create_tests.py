def create_tests(cursor):
    cursor.execute('''CREATE TABLE tests
        (   text_column text,
            real_column real
            )''')