from flask import Flask, render_template, redirect, request, session
from flask_session import Session
from database import *
import secrets

app = Flask(__name__)
app.secret_key = secrets.token_urlsafe(32)
print(app.secret_key)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

current_patient = ''
# userList = []
@app.route('/', methods = ['POST','GET'])
def homepage():
    # print('get started')
    # return render_template('homepage.html')
    # if not session.get("user_id"):
    #     # if not there in the session then redirect to the login page
    #     return redirect("/login")
    return render_template('homepage.html')

@app.route("/logout")
def logout():
    session['user_id'] = None # reset session
    return redirect("/")

@app.route('/employeeIn4', methods = ['POST','GET'])
def PatientIn4Test():
    print('get info')
    empID = session["user_id"]
    cursor.execute('SELECT * from Employee where account_id = ?', (empID))
    employeeInfo = cursor.fetchone()
    if employeeInfo == None:
        return redirect('/login')
    print(employeeInfo.employee_name)
    return render_template('employeein4.html',employee = employeeInfo)

@app.route('/login', methods = ['POST','GET'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        # print('start')
        # print(username,password)
        try:
            password = hashPass(password)
            # Check if the username and password are correct
            cursor.execute('SELECT * FROM Account WHERE username = ?', username)
            user = cursor.fetchone()
            # print(user.password)
            # print(password)
            if user.password == password:
                session["user_id"] = user.accountID
                # userList.append(user.username)
                # print(userList)
                print('success')
                return redirect('/employeeIn4')
            else:
                print('fail')
                return render_template('login.html', error='Invalid username or password. Please try again.')

        except Exception as e:
            return render_template('login.html', error=f'Error: {str(e)}')

    return render_template('login.html')

@app.route('/signup', methods = ['POST','GET'])
def signup():
    # if request.method == 'POST':
    #     username = request.form['username']
    #     password = request.form['password']

    #     cursor = mysql.connection.cursor()
    #     cursor.execute('INSERT INTO users (username, password) VALUES (%s, %s)', (username, password))
    #     mysql.connection.commit()
    #     cursor.close()

    #     return redirect(url_for('login'))

    return render_template('signup.html')

@app.route('/patientinfo', methods = ['POST','GET'])
def patientinfo():
    cursor.execute('SELECT * FROM Patient')
    patients = cursor.fetchall()

    return render_template('patientinfo.html', patients=patients)

@app.route('/addpatient', methods = ['POST','GET'])
def addpatient():
    if request.method == 'POST':
        # Lấy thông tin từ form
        patient_name = request.form['patient_name']
        patient_birthday = request.form['patient_birthday']
        patient_address = request.form['patient_address']
        patient_phone = request.form['patient_phone']
        patient_gender = request.form['patient_gender']
        patient_email = request.form['patient_email']

        cursor.execute("EXEC insertPatient ?, ?, ?, ?, ?, ?", 
                       (patient_name, patient_birthday, patient_address, 
                        patient_phone, patient_gender, patient_email))
    return render_template('addpatient.html')

@app.route('/updatepatient', methods = ['POST','GET'])
def updatepatient():
    patient_id = request.args.get('get_patient_id')
    if request.method == 'POST':
        # Lấy thông tin từ form
        patient_name = request.form['patient_name']
        patient_birthday = request.form['patient_birthday']
        patient_address = request.form['patient_address']
        patient_phone = request.form['patient_phone']
        patient_gender = request.form['patient_gender']
        patient_email = request.form['patient_email']

        cursor.execute("EXEC updatePatient ?, ?, ?, ?, ?, ?, ?", 
                       (patient_id, patient_name, patient_birthday, patient_address, 
                        patient_phone, patient_gender, patient_email))
    return render_template('updatepatient.html')

@app.route('/updategeneralhealth', methods = ['POST','GET'])
def updateGeneralHealth():
    patient_id = request.args.get('get_patient_id')
    if request.method == 'POST':
        # Lấy thông tin từ form
        note_date = request.form['note_date']
        health_description = request.form['health_description']

        # Thực thi stored procedure
        cursor.execute("EXEC updateGeneralHealth ?, ?, ?", 
                       (patient_id, note_date, health_description))
    return render_template('updategeneralhealth.html')

@app.route('/patientrecord', methods = ['POST','GET'])
def patientrecord():
    patient_id = request.args.get('get_patient_id')
    cursor.execute('SELECT * FROM Patient where patient_id = ?', patient_id)
    patient = cursor.fetchone()
    cursor.execute('SELECT * FROM generalhealth where patient_id = ?', patient_id)
    generalhealth = cursor.fetchone()
    cursor.execute('''SELECT SUM(paid_money)
    FROM PaymentRecord
    JOIN TreatmentPlan ON PaymentRecord.treatment_plan_id = TreatmentPlan.treatment_plan_id
    WHERE patient_id = ?''', patient_id)
    paid_money = cursor.fetchone()
    cursor.execute('''SELECT SUM(total_cost)
    FROM PaymentRecord
    JOIN TreatmentPlan ON PaymentRecord.treatment_plan_id = TreatmentPlan.treatment_plan_id
    WHERE patient_id = ?''', patient_id)
    total_cost = cursor.fetchone()
    
    return render_template('patientrecord.html', patient = patient, generalhealth = generalhealth, total_cost= total_cost[0], paid_money = paid_money[0])

@app.route('/treatmentplandetail', methods = ['POST','GET'])
def treatmentplandetail():
    treatment_plan_id = request.args.get('get_treatment_plan_id')
    cursor.execute('SELECT * FROM TreatmentPlan join Treatment on TreatmentPlan.treatment_id = Treatment.treatment_id where TreatmentPlan.treatment_plan_id = ?', treatment_plan_id)
    treatment = cursor.fetchone()
    cursor.execute('SELECT * FROM TreatmentPlan join TreatmentSession on TreatmentSession.treatment_plan_id = TreatmentPlan.treatment_plan_id  where TreatmentPlan.treatment_plan_id = ?', treatment_plan_id)
    treatmentsession = cursor.fetchall()
    cursor.execute('SELECT * from ToothSelection JOIN ToothSurface ON ToothSurface.tooth_surface_code = ToothSelection.tooth_surface_code JOIN ToothPosition ON ToothPosition.tooth_position_id = ToothSelection.tooth_position_id where treatment_plan_id = ?', treatment_plan_id)
    listtreatmenttooth = cursor.fetchall()
    return render_template('treatmentplandetail.html', treatment = treatment, treatmentsession = treatmentsession, listtreatmenttooth= listtreatmenttooth)

@app.route('/treatmentplanlist', methods = ['POST','GET'])
def treatmentplanlist():
    patient_id = request.args.get('get_patient_id')
    cursor.execute('SELECT * FROM TreatmentPlan where patient_id = ?', patient_id)
    treatmentplanlist = cursor.fetchall()
    return render_template('treatmentplanlist.html', treatmentplanlist = treatmentplanlist)

@app.route('/allergycontracdication', methods = ['POST','GET'])
def allergycontracdication():
    patient_id = request.args.get('get_patient_id')
    drug_id = request.args.get('get_drug_id')
    if drug_id != None:
        cursor.execute(f"Delete * from Contradication where patient_id = ? and drug_id = ?", patient_id, drug_id)
    cursor.execute('SELECT * FROM DrugAllergy where patient_id = ?', patient_id)
    allergy = cursor.fetchall()
    cursor.execute('SELECT * FROM Contradication where patient_id = ?', patient_id)
    contradication = cursor.fetchall()
    return render_template('allergycontracdication.html', allergy=allergy, contradication=contradication, patient_id=patient_id)

@app.route('/adddrugallergy', methods = ['POST','GET'])
def adddrugallergy():
    patient_id = request.args.get('get_patient_id')
    drug_id = request.args.get('get_drug_id')
    if drug_id != None:
        cursor.execute(f"Delete * from drugallergy where patient_id = ? and drug_id = ?", patient_id, drug_id)
    if request.method == 'POST':
        # Lấy thông tin từ form
        drug_id = request.form['drug_id']
        drug_allergy_description = request.form['drug_allergy_description']

        # Thực thi stored procedure
        cursor.execute("EXEC insertDrugAllergy ?, ?, ?", 
                       (patient_id, drug_id, drug_allergy_description))
    return render_template('adddrugallergy.html')

@app.route('/addcontradication', methods = ['POST','GET'])
def addcontradication():
    patient_id = request.args.get('get_patient_id')
    if request.method == 'POST':
        # Lấy thông tin từ form
        drug_id = request.form['drug_id']
        drug_allergy_description = request.form['drug_allergy_description']

        # Thực thi stored procedure
        cursor.execute("EXEC insertContradiction ?, ?, ?", 
                       (patient_id, drug_id, drug_allergy_description))
    return render_template('addcontradication.html')

@app.route('/updatedrugallergy', methods = ['POST','GET'])
def updatedrugallergy():
    patient_id = request.args.get('get_patient_id')
    drug_id = request.args.get('get_drug_id')
    if request.method == 'POST':
        # Lấy thông tin từ form
        drug_allergy_description = request.form['drug_allergy_description']

        # Thực thi stored procedure
        cursor.execute("EXEC insertDrugAllergy ?, ?, ?", 
                       (patient_id, drug_id, drug_allergy_description))
    return render_template('updatedrugallergy.html')

@app.route('/updatecontradication', methods = ['POST','GET'])
def updatecontradication():
    patient_id = request.args.get('get_patient_id')
    drug_id = request.args.get('get_drug_id')
    if request.method == 'POST':
        # Lấy thông tin từ form
        drug_allergy_description = request.form['drug_allergy_description']

        # Thực thi stored procedure
        cursor.execute("EXEC insertContradiction ?, ?, ?", 
                       (patient_id, drug_id, drug_allergy_description))
    return render_template('updatecontradication.html')

@app.route('/invoice', methods = ['POST','GET'])
def invoice():
    patient_id = request.args.get('get_patient_id')
    cursor.execute('''
        SELECT *
        FROM TreatmentPlan
        JOIN PaymentRecord ON TreatmentPlan.treatment_plan_id = PaymentRecord.treatment_plan_id
        WHERE TreatmentPlan.patient_id = ?
    ''', patient_id)
    invoices = cursor.fetchall()
    return render_template('invoice.html', invoices=invoices)

@app.route('/invoicedetail', methods = ['POST','GET'])
def invoicedetail():
    payment_id = request.args.get('get_payment_id')
    cursor.execute('''SELECT *
        FROM PaymentRecord
        JOIN TreatmentPlan ON TreatmentPlan.treatment_plan_id = PaymentRecord.treatment_plan_id
        JOIN Patient ON Patient.patient_id = TreatmentPlan.patient_id
        JOIN PaymentMethod ON PaymentMethod.payment_method_id = PaymentRecord.payment_method_id
        JOIN Treatment ON Treatment.treatment_id = TreatmentPlan.treatment_id
        WHERE PaymentRecord.payment_id = ?
    ''', payment_id)
    payinfo = cursor.fetchone()
    cursor.execute('''SELECT *
        FROM PaymentRecord
        JOIN TreatmentPlan ON TreatmentPlan.treatment_plan_id = PaymentRecord.treatment_plan_id
        JOIN ToothSelection ON ToothSelection.treatment_plan_id = TreatmentPlan.treatment_plan_id
        JOIN ToothSurface ON ToothSurface.tooth_surface_code = ToothSelection.tooth_surface_code
        JOIN ToothPosition ON ToothPosition.tooth_position_id = ToothSelection.tooth_position_id
        WHERE PaymentRecord.payment_id = ?
    ''', payment_id)
    treatment = cursor.fetchall()
    return render_template('invoicedetail.html', payinfo=payinfo, treatment=treatment)

@app.route('/addinvoice', methods = ['POST','GET'])
def addinvoice():
    if request.method == 'POST':
        # Lấy thông tin từ form
        paid_time = request.form['paid_time']
        paid_money = request.form['paid_money']
        payment_note = request.form['payment_note']
        payment_method_id = request.form['payment_method_id']
        treatment_plan_id = request.form['treatment_plan_id']

        # Thực thi stored procedure
        cursor.execute("EXEC InsertPaymentRecord ?, ?, ?, ?, ?", 
                       (paid_time, paid_money, payment_note, 
                        payment_method_id, treatment_plan_id))
    return render_template('addinvoice.html')

@app.route('/drug', methods = ['POST','GET'])
def drug():
    drug_id = request.args.get('get_drug_id')
    
    if(drug_id != None):
        cursor.execute(f"EXEC deleteDrug ?", drug_id)
    cursor.execute('SELECT * FROM Drug')
    drugs = cursor.fetchall()
    return render_template('drug.html', drugs=drugs)

@app.route('/adddrug', methods = ['POST','GET'])
def adddrug():
    if request.method == 'POST':
        medicine_name = request.form.get('medicineName')
        stock = request.form.get('stock')
        price = request.form.get('price')
        expiry_date = request.form.get('expiryDate')
        contraindications = request.form.get('contraindications')
        cursor.execute(f"EXEC insertDrug ?, ?, ?, ?, ?", medicine_name, contraindications, expiry_date, price, stock)
    return render_template('adddrug.html')

@app.route('/updatedrug', methods = ['POST','GET'])
def updatedrug():
    drug_id = request.args.get('get_drug_id')
    if request.method == 'POST':
        medicine_name = request.form.get('medicineName')
        stock = request.form.get('stock')
        price = request.form.get('price')
        expiry_date = request.form.get('expiryDate')
        contraindications = request.form.get('contraindications')
        cursor.execute(f"EXEC updateDrug ?, ?, ?, ?, ?, ?",drug_id, medicine_name, contraindications, expiry_date, price, stock)
    return render_template('updatedrug.html')

@app.route('/prescription', methods = ['POST','GET'])
def prescription():
    treatment_plan_id = request.args.get('get_treatment_plan_id')
    cursor.execute('SELECT * FROM Prescription where treatment_plan_id =?', treatment_plan_id)
    prescription = cursor.fetchall()
    return render_template('prescription.html', prescription=prescription)

@app.route('/addprescription', methods = ['POST','GET'])
def addprescription():
    treatment_plan_id = request.args.get('get_treatment_plan_id')
    if request.method == 'POST':
        # Lấy thông tin từ form
        drug_id = request.form['drug_id']
        drug_quantity = request.form['drug_quantity']

        # Thực thi stored procedure
        cursor.execute("EXEC AddPrescription ?, ?, ?", 
                       (treatment_plan_id, drug_id, drug_quantity))
    return render_template('addprescription.html')

@app.route('/updateprescription', methods = ['POST','GET'])
def updateprescription():
    drug_id = request.args.get('get_drug_id')
    if request.method == 'POST':
        medicine_name = request.form.get('medicineName')
        stock = request.form.get('stock')
        price = request.form.get('price')
        expiry_date = request.form.get('expiryDate')
        contraindications = request.form.get('contraindications')
        cursor.execute(f"EXEC updateDrug ?, ?, ?, ?, ?, ?",drug_id, medicine_name, contraindications, expiry_date, price, stock)
    return render_template('updateprescription.html')

@app.route('/appointment', methods = ['POST','GET'])
def appointment():
    date = request.form.get('date')
    time = request.form.get('time')
    cursor.execute('''SELECT * FROM Appointment Join Employee on dentist_id = employee_id''')
    appointments = cursor.fetchall()
    return render_template('appointment.html', appointments = appointments)


@app.route('/selectAppointment', methods = (['POST', 'GET']))
def selectAppointment():
    # if request.method == 'POST':
    #     date = request.form.get('date')
    #     time = request.form.get('time')
    #     cursor.execute('''SELECT *
    #     FROM Appointment
    #     WHERE appointment_date = ? and appointment_time = ?
    #     ''', date, time)
    return render_template('selectAppointment.html')


# @app.route('/appointment', methods = (['POST', 'GET']))
# def appointment():
#     if request.method == 'POST':
#         date = request.form.get('date')
#         time = request.form.get('time')
#         cursor.execute('''SELECT *
#         FROM Appointment Join Employee on dentist_id = employee_id
#         WHERE appointment_date = ? and appointment_time = ?
#         ''', date, time)
#         appointments = cursor.fetchall()
#     return render_template('createAppointment.html', appointments = appointments) 


# @app.route('/appointmentinfo', methods = ['POST','GET'])
# def appointmentinfo():
#     return render_template('thongtincuochen.html')