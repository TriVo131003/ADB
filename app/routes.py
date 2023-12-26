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
    if not session.get("user_id"):
        # if not there in the session then redirect to the login page
        return redirect("/login")
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
    return render_template('addpatient.html')

@app.route('/updatepatient', methods = ['POST','GET'])
def updatepatient():
    patient_id = request.args.get('get_patient_id')
    print("Cập nhật",patient_id)
    return render_template('updatepatient.html')

@app.route('/patientrecord', methods = ['POST','GET'])
def patientrecord():
    patient_id = request.args.get('get_patient_id')
    cursor.execute('SELECT * FROM Patient where patient_id = ?', patient_id)
    patient = cursor.fetchone()
    return render_template('patientrecord.html', patient = patient)

@app.route('/treatmentplan', methods = ['POST','GET'])
def treatmentplan():
    return render_template('treatmentplan.html')

@app.route('/treatmentplanlist', methods = ['POST','GET'])
def treatmentplanlist():
    return render_template('treatmentplanlist.html')

@app.route('/allergycontracdication', methods = ['POST','GET'])
def allergycontracdication():
    patient_id = request.args.get('get_patient_id')
    cursor.execute('SELECT * FROM DrugAllergy where patient_id = ?', patient_id)
    allergy = cursor.fetchall()
    cursor.execute('SELECT * FROM Contradication where patient_id = ?', patient_id)
    contradication = cursor.fetchall()
    return render_template('allergycontracdication.html', allergy=allergy, contradication=contradication)

@app.route('/invoice', methods = ['POST','GET'])
def invoice():
    return render_template('invoice.html')

@app.route('/drug', methods = ['POST','GET'])
def drug():
    cursor.execute('SELECT * FROM Drug')
    drugs = cursor.fetchall()

    return render_template('drug.html', drugs=drugs)

@app.route('/adddrug', methods = ['POST','GET'])
def adddrug():
    return render_template('adddrug.html')

@app.route('/updatedrug', methods = ['POST','GET'])
def updatedrug():
    drug_id = request.args.get('get_drug_id')
    print("Updating on this",drug_id)
    return render_template('updatedrug.html')

@app.route('/appointment', methods = ['POST','GET'])
def appointment():
    return render_template('appointment.html')

# @app.route('/appointmentinfo', methods = ['POST','GET'])
# def appointmentinfo():
#     return render_template('thongtincuochen.html')