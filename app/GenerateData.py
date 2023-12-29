from faker import Faker
from fakeLib import *
import pyodbc
# hosting a database locally, got connection timeout sometimes when u use Ethernet instead of Wifi, turn of Ethernet, 
# try Wifi and plug again

key = open("ServernameHere.txt",'r')
contents = key.read()
print(contents)

# đổi tên Server để chạy được trên máy của mn nha
conn = pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};'
                      f'Server={contents};'
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
File = open("../database/DataGenerator.sql",'w',encoding='utf-8')
File.write(command)
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
cursor.execute(final_command) # INSERT THE DATA
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

#-------------EMPLOYEE---------------- # DE, NURSE, STAFF, ADMIN
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
    typeID = random.choice(["DE","NU","ST","AD"])
    while EmployeeDict[typeID][0] + 1 > EmployeeDict[typeID][1]:
        typeID = random.choice(["DE","NU","ST","AD"])
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
for i, empID in enumerate(EmployeeDict['DE'][2].keys()):
    temp += f"('{empID}')"
    temp += ",\n" if i != len(EmployeeDict['DE'][2]) - 1 else ";\n"

final_command = command.format(temp)
cursor.execute(final_command) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#-------------------Nurse----------------------
command = '''
INSERT INTO Nurse (nurse_id)
VALUES {0}
'''
temp = ''
for i, empID in enumerate(EmployeeDict['NU'][2].keys()):
    temp += f"('{empID}')"
    temp += ",\n" if i != len(EmployeeDict['NU'][2]) - 1 else ";\n"

final_command = command.format(temp)
cursor.execute(final_command) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#-----------------Patient-----------------------
command = '''
{0}
'''
temp = ''
for i in range(1, patient_size + 1):
    pa_id = f"{i:05}"
    pa_phone = gen_phone()
    temp1 = f"EXEC insertPatient '{gen_name(30)}','{gen_birthday(6, 65)}','{gen_address(40)}','{pa_phone}',{gen_gender()},'{gen_email(20)}';\n"
    patient_list[pa_id] = pa_phone
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
    temp1 = f"EXEC insertGeneralHealth '{patient_list[pa_id]}','{gen_datetime(6, 10)}',{gen_sickness()};\n"
    temp += temp1
    cursor.execute(temp1) # INSERT THE DATA

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#-----------------Default DE---------------------
command = '''
INSERT INTO DefaultDentist (patient_id, dentist_id)
VALUES {0}
'''
temp = ''
for i in range(1, patient_size + 1):
    pa_id = f"{i:05}"
    dentist_id = list(EmployeeDict["DE"][2].keys())
    temp += f"('{pa_id}','{random.choice(dentist_id)}')"
    temp += ",\n" if i != patient_size else ";\n"

final_command = command.format(temp)
cursor.execute(final_command) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#---------------------Room----------------------------
command = '''
INSERT INTO Room (room_id, room_name, branch_id)
VALUES {0}
'''
temp = ''
branch_room = {}
for i in Branch_list:
    branch_room[i] = []
for i in range(1, room_size):
    branch_id = random.choice(Branch_list)
    while len(branch_room[branch_id]) >= 50:
        branch_id = random.choice(Branch_list)
    room_id = f"{i:02}"
    branch_room[branch_id].append(room_id)
    room_list.append(room_id)
    temp += f"('{room_id}',{gen_roomName()},'{branch_id}')"
    temp += ",\n" if i != room_size - 1 else ";\n"

final_command = command.format(temp)
cursor.execute(final_command) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#--------------------Drug---------------------------
command = '''
{0}
'''
temp = ''
for i in range(1, Drug_size + 1):
    drug_id = f"DR{i:03}"
    Drug_list.append(drug_id)
    stock_quantity = random.randint(1, 10000)
    temp1 = f"EXEC insertDrug '{gen_drugname(30)}',{gen_indication()},'{fake.future_date(365)}',{gen_price(10.0, 100000.0)},'{stock_quantity}';\n"
    temp += temp1
    try:
        cursor.execute(temp1) # INSERT THE DATA
    except:
        print(temp1)
        print("Skip insertDrug")

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#-------------------Contradiction------------------------
command = '''
{0}
'''
temp = ''
for i in range(1, patient_size + 1):
    pa_id = f"{i:05}"
    contradiction_list[pa_id] = []
for i in range(1, contradiction_size + 1):
    patientList = list(patient_list.keys())
    pa_id = random.choice(patientList)
    drug_id = random.choice(Drug_list)
    while drug_id in contradiction_list[pa_id]:
        drug_id = random.choice(Drug_list)
    contradiction_list[pa_id].append(drug_id)
    temp1 = f"EXEC insertContradiction '{pa_id}','{drug_id}',{gen_symptoms()};\n"
    temp += temp1
    try:
        cursor.execute(temp1) # INSERT THE DATA
    except:
        print(temp1)
        print("Skip contradiction")

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#-------------------Allergic------------------------
command = '''
{0}
'''
temp = ''
for i in range(1, patient_size + 1):
    pa_id = f"{i:05}"
    allergic_list[pa_id] = []
for i in range(1, allergic_size + 1):
    patientList = list(patient_list.keys())
    pa_id = random.choice(patientList)
    drug_id = random.choice(Drug_list)
    while drug_id in allergic_list[pa_id]:
        drug_id = random.choice(Drug_list)
    allergic_list[pa_id].append(drug_id)
    temp1 = f"EXEC insertDrugAllergy '{pa_id}','{drug_id}',{gen_symptoms()};\n"
    temp += temp1
    try:
        cursor.execute(temp1) # INSERT THE DATA
    except:
        print(temp1)
        print("Skip Allergy")

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#------------------ToothSurface----------------------------------
command = '''
INSERT INTO ToothSurface
VALUES ('L',N'Mặt trong',N'Bề mặt răng hướng vào trong'),
       ('F',N'Mặt ngoài',N'Bề mặt răng hướng ra ngoài môi'),
       ('D',N'Mặt xa',N'Mặt cạnh răng nằm về phía xa'),
       ('M',N'Mặt gần',N'Mặt cạnh răng nằm về phía gần'),
       ('T',N'Mặt đỉnh',N'Diện nhai đối với răng hàm'),
       ('R',N'Mặt chân răng',N'Phần chân tiếp xúc với nướu');
'''
cursor.execute(command)
File.write(command)

#------------------ToothPosition-------------------------------
command = '''
INSERT INTO ToothPosition
VALUES {0}
'''
temp = ''
for i in range(1,5):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng cửa',N'Răng cửa trên'),\n"
for i in range(5,9):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng cửa',N'Răng cửa dưới'),\n"
for i in range(9,11):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng nanh',N'Răng nanh trên'),\n"
for i in range(11,13):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng nanh',N'Răng nanh dưới'),\n"
for i in range(13,17):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng hàm nhỏ',N'Răng hàm nhỏ trên'),\n"
for i in range(17,21):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng hàm nhỏ',N'Răng hàm nhỏ dưới'),\n"
for i in range(21,25):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng hàm lớn',N'Răng hàm lớn trên'),\n"
for i in range(25,29):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng hàm lớn',N'Răng hàm lớn dưới'),\n"
for i in range(29,31):
    toothID = f"{i:02}"
    temp += f"('{toothID}',N'Răng khôn',N'Răng khôn trên'),\n"

temp += f"('31',N'Răng khôn',N'Răng khôn dưới'),\n"
temp += f"('32',N'Răng khôn',N'Răng khôn dưới');"

final_command = command.format(temp)
cursor.execute(final_command)
File.write(final_command)

#------------------------Treatment-----------------------------
command = '''
INSERT INTO Treatment
VALUES {0}
'''
temp = ''
tempF = open('treatment.txt','r',encoding='utf-8')
treatmentStuff = [line.rstrip('\n') for line in tempF]
treatment_size = len(treatmentStuff)
for i in range(1, treatment_size + 1):
    treat_id = f"{i:02}"
    treatment_list.append(treat_id)
    temp += f"('{treat_id}',N'{treatmentStuff[i - 1]}','{gen_sentence(30)}',{gen_price(100000.0, 50000000.0)})"
    temp += ",\n" if i != treatment_size else ";\n"

final_command = command.format(temp)
cursor.execute(final_command) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#----------------------TreatmentTooth-----------------------------
command = '''
INSERT INTO TreatmentTooth
VALUES {0}
'''
temp = ''
cnt = 0
for toothID in toothPosList:
    for treat in treatment_list:
        cnt += 1
        temp += f"('{toothID}','{treat}',{gen_price(100000.0, 50000000.0)})"
        temp += ",\n" if cnt != treatment_size * 32 else ";\n"

final_command = command.format(temp)
cursor.execute(final_command) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#---------------------Appointment-------------------------------- # fix the goddam PROC
command = '''
{0}
'''
temp = ''
for i in range(1, appointment_size + 1):
    appoint_id = f"{i:05}"
    appointment_list.append(appoint_id)
    room = random.choice(room_list)
    isNew = random.choice([0,1])
    patient = random.choice(list(patient_list.keys()))
    dentist = random.choice(list(EmployeeDict["DE"][2].keys()))
    nurse = random.choice(list(EmployeeDict["NU"][2].keys()))
    temp1 = f"EXEC InsertAppointment '{fake.past_datetime('-5d')}','{fake.future_date(7)}','{gen_time(8,21)}','{room}',{isNew},'{patient}','{dentist}','{nurse}';\n"
    temp += temp1
    cursor.execute(temp1) # INSERT THE DATA

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#---------------------Payment Method-----------------------------
command = '''
INSERT INTO PaymentMethod (payment_method_id,payment_method_title)
VALUES {0}
'''
temp = ''
methods = ["N'Ngân hàng'","N'Tiền mặt'","N'Momo'","N'Zalopay'",
           "N'VNPay'","N'ViettelPay'"]
cnt = 0
for i in methods:
    cnt += 1
    method_id = f"{cnt:05}"
    method_list.append(method_id)
    temp += f"('{method_id}',{i})"
    temp += ",\n" if cnt != len(methods) else ";\n"

final_command = command.format(temp)
cursor.execute(final_command) # INSERT THE DATA
File.write(final_command) # GENERATE DATA SCRIPT

#--------------------TreatmentPlan---------------------------
command = '''
{0}
'''
temp = ''
for i in range(1, treatmentPlanSize + 1):
    plan_id = f"{i:05}"
    treatmentPlanList.append(plan_id)
    treatment = random.choice(treatment_list)
    patient = random.choice(list(patient_list.keys()))
    dentist = random.choice(list(EmployeeDict["DE"][2].keys()))
    nurse = random.choice(list(EmployeeDict["NU"][2].keys()))
    temp1 = f"EXEC InsertTreatmentPlan '{fake.future_datetime('+7d')}','{gen_sentence(30)}','{gen_sentence(50)}','{treatment}','{patient}','{dentist}','{nurse}';\n"
    temp += temp1
    cursor.execute(temp1) # INSERT THE DATA

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#---------------------TreatmentSession-----------------------------
temp = ''
for i in range(1, treatmentSessionSize + 1):
    plan = random.choice(treatmentPlanList)
    id = f"{i:05}"
    temp1 = f"INSERT INTO TreatmentSession VALUES ('{id}','{fake.future_datetime('+7d')}','{gen_sentence(50)}','{plan}');\n"
    temp += temp1
    cursor.execute(temp1) # INSERT THE DATA

final_command = temp
File.write(final_command) # GENERATE DATA SCRIPT

#--------------------Prescription----------------------------------Some wont be added due to insufficient stock quantity
command = '''
{0}
'''
temp = ''
for i in range(1, PrescriptionSize + 1):
    plan = random.choice(treatmentPlanList)
    drug = random.choice(Drug_list)
    temp1 = f"EXEC AddPrescription '{plan}','{drug}',{random.randint(1, 10)};\n"
    temp += temp1
    try:
        cursor.execute(temp1) # INSERT THE DATA
    except:
        continue

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#------------------ToothSelection------------------------------------Some wont be inserted well due to price
command = '''
{0}
'''
temp = ''
for i in range(1, ToothSelectionSize + 1):
    plan = random.choice(treatmentPlanList)
    pos = random.choice(toothPosList)
    surface = random.choice(['L','F','D','M','T','R'])
    temp1 = f"EXEC insertToothSelection '{plan}','{pos}',{surface};\n"
    temp += temp1
    try:
        cursor.execute(temp1) # INSERT THE DATA
    except:
        continue

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT

#----------------------PaymentRecord--------------------------------------------
command = '''
{0}
'''
temp = ''
for i in range(1, PaymentRecordSize + 1):
    plan = random.choice(treatmentPlanList)
    method = random.choice(method_list)
    temp1 = f"EXEC InsertPaymentRecord '{fake.future_datetime('+7d')}',{gen_price(50000.0,100000000.0)},'{gen_sentence(15)}','{method}','{plan}';\n"
    temp += temp1
    try:
        cursor.execute(temp1) # INSERT THE DATA
    except:
        continue

final_command = command.format(temp)
File.write(final_command) # GENERATE DATA SCRIPT


print("Successfully generated Data and DataGenerator.sql")
File.close()
cursor.close()
conn.close()