def get_all_people():
    conn = sqlite3.connect('crunchbase.db')
    cursor = conn.cursor()
    
    cursor.execute("SELECT DISTINCT person_permalink FROM dimension_relationships")
    ppl = cursor.fetchall()
    
    conn.close()
    
    people = []
    for p in ppl:
        people.append(p[0])
    
    return people