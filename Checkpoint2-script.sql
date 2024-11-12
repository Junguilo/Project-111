-- CREATE TABLE User (
--     u_userkey DECIMAL(10, 0) NOT NULL PRIMARY KEY,
--     u_name VARCHAR(152) NOT NULL,
--     u_email VARCHAR(152) NOT NULL,
--     u_password VARCHAR(152) NOT NULL
-- );

-- CREATE TABLE MediaWatched (
--     mw_mediaid INTEGER PRIMARY KEY,  
--     mw_userkey INTEGER NOT NULL,
--     mw_mediatype VARCHAR(252) NOT NULL,
--     mw_title VARCHAR(252) NOT NULL,
--     mw_complete BOOLEAN NOT NULL DEFAULT FALSE,
--     FOREIGN KEY (mw_userkey) REFERENCES User(u_userkey)
-- );

-- CREATE TABLE HabitManager (
--     hm_habitid DECIMAL(10, 0) NOT NULL PRIMARY KEY,
--     hm_userkey DECIMAL(10, 0) NOT NULL, 
--     hm_startdate DATE NOT NULL,
--     hm_enddate DATE NOT NULL,
--     hm_nonseq BOOLEAN NOT NULL DEFAULT FALSE,
--     hm_recurring BOOLEAN NOT NULL DEFAULT FALSE,
--     hm_percentcompleted DECIMAL(10, 0) DEFAULT NULL
-- );

-- CREATE TABLE HabitLog (
--     hl_logid DECIMAL(10, 0) NOT NULL PRIMARY KEY,
--     hl_habitid DECIMAL(10, 0) NOT NULL,
--     hl_log_date DATE NOT NULL,
--     hl_status BOOLEAN NOT NULL DEFAULT FALSE
-- );

-- CREATE TABLE StudyHabit (
--     sh_shhabitid DECIMAL(10, 0) NOT NULL PRIMARY KEY,
--     sh_title VARCHAR(252) NOT NULL,
--     sh_habitid DECIMAL(10, 0) NOT NULL,
--     sh_subject VARCHAR(252) NOT NULL, 
--     sh_durationmin VARCHAR(252) NOT NULL
-- );

-- CREATE TABLE ExerciseHabit (
--     eh_ehhabitid DECIMAL(10, 0) NOT NULL PRIMARY KEY,
--     eh_habitid DECIMAL(10, 0) NOT NULL,
--     eh_title VARCHAR(252) NOT NULL,
--     eh_activitytype VARCHAR(252) NOT NULL,
--     eh_durationmin VARCHAR(252) NOT NULL
-- );


--User wants to update his email (UPDATE)
UPDATE User
SET u_email = "TestEmail@gmail.com"
WHERE 
    u_userkey = 20;

-- User wants to update his password (UPDATE)
UPDATE User
SET u_password = "Password123"
WHERE 
    u_userkey = 20;

--User wants to look back on all his studyTasks
--that have a duration higher than 60 minutes (SELECT)
SELECT sh_subject, sh_durationmin, 
FROM User, HabitManager, StudyHabit
WHERE
    u_userkey = hm_userkey AND
    hm_habitid = sh_habitid AND
    sh_durationmin > 60;

--User wants to make a new Habit for study(CREATE) (seq habit)

INSERT INTO HabitManager
VALUES(31, 1, "2024-12-08", "2024-12-14", "FALSE", "FALSE", 0);
INSERT INTO StudyHabit
VALUES(16, "US History" , 16, "History", 60);
UPDATE StudyHabit
SET sh_habitid = 31
WHERE sh_shhabitid = 16;

--User wants to make a new Habit for exercise (CREATE) (seq habit)
INSERT INTO HabitManager
VALUES(32, 1, "2024-12-20", "2024-12-27", "FALSE", "TRUE", 0);
INSERT INTO StudyHabit
VALUES(16, 32, "US History" , 16, "History", 60);

--For habit ID that has been finalized (end date has passed)
-- see how the user did for the a specific task (RATIO OF status/total logs SELECT)
WITH temp_user AS (
    SELECT 1 AS user_ID --1 WILL BE QUESTION MARK INSTEAD
),
temp_habit AS (
    SELECT 1 AS habit_key --1 WILL BE QUESTION MARK INSTEAD
)
SELECT
    (
        SELECT COUNT()
        FROM User, HabitManager, HabitLog, temp_user, temp_habit
        WHERE temp_user.user_ID = User.u_userkey
        AND User.u_userkey = HabitManager.hm_userkey
        AND HabitManager.hm_habitid = temp_habit.habit_key
        AND HabitManager.hm_habitid = HabitLog.hl_habitid
        AND HabitLog.hl_status = 'TRUE'
    ) 100.0 / 
    (
        SELECT COUNT(*)
        FROM User, HabitManager, HabitLog, temp_user, temp_habit
        WHERE temp_user.user_ID = User.u_userkey
        AND HabitManager.hm_habitid = temp_habit.habit_key
        AND User.u_userkey = HabitManager.hm_userkey
        AND HabitManager.hm_habitid = HabitLog.hl_habitid
    ) AS RATIO;

--User wants to see the data of specific subjects
-- that they studied after a certain date. (SELECT)
SELECT sh_subject
FROM User, HabitManager, StudyHabit
WHERE 
    u_userkey = hm_userkey AND
    hm_habitid = sh_habitid AND
    hm_enddate < CURRENT_DATE;
    --hm_enddate < ?; -- can be a date the user chooses. 

--Update non sequential to change date of habit must be done (UPDATE)
UPDATE HabitLog
SET hl_log_date = "2023-03-16"
WHERE hl_logid = 10;

-- UPDATE HabitLog
-- SET hl_log_date = ?
-- WHERE hl_logid = ?;


--pull up users movie list
--1)
SELECT mw_title, MediaWatched.mw_complete
FROM MediaWatched, User
WHERE MediaWatched.mw_userkey = User.u_userkey AND
    User.u_userkey = 1;

--pull up study habit 

SELECT *
FROM User, HabitManager, HabitLog, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitLog.hl_habitid = HabitManager.hm_habitid
AND HabitManager.hm_habitid = StudyHabit.sh_habitid;

--pull up exercise

SELECT *
FROM User, HabitManager, HabitLog, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitLog.hl_habitid = HabitManager.hm_habitid
AND HabitManager.hm_habitid = ExerciseHabit.eh_ehhabitid;

--User wants to add add a movie/anime thing to watch so the SQL makes a an ID for the new thing and sets the bool to false(user hasn't watched it yet) (CREATE)    (Needs python)
INSERT INTO MediaWatched (mw_userkey, mw_mediatype, mw_title) VALUES (1, "Documentary", "Jeffrey Dahmer Files");
UPDATE MediaWatched
SET mw_complete = "TRUE"
WHERE 
    mw_title = "Jeffrey Dahmer Files";
--INSERT INTO MediaWatched (mw_userkey, mw_mediatype, mw_title) VALUES (?, ?, ?);


--User wants to set some movie to watched (UPDATE) bool is set to true in db

UPDATE MediaWatched
SET mw_complete = "TRUE"
WHERE mw_mediaid = 30;

-- UPDATE MediaWatched
-- SET mw_complete = "TRUE"
-- WHERE mw_mediaid = ?;

--User wants to delete movie ID (DELETE) info about a specific movie is deleted

DELETE FROM MediaWatched
WHERE mw_mediaid = 31;

-- DELETE FROM MediaWatched
-- WHERE mw_mediaid = ?;

--User misclicked on the on set to true wants to set to not seen again (UPDATE) bool set to false again

UPDATE MediaWatched
SET mw_complete = "FALSE"
WHERE mw_mediaid = 30;
--WHERE mw_mediaid = ?;

--User wants to change schedule for non seq task (UPDATE)

UPDATE HabitLog
SET hl_log_date = "2023-03-16"
WHERE hl_logid = 26;--log id we're changing

-- UPDATE HabitLog
-- SET HabitLog.h1_Log_date = ?
-- WHERE HabitLog.hl_logid = ?; --log id we're changing

-- Set log for the day to complete (UPDATE)

UPDATE HabitLog
SET hl_status = 'TRUE'
WHERE hl_logid = 13;
--WHERE HabitLog.hl_logid = ? ;

--User wants to see the habits with durationmins < 60 for borth. (SELECT)

SELECT ExerciseHabit.eh_title AS title, hm_percentcompleted AS percentdone
FROM User, HabitManager, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND ExerciseHabit.eh_habitid = HabitManager.hm_habitid
AND ExerciseHabit.eh_durationmin < 60

UNION ALL

SELECT StudyHabit.sh_title AS title, hm_percentcompleted AS percentdone
FROM User, HabitManager, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND StudyHabit.sh_habitid= HabitManager.hm_habitid
AND StudyHabit.sh_durationmin < 60;

-- pull all user information
SELECT *
FROM User;