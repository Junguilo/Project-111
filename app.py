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

#redirects to the create page
@app.route('/create')
def create():
    return render_template('create.html')

#Only works if the user key is in our db
@app.route('/add_habit', methods=['GET', 'POST'])
def add_habit():
    if request.method == 'POST':
        hm_userkey = request.form['hm_userkey']
        hm_startdate = request.form['hm_startdate']
        hm_enddate = request.form['hm_enddate']
        hm_nonseq = request.form.get('hm_nonseq') == 'on' 
        hm_recurring = request.form.get('hm_recurring') == 'on'  
        hm_percentcompleted = request.form.get('hm_percentcompleted') or None
        
        conn = openConnection(db)

        conn.execute('''
            INSERT INTO HabitManager (
                hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted
            ) VALUES (?, ?, ?, ?, ?, ?)
        ''', (hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted))
        conn.commit()


        conn.close()
    
    return render_template('create.html')


if __name__ == "__main__":
    app.run(debug=True)
