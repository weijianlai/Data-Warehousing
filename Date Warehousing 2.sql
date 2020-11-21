--Task 3
-- Create Company Size Dimension table manually
drop table companysizedim;
create table companysizedim (
companysizeid varchar2(10),
minnumberofemployees number(10),
maxnumberofemployees number(10),
companysizedesc varchar2(20)
);

-- Insert the values manually into the table
insert into companysizedim values ('S', 0, 19, 'Small Size Company');
insert into companysizedim values ('M', 20, 100, 'Medium Size Company');
insert into companysizedim values ('L', 100, null, 'Large Size Company');

-- Create Lease Duration Dimension table manually
drop table leasedurationdim;
create table leasedurationdim (
leasedurationid varchar2(10),
minduration number(10),
maxduration number(10),
leasedurationdesc varchar2(20)
);

-- Insert the values manually into the table
insert into leasedurationdim values ('ST', 0, 1, 'Short-term lease');
insert into leasedurationdim values ('MT', 1, 5, 'Medium-term lease');
insert into leasedurationdim values ('LT', 5, null, 'Long-term lease');


-- Create Temporary Dimension for ContractSignedDate
drop table tempcontractdatedim;
create table tempcontractdatedim as select distinct to_char(contractsigneddate, 'YYYYq') as TimeID, to_char(contractsigneddate, 'q') as quarter,
to_char(contractsigneddate, 'YYYY') as year from mrecomany.contract;


-- Create Temporary Dimension for InvoiceDate
drop table tempinvoicedatedim;
--version 1
create table tempinvoicedatedim as select distinct to_char(invoicedate, 'YYYYq') as TimeID, to_char(invoicedate, 'q') as quarter,
to_char(invoicedate, 'YYYY') as year from MRECOMANY.invoice;


-- Create Temporary Dimension for ConsumptionStartDate
drop table tempconsumptiondatedim;
create table tempconsumptiondatedim as select distinct to_char(consumptionstartdate, 'YYYYq') as TimeID, to_char(consumptionstartdate, 'q') as quarter,
to_char(consumptionstartdate, 'YYYY') as year from MRECOMANY.utilities_used;


-- Create Time Dimension for all the dates by using union function.
drop table timedim;
create table timedim as
select *
from tempcontractdatedim
union
select *
from tempinvoicedatedim
union
select *
from tempconsumptiondatedim;



-- Create Utilities Dimension
drop table utilitiesdim;
create table utilitiesdim as select utilitiesid, description as utilitiesdesc from MRECOMANY.utilities;



-- Create temporary revenue fact table
drop table temprevenuefact;
create table temprevenuefact as
select distinct c.numberofemployees, i.invoicedate, i.totalprice
from MRECOMANY.client c, MRECOMANY.invoice i
where i.clientid = c.clientid;

-- Add columns to store company size ID and Time ID
alter table temprevenuefact
add(companysizeid varchar2(20), timeid varchar2(20));


-- Update the Company Size ID with Small company has less than 20 employees, Medium size company has between 20-100 employees and Large size company has more than 100 employees
update temprevenuefact
set companysizeid = 'S'
where numberofemployees < 20;

update temprevenuefact
set companysizeid = 'M'
where numberofemployees >= 20
and numberofemployees <=100;

update temprevenuefact
set companysizeid = 'L'
where numberofemployees > 100;

--Update the year with timeID
update temprevenuefact set timeid = to_char(invoicedate, 'YYYYq');


--Create final fact table for revenue
drop table revenuefact;
create table revenuefact as
select timeid, companysizeid, sum(totalprice) as TotalLeasingRevenue
from temprevenuefact
group by timeid, companysizeid;

select * from revenuefact;



-- Create temp fact table for contract
drop table tempcontractfact;
create table tempcontractfact as
select distinct ct.leasingstartdate, ct.leasingenddate, ct.contractsigneddate, cl.numberofemployees
from MRECOMANY.client cl, MRECOMANY.contract ct
where ct.clientid = cl.clientid;

-- Add Columns to store the LeasingDuration ID
alter table tempcontractfact
ADD(leasedurationid varchar2(20), companysizeid varchar2(20), timeid varchar2(20));


-- Update the Lease duration, company size and time ID with leasing start and end date, number of employees and contractsigneddate.
UPDATE tempcontractfact
SET leasedurationid = 'ST'
WHERE to_char(leasingenddate, 'YYMMDD') - to_char(leasingstartdate, 'YYMMDD') < '10000';


UPDATE tempcontractfact
SET leasedurationid = 'MT'
WHERE to_char(leasingenddate, 'YYMMDD') - to_char(leasingstartdate, 'YYMMDD') >= '10000'
AND to_char(leasingenddate, 'YYMMDD') - to_char(leasingstartdate, 'YYMMDD') <= '50000';

UPDATE tempcontractfact
SET leasedurationid = 'LT'
WHERE to_char(leasingenddate, 'YYMMDD') - to_char(leasingstartdate, 'YYMMDD') > '50000';

update tempcontractfact
set companysizeid = 'S'
where numberofemployees < 20;

update tempcontractfact
set companysizeid = 'M'
where numberofemployees >= 20
and numberofemployees <=100;

update tempcontractfact
set companysizeid = 'L'
where numberofemployees > 100;
--Update the year with timeID
update tempcontractfact set timeid = to_char(contractsigneddate, 'YYYYq');


--Create final fact table for contract
drop table contractfact;
create table contractfact as
select distinct companysizeid, timeid, leasedurationid, count(*) as NumberOfContracts
from tempcontractfact 
group by companysizeid, timeid, leasedurationid;

SELECT * FROM contractfact;



-- Create temp fact table for service
drop table tempservicefact;
create table tempservicefact as 
select distinct ut.utilitiesid, ut.consumptionstartdate, ut.totalprice,
sum(ut.totalprice) as TotalServiceCharged
from timedim t, MRECOMANY.utilities u, MRECOMANY.utilities_used ut, mrecomany.client c
where ut.utilitiesid = u.utilitiesid
group by ut.utilitiesid, ut.consumptionstartdate, ut.totalprice;

-- Add columns to store TimeID
alter table tempservicefact
add(timeid varchar2(20));

-- Update the consumption start date with TimeID
update tempservicefact set timeid = to_char(consumptionstartdate, 'YYYYq');


--Create final fact table for service
drop table servicefact;
create table servicefact as
select timeid, utilitiesid, sum(totalprice) as TotalServiceCharged
from tempservicefact
group by timeid, utilitiesid;

select * from servicefact;




--Task 4
--Task A
select c.companysizedesc ,sum(r.totalleasingrevenue) as TotalLeasingRevenue
from revenuefact r, companysizedim c, timedim t
where r.companysizeid = c.companysizeid
and r.timeid = t.timeid
and t.year = '2019'
group by c.companysizedesc;



--Task B
select t.quarter, t.year, sum(s.totalservicecharged) as TotalServiceCharged
from servicefact s, timedim t, utilitiesdim u
where s.timeid = t.timeid
and t.quarter = '1'
and t.year = '2016'
and s.utilitiesid = u.utilitiesid
and u.utilitiesdesc = 'Water'
group by t.quarter, t.year;



--Task C
select ld.leasedurationdesc, sum(cf.NumberOfContracts) as NumberOfContracts
from contractfact cf, leasedurationdim ld, companysizedim cs
where cf.leasedurationid = ld.leasedurationid
and cf.companysizeid = cs.companysizeid
and cs.companysizedesc = 'Large Size Company'
group by ld.leasedurationdesc;



--Task D
select t.year, cs.companysizedesc, sum(cf.NumberOfContracts) as NumberOfContracts
from contractfact cf, timedim t, companysizedim cs
where cf.timeid = t.timeid
and cf.companysizeid = cs.companysizeid
group by t.year, cs.companysizedesc
order by numberofcontracts DESC;





