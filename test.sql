--USED TO TEST SQL QUERIES

--To get all habits that the user has created
SELECT sh_title, sh_subject, hm_startdate, hm_enddate,hl_log_date, sh_durationmin, hm_nonseq, hm_recurring
FROM User, HabitManager, HabitLog, StudyHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitLog.hl_habitid = HabitManager.hm_habitid
AND HabitManager.hm_habitid = StudyHabit.sh_habitid
AND hm_userkey = 1;

SELECT eh_title, eh_activitytype, hm_startdate, hm_enddate,hl_log_date, eh_durationmin, hm_nonseq, hm_recurring
FROM User, HabitManager, HabitLog, ExerciseHabit
WHERE User.u_userkey = HabitManager.hm_userkey 
AND HabitLog.hl_habitid = HabitManager.hm_habitid
AND HabitManager.hm_habitid = ExerciseHabit.eh_ehhabitid
AND hm_userkey = 1;

SELECT MediaWatched.mw_title, MediaWatched.mw_complete
FROM MediaWatched, User
WHERE MediaWatched.mw_userkey = User.u_userkey AND
    User.u_userkey = 1;