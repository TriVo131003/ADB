import random
import string
import pyodbc
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
# cursor.execute('select * from Patient')
# # cursor.execute('exec DSKhoaTGDT')
# results = cursor.fetchall()
# columns = [column[0] for column in cursor.description]
# print(columns)
# for i in results:
#     i.KETQUA = i.KETQUA if i.KETQUA is not None else 'NULL'
#     i.PHUCAP = i.PHUCAP if i.PHUCAP is not None else '0.0'
#     print(f"[{i.MAGV:^6}|{i.MADT:^7}|{i.STT:^6}|{i.PHUCAP:^9}|{i.KETQUA:^9}]")

# # customer_name = cursor.fetchone()

# # Close the cursor and connection objects.

def generate_branch_address() -> str:
    street_names = ["Main St.", "Elm St.", "Park Ave.", "Maple St.", "Hill Blvd.", "Ocean Ave."]
    city_names = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia"]
    street_number = str(random.randint(100, 999))
    street_name = random.choice(street_names)
    city_name = random.choice(city_names)
    return f"{street_number} {street_name},{city_name}"


branch_size = 100
command = '''
INSERT INTO Branch (branch_id,branch_name,branch_address,branch_phone)
VALUES {0}
'''
temp = ''
for i in range(branch_size - 1):
    branch_id = i + 1 if i + 1 >= 10 else '0' + str(i + 1)
    branch_name = 'Company No.' + str(branch_id)
    branch_address = generate_branch_address()
    branch_phone = ''.join(random.choices(string.digits, k=10))
    temp += f"('{branch_id}','{branch_name}','{branch_address}','{branch_phone}')"
    temp += ',' if i != branch_size - 2 else ';'
# print(command.format(temp))
cursor.execute(command.format(temp))

branch_size = 5
command = '''
INSERT INTO Branch (branch_id,branch_name,branch_address,branch_phone)
VALUES {0}
'''
temp = ''
for i in range(branch_size - 1):
    branch_id = i + 1 if i + 1 >= 10 else '0' + str(i + 1)
    branch_name = 'Company No.' + str(branch_id)
    branch_address = generate_branch_address()
    branch_phone = ''.join(random.choices(string.digits, k=10))
    temp += f"('{branch_id}','{branch_name}','{branch_address}','{branch_phone}')"
    temp += ',' if i != branch_size - 2 else ';'



cursor.close()
conn.close()