def ifnull(var, val):
  if var is None:
    return val
  return var

def drop_table(tables):
    conn = sqlite3.connect('crunchbase.db')
    cursor = conn.cursor()
    
    for t in tables:
        cursor.execute("DROP TABLE" + " " + t)
    
    conn.commit()
    conn.close()

def unc(string):
    n = string.encode('utf-8').strip()
    return n

def strip_special_2(array,columns_with_string):
    new_table = []
    for i in array:
        print(i)
        new_row =[]
        for j in range(len(i)):
            print(j)
            if j in columns_with_string:
                print(i[j])
                x = i[j].encode('utf-8').strip()
            else:
                x = i[j]
            new_row.append(x)
            
        new_table.append(new_row)
    
    return new_table