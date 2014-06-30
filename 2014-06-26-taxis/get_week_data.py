import csv
from operator import itemgetter, attrgetter

def write_to_csv(csv_name,array):
    columns = len(array[0])
    rows = len(array)
    
    with open(csv_name, "wb") as test_file:
        file_writer = csv.writer(test_file)
        for i in range(rows):
            file_writer.writerow([array[i][j] for j in range(columns)])

def read_table(csv_name,include_header):
    table = []
    
    with open(csv_name, 'Ub') as csvfile:
        f = csv.reader(csvfile, delimiter=',')
        firstline = True
        
        for row in f:
            if firstline == False or include_header == True:
                table.append(tuple(row))
            firstline = False
    
    return table

trips = read_table("trip_data_6.csv",True)

trimmed = []

h = trips[0]

for t in trips[1:]:
    start_day = t[5][:10]
    day = int(start_day[8:])
        
    if day >= 17 and day <= 23:
        entry = [t[1],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12],t[13]]
        trimmed.append(entry)

sorted_trips = sorted(trimmed, key=itemgetter(0,1))

result = []
result.append([h[1],h[5],h[6],h[7],h[8],h[9],h[10],h[11],h[12],h[13],"trip_number"])

start_driver = sorted_trips[0][0]
trip_number = 1

for s in sorted_trips:
    driver = s[0]
    row = [s[0],s[1],s[2],s[3],s[4],s[5],s[6],s[7],s[8],s[9]]
    if driver != start_driver:
        trip_number = 1
        start_driver = driver
        row.append(trip_number)
    else:
        row.append(trip_number)
    trip_number +=1
    
    result.append(row)

write_to_csv("nyc_taxi_june_week.csv",result)