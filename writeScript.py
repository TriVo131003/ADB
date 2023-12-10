import random
import string
import pyodbc
from fakeLib import *
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

cursor.execute(f"select count(*) from Drug")
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
dick = {'343': 546, '43545': 4345, '566': 67657}
for cnt, i in enumerate(dick.keys()):
    temp += f"('{i}')"
    temp += ',\n' if cnt != len(dick.keys()) - 1 else ';\n'
print(temp)

print(list(dick.keys()))