from faker import Faker
import random
import string
from hashlib import sha256
from datetime import datetime, timedelta


fake = Faker()

branch_size = 5
Branch_list = []

account_size = 350
Account_list = []
takenUsername = set()

takenAcc = set()
EmployeeDict = {
  "Doctor": [0,100,{}],
  "Nurse": [0,50,{}],
  "Staff": [0,200,{}]
}

takenEmail = set()
patient_size = 1000
patient_list = []

DefaultDentist = {}

room_size = random.randint(10, 50)
room_list = []

Drug_size = 300
Drug_list = []




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
    return '0' + ''.join(random.choices(string.digits, k=9))

def gen_gender() -> str:
    return "N'Nam'" if random.randint(0,1) == 0 else "N'Nữ'"

def gen_date(min, max) -> str:
    res = ''
    while (res == '' or datetime.now().year - res.year < min or datetime.now().year - res.year > max):
        res = fake.date_of_birth()
    return str(res)

def gen_nationalID() -> str:
    return fake.country_code()

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


# for _ in range(100):
#     print(gen_datetime(6, 10))


# -------------------------------------------------
# import random

# my_list = ["apple", "banana", "cherry", "orange"]
# random_element = random.choice(my_list)

# print(f"Random element: {random_element}")