from faker import Faker
from fakeLib import *
import pyodbc
# hosting a database locally, got connection timeout sometimes when u use Ethernet instead of Wifi, turn of Ethernet, 
# try Wifi and plug again

# đổi tên Server để chạy được trên máy của mn nha
conn = pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};'
                      'Server=LAPTOP-6KGH4NMD;'
                      'Database=QLPHONGKHAM;'
                      'Trusted_Connection=yes;', autocommit=True) # autocommit for fast transaction

def show_result(results):
    columns = [column[0] for column in cursor.description]
    print(columns)
    for i in results:
        print(i)

# Create a cursor object.
cursor = conn.cursor()

# ----------------------clear first DO SHIT LATER :33--------------------------
command = """
EXEC sys.sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
EXEC sys.sp_msforeachtable 'DELETE FROM ?';
EXEC sys.sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL';
"""
cursor.execute(command)
# -----------REMEMBER TO DELETE THOSE LINES ABOVE WHEN RELEASE------------------

# Generate Data Script
File = open("DataGenerator.sql",'w',encoding='utf-8')
fake = Faker()

#---------------Branch------------------------------
command = '''
INSERT INTO Branch (branch_id,branch_name,branch_address,branch_phone)
VALUES {0}
'''
temp = ''
for i in range(branch_size):
    branch_id = i + 1 if i + 1 >= 10 else '0' + str(i + 1)
    branch_name = gen_company(20)
    branch_address = gen_address(30)
    branch_phone = gen_phone()
    temp += f"('{branch_id}','{branch_name}','{branch_address}','{branch_phone}')"
    temp += ",\n" if i != branch_size - 1 else ';\n'
    Branch_list.append(branch_id)

final_command = command.format(temp)
cursor.execute(command.format(temp)) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#--------------Account-------------------------------
command = '''
{0}
'''
temp = ''
for i in range(1, account_size + 1):
    acc_id = f"{i:05}"
    username = gen_username(20)
    password = 'pass' + str(i)
    temp += f"EXEC insertAccount '{username}','{hashPass(password)}';\n"
    Account_list.append(acc_id)
    cursor.execute(f"EXEC insertAccount '{username}','{hashPass(password)}'") # INSERT THE DATA

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#-------------EMPLOYEE---------------- # DOCTOR, NURSE, STAFF
command = '''
INSERT INTO Employee (employee_id,
                    employee_name,
                    employee_gender,
                    employee_birthday,
                    employee_address,
                    employee_national_id,
                    employee_phone,
                    employee_type,
                    branch_id,
                    account_id)
VALUES {0}
'''
temp = ''
for i in range(1, account_size + 1):
    empID = f"{i:03}"
    gender = "N'Nam'" if random.randint(0,1) == 0 else "N'Nữ'"
    typeID = random.choice(["Doctor","Nurse","Staff"])
    while EmployeeDict[typeID][0] + 1 > EmployeeDict[typeID][1]:
        typeID = random.choice(["Doctor","Nurse","Staff"])
    EmployeeDict[typeID][0] += 1
    account = random.choice(Account_list)
    while account in takenAcc:
        account = random.choice(Account_list)
    takenAcc.add(account)
    EmployeeDict[typeID][2][empID] = account
    temp += f"('{empID}','{gen_name(30)}',{gender},'{gen_date(20, 65)}','{gen_address(30)}','{gen_nationalID()}','{gen_phone()}','{typeID}','{random.choice(Branch_list)}','{account}')"
    temp += ",\n" if i != account_size else ';\n'

final_command = command.format(temp)
# print(final_command)
cursor.execute(final_command) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#--------------------Dentist-----------------
command = '''
INSERT INTO Dentist (dentist_id)
VALUES {0}
'''
temp = ''
for i, empID in enumerate(EmployeeDict['Doctor'][2].keys()):
    temp += f"('{empID}')"
    temp += ",\n" if i != len(EmployeeDict['Doctor'][2]) - 1 else ";\n"

final_command = command.format(temp)
cursor.execute(command.format(temp)) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#-------------------Nurse----------------------
command = '''
INSERT INTO Nurse (nurse_id)
VALUES {0}
'''
temp = ''
for i, empID in enumerate(EmployeeDict['Nurse'][2].keys()):
    temp += f"('{empID}')"
    temp += ",\n" if i != len(EmployeeDict['Nurse'][2]) - 1 else ";\n"

final_command = command.format(temp)
cursor.execute(command.format(temp)) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#-----------------Patient-----------------------
command = '''
{0}
'''
temp = ''
for i in range(1, patient_size + 1):
    pa_id = f"{i:05}"
    temp1 = f"EXEC insertPatient '{gen_name(30)}','{gen_date(6, 65)}','{gen_address(40)}','{gen_phone()}',{gen_gender()},'{gen_email(20)}';\n"
    patient_list.append(pa_id)
    temp += temp1
    cursor.execute(temp1) # INSERT THE DATA

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT


#----------------General Health--------------------
command = '''
{0}
'''
temp = ''
for i in range(1, patient_size + 1):
    pa_id = f"{i:05}"
    temp1 = f"EXEC insertGeneralHealth '{pa_id}','{gen_datetime(6, 10)}','{gen_sentence(30)}';\n"
    temp += temp1
    cursor.execute(temp1) # INSERT THE DATA

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#-----------------Default Doctor---------------------
command = '''
INSERT INTO DefaultDentist (patient_id, dentist_id)
VALUES {0}
'''
temp = ''
for i in range(1, patient_size + 1):
    pa_id = f"{i:05}"
    dentist_id = list(EmployeeDict["Doctor"][2].keys())
    temp += f"('{pa_id}','{random.choice(dentist_id)}')"
    temp += ",\n" if i != patient_size else ";\n"

final_command = command.format(temp)
cursor.execute(command.format(temp)) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#---------------------Room----------------------------
command = '''
INSERT INTO Room (room_id, room_name)
VALUES {0}
'''
temp = ''
for i in range(1, room_size + 1):
    room_id = f"{i:02}"
    room_list.append(room_id)
    temp += f"('{room_id}',{gen_roomName()})"
    temp += ",\n" if i != room_size else ";\n"

final_command = command.format(temp)
cursor.execute(command.format(temp)) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#--------------------Drug---------------------------









print("Successfully generated Data and DataGenerator.sql")
File.close()
cursor.close()
conn.close()