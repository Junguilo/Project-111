
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


--1.
-- This sql code will grab the ratio of the amount of habits that are completed in a day
-- (True Habits Today)/(All Habits Today)
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
LIMIT 1;

--2.
-- Used to grab only the habit ids so we can populate all the ratios of the next sql query
SELECT hm_habitid
FROM HabitManager;

-- 3.
-- Updates the ratio of every single habit. 
--Will grab every single habitlog that is marked true
-- and divide it by every single habit log with its id. 
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
hm_habitid = ?;

--4. 
-- Grabs every single study habit that the user created for the week.
SELECT hm_habitid, sh_title, sh_description, sh_subject, hm_startdate, hm_enddate, sh_durationmin, hm_percentCompleted
FROM User, HabitManager, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = StudyHabit.sh_habitid
AND hm_userkey = ?
AND ? >= hm_startdate
AND ? <= hm_enddate;

--5.
-- Grabs every single exercise habit that the user created for the week.
SELECT hm_habitid, eh_title, eh_description, eh_activitytype, hm_startdate, hm_enddate, eh_durationmin, hm_percentCompleted
FROM User, HabitManager, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = ExerciseHabit.eh_habitid
AND hm_userkey = ?
AND ? >= hm_startdate
AND ? <= hm_enddate;

--6. 
-- Grabs the LOGGED study habits that the user has done. 
SELECT sh_title, sh_subject, hm_startdate, hm_enddate,hl_log_date, sh_durationmin, hl_status, hm_percentCompleted
FROM User, HabitManager, HabitLog, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitLog.hl_habitid = HabitManager.hm_habitid
AND HabitManager.hm_habitid = StudyHabit.sh_habitid
AND hm_userkey = ?
AND hl_log_date = ?;

--7. 
-- Grabs the LOGGED Exercise Habits that the user has done.
SELECT eh_title, eh_activitytype, hm_startdate, hm_enddate,hl_log_date, eh_durationmin, hl_status, hm_percentCompleted
FROM User, HabitManager, HabitLog, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitLog.hl_habitid = HabitManager.hm_habitid
AND HabitManager.hm_habitid = ExerciseHabit.eh_habitid
AND hm_userkey = ?
AND hl_log_date = ?;

--8. 
-- Updates the ExerciseHabit
UPDATE ExerciseHabit
SET eh_title = ?, eh_description = ?, eh_activitytype = ?, eh_durationmin = ?
WHERE eh_habitid = ?;

--9. 
--Updates the Study Habit
UPDATE StudyHabit
SET sh_title = ?, sh_description = ?, sh_subject = ?, sh_durationmin = ?
WHERE sh_habitid = ?;

-- 10. 
-- Updates the Media Watched
UPDATE MediaWatched
SET mw_title = ? , mw_complete = ?
WHERE mw_mediaid = ?;

-- 11. 
-- Deletes MediaWatched for a specific INDEX
DELETE FROM MediaWatched
WHERE mw_mediaid = ?;

--12. 
--Deletes a habit from the entire system
DELETE FROM HabitManager
WHERE hm_habitid = ?;
--13
DELETE From StudyHabit
WHERE sh_habitid = ?;
--14
DELETE From ExerciseHabit
WHERE eh_habitid = ?;
--15
DELETE FROM HabitLog
WHERE hl_habitid = ?;

--16
--Grab all false habits
SELECT *
FROM HabitLog
WHERE
hl_habitid = ? AND
hl_log_date = ? AND
hl_status = "FALSE";

--17
-- Grab all True Habits
SELECT *
FROM HabitLog
WHERE
    hl_habitid = ? AND
    hl_log_date = ? AND
    hl_status = "TRUE";

--18
--Change Specific Habits To True
UPDATE HabitLog
SET hl_status = "TRUE"
WHERE 
    hl_habitid = ? AND
    hl_log_date = ?;

--19
--Change Specific Habits to False
UPDATE HabitLog
SET hl_status = "FALSE"
WHERE 
    hl_habitid = ? AND
    hl_log_date = ?;

--20
--Grab singular Habit that the user has created
SELECT hm_habitid, sh_title, sh_description, sh_subject, hm_startdate, hm_enddate, sh_durationmin, hm_percentCompleted
FROM User, HabitManager, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = StudyHabit.sh_habitid
AND hm_userkey = ?

--21
--Grab singular exercise habit the user has created
SELECT hm_habitid, eh_title, eh_description, eh_activitytype, hm_startdate, hm_enddate, eh_durationmin, hm_percentCompleted
FROM User, HabitManager, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = ExerciseHabit.eh_habitid
AND hm_userkey = ?;

--22
--Grab all media that the user has created
SELECT mw_mediaid, mw_title, MediaWatched.mw_complete
FROM MediaWatched, User
WHERE MediaWatched.mw_userkey = User.u_userkey AND
User.u_userkey = ?;

--23
--insert into habit manager
INSERT INTO HabitManager (
    hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted
) VALUES (?, ?, ?, ?, ?, ?);

--24
--Grab most recent HM key
SELECT *
FROM HabitManager
ORDER BY hm_habitid DESC
LIMIT 1;

--25
--Insert into exercise habit
INSERT INTO ExerciseHabit (
            eh_habitid, eh_title, eh_activitytype, eh_durationmin, eh_description   
) VALUES (?, ?, ?, ?, ?);

--26
--insert into habitlog
INSERT INTO HabitLog( hl_habitid, hl_log_date, hl_status)
            VALUES (?, ?, ?)

--27
--insert into mediaWatched
INSERT INTO MediaWatched (mw_userkey, mw_mediatype, mw_title, mw_complete)
VALUES (?, ?, ?, ? );

--28
--insert into habitmanager
INSERT INTO HabitManager (
    hm_userkey, hm_startdate, hm_enddate, hm_nonseq, hm_recurring, hm_percentcompleted
) VALUES (?, ?, ?, ?, ?, ?);

--29
--insert into study habit
INSERT INTO StudyHabit (
            sh_title, sh_habitid, sh_subject, sh_durationmin, sh_description   
) VALUES (?, ?, ?, ?, ?);


--30
--get the user information
SELECT * 
FROM User
WHERE 
    u_userkey = ?;

--31
-- get all movies watched
SELECT mw_title, MediaWatched.mw_complete
FROM MediaWatched, User
WHERE MediaWatched.mw_userkey = User.u_userkey AND
User.u_userkey = ?;

--32
--check if there is an existing user with same name.
SELECT *
FROM User
WHERE
u_name = ?;

--33
--Insert into USER
INSERT INTO User(u_name, u_email, u_password)
    VALUES (?, ?, ?);

--34
--gets the user if they have the same pass and user
SELECT * 
FROM User
WHERE 
    u_name = ? AND 
    u_password = ?;