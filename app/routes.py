from flask import Flask, render_template, redirect, request
from database import *
app = Flask(__name__)

@app.route('/login', methods = ['POST','GET'])
def login():
    print('get started')
    return render_template('login.html')

@app.route('/signup', methods = ['POST','GET'])
def signup():
    print('get started')
    return render_template('signup.html')

# @app.route('/appointmentinfo', methods = ['POST','GET'])
# def appointmentinfo():
#     return render_template('thongtincuochen.html')