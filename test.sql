--USED TO TEST SQL QUERIES

--To get all habits that the user has created
SELECT sh_title, sh_description, sh_subject, hm_startdate, hm_enddate, sh_durationmin, hm_nonseq, hm_recurring
FROM User, HabitManager, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = StudyHabit.sh_habitid
AND hm_userkey = 1;

SELECT eh_title, eh_description, eh_activitytype, hm_startdate, hm_enddate, eh_durationmin, hm_nonseq, hm_recurring
FROM User, HabitManager, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = ExerciseHabit.eh_habitid
AND hm_userkey = 1;

--GETTING HABIT LOGS
SELECT eh_title, eh_activitytype, hm_startdate, hm_enddate,hl_log_date, eh_durationmin, hm_nonseq, hm_recurring
FROM User, HabitManager, HabitLog, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitLog.hl_habitid = HabitManager.hm_habitid
AND HabitManager.hm_habitid = ExerciseHabit.eh_habitid
AND hm_userkey = ?;

SELECT sh_title, sh_subject, hm_startdate, hm_enddate,hl_log_date, sh_durationmin, hm_nonseq, hm_recurring
FROM User, HabitManager, HabitLog, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitLog.hl_habitid = HabitManager.hm_habitid
AND HabitManager.hm_habitid = StudyHabit.sh_habitid
AND hm_userkey = 1;


SELECT MediaWatched.mw_title, MediaWatched.mw_complete
FROM MediaWatched, User
WHERE MediaWatched.mw_userkey = User.u_userkey AND
    User.u_userkey = 1;

SELECT *
FROM HabitLog
WHERE
    hl_habitid = 1 AND
    hl_log_date = "2024-12-07";

SELECT hm_habitid, sh_title, sh_description, sh_subject, hm_startdate, hm_enddate, sh_durationmin, hm_nonseq, hm_recurring
FROM User, HabitManager, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = StudyHabit.sh_habitid
AND hm_userkey = 1
AND '2024-12-07' > hm_startdate
AND '2024-12-07' < hm_enddate ;


SELECT hm_habitid, eh_title, eh_description, eh_activitytype, hm_startdate, hm_enddate, eh_durationmin, hm_percentCompleted
FROM User, HabitManager, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = ExerciseHabit.eh_habitid
AND hm_userkey = 1;

SELECT hm_habitid, sh_title, sh_description, sh_subject, hm_startdate, hm_enddate, sh_durationmin, hm_percentCompleted
FROM User, HabitManager, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitManager.hm_habitid = StudyHabit.sh_habitid
AND hm_userkey = 1;