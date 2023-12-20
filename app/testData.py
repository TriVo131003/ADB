import random
import string
import pyodbc
from app.fakeLib import *
# hosting a database locally, got connection timeout sometimes when u use Ethernet instead of Wifi, turn of Ethernet, 
# try Wifi and plug again

# đổi tên Server để chạy được trên máy của mn nha
conn = pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};'
                      'Server=LAPTOP-6KGH4NMD;'
                      'Database=QLPHONGKHAM;'
                      'Trusted_Connection=yes;', autocommit=True) # autocommit for fast transaction

# Create a cursor object.
cursor = conn.cursor()

# # Execute the stored function.
# # 'exec DSKhoaTGDT'

def show_result(results):
    columns = [column[0] for column in cursor.description]
    print(columns)
    for i in results:
        print(i,end=' | ')

cursor.execute(f"select count(*) from PaymentRecord")
results = cursor.fetchall()
print(results[0])

# print(len(results))
# for i in results:
#     print(i)

# branch_id = random.randint(1,results[0])
# branch_id = '0' + str(branch_id) if branch_id < 10 else str(branch_id)

# cursor.execute(f"select * from Branch")
# results = cursor.fetchall()
# print(results[int(branch_id) - 1].branch_name)

# show_result(results)

cursor.close()
conn.close()

temp = ''
dick = {'343': [1,2,3,4,5], '43545': [34,5,4], '566': [34,34,3]}
for cnt, i in enumerate(dick.keys()):
    temp += f"('{i}')"
    temp += ',\n' if cnt != len(dick.keys()) - 1 else ';\n'
print(temp)

for i in dick.values():
    if 34 in i: 
        print('its here')
        break