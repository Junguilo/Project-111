CREATE TABLE User (
    u_userkey INTEGER PRIMARY KEY,
    u_name VARCHAR(152) NOT NULL,
    u_email VARCHAR(152) NOT NULL,
    u_password VARCHAR(152) NOT NULL
);

CREATE TABLE MediaWatched (
    mw_mediaid INTEGER PRIMARY KEY,  
    mw_userkey INT NOT NULL,
    mw_mediatype VARCHAR(252) NOT NULL,
    mw_title VARCHAR(252) NOT NULL,
    mw_complete BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (mw_userkey) REFERENCES User(u_userkey)
);

DROP TABLE HabitManager;
CREATE TABLE HabitManager (
    hm_habitid INTEGER PRIMARY KEY,
    hm_userkey INT NOT NULL, 
    hm_startdate DATE NOT NULL,
    hm_enddate DATE NOT NULL,
    --hm_nonseq BOOLEAN NOT NULL DEFAULT FALSE,
    --hm_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    hm_percentcompleted DECIMAL(5, 2) DEFAULT NULL,
    FOREIGN KEY (hm_userkey) REFERENCES User(u_userkey)
);

DROP TABLE HabitLog;
CREATE TABLE HabitLog (
    hl_logid INTEGER PRIMARY KEY,
    hl_habitid INT NOT NULL,
    hl_log_date DATE NOT NULL,
    hl_status BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (hl_habitid) REFERENCES HabitManager(hm_habitid)
);

DROP TABLE StudyHabit;
CREATE TABLE StudyHabit (
    sh_shhabitid INTEGER PRIMARY KEY,
    sh_habitid INT NOT NULL,
    sh_title VARCHAR(252) NOT NULL,
    sh_description VARCHAR(252),
    sh_subject VARCHAR(252) NOT NULL, 
    sh_durationmin VARCHAR(252) NOT NULL,
    FOREIGN KEY (sh_habitid) REFERENCES HabitManager(hm_habitid)
);

DROP Table ExerciseHabit;
CREATE TABLE ExerciseHabit (
    eh_ehhabitid INTEGER PRIMARY KEY,
    eh_habitid INT NOT NULL,
    eh_title VARCHAR(252) NOT NULL,
    eh_description VARCHAR(252),
    eh_activitytype VARCHAR(252) NOT NULL,
    eh_durationmin VARCHAR(252) NOT NULL,
    FOREIGN KEY (eh_habitid) REFERENCES HabitManager(hm_habitid)
);

--create descriptions for studyhabit & exercisehabit
ALTER TABLE StudyHabit
ADD sh_description VARCHAR(252);

ALTER TABLE ExerciseHabit
ADD eh_description VARCHAR(252);

ALTER TABLE HabitLog
ALTER COLUMN hl_logid INTEGER PRIMARY KEY;

-- --User wants to update his email (UPDATE)
-- UPDATE User
-- SET u_email = "MaryClark@gmail.com"
-- WHERE 
--     u_userkey = 20;

-- -- User wants to update his password (UPDATE)
-- UPDATE User
-- SET u_password = "Password123"
-- WHERE 
--     u_userkey = 20;

-- --User wants to look back on all his studyTasks
-- --that have a duration higher than 60 minutes (SELECT)
-- SELECT sh_subject, sh_durationmin 
-- FROM User, HabitManager, StudyHabit
-- WHERE
--     u_userkey = hm_userkey AND
--     hm_habitid = sh_habitid AND
--     sh_durationmin > 60;

-- --User wants to make a new Habit for study(CREATE) (seq habit)

-- INSERT INTO HabitManager (hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted)
-- VALUES(1, "2024-12-08", "2024-12-14", "FALSE", "FALSE", 0);
-- INSERT INTO StudyHabit (sh_title, sh_habitid, sh_subject, sh_durationmin)
-- VALUES("US History" , 32, "History", 60);

-- --User wants to make a new Habit for exercise (CREATE) (seq habit)
-- INSERT INTO HabitManager (hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted)
-- VALUES(2, "2024-12-20", "2024-12-27", "FALSE", "TRUE", 0);
-- INSERT INTO ExerciseHabit (eh_habitid, eh_title, eh_activitytype, eh_durationmin)
-- VALUES(33, "Push Day", "Weightlifting", 60);

-- --For habit ID that has been finalized (end date has passed)
-- -- see how the user did for the a specific task (RATIO OF status/total logs SELECT)
WITH temp_user AS (
    SELECT 1 AS user_ID --1 WILL BE QUESTION MARK INSTEAD
),
temp_habit AS (
    SELECT 1 AS habit_key --1 WILL BE QUESTION MARK INSTEAD
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
    ) AS RATIO;


WITH temp_user AS (
    SELECT 1 AS user_ID --1 WILL BE QUESTION MARK INSTEAD
)SELECT
    (
        SELECT COUNT(*)
        FROM User, HabitManager, HabitLog, temp_user
        WHERE temp_user.user_ID = User.u_userkey
        AND User.u_userkey = HabitManager.hm_userkey
        --AND HabitManager.hm_habitid = temp_habit.habit_key
        AND HabitManager.hm_habitid = HabitLog.hl_habitid
        AND HabitLog.hl_log_date = '2024-12-08'
        AND HabitLog.hl_status = 'TRUE'
    ) *100.0 / 
    (
        SELECT COUNT(*)
        FROM User, HabitManager, HabitLog, temp_user
        WHERE temp_user.user_ID = User.u_userkey
        --AND HabitManager.hm_habitid = temp_habit.habit_key
        AND User.u_userkey = HabitManager.hm_userkey
        AND HabitLog.hl_log_date = '2024-12-08'
        AND HabitManager.hm_habitid = HabitLog.hl_habitid
    ) AS RATIO;

-- --User wants to see the data of specific subjects
-- -- that they studied after a certain date. (SELECT)
-- SELECT sh_subject
-- FROM User, HabitManager, StudyHabit
-- WHERE 
--     u_userkey = hm_userkey AND
--     hm_habitid = sh_habitid AND
--     hm_enddate < CURRENT_DATE;
--     --hm_enddate < ?; -- can be a date the user chooses. 

-- --Update non sequential to change date of habit must be done (UPDATE)
-- UPDATE HabitLog
-- SET hl_log_date = "2023-03-16"
-- WHERE hl_logid = 10;

-- -- UPDATE HabitLog
-- -- SET hl_log_date = ?
-- -- WHERE hl_logid = ?;


-- --pull up users movie list
-- --1)
-- SELECT mw_title, MediaWatched.mw_complete
-- FROM MediaWatched, User
-- WHERE MediaWatched.mw_userkey = User.u_userkey AND
--     User.u_userkey = 1;

-- --pull up study habit 

-- SELECT *
-- FROM User, HabitManager, HabitLog, StudyHabit
-- WHERE User.u_userkey = HabitManager.hm_userkey 
-- AND HabitLog.hl_habitid = HabitManager.hm_habitid
-- AND HabitManager.hm_habitid = StudyHabit.sh_habitid;

-- --pull up exercise

-- SELECT *
-- FROM User, HabitManager, HabitLog, ExerciseHabit
-- WHERE User.u_userkey = HabitManager.hm_userkey 
-- AND HabitLog.hl_habitid = HabitManager.hm_habitid
-- AND HabitManager.hm_habitid = ExerciseHabit.eh_ehhabitid;

-- --User wants to add add a movie/anime thing to watch so the SQL makes a an ID for the new thing and sets the bool to false(user hasn't watched it yet) (CREATE)    (Needs python)
-- INSERT INTO MediaWatched (mw_userkey, mw_mediatype, mw_title, mw_complete) 
-- VALUES (1, "Documentary", "Jeffrey Dahmer Files", "TRUE");
-- UPDATE MediaWatched
-- SET mw_complete = "TRUE"
-- WHERE 
--     mw_title = "Jeffrey Dahmer Files";
-- --INSERT INTO MediaWatched (mw_userkey, mw_mediatype, mw_title) VALUES (?, ?, ?);


-- --User wants to set some movie to watched (UPDATE) bool is set to true in db

-- UPDATE MediaWatched
-- SET mw_complete = "TRUE"
-- WHERE mw_mediaid = 30;

-- -- UPDATE MediaWatched
-- -- SET mw_complete = "TRUE"
-- -- WHERE mw_mediaid = ?;

-- --User wants to delete movie ID (DELETE) info about a specific movie is deleted

-- DELETE FROM MediaWatched
-- WHERE mw_mediaid = 31;

-- -- DELETE FROM MediaWatched
-- -- WHERE mw_mediaid = ?;

-- --User misclicked on the on set to true wants to set to not seen again (UPDATE) bool set to false again

-- UPDATE MediaWatched
-- SET mw_complete = "FALSE"
-- WHERE mw_mediaid = 30;
-- --WHERE mw_mediaid = ?;

-- --User wants to change schedule for non seq task (UPDATE)

-- UPDATE HabitLog
-- SET hl_log_date = "2023-03-16"
-- WHERE hl_logid = 26;--log id we're changing

-- -- UPDATE HabitLog
-- -- SET HabitLog.h1_Log_date = ?
-- -- WHERE HabitLog.hl_logid = ?; --log id we're changing

-- -- Set log for the day to complete (UPDATE)

-- UPDATE HabitLog
-- SET hl_status = 'TRUE'
-- WHERE hl_logid = 13;
-- --WHERE HabitLog.hl_logid = ? ;

-- --User wants to see the habits with durationmins < 60 for borth. (SELECT)

-- SELECT ExerciseHabit.eh_title AS title, hm_percentcompleted AS percentdone
-- FROM User, HabitManager, ExerciseHabit
-- WHERE User.u_userkey = HabitManager.hm_userkey 
-- AND ExerciseHabit.eh_habitid = HabitManager.hm_habitid
-- AND ExerciseHabit.eh_durationmin < 60

-- UNION ALL

-- SELECT StudyHabit.sh_title AS title, hm_percentcompleted AS percentdone
-- FROM User, HabitManager, StudyHabit
-- WHERE User.u_userkey = HabitManager.hm_userkey 
-- AND StudyHabit.sh_habitid= HabitManager.hm_habitid
-- AND StudyHabit.sh_durationmin < 60;

-- -- pull all user information
-- SELECT *
-- FROM User;

-- --Sequential SQL for the User, (Non Recurring)
-- -- if non Sequential = false, then add 7 
-- -- if the date is passed, log for it then set it for null
-- -- null, 0 , or 100 
-- --if non recurring, we dont care about null
-- -- if recurring we care about null, 

-- -- REQUERYING SEQ

-- -- PART 1 EXTRACT THE 

-- INSERT INTO HabitManager (
--     hm_userkey,
--     hm_startdate,
--     hm_enddate,
--     hm_nonseq, -- will be true
--     hm_recurring
-- ) 
-- VALUES ( ?,?,?, "TRUE", ?));

-- --part 2 extract habit id created
-- --python code to get the habit id created habit_key = cursor.lastrowid

-- --part 3
-- --there will be a loop in pyton for the amount of days

-- INSERT INTO HabitLog (hl_habitid, hl_log_date) 
--          VALUES (?, ?)