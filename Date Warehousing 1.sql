--Task 3-------------------------------------
drop table campus_dim;
--Campus dimension
Create table campus_dim as
SELECT distinct Campus
FROM MClub.event;


drop table category_dim;
--Category dimension
Create table category_dim as
SELECT distinct *
FROM MClub.category;


drop table course_dim;
--Course dimension
Create table course_dim as
SELECT distinct courselevel
FROM MClub.student;



drop table eventsize_dim;
--EventSize dimension
Create table eventsize_dim (
 eventsizeid VARCHAR2(10),
 minnumberinvolved varchar2(20),
 maxnumberinvolved varchar2(20),
 eventsizedesc varchar2(20)
);


 insert into eventsize_dim 
 VALUES('S', '0', '20', 'Small');

 insert into eventsize_dim 
 VALUES('M', '21', '80', 'Medium');
 
  insert into eventsize_dim 
 VALUES('L', '81', '10000', 'Large');
 
select * from eventsize_dim;


drop table semester_dim;
--Semester dimension

Create table semester_dim (
 semesterid VARCHAR2(10),
 semesterdesc VARCHAR2(20),
 startdate DATE,
 enddate DATE
);


insert into semester_dim 
 VALUES('S1', 'Semester One', TO_DATE('01-MAR', 'DD-MON'), TO_DATE('30-JUN', 'DD-MON'));

insert into semester_dim 
 VALUES('S2', 'Semester Two', TO_DATE('01-AUG', 'DD-MON'), TO_DATE('30-NOV', 'DD-MON'));
 
insert into semester_dim 
 VALUES('S3', 'Winter Semester', TO_DATE('01-JUL', 'DD-MON'), TO_DATE('30-JUL', 'DD-MON'));
 
insert into semester_dim 
 VALUES('S4', 'Summer Semester', TO_DATE('01-DEC', 'DD-MON'), TO_DATE('28-FEB', 'DD-MON'));
 
select * from campus_dim;
select * from course_dim;
select * from category_dim;
select * from eventsize_dim;
select * from semester_dim;

 
 DROP TABLE temp_fact_club CASCADE CONSTRAINTS PURGE;
 
 CREATE TABLE temp_fact_club AS
 SELECT ev.campus, ev.eventfee, ev.maxnumberinvolved, to_date(r.registrationdate, 'YY-MON-DD') as registration_date, r.registrationid
 FROM MCLUB.event ev, MCLUB.registration r
 where r.eventid = ev.eventid;

select * from temp_fact_club; 

 

-- add a column in the temp_fact_club table to store semester id
-- (cannot directly do this in the test table because
-- startdate was of DATE type and semid is of VARCHAR type.)
alter table temp_fact_club
ADD(semesterid varchar2(20));


-- populate semester dimension for Semester 1, Semester 2, Winter Semester and Summer Semester.
-- (the registration date can be changed accoding to the case)
UPDATE temp_fact_club
SET semesterid = 'S1'
WHERE to_char(registration_date, 'MMDD') >= '0301'
AND to_char(registration_date, 'MMDD') <= '0630';

UPDATE temp_fact_club
SET semesterid = 'S2'
WHERE to_char(registration_date, 'MMDD') >= '0801'
AND to_char(registration_date, 'MMDD') <= '1130';

UPDATE temp_fact_club
SET semesterid = 'S3'
WHERE to_char(registration_date, 'MMDD') >= '0701'
AND to_char(registration_date, 'MMDD') <= '0731';

UPDATE temp_fact_club
SET semesterid = 'S4'
WHERE to_char(registration_date, 'MMDD') >= '1201'
AND to_char(registration_date, 'MMDD') <= '0228';


-- add a column in the tempfact_club table to store event size id
alter table temp_fact_club
ADD (eventsizeid varchar2(20));

 -- update event size dimension for small, medium and large event size.
 -- small event <= 20 students, medium event between 21 and 80 students, and large event > 80 students.
UPDATE temp_fact_club
SET eventsizeid = 'S'
WHERE maxnumberinvolved <= 20;

UPDATE temp_fact_club
SET eventsizeid = 'M'
WHERE maxnumberinvolved > 20
AND maxnumberinvolved <= 80;

UPDATE temp_fact_club
SET eventsizeid = 'L'
WHERE maxnumberinvolved > 80;

select * from temp_fact_club;


-- create the fact table
-- this is an aggregate table of the earlier tempfact table
DROP TABLE club_fact CASCADE CONSTRAINTS PURGE;
CREATE TABLE club_fact AS
SELECT ct.categoryid, f.semesterid, f.eventsizeid, c.courselevel, f.campus,
 count(f.registrationid) as numberofstudent, sum(f.eventfee) as totalfees
FROM temp_fact_club f, course_dim c, category_dim ct
GROUP BY ct.categoryid, f.semesterid, f.eventsizeid, c.courselevel, f.campus;

select * from club_fact;



-- Task 4 --------------------------------------------------------------

-- Question A: The number of registered students in each semester for each event size.
SELECT s.semesterdesc, e.eventsizedesc, sum(f.numberofstudent) as Number_Of_Student
from club_fact f, semester_dim s, eventsize_dim e 
WHERE f.semesterid = s.semesterid
AND f.eventsizeid = e.eventsizeid
Group by s.semesterdesc, e.eventsizedesc;


-- Question B: The total event fees collected from students according to each campus location.
select cp.campus, sum(f.totalfees) as Total_Fees
from club_fact f, campus_dim cp
WHERE f.campus = cp.campus
GROUP BY cp.campus
order by Total_Fees ASC;



-- Question C: The number of registered students in events run by each club category in Clayton.
SELECT ct.category, sum(f.numberofstudent) as Number_Of_Student
from club_fact f, category_dim ct, campus_dim cp
WHERE f.categoryid = ct.categoryid
AND f.campus = cp.campus
AND cp.campus = 'Clayton'
group by ct.category;



-- Question D: The total event fees for “Special Interest Club” in each course level.
select c.courselevel, sum(f.totalfees) as Total_Fees
from club_fact f, category_dim ct, course_dim c
WHERE f.courselevel = c.courselevel
and f.categoryid = ct.categoryid
and ct.category = 'Special Interest Club'
GROUP BY c.courselevel;
