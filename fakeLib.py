from faker import Faker
import random
import string
from hashlib import sha256
from datetime import datetime, timedelta

fake = Faker()

#-------------config stuff below----------------------

branch_size = 5
Branch_list = []

account_size = 360
Account_list = []
takenUsername = set()

takenAcc = set()
# total Employee is same as Account_size
EmployeeDict = {
  "DE": [0,100,{}],
  "NU": [0,50,{}],
  "ST": [0,200,{}],
  "AD": [0,10,{}]
}

takenEmail = set()
takenPhone = set()
patient_size = 1000
patient_list = {}

DefaultDentist = {}

room_size = 50 # random.randint(10, 50)
room_list = []

branch_room = {}

Drug_size = 300
Drug_list = []
takenDrugName = ()
File = open("drugName.txt", "r")
drug_names = [line.rstrip('\n') for line in File]
random.shuffle(drug_names)

contradiction_size = 1000
contradiction_list = {}
allergic_size = 1000
allergic_list = {}


toothPosList = []
for i in range(1,33): toothPosList.append(f"{i:02}") 
treatment_list = []

appointment_size = 10000
appointment_list = []

method_list = []

treatmentPlanSize = 9000
treatmentPlanList = []
treatmentSessionSize = 20000
treatmentSessionList = []

PrescriptionSize = 20000

ToothSelectionSize = 1600

PaymentRecordSize = 20000

#--------------------config stuff above------------------------


def gen_indication() -> str: # havent used this
    stuff = ["N'Uống 2 lần 1 ngày'",
             "N'Uống 1 lần 5 viên'",
             "N'Uống 2 lần buổi trưa'",
             "N'Uống 3 lần vào buổi tối'"
             ]
    return random.choice(stuff)

def gen_symptoms() -> str:
    stuff = ["N'Sốc phản vệ'",
             "N'Buồn nôn'",
             "N'Hạ huyết áp'",
             "N'Tăng huyết áp'",
             "N'Khó thở'",
             "N'Suy gan'",
             "N'Suy thận'",
             "N'Phát ban'",
             "N'Tiêu chảy'",
             "N'Ho'"
             ]
    return random.choice(stuff)

def gen_sickness() -> str:
    stuff = ["N'Viêm lợi'",
             "N'Loét miệng'",
             "N'Sâu răng'",
             "N'Hôi miệng'",
             "N'Viêm nha chu'",
             "N'Răng lệch'",
             "N'Mất răng'",
             "N'Chảy máu chân răng'"
             ]
    return random.choice(stuff)

def gen_price(min, max) -> str:
    res = fake.pyfloat(min_value=min, max_value=max, right_digits=2)
    return res

def gen_drugname(max_length: int) -> str:
    res = ''
    while res == '' or len(res) > max_length or res in takenDrugName:
        res = random.choice(drug_names)
    return res

def gen_roomName() -> str:
    return random.choice(["N'Phòng nhổ răng'","N'Phòng trám răng'", "N'Phòng trồng răng'"])

def hashPass(password: str) -> str:
    return sha256(password.encode('utf-8')).hexdigest()

def gen_address(max_length: int) -> str:
    res = ''
    while (res == '' or len(res) > max_length):
        siu = fake.address().split('\n')
        res = siu[0] + ', ' + siu[1].split(',')[0]
    return res

def gen_name(max_length: int) -> str:
    res = ''
    while (res == '' or len(res) > max_length):
        res = fake.name()
    return res

def gen_username(max_length: int) -> str:
    res = ''
    while (res == '' or len(res) > max_length or res in takenUsername):
        res = fake.user_name()
    takenUsername.add(res)
    return res

def gen_email(max_length: int) -> str:
    res = ''
    while (res == '' or len(res) > max_length or res in takenEmail):
        res = fake.email()
    takenEmail.add(res)
    return res

def gen_company(max_length: int) -> str:
    res = ''
    while (res == '' or len(res) > max_length):
        res = fake.company()
    return res

def gen_phone() -> str:
    res = '0' + ''.join(random.choices(string.digits, k=9))
    while res in takenPhone:
        res = '0' + ''.join(random.choices(string.digits, k=9))
    takenPhone.add(res)
    return res

def gen_gender() -> str:
    return "N'Nam'" if random.randint(0,1) == 0 else "N'Nữ'"

def gen_birthday(min_age, max_age) -> str:
    res = fake.date_of_birth(None,min_age, max_age)
    return res

def gen_date(min, max):
    return fake.date()

def gen_nationalID() -> str:
    return '0' + ''.join(random.choices(string.digits, k=11))

def gen_sentence(max_length: int) -> str:
    res = ''
    while (res == '' or len(res) > max_length):
        res = fake.sentence()
    return res

def gen_datetime(min, max) -> str:
    res = ''
    while (res == '' or datetime.now().year - res.year < min or datetime.now().year - res.year > max):
        res = fake.date_time()
    return str(res)

def gen_time(min, max) -> str:
    res = ''
    while (res == '' or int(res[0:2]) < min or int(res[0:2]) > max):
        res = fake.time()
    return res




# for _ in range(100):
#     print(fake.future_datetime())


# -------------------------------------------------
# import random

# my_list = ["apple", "banana", "cherry", "orange"]
# random_element = random.choice(my_list)

# print(f"Random element: {random_element}")
# print(fake.time())