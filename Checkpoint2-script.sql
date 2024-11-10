CREATE TABLE User (
    u_userkey  decimal(10,0) not null PRIMARY KEY,
    u_name       varchar(152) not null,
    u_email    varchar(152) not null,
    u_password varchar(152) not null
);

CREATE TABLE MediaWatched(
    mw_mediaid decimal(10, 0) not null PRIMARY KEY,
    mw_userid decimal(10, 0) not null,
    mw_mediatype varchar(252) not null,
    mw_title varchar(252) not null,
    mw_complete BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE HabitManager (
    hm_habitid decimal(10, 0) not null PRIMARY KEY,
    hm_userid  decimal(10,0) not null, 
    hm_startdate date not null,
    hm_enddate date not null
);

CREATE TABLE HabitLog (
    hl_logid decimal(10, 0) not null PRIMARY KEY,
    hl_habitid decimal(10, 0) not null,
    h1_completeddate not null,
    h1_status BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE StudyHabit (
    sh_shhabitid decimal(10, 0) not null PRIMARY KEY,
    sh_habitid decimal(10, 0) not null,
    sh_subject varchar(252) not null, 
    sh_durationmin varchar(252) not null
);

CREATE TABLE ExerciseHabit(
    eh_ehhabitid decimal(10, 0) not null PRIMARY KEY,
    eh_habitid decimal(10, 0) not null,
    eh_activitytype varchar(252) not null,
    eh_durationmin varchar(252) not null
);