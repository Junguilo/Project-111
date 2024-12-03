from flask import Flask, url_for, redirect, jsonify, request, render_template # Create our server, as well as sending/reading JSON
import sqlite3 
#Using sqlite3 is a problem if we were to have more than 100 users use it at the same time
#If we want to have a better system flask_alchemy is leagues better, but sqlite3 is familiar

app = Flask(__name__)
app.config['SECRET_KEY'] = 'super_secret_key'
db = database = r"Checkpoint2-dbase.sqlite"

## db Functions
def openConnection(_dbFile):
    print("++++++++++++++++++++++++++++++++++")
    print("Open database: ", _dbFile)

    conn = None
    try:
        conn = sqlite3.connect(_dbFile)
        print("success")
    except Error as e:
        print(e)

    print("++++++++++++++++++++++++++++++++++")

    return conn


def closeConnection(_conn, _dbFile):
    print("++++++++++++++++++++++++++++++++++")
    print("Close database: ", _dbFile)

    try:
        _conn.close()
        print("success")
    except Error as e:
        print(e)

    print("++++++++++++++++++++++++++++++++++")

## Flask Functions
@app.route('/')
def index():
    conn = openConnection(db)
    
    sql = conn.execute('''
            SELECT *
            FROM ExerciseHabit
    ''').fetchall()
    
    conn.close()

    return render_template('index.html', posts = sql)

@app.route('/create', methods=('GET', 'POST'))
def create():

    return render_template('create.html')

if __name__ == "__main__":
    app.run(debug=True)
