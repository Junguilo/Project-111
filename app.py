from flask import Flask, session, url_for, redirect, jsonify, request, render_template # Create our server, as well as sending/reading JSON
import sqlite3 
from datetime import date, datetime, timedelta
#Using sqlite3 is a problem if we were to have more than 100 users use it at the same time
#If we want to have a better system flask_alchemy is leagues better, but sqlite3 is familiar

app = Flask(__name__)
app.config['SECRET_KEY'] = 'super_secret_key'
db = r"Checkpoint2-dbase.sqlite"
today = date.today()

# User: John Smith
# Pass: password1
# to test out the website 

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


#Function required to get the percentage of every single week
def getFirstDayofWeek(date):
    dateObj = datetime.strptime(date, '%Y-%m-%d')
    firstDay = dateObj - timedelta(days=dateObj.weekday())
    return firstDay.date()

## Flask Functions
@app.route('/')
def index():
    conn = openConnection(db)
    studyHabits = None
    exerciseHabits = None
    loggedStudy = None
    loggedExercise = None
    date = today.isoformat()
    week = []
    percCompletedDays = []

    #print(getFirstDayofWeek(date) + timedelta(days=1))
    #Check if we are logged in 
    if 'username' in session:
        date = session['date']
        id = session['userID']
        #print(date)
        #GRAB THE PERCENT OF COMPLETED TASKS -- FOR THAT DAY --
        #Grab the week
        for i in range(7):
            #print(getFirstDayofWeek(date) + timedelta(days=i))
            week.append(getFirstDayofWeek(date) + timedelta(days=i))

        #UPDATE THE WEEK BASED ON THE TASKS COMPLETED
        #--FOR THAT DAY --
        for i in week:
            sql = conn.execute('''
                WITH temp_user AS (
                    SELECT ? AS user_ID --1 WILL BE QUESTION MARK INSTEAD
                )SELECT
                    (
                        SELECT COUNT(*)
                        FROM User, HabitManager, HabitLog, temp_user
                        WHERE temp_user.user_ID = User.u_userkey
                        AND User.u_userkey = HabitManager.hm_userkey
                        AND HabitManager.hm_habitid = HabitLog.hl_habitid
                        AND HabitLog.hl_log_date = ?
                        AND HabitLog.hl_status = 'TRUE'
                    ) *100.0 / 
                    (
                        SELECT COUNT(*)
                        FROM User, HabitManager, HabitLog, temp_user
                        WHERE temp_user.user_ID = User.u_userkey
                        AND User.u_userkey = HabitManager.hm_userkey
                        AND HabitLog.hl_log_date = ?
                        AND HabitManager.hm_habitid = HabitLog.hl_habitid
                    ) AS RATIO
                    LIMIT 1
            ''', (id, str(i), str(i) ) ).fetchall()
            percCompletedDays.append(sql[0][0])

        #Grab all habitids, ready to update 
        habitIDs = conn.execute('''
                SELECT hm_habitid
                FROM HabitManager
        ''').fetchall()
        #UPDATE THE RATIO OF ALLLL HABITS IN THEHABIT LOG ASSOCIATED WITH THEHABIT
        for i in habitIDs:
            conn.execute('''
                UPDATE HabitManager
                SET hm_percentcompleted = ROUND((WITH temp_user AS (
                                                SELECT ? AS user_ID --1 WILL BE QUESTION MARK INSTEAD
                                            ),
                                            temp_habit AS (
                                                SELECT ? AS habit_key --1 WILL BE QUESTION MARK INSTEAD
                                            )
                                            SELECT
                                                (
                                                    SELECT COUNT(*)
                                                    FROM User, HabitManager, HabitLog, temp_user, temp_habit
                                                    WHERE temp_user.user_ID = User.u_userkey
                                                    AND User.u_userkey = HabitManager.hm_userkey
                                                    AND HabitManager.hm_habitid = temp_habit.habit_key
                                                    AND HabitManager.hm_habitid = HabitLog.hl_habitid
                                                    AND HabitLog.hl_status = 'TRUE'
                                                ) *100.0 / 
                                                (
                                                    SELECT COUNT(*)
                                                    FROM User, HabitManager, HabitLog, temp_user, temp_habit
                                                    WHERE temp_user.user_ID = User.u_userkey
                                                    AND HabitManager.hm_habitid = temp_habit.habit_key
                                                    AND User.u_userkey = HabitManager.hm_userkey
                                                    AND HabitManager.hm_habitid = HabitLog.hl_habitid
                                                ) AS RATIO), 2)
                WHERE 
                    hm_habitid = ?
            ''', ( id, i[0], i[0]))

        conn.commit()



        #Grab the SINGULAR habits that the user has created 
        studyHabits = conn.execute('''
            SELECT hm_habitid, sh_title, sh_description, sh_subject, hm_startdate, hm_enddate, sh_durationmin, hm_percentCompleted
            FROM User, HabitManager, StudyHabit
            WHERE User.u_userkey = HabitManager.hm_userkey 
            AND HabitManager.hm_habitid = StudyHabit.sh_habitid
            AND hm_userkey = ?
            AND ? >= hm_startdate
            AND ? <= hm_enddate
        ''', (id, str(date), str(date))).fetchall()

        exerciseHabits = conn.execute('''
            SELECT hm_habitid, eh_title, eh_description, eh_activitytype, hm_startdate, hm_enddate, eh_durationmin, hm_percentCompleted
            FROM User, HabitManager, ExerciseHabit
            WHERE User.u_userkey = HabitManager.hm_userkey 
            AND HabitManager.hm_habitid = ExerciseHabit.eh_habitid
            AND hm_userkey = ?
            AND ? >= hm_startdate
            AND ? <= hm_enddate
        ''', (id, str(date), str(date))).fetchall()

        #Grab both exercise habits & Study LOGGED habits that the user has done
        loggedStudy = conn.execute('''
                SELECT sh_title, sh_subject, hm_startdate, hm_enddate,hl_log_date, sh_durationmin, hl_status, hm_percentCompleted
                FROM User, HabitManager, HabitLog, StudyHabit
                WHERE User.u_userkey = HabitManager.hm_userkey 
                AND HabitLog.hl_habitid = HabitManager.hm_habitid
                AND HabitManager.hm_habitid = StudyHabit.sh_habitid
                AND hm_userkey = ?
                AND hl_log_date = ?
            ''', (id, str(date))).fetchall()

        loggedExercise = conn.execute('''
            SELECT eh_title, eh_activitytype, hm_startdate, hm_enddate,hl_log_date, eh_durationmin, hl_status, hm_percentCompleted
            FROM User, HabitManager, HabitLog, ExerciseHabit
            WHERE User.u_userkey = HabitManager.hm_userkey 
            AND HabitLog.hl_habitid = HabitManager.hm_habitid
            AND HabitManager.hm_habitid = ExerciseHabit.eh_habitid
            AND hm_userkey = ?
            AND hl_log_date = ?
            ''', (id, str(date))).fetchall()
    conn.close()
    # print(study)
    # print(exercise)
    

    return render_template('index.html', date = date, studyHabits = studyHabits, exerciseHabits = exerciseHabits ,studyLoggedHabits = loggedStudy, exerciseLoggedHabits = loggedExercise, percCompletedDays = percCompletedDays)

@app.route('/editHabit', methods=['GET', 'POST'])
def editHabit():
    print("pressed Edit")
    return redirect(url_for('index'))


@app.route('/deleteHabit', methods=['GET', 'POST'])
def deleteHabit():
    checkedStudy = request.form.getlist('studyHabits')
    checkedExercise = request.form.getlist('exerciseHabits')
    print(checkedExercise)
    print(checkedStudy)
    print("pressed Delete")
    return redirect(url_for('index'))

#We NEED a date changer in order to test out needed functions
@app.route('/changeDate', methods=['GET', 'POST'])
def changeDate():
    if request.method == 'POST':
        date = request.form['date']
        if date == "":
            session['date'] = today.isoformat()
            #print(today.isoformat())
        else:
            session['date'] = date
        #print(date)        
        #print(session['date'])
        return redirect(url_for('index'))

#we can log specific habits that we can click the checkmark
#This grabs specific habitIDs to log into the specific date
@app.route('/logHabit', methods=['GET', 'POST'])
def logHabit():
    if request.method == 'POST':
        checkedStudy = request.form.getlist('studyHabits')
        checkedExercise = request.form.getlist('exerciseHabits')
        #print(checkedExercise)
        #print(checkedStudy)
        checkedAll = checkedExercise + checkedStudy
        falseHabits = []
        trueHabits = []
    
        conn = openConnection(db)
        #Check if theres a habitlog already with our specific date & hmid
        #We want to flipflop between True and False
        for i in checkedAll:
            sql = conn.execute('''
                    SELECT *
                    FROM HabitLog
                    WHERE
                        hl_habitid = ? AND
                        hl_log_date = ? AND
                        hl_status = "FALSE"
            ''', (i, str(session['date'])))
            res = sql.fetchone()
            #print(res)
            if res != None:
                falseHabits.append(str(res[1]))
        #Now that we got the False Habits, Turn them to True
        #Now we try to get the True Habits
        for i in checkedAll:
            sql = conn.execute('''
                    SELECT *
                    FROM HabitLog
                    WHERE
                        hl_habitid = ? AND
                        hl_log_date = ? AND
                        hl_status = "TRUE"
            ''', (i, str(session['date'])))
            res = sql.fetchone()
            #print(res)
            if res != None:
                trueHabits.append(str(res[1]))

        #print("FalseHabits: ", falseHabits)
        #print("TrueHabits: ", trueHabits)

        #change shit to TRUE
        for i in falseHabits:
            conn.execute('''
                UPDATE HabitLog
                SET hl_status = "TRUE"
                WHERE 
                    hl_habitid = ? AND
                    hl_log_date = ?
            ''', (i, session['date']))
        
        for i in trueHabits:
            conn.execute('''
                UPDATE HabitLog
                SET hl_status = "FALSE"
                WHERE 
                    hl_habitid = ? AND
                    hl_log_date = ?
            ''', (i, session['date']))

        conn.commit()
        conn.close()
        #print("Study: ", checkedStudy)
        #print("Exercise:", checkedExercise)
        return redirect(url_for('index'))


#redirects to the create habit page
@app.route('/create')
def create():
    return render_template('create.html')

#Only works if the user key is in our db
#We gotta add like two different functions of the same function cause idk how to grab specific items
@app.route('/add_exercisehabit', methods=['GET', 'POST'])
def add_exercisehabit():
    if request.method == 'POST' and session['username']:
        #get habit manager items
        hm_userkey = session['userID']
        hm_startdate = request.form['hm_exercise_startdate']
        hm_enddate = request.form['hm_exercise_enddate']
        hm_nonseq = request.form.get('hm_exercise_nonseq') == 'on' 
        hm_recurring = request.form.get('hm_exercise_recurring') == 'on'  
        hm_percentcompleted = 0

        #get exercisehabit items
        title = request.form['eh_title']
        description = request.form['eh_description']
        activity = request.form['eh_activitytype']
        duration = request.form['eh_durationmin']
        
        #hardcode the shit out of those booleans
        if hm_nonseq == '0':
            hm_nonseq = 'FALSE'
        else:
            hm_nonseq = 'TRUE'

        if hm_recurring == '0':
            hm_recurring = 'FALSE'
        else:
            hm_recurring = 'TRUE'

        conn = openConnection(db)

        #input into the habitManager
        conn.execute('''
            INSERT INTO HabitManager (
                hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted
            ) VALUES (?, ?, ?, ?, ?, ?)
        ''', (hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted))
        conn.commit()

        #Grabbing the HM key in order to connect these two together
        #taking the most recent activity with the information we have 
        c = conn.cursor()
        c.execute('''
            SELECT *
            FROM HabitManager
            ORDER BY hm_habitid DESC
            LIMIT 1
        ''')
        recentHabit = c.fetchall()
        hmID = recentHabit[0][0]

        #input into the exercisehabit
        conn.execute('''
            INSERT INTO ExerciseHabit (
                      eh_habitid, eh_title, eh_activitytype, eh_durationmin, eh_description   
            ) VALUES (?, ?, ?, ?, ?)
        ''', (hmID, title, activity, duration, description))


        #Will insert 7 exercisehabits into the habitlog
        startDate = datetime.strptime(hm_startdate, '%Y-%m-%d')
        endDate = datetime.strptime(hm_enddate, '%Y-%m-%d')

        currentDate = startDate
        print(currentDate.date())
        while currentDate <= endDate:
            conn.execute('''
                INSERT INTO HabitLog( hl_habitid, hl_log_date, hl_status)
                         VALUES (?, ?, ?)
            ''', (hmID, currentDate.date(), "FALSE"))
            #To the next day
            currentDate += timedelta(days=1)

        conn.commit()

        
        conn.close()
    
    return render_template('create.html')

@app.route('/add_studyhabit', methods=['GET', 'POST'])
def add_studyhabit():
    if request.method == 'POST' and session['username']:
        hm_userkey = session['userID']
        hm_startdate = request.form['hm_study_startdate']
        hm_enddate = request.form['hm_study_enddate']
        hm_nonseq = request.form.get('hm_study_nonseq') == 'on' 
        hm_recurring = request.form.get('hm_study_recurring') == 'on'  
        hm_percentcompleted = 0

        #Get studyhabit items
        title = request.form['sh_title']
        description = request.form['sh_description']
        subject = request.form['sh_subject']
        duration = request.form['sh_durationmin']

        #hardcode the shit out of those booleans
        if hm_nonseq == '0':
            hm_nonseq = 'FALSE'
        else:
            hm_nonseq = 'TRUE'

        if hm_recurring == '0':
            hm_recurring = 'FALSE'
        else:
            hm_recurring = 'TRUE'

        conn = openConnection(db)

        #input into the habitManager
        conn.execute('''
            INSERT INTO HabitManager (
                hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted
            ) VALUES (?, ?, ?, ?, ?, ?)
        ''', (hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted))
        conn.commit()

        #Grabbing the HM key in order to connect these two together
        #taking the most recent activity with the information we have 
        c = conn.cursor()
        c.execute('''
            SELECT *
            FROM HabitManager
            ORDER BY hm_habitid DESC
            LIMIT 1
        ''')
        recentHabit = c.fetchall()
        hmID = recentHabit[0][0]

        #input into the exercisehabit
        conn.execute('''
            INSERT INTO StudyHabit (
                      sh_title, sh_habitid, sh_subject, sh_durationmin, sh_description   
            ) VALUES (?, ?, ?, ?, ?)
        ''', (title, hmID, subject, duration, description))



        #Will insert 7 exercisehabits into the habitlog
        startDate = datetime.strptime(hm_startdate, '%Y-%m-%d')
        endDate = datetime.strptime(hm_enddate, '%Y-%m-%d')

        currentDate = startDate
        print(currentDate.date())
        while currentDate <= endDate:
            conn.execute('''
                INSERT INTO HabitLog( hl_habitid, hl_log_date, hl_status)
                         VALUES (?, ?, ?)
            ''', (hmID, currentDate.date(), "FALSE"))
            #To the next day
            currentDate += timedelta(days=1)


        conn.commit()
        conn.close()
    
    return render_template('create.html')

# User Profile
#listing their information, 
#movies they like, name, email, etc, can add more later
@app.route('/profile', methods=['GET', 'POST'])
def profile():
    user = None
    movies = None
    if session['username']:
        print(session['username'])
        user = session['username']
        id = session['userID']

        conn = openConnection(db)
        c = conn.cursor()
        c.execute('''
            SELECT * 
            FROM User
            WHERE 
                u_userkey = ?
        ''', (id, )) #if you're using only 1 param, add a comma to the end for some reason
        user = c.fetchall()

        c.execute('''
                 SELECT mw_title, MediaWatched.mw_complete
                 FROM MediaWatched, User
                 WHERE MediaWatched.mw_userkey = User.u_userkey AND
                     User.u_userkey = ?
        ''', (id, ))

        movies = c.fetchall()


        conn.close()

        #print(user)
        return render_template('profile.html', user=user, movies = movies)
    else:
        return render_template('profile.html', user = None, movies = None)

## User Registration & Login
@app.route('/register', methods=['GET', 'POST'])
def register():
    message = None
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']

        conn = openConnection(db)
        
        ##used to check if theres an existing user
        user = conn.execute('''
                    SELECT *
                    FROM User
                    WHERE
                        u_name = ?
                    ''', (username,)).fetchall()
        
        if user == []: #If we can't find any users with the same name, add to db
            conn.execute('''
                INSERT INTO User(u_name, u_email, u_password)
                            VALUES (?, ?, ?)
            ''', (username, email, password))
            conn.commit()
            message = "Successfully Registered"
        else:
            message = "Username already exists!!"

        conn.close()
        
        return render_template('register.html', message = message)
    return render_template('register.html')
    
@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None

    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        conn = openConnection(db)
        c = conn.cursor()
        c.execute('''
            SELECT * 
            FROM User
            WHERE 
                u_name = ? AND 
                u_password = ?
        ''', (username, password))
        user = c.fetchone()


        conn.close()
        
        print(user)
        if user:
            session['username'] = username
            session['userID'] = user[0]
            session['date'] = today.isoformat() #HARD CODED WAY OF STORING THE DATE IN THE SESSION
            
            print('User logged in:', session['username'], 'User ID:', session['userID'])
            return redirect(url_for('index'))
        else:
            error = 'Invalid user or password'
    return render_template('login.html', error = error)

@app.route('/logout')
def logout():
    session.pop('username', None)
    session.pop('userID', None)
    #reset date to current date
    session['date'] = today.isoformat()
    return redirect(url_for('index'))



if __name__ == "__main__":
    app.run(debug=True)
