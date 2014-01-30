def create_db():
    conn = sqlite3.connect('crunchbase.db')
    cursor = conn.cursor()
    
    create_dimension_companies(cursor)
    create_dimension_financial_orgs(cursor)
    create_dimension_relationships(cursor)
    create_dimension_competitors(cursor)
    create_dimension_funding_rounds(cursor)
    create_dimension_investments(cursor)
    create_dimension_acquisitions(cursor)
    create_dimension_funds(cursor)
    create_dimension_people(cursor)
    create_dimension_degrees(cursor)
    create_tests(cursor)
    
    conn.commit()
    conn.close()