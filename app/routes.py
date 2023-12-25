from flask import Flask, render_template, redirect, request, session
from database import *
app = Flask(__name__)


@app.route('/', methods = ['POST','GET'])
def homepage():
    print('get started')
    return render_template('homepage.html')

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
            cursor.execute('SELECT * FROM Account WHERE username = ?', (username))
            user = cursor.fetchone()
            # print(user.password)
            # print(password)
            if user.password == password:
                # session['username'] = username
                print('success')
                return redirect('/')
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
    return render_template('patientinfo.html')

@app.route('/addpatient', methods = ['POST','GET'])
def addpatient():
    return render_template('addpatient.html')

@app.route('/updatepatient', methods = ['POST','GET'])
def updatepatient():
    return render_template('updatepatient.html')

@app.route('/patientrecord', methods = ['POST','GET'])
def patientrecord():
    return render_template('patientrecord.html')

@app.route('/treatmentplan', methods = ['POST','GET'])
def treatmentplan():
    return render_template('treatmentplan.html')

@app.route('/treatmentplanlist', methods = ['POST','GET'])
def treatmentplanlist():
    return render_template('treatmentplanlist.html')

@app.route('/allergycontracdication', methods = ['POST','GET'])
def allergycontracdication():
    return render_template('allergycontracdication.html')

@app.route('/invoice', methods = ['POST','GET'])
def invoice():
    return render_template('invoice.html')

@app.route('/drug', methods = ['POST','GET'])
def drug():
    return render_template('drug.html')

@app.route('/adddrug', methods = ['POST','GET'])
def adddrug():
    return render_template('adddrug.html')

@app.route('/updatedrug', methods = ['POST','GET'])
def updatedrug():
    return render_template('updatedrug.html')


# @app.route('/appointmentinfo', methods = ['POST','GET'])
# def appointmentinfo():
#     return render_template('thongtincuochen.html')