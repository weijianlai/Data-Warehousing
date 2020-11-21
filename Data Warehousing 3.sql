-- FIT3003 Assignment 1
-- Prashant Murali, Lai Wei Jian, Andre Hiu

--------------------------------------------------------------------------
-- DATA EXPLORATION
--------------------------------------------------------------------------

select * from MonChef.category; 
select * from MONCHEF.product_category;
select * from MonChef.product;
select * from MONCHEF.product_review;
select * from MONCHEF.school_canteen_orderline;
select * from MONCHEF.catering_orderline;
select * from MONCHEF.catering_order;
select * from MONCHEF.delivery_type;
select * from MONCHEF.school_canteen_order;
select * from MonChef.promotion;
select * from MONCHEF.order_status;
select * from MONCHEF.payment_type;
select * from MONCHEF.delivery_provider;
select * from MONCHEF.staff;
select * from MONCHEF.customer;
select * from MONCHEF.customer_type;
select * from MONCHEF.address;


select count(*) from MonChef.category;
select count(*) from MONCHEF.product_category;
select count(*) from MonChef.product;
select count(*) from MONCHEF.product_review;
select count(*) from MONCHEF.school_canteen_orderline;
select count(*) from MONCHEF.catering_orderline;
select count(*) from MONCHEF.catering_order;
select count(*) from MONCHEF.delivery_type;
select count(*) from MONCHEF.school_canteen_order;
select count(*) from MonChef.promotion;
select count(*) from MONCHEF.order_status;
select count(*) from MONCHEF.payment_type;
select count(*) from MONCHEF.delivery_provider;
select count(*) from MONCHEF.staff;
select count(*) from MONCHEF.customer;
select count(*) from MONCHEF.customer_type;
select count(*) from MONCHEF.address;



--------------------------------------------------------------------------
-- DATA CLEANING
--------------------------------------------------------------------------

-- The ideal exploration and detection strategy here is to search for duplicate records,
-- followed by searching for null values, and lastly looking for illegal records.


-- ERROR 1: Category table has a null value
-- Detection strategy: Count number of null records
select count(*)
from MONCHEF.category
where category_id IS NULL;
-- There is 1 null record so we will remove this in the new table
DROP TABLE category CASCADE CONSTRAINTS PURGE;
Create table category as
SELECT distinct category_id, category_description
FROM MONCHEF.category
where category_id IS NOT NULL;
-- Compare and view the count and cleaned category table
select * from MonChef.category;
select * from category;
select count(*) from MonChef.category;
select count(*) from category;



-- ERROR 2: Product table has duplicate records
-- Detection strategy: Count number of duplicate records
select product_id, count(*)
from MONCHEF.product
group by product_id
having count(*) > 1;
-- There is 1 record which has been duplicated 4 times, and another record duplicated twice
-- We will remove these duplicate records in the new temporary table
DROP TABLE updated_product CASCADE CONSTRAINTS PURGE;
Create table updated_product as
SELECT distinct product_id, product_name, product_price
FROM MONCHEF.product;
-- Compare and view the count and cleaned temporary product table
select * from MonChef.product;
select * from updated_product;
select count(*) from MonChef.product;
select count(*) from updated_product;



-- ERROR 3: The new temporary product table also has a null value
-- Detection strategy: Count number of null records
select count(*)
from updated_product
where product_id IS NULL
OR product_name IS NULL
OR product_price IS NULL;
-- There is 1 null record so we will remove this in the new table
DROP TABLE product CASCADE CONSTRAINTS PURGE;
Create table product as
SELECT distinct product_id, product_name, product_price
FROM updated_product
where product_id IS NOT NULL
AND product_name IS NOT NULL
AND product_price IS NOT NULL;
-- Compare and view the count and cleaned product table
select * from updated_product;
select * from product;
select count(*) from updated_product;
select count(*) from product;



-- ERROR 4: There is an illegal product id in the product review table
-- Detection strategy: Finding illegal records
select * 
from MONCHEF.product_review
where product_id NOT IN (select product_id from product);
-- There is 1 illegal record so we will remove this in the new table
DROP TABLE product_review CASCADE CONSTRAINTS PURGE;
Create table product_review as
SELECT distinct REVIEW_NO, PRODUCT_ID, REVIEW_TEXT, REVIEW_STAR
FROM MONCHEF.product_review
where product_id IN (select product_id from product);
-- Compare and view the count and cleaned product review table
select * from MONCHEF.product_review;
select * from product_review;
select count(*) from MONCHEF.product_review;
select count(*) from product_review;



-- ERROR 5: There is an illegal product id in the catering order line table
-- Detection strategy: Finding illegal records
select * 
from MONCHEF.catering_orderline
where product_id NOT IN (select product_id from product);
-- There is 1 illegal record so we will remove this in the new table
DROP TABLE catering_orderline CASCADE CONSTRAINTS PURGE;
Create table catering_orderline as
SELECT distinct CA_ORDERID, PRODUCT_ID, COL_QUANTITYSOLD, COL_LINEPRICE
FROM MONCHEF.catering_orderline
where product_id IN (select product_id from product);
-- Compare and view the count and cleaned catering order line table
select * from MONCHEF.catering_orderline;
select * from catering_orderline;
select count(*) from MONCHEF.catering_orderline;
select count(*) from catering_orderline;



-- ERROR 6: Catering order table has duplicate records
-- Detection strategy: Count number of duplicate records
select CA_ORDERID, count(*)
from MONCHEF.catering_order
group by CA_ORDERID
having count(*) > 1;
-- There are 2 ca_orderID's which have been duplicated
-- We will remove these duplicate records in the new table
DROP TABLE catering_order CASCADE CONSTRAINTS PURGE;
Create table catering_order as
SELECT distinct CA_ORDERID, CA_ORDERDATE, CA_TOTALPRICE, CA_FINALPRICE, STATUS_ID, PROMO_CODE, PROVIDER_ID, STAFF_ID
FROM MONCHEF.catering_order;
-- Compare and view the count and cleaned temporary product table
select * from MONCHEF.catering_order;
select * from catering_order;
select count(*) from MONCHEF.catering_order;
select count(*) from catering_order;
-- After comparing, we notice that 1 of the duplicate records were not removed. This is because
-- the duplicate had a different ca_orderdate, and the orderdate was incorrect because it was
-- 12-MAY-35, hence not a real date. This record will be removed.
DELETE FROM catering_order
WHERE ca_orderid = 'C0001'
AND ca_orderdate = '12-MAY-35';
-- Compare and view the count and cleaned temporary product table again
select * from MONCHEF.catering_order;
select * from catering_order;
select count(*) from MONCHEF.catering_order;
select count(*) from catering_order;



-- ERROR 7: There is an illegal payment type id in the school canteen order table
-- Detection strategy: Finding illegal records
select * 
from MONCHEF.school_canteen_order
where type_id NOT IN (select type_id from MONCHEF.payment_type);
-- There is 1 illegal record so we will remove this in the new temporary table
DROP TABLE temp_school_canteen_order CASCADE CONSTRAINTS PURGE;
Create table temp_school_canteen_order as
SELECT distinct SC_ORDERID, SC_ORDERDATE, SC_DELIVERYDATE, SC_TOTALPRICE, SC_FINALPRICE, STATUS_ID, PROMO_CODE, 
                TYPE_ID, DELIVERY_ID, STAFF_ID, CUSTOMER_ID
FROM MONCHEF.school_canteen_order
where type_id IN (select type_id from MONCHEF.payment_type);
-- Compare and view the count and cleaned temporary school canteen order table
select * from MONCHEF.school_canteen_order;
select * from temp_school_canteen_order;
select count(*) from MONCHEF.school_canteen_order;
select count(*) from temp_school_canteen_order;



-- ERROR 8: There is another illegal record. There is an sc_orderid in the school canteen order table 
-- that is not in school canteen orderline
-- Detection strategy: Finding illegal records
select * 
from temp_school_canteen_order
where sc_orderid NOT IN (select sc_orderid from MonChef.school_canteen_orderline);
-- There is 1 illegal record so we will remove this in the new table
DROP TABLE school_canteen_order CASCADE CONSTRAINTS PURGE;
Create table school_canteen_order as
SELECT distinct SC_ORDERID, SC_ORDERDATE, SC_DELIVERYDATE, SC_TOTALPRICE, SC_FINALPRICE, STATUS_ID, PROMO_CODE, 
                TYPE_ID, DELIVERY_ID, STAFF_ID, CUSTOMER_ID
FROM temp_school_canteen_order
where sc_orderid IN (select sc_orderid from MONCHEF.school_canteen_orderline);
-- Compare and view the count and cleaned school canteen order table
select * from temp_school_canteen_order;
select * from school_canteen_order;
select count(*) from temp_school_canteen_order;
select count(*) from school_canteen_order;



-- ERROR 9: There is an illegal address id in the staff table.
-- Detection strategy: Finding illegal records
select * 
from MONCHEF.staff
where address_id NOT IN (select address_id from MONCHEF.address);
-- There is 1 illegal record so we will remove this in the new table. Furthermore, this record
-- has negative values for salary and weekly working hours, so it should be removed.
DROP TABLE staff CASCADE CONSTRAINTS PURGE;
Create table staff as
SELECT distinct STAFF_ID, STAFF_TITLE, STAFF_FIRSTNAME, STAFF_LASTNAME, STAFF_GENDER, ADDRESS_ID, STAFF_SALARYPERHOUR, 
                STAFF_WEEKLYWORKINGHOURS
FROM MONCHEF.staff
where address_id IN (select address_id from MONCHEF.address);
-- Compare and view the count and cleaned staff table
select * from MONCHEF.staff;
select * from staff;
select count(*) from MONCHEF.staff;
select count(*) from staff;



-- ERROR 10: There are duplicate records in the customer table.
-- Detection strategy: Finding illegal records
select CUSTOMER_ID, count(*)
from MONCHEF.customer
group by CUSTOMER_ID
having count(*) > 1;
-- There is 1 customer_id that has been duplicated 8 times.
DROP TABLE customer CASCADE CONSTRAINTS PURGE;
Create table customer as
SELECT distinct CUSTOMER_ID, CUSTOMER_NAME, CUSTOMER_PHONE, CUSTOMER_EMAIL, CUSTOMER_ABN, CUSTOMER_BANKACCOUNT, 
                TYPE_ID, ADDRESS_ID
FROM MONCHEF.customer;
-- Compare and view the count and cleaned customer table
select * from MONCHEF.customer;
select * from customer;
select count(*) from MONCHEF.customer;
select count(*) from customer;


--------------------------------------------------------------------------
-- LVL2 SQL Implementation
--------------------------------------------------------------------------

--SQL Implementation (LVL2)

-- Create Customer Location Dimension table
drop table customerlocationdim;
create table customerlocationdim as 
SELECT distinct address_suburb as suburb
FROM MONCHEF.address;

select * from customerlocationdim;


-- Create Customer Type Dimension table
drop table customertypedim;
create table customertypedim as 
select * from MONCHEF.customer_type;

select * from customertypedim;


-- Create Staff Gender Dimension table manually
drop table staffgenderdim;
create table staffgenderdim (
gender varchar2(1)
);

-- Insert the values manually into the table
insert into staffgenderdim values ('M');
insert into staffgenderdim values ('F');

select * from staffgenderdim;


-- Create Payment Type Dimension table
drop table paymenttypedim;
create table paymenttypedim as 
select * from MONCHEF.payment_type;

select * from paymenttypedim;


-- Create Order Status Dimension table
drop table orderstatusdim;
create table orderstatusdim as 
select * from MONCHEF.order_status;

select * from orderstatusdim;


-- Create Order Price Scale  Dimension table manually
drop table orderpricescaledim;
create table orderpricescaledim (
orderpricescaleid varchar2(10),
orderpricescale varchar2(10),
orderprice_description varchar2(50)
);

-- Insert the values manually into the table
insert into orderpricescaledim values ('OL', '0-50', 'Low Price Order');
insert into orderpricescaledim values ('OM', '51-150', 'Medium Price Order');
insert into orderpricescaledim values ('OE', '>150', 'Expensive Price Order');

select * from orderpricescaledim;


-- Create Product Price  Dimension table manually
drop table productpricedim;
create table productpricedim (
productpriceid varchar2(10),
productpricescale varchar2(10),
pricescale_description varchar2(50)
);

-- Insert the values manually into the table
insert into productpricedim values ('PL', '<10', 'Low Price Product');
insert into productpricedim values ('PM', '10-20', 'Medium Price Product');
insert into productpricedim values ('PH', '>20', 'High Price Product');

select * from productpricedim;


-- Create Promotion Dimension table
drop table promotiondim;
create table promotiondim as 
select * from MONCHEF.promotion;

select * from promotiondim;


-- Create Season Dimension table manually
drop table seasondim;
create table seasondim (
seasonid VARCHAR2(10),
 seasondesc VARCHAR2(20),
 startdate DATE,
 enddate DATE
);

-- Insert the values manually into the table
insert into seasondim values ('S1', 'Spring', TO_DATE('01-SEP', 'DD-MON'), TO_DATE('30-NOV', 'DD-MON'));
insert into seasondim values ('S2', 'Summer', TO_DATE('01-DEC', 'DD-MON'), TO_DATE('29-FEB', 'DD-MON'));
insert into seasondim values ('S3', 'Autumn', TO_DATE('01-MAR', 'DD-MON'), TO_DATE('30-MAY', 'DD-MON'));
insert into seasondim values ('S4', 'Winter', TO_DATE('01-JUN', 'DD-MON'), TO_DATE('30-AUG', 'DD-MON'));

select * from seasondim;


-- Create Temporary Catering Order Date Dimension table
drop table temp_ca_orderdatedim;
create table temp_ca_orderdatedim as 
select distinct to_char(ca_orderdate, 'DYYYMM') as orderdateID, to_char(ca_orderdate, 'Day') as day, 
                to_char(ca_orderdate, 'MM') as month, to_char(ca_orderdate, 'YYYY') as year
from catering_order;

select * from temp_ca_orderdatedim;


-- Create Temporary School Canteen Order Date Dimension table
drop table temp_sc_orderdatedim;
create table temp_sc_orderdatedim as 
select distinct to_char(sc_orderdate, 'DYYYMM') as orderdateID, to_char(sc_orderdate, 'Day') as day,
                to_char(sc_orderdate, 'MM') as month, to_char(sc_orderdate, 'YYYY') as year
from school_canteen_order;

select * from temp_sc_orderdatedim;


-- Create Order Date Dimension for all the dates by using union function.
drop table orderdatedim;
create table orderdatedim as
select *
from temp_ca_orderdatedim
union
select *
from temp_sc_orderdatedim;

select * from orderdatedim;


-- Create Delivery Provider Dimension table
drop table deliveryproviderdim;
create table deliveryproviderdim as 
select * from MONCHEF.delivery_provider;

select * from deliveryproviderdim;


-- Create Star Rating Dimension table
drop table starratingdim;
create table starratingdim  
( StarID Number(1), Star_Description Varchar2(15));
 
Insert Into starratingdim Values (0, 'Unknown');
Insert Into starratingdim Values (1, 'Poor');
Insert Into starratingdim Values (2, 'Not Good');
Insert Into starratingdim Values (3, 'Average');
Insert Into starratingdim Values (4, 'Good');
Insert Into starratingdim Values (5, 'Excellent');

select * from starratingdim;


-- Create Product Dimension table
drop table productdim;
create table productdim as
select distinct * from product;

select * from productdim;


-- Create Category Dimension table
drop table categorydim;
create table categorydim as
select distinct *
from category;

select * from categorydim;


-- Create Product Category Bridge Dimension table
drop table productcategorybridgedim;
create table productcategorybridgedim as select distinct * from monchef.product_category;

select * from productcategorybridgedim;


-- Create Catering Order Dimension table
drop table ca_orderdim;
create table ca_orderdim as
select distinct *
from catering_order;

select * from ca_orderdim;


-- Create School Canteen Order Dimension table
drop table sc_orderdim;
create table sc_orderdim as
select distinct *
from school_canteen_order;

select * from sc_orderdim;


-- Create -Catering Orderline Bridge Dimension table
drop table ca_orderlinebridgedim;
create table ca_orderlinebridgedim as
select distinct ca.ca_orderid, p.product_id, sr.starid, p.product_price
from ca_orderdim ca, productdim p, starratingdim sr;

alter table ca_orderlinebridgedim add (productpriceid varchar (10));

update ca_orderlinebridgedim 
set productpriceid = 'PL' 
where product_price <10;

update ca_orderlinebridgedim 
set productpriceid = 'PM'
where product_price >=10
and product_price <=20;

update ca_orderlinebridgedim 
set productpriceid = 'PH' 
where product_price >20;

ALTER TABLE ca_orderlinebridgedim
DROP COLUMN product_price;

select * from ca_orderlinebridgedim;


-- Create School Canteen Orderline Bridge Dimension table
drop table sc_orderlinebridgedim;
create table sc_orderlinebridgedim as
select distinct sc.sc_orderid, p.product_id, p.product_price
from sc_orderdim sc, productdim p;

alter table sc_orderlinebridgedim add (productpriceid varchar (10));

update sc_orderlinebridgedim 
set productpriceid = 'PL' 
where product_price <10;

update sc_orderlinebridgedim 
set productpriceid = 'PM'
where product_price >=10
and product_price <=20;

update sc_orderlinebridgedim 
set productpriceid = 'PH' 
where product_price >20;

ALTER TABLE sc_orderlinebridgedim
DROP COLUMN product_price;

select * from sc_orderlinebridgedim;

-- FACT TABLES

-- Service Delivery Cost Fact
select * from deliveryproviderdim;
--Service Delivery Cost Fact
drop table tempservicedeliverycostfact;
create table tempservicedeliverycostfact as select c.ca_orderdate, c.provider_id, c.ca_orderid, c.ca_totalprice, 
             d.provider_rate from catering_order c, monchef.delivery_provider d where c.provider_id = d.provider_id;

select * from tempservicedeliverycostfact;

alter table tempservicedeliverycostfact add (OrderDateID varchar (10), DeliveryCost varchar(10));
update tempservicedeliverycostfact set orderdateid = to_char(ca_orderdate, 'DYYYMM');
update tempservicedeliverycostfact set deliverycost = round(ca_totalprice * provider_rate, 2);

drop table servicedeliverycostfact;
create table servicedeliverycostfact as select s.orderdateid, s.provider_id, s.ca_orderid,
                                     sum(s.deliverycost) as TotalServiceDeliveryCost from tempservicedeliverycostfact s
group by s.orderdateid, s.provider_id, s.ca_orderid;

select * from servicedeliverycostfact;


--Customer Fact
drop table customerfact;
create table customerfact as select c.type_id as CustomerType_ID, a.address_suburb as Suburb, 
                                    count(a.address_id) as NumberofCustomers from monchef.customer_type ct, 
                                    customer c, monchef.address a 
where c.address_id = a.address_id and c.type_id = ct.type_id
group by c.type_id, a.address_suburb;

--CA_Order Fact
drop table tempcaorderfact;
create table tempcaorderfact as select c.ca_orderdate, extract(day from c.ca_orderdate) as datenumber,
                                        extract(month from c.ca_orderdate) as month, co.col_lineprice, p.product_id,
                                        p.product_price, c.provider_id, c.promo_code, c.ca_totalprice, c.ca_orderid, 
                                        co.col_quantitysold
from catering_order c, monchef.delivery_provider d,  product p, catering_orderline co, product_review pr
where co.ca_orderid = c.ca_orderid and 
    d.provider_id = c.provider_id and
    co.product_id = p.product_id and
    co.product_id = pr.product_id;

alter table tempcaorderfact add (
    OrderDateID varchar (10),
    ProductPriceID varchar (2),
    SeasonID varchar(2),
    OrderPriceScaleID varchar(2)
);
update tempcaorderfact set orderdateid = to_char(ca_orderdate, 'DYYYMM');
update tempcaorderfact set productpriceid = 'PL' where product_price < 10; 
update tempcaorderfact set productpriceid = 'PM' where product_price >= 10 and product_price <=20; 
update tempcaorderfact set productpriceid = 'PH' where product_price > 20;
update tempcaorderfact set seasonid = 'S1' where datenumber >= 1 and datenumber <= 31 and month >= 9 and month <= 11; 
update tempcaorderfact set seasonid = 'S2' where datenumber >= 1 and datenumber <= 31 and month = 12 or month <= 2; 
update tempcaorderfact set seasonid = 'S3' where datenumber >= 1 and datenumber <= 31 and month >= 3 and month <= 5; 
update tempcaorderfact set seasonid = 'S4' where datenumber >= 1 and datenumber <= 31 and month >= 6 and month <= 8; 
update tempcaorderfact set orderpricescaleid = 'OL' where ca_totalprice >= 0 and ca_totalprice <=50;
update tempcaorderfact set orderpricescaleid = 'OM' where ca_totalprice >= 51 and ca_totalprice <=150;
update tempcaorderfact set orderpricescaleid = 'OE' where ca_totalprice > 150;
select * from tempcaorderfact;


drop table caorderfact;
create table caorderfact as select c.orderpricescaleid, c.orderdateid as Date_ID, c.seasonid,c.promo_code, c.ca_orderid, 
                                    c.productpriceid, c.provider_id, sum(c.col_lineprice) as TotalSales,
count(distinct c.ca_orderid) as NumberofCateringOrders, sum(c.col_quantitysold) as QuantitySold from tempcaorderfact c 
group by c.orderpricescaleid, c.orderdateid, c.seasonid,c.promo_code, c.ca_orderid, c.productpriceid, c.provider_id;

select * from caorderfact;


--Product Fact

drop table averagestarstable;
create table averagestarstable as select pr.product_id, round(avg(pr.review_star), 0) as starid from product_review pr
group by pr.product_id;

select * from averagestarstable;


drop table tempproductfact;
create table tempproductfact as select p.product_id, p.product_price, a.starid from averagestarstable a, product p,
monchef.product_category pc
where p.product_id = a.product_id and
p.product_id = pc.product_id;

alter table tempproductfact add (productpriceid varchar (10));

update tempproductfact set productpriceid = 'PL' where product_price < 10; 
update tempproductfact set productpriceid = 'PM' where product_price >= 10 and product_price <=20; 
update tempproductfact set productpriceid = 'PH' where product_price > 20;

select * from tempproductfact;

drop table productfact;       
create table productfact as select p.starid, product_id, productpriceid,
                                    count(product_id) as Numberofproducts from tempproductfact p
group by starid, product_id, productpriceid; 

select * from productfact;


-- School Canteen Order Fact
drop table tempscorderfact;
create table tempscorderfact as select c.sc_orderdate, extract(day from c.sc_orderdate) as datenumber,
                                        extract(month from c.sc_orderdate) as month, co.sol_lineprice, p.product_id, 
                                        p.product_price, c.staff_id, s.staff_gender,c.status_id, c.type_id as paymenttypeid, 
                                        c.customer_id, cu.type_id as customertypeid, c.promo_code, c.sc_totalprice,
                                        c.sc_orderid, co.sol_quantitysold
from school_canteen_order c, monchef.delivery_type d,  product p, monchef.school_canteen_orderline co, monchef.promotion pr, 
        staff s, customer cu
where co.sc_orderid = c.sc_orderid and
    c.promo_code = pr.promo_code and
    d.delivery_id = c.delivery_id and
    co.product_id = p.product_id and
    c.staff_id = s.staff_id and
    c.customer_id = cu.customer_id;
    
select * from tempscorderfact;


alter table tempscorderfact add (
    OrderDateID varchar (10),
    ProductPriceID varchar (2),
    SeasonID varchar(2)
);
update tempscorderfact set orderdateid = to_char(sc_orderdate, 'DYYYMM');
update tempscorderfact set productpriceid = 'PL' where product_price < 10; 
update tempscorderfact set productpriceid = 'PM' where product_price >= 10 and product_price <=20; 
update tempscorderfact set productpriceid = 'PH' where product_price > 20;
update tempscorderfact set seasonid = 'S1' where datenumber >= 1 and datenumber <= 31 and month >= 9 and month <= 11; 
update tempscorderfact set seasonid = 'S2' where datenumber >= 1 and datenumber <= 31 and month = 12 or month <= 2; 
update tempscorderfact set seasonid = 'S3' where datenumber >= 1 and datenumber <= 31 and month >= 3 and month <= 5; 
update tempscorderfact set seasonid = 'S4' where datenumber >= 1 and datenumber <= 31 and month >= 6 and month <= 8; 

select * from tempscorderfact;


drop table scorderfact;
create table scorderfact as select c.orderdateid, c.seasonid, c.paymenttypeid, c.customertypeid, c.promo_code, c.sc_orderid, 
                                    c.productpriceid, c.staff_gender, c.status_id, sum(c.sol_lineprice) as TotalSales,
count(distinct c.sc_orderid) as NumberofSchoolCanteenOrders, sum(c.sol_quantitysold) as QuantitySold from tempscorderfact c 
group by c.orderdateid, c.seasonid, c.paymenttypeid, c.customertypeid, c.promo_code, c.sc_orderid, c.productpriceid, 
            c.staff_gender, c.status_id;

select * from scorderfact;



--------------------------------------------------------------------------
-- TASK 3A - OLAP with Level 2 Star Schema
--------------------------------------------------------------------------

-- What are the top 5 months that have the highest number of school canteen orders from a school customer?
SELECT *
FROM
    (SELECT od.month, ct.type_description, sum(f.NumberOfSchoolCanteenOrders) as Total_Number_Of_School_Canteen_Orders,
        DENSE_RANK() OVER (ORDER BY SUM(f.NumberOfSchoolCanteenOrders) DESC) AS Top_5_Months
    FROM scorderfact f, orderdatedim od, customertypedim ct
    WHERE f.OrderDateID = od.OrderDateID
    AND f.customertypeid = ct.type_id
    AND ct.type_description = 'School'
    GROUP BY od.month, ct.type_description)
WHERE Top_5_Months <= 5;

-- What is the top 10% of sales for orders in a school canteen order taken by male and female staff in March?
SELECT *
FROM(
    SELECT od.month, s.gender, sum(f.TotalSales) as Total_Sales,
        PERCENT_RANK() OVER (ORDER BY SUM(f.TotalSales) DESC) AS "Percent Rank"
    FROM scorderfact f, orderdatedim od, staffgenderdim s
    WHERE f.OrderDateID = od.OrderDateID
    AND f.staff_gender = s.gender
    GROUP BY od.month, s.gender)
WHERE "Percent Rank" < 0.1;

-- Show the total number of customers and the type of customers from different suburbs.
SELECT ct.type_description, cl.suburb, sum(f.NumberOfCustomers) as Total_Number_Of_Customers
FROM customerfact f, customerlocationdim cl, customertypedim ct
WHERE f.CustomerType_ID = ct.type_id
AND f.suburb = cl.suburb
GROUP BY cl.suburb, ct.type_description
ORDER BY Total_Number_Of_Customers DESC;


--------------------------------------------------------------------------
-- TASK 3B AND 3C - OLAP with Level 2 Star Schema
--------------------------------------------------------------------------

--CUBE 
SELECT 
 DECODE(GROUPING(p.promo_code), 1, 'All Promotion',
p.promo_code) As Promotion, 
 DECODE(GROUPING(od.month), 1, 'All Months',
od.month) AS Month,
 DECODE(GROUPING(dp.provider_description), 1, 'All Providers',
dp.provider_description) As Provider,
 SUM(ca.totalsales) as TotalSales
FROM caorderfact ca, promotiondim p, orderdatedim od, deliveryproviderdim dp 
WHERE ca.promo_code = p.promo_code
AND ca.date_id = od.OrderDateID
AND ca.provider_id = dp.provider_id
GROUP BY CUBE (p.promo_code, od.month, dp.provider_description)
order by p.promo_code;



-- Partial Cube
SELECT
 DECODE(GROUPING(p.promo_code), 1, 'All Promotion',
p.promo_code) As Promotion, 
 DECODE(GROUPING(od.month), 1, 'All Months',
od.month) AS Month,
 DECODE(GROUPING(dp.provider_description), 1, 'All Providers',
dp.provider_description) As Provider,
 SUM(ca.totalsales) as TotalSales
FROM caorderfact ca, promotiondim p, orderdatedim od, deliveryproviderdim dp 
WHERE ca.promo_code = p.promo_code
AND ca.date_id = od.OrderDateID
AND ca.provider_id = dp.provider_id
GROUP BY CUBE (od.month, dp.provider_description), p.promo_code
order by p.promo_code;


-- The total number of catering orders from each promotion, time period (year), and order price?
-- RollUp
SELECT
 DECODE(GROUPING(p.promo_code), 1, 'All Promotion',
p.promo_code) As Promotion, 
 DECODE(GROUPING(od.year), 1, 'All Years',
od.year) AS Year,
DECODE(GROUPING(odp.orderprice_description), 1, 'All Price Orders',
odp.orderprice_description) As OrderPrice, 
 SUM(ca.numberofcateringorders) as NumberOfCateringOrders
FROM caorderfact ca, promotiondim p, orderdatedim od, orderpricescaledim odp
WHERE ca.promo_code = p.promo_code
AND ca.date_id = od.OrderDateID
AND ca.orderpricescaleid = odp.orderpricescaleid
GROUP BY ROLLUP (od.year, odp.orderprice_description, p.promo_code)
order by p.promo_code;


-- Partial RollUp
SELECT
 DECODE(GROUPING(p.promo_code), 1, 'All Promotion',
p.promo_code) As Promotion, 
 DECODE(GROUPING(od.year), 1, 'All Years',
od.year) AS Year,
DECODE(GROUPING(odp.orderprice_description), 1, 'All Price Orders',
odp.orderprice_description) As OrderPrice, 
 SUM(ca.numberofcateringorders) as NumberOfCateringOrders
FROM caorderfact ca, promotiondim p, orderdatedim od, orderpricescaledim odp
WHERE ca.promo_code = p.promo_code
AND ca.date_id = od.OrderDateID
AND ca.orderpricescaleid = odp.orderpricescaleid
GROUP BY ROLLUP (od.year, odp.orderprice_description), p.promo_code
order by p.promo_code;


-- What are the total catering sales and cumulative total catering sales of Savoury dishes in each year?
--Cumulative aggregate
Select od.year,  SUM(caf.totalsales) as TotalCateringSales,
 TO_CHAR(SUM(SUM(caf.totalsales))
 OVER(ORDER BY od.year ROWS UNBOUNDED PRECEDING),
 '9,999,999.99') AS Cummulative_CateringSales
From caorderfact caf, orderdatedim od, categorydim c, ca_orderdim cad
Where caf.date_id = od.OrderDateID
and caf.ca_orderid = cad.ca_orderid
and c.category_description = 'Savoury'
Group By od.year;


-- What are the total school canteen sales and cumulative total school canteen sales for business customer types every year?
-- Moving aggregate
Select od.year, c.type_description,  SUM(scf.totalsales) as TotalSchoolCanteenSales,
 TO_CHAR(AVG(SUM(scf.totalsales))
 OVER(ORDER BY od.year, c.type_description ROWS 2 PRECEDING),
 '9,999,999.99') AS Moving_1_Year_Avg
From scorderfact scf, orderdatedim od, customertypedim c
Where scf.orderdateid = od.OrderDateID
and scf.customertypeid = c.type_id
and c.type_description = 'Business'
Group By od.year, c.type_description
order by od.year;


-- Cumulative aggregate
Select od.year, c.type_description,  SUM(scf.totalsales) as TotalSchoolCanteenSales,
 TO_CHAR(SUM(SUM(scf.totalsales))
 OVER(ORDER BY od.year, c.type_description ROWS UNBOUNDED PRECEDING),
 '9,999,999.99') AS Cummulative_CanteenSales
From scorderfact scf, orderdatedim od, customertypedim c
Where scf.orderdateid = od.OrderDateID
and scf.customertypeid = c.type_id
and c.type_description = 'Business'
Group By od.year, c.type_description
order by od.year;


--------------------------------------------------------------------------
-- TASK 3D - OLAP with Level 2 Star Schema
--------------------------------------------------------------------------


-- ranking of each cuisine based on the monthly total number of sales for school canteen orders and the ranking of each 
-- customer type based on the monthly total number of sales for school canteen orders.
select cd.category_description, c.type_description,od.month,sum(s.totalsales) as SalesPerMonth,
rank() over (partition by cd.category_description order by sum(s.totalsales) desc) as SalesPerCategory,
rank() over (partition by c.type_description order by sum(s.totalsales) desc) as SalesPerCustomerType
from categorydim cd, productcategorybridgedim pcb, productdim p, sc_orderlinebridgedim sb, sc_orderdim so, scorderfact s, 
        orderdatedim od, customertypedim c
where s.sc_orderid = so.sc_orderid and
s.customertypeid = c.type_id and
so.sc_orderid = sb.sc_orderid and
sb.product_id = p.product_id and
p.product_id = pcb.product_id and 
pcb.category_id = cd.category_id and
s.orderdateid = od.orderdateid and
cd.category_description in ('Thai','Indonesian','Korean') 
group by cd.category_description, c.type_description,od.month;

select * from customertypedim;
-- customertype with the highest number of orders by month
select c.type_description, od.month,sum(s.numberofschoolcanteenorders) as NumberOfOrders, 
dense_rank() over (partition by c.type_description order by sum(s.numberofschoolcanteenorders) desc) as rankbycustomertype,
rank() over (partition by od.month order by sum(s.numberofschoolcanteenorders) desc) as rankbymonth
from customertypedim c, seasondim sd, scorderfact s, orderdatedim od
where s.customertypeid = c.type_id and
s.orderdateid = od.orderdateid
group by c.type_description, od.month;



--------------------------------------------------------------------------
-- LVL0 SQL Implementation
--------------------------------------------------------------------------
-- Drop the table in LVL2 SQL Implementation
drop table ca_orderlinebridgedim;


-- Create Address Dimension table
drop table addressdim_v2;
create table addressdim_v2 as 
SELECT distinct address_id, address_streetno as streetno, address_streetname as streetname,
                address_suburb as suburb, address_state as state, address_postcode as postcode
FROM MONCHEF.address;

select * from addressdim_v2;

select * from customer;

-- Create Customer Dimension table
drop table customerdim_v2;
create table customerdim_v2 as 
SELECT distinct customer_id, customer_name as name, customer_phone as phone, customer_email as email,
customer_bankaccount as bankaccount, type_id, address_id from customer;

select * from customerdim_v2;


-- Create Customer Type Dimension table
drop table customertypedim_v2;
create table customertypedim_v2 as 
select * from MONCHEF.customer_type;

select * from customertypedim_v2;


-- Create Payment Type Dimension table
drop table paymenttypedim_v2;
create table paymenttypedim_v2 as 
select * from MONCHEF.payment_type;

select * from paymenttypedim_v2;


-- Create Order Status Dimension table
drop table orderstatusdim_v2;
create table orderstatusdim_v2 as 
select * from MONCHEF.order_status;

select * from orderstatusdim_v2;


-- Create Staff Dimension table
drop table staffdim_v2;
create table staffdim_v2 as 
select * from staff;

select * from staffdim_v2;


-- Create Promotion Dimension table
drop table promotiondim_v2;
create table promotiondim_v2 as 
select * from MONCHEF.promotion;

select * from promotiondim_v2;


-- Create Temporary Catering Order Date Dimension table
drop table temp_ca_orderdatedim_v2;
create table temp_ca_orderdatedim_v2 as 
select distinct to_char(ca_orderdate, 'DYYYMM') as orderdateID, to_char(ca_orderdate, 'Day') as day, 
                to_char(ca_orderdate, 'MM') as month, to_char(ca_orderdate, 'YYYY') as year,
                extract(day from ca_orderdate) as datenumber
from catering_order;

select * from temp_ca_orderdatedim_v2;


-- Create Temporary School Canteen Order Date Dimension table
drop table temp_sc_orderdatedim_v2;
create table temp_sc_orderdatedim_v2 as 
select distinct to_char(sc_orderdate, 'DYYYMM') as orderdateID, to_char(sc_orderdate, 'Day') as day, 
                to_char(sc_orderdate, 'MM') as month, to_char(sc_orderdate, 'YYYY') as year, 
                extract(day from sc_orderdate) as datenumber
from school_canteen_order;

select * from temp_sc_orderdatedim_v2;



-- Create Temp Order Date Dimension for all the dates by using union function.
drop table temp_orderdatedim_v2;
create table temp_orderdatedim_v2 as
select *
from temp_ca_orderdatedim_v2
union
select *
from temp_sc_orderdatedim_v2;

select * from temp_orderdatedim_v2;


alter table temp_orderdatedim_v2 add (
    seasonid varchar (2),
    seasondescription varchar (10));

update temp_orderdatedim_v2 set seasonid = 'S1' where datenumber >= 1 and datenumber <= 31 and month >= 9 and month <= 11; 
update temp_orderdatedim_v2 set seasonid = 'S2' where datenumber >= 1 and datenumber <= 31 and month = 12 or month <= 2; 
update temp_orderdatedim_v2 set seasonid = 'S3' where datenumber >= 1 and datenumber <= 31 and month >= 3 and month <= 5; 
update temp_orderdatedim_v2 set seasonid = 'S4' where datenumber >= 1 and datenumber <= 31 and month >= 6 and month <= 8; 
update temp_orderdatedim_v2 set seasondescription = 'Spring' where seasonid = 'S1'; 
update temp_orderdatedim_v2 set seasondescription = 'Summer' where seasonid = 'S2';
update temp_orderdatedim_v2 set seasondescription = 'Autumn' where seasonid = 'S3'; 
update temp_orderdatedim_v2 set seasondescription = 'Winter' where seasonid = 'S4';

select * from temp_orderdatedim_v2;

-- Create Order Date Dimension
drop table orderdatedim_v2;
create table orderdatedim_v2 as 
select distinct orderdateid as date_id, day, month, year, seasonid, seasondescription
from temp_orderdatedim_v2;

select * from orderdatedim_v2;


-- Create Delivery Provider Dimension table
drop table deliveryproviderdim_v2;
create table deliveryproviderdim_v2 as 
select * from MONCHEF.delivery_provider;

select * from deliveryproviderdim_v2;


-- Create Category Dimension table
drop table categorydim_v2;
create table categorydim_v2 as
select distinct *
from category;

select * from categorydim_v2;


-- Create Product Category Bridge Dimension table
drop table productcategorybridgedim_v2;
create table productcategorybridgedim_v2 as select distinct * from monchef.product_category;

select * from productcategorybridgedim_v2;


-- Create Catering Order Dimension table
drop table ca_orderdim_v2;
create table ca_orderdim_v2 as
select distinct *
from catering_order;

select * from ca_orderdim_v2;

alter table ca_orderdim_v2 add (
    orderpricescaleid varchar2(10),
    orderpricescale varchar2(10),
    orderprice_description varchar2(50)
    );

update ca_orderdim_v2 set orderpricescaleid = 'OL' where ca_totalprice >=0 and ca_totalprice <=50;
update ca_orderdim_v2 set orderpricescaleid = 'OM' where ca_totalprice >=51 and ca_totalprice <=150;
update ca_orderdim_v2 set orderpricescaleid = 'OE' where ca_totalprice > 150;
update ca_orderdim_v2 set orderpricescale = '0-50' where orderpricescaleid = 'OL'; 
update ca_orderdim_v2 set orderpricescale = '51-150' where orderpricescaleid = 'OM';
update ca_orderdim_v2 set orderpricescale = '>150' where orderpricescaleid = 'OE';
update ca_orderdim_v2 set orderprice_description = 'Low Price Order' where orderpricescaleid = 'OL'; 
update ca_orderdim_v2 set orderprice_description = 'Medium Price Order' where orderpricescaleid = 'OM';
update ca_orderdim_v2 set orderprice_description = 'High Price Order' where orderpricescaleid = 'OE'; 

select * from ca_orderdim_v2;


-- Create School Canteen Order Dimension table
drop table sc_orderdim_v2;
create table sc_orderdim_v2 as
select distinct *
from school_canteen_order;

select * from sc_orderdim_v2;


-- Create Star Rating Dimension table
drop table starratingdim_v2;
create table starratingdim_v2  
( StarID Number(1),
 Star_Description Varchar2(15));
 
Insert Into starratingdim_v2 Values (0, 'Unknown');
Insert Into starratingdim_v2 Values (1, 'Poor');
Insert Into starratingdim_v2 Values (2, 'Not Good');
Insert Into starratingdim_v2 Values (3, 'Average');
Insert Into starratingdim_v2 Values (4, 'Good');
Insert Into starratingdim_v2 Values (5, 'Excellent');

select * from starratingdim_v2;


-- Create Product Dimension table
drop table productdim_v2;
create table productdim_v2 as
select distinct * from product;

select * from productdim_v2;

alter table productdim_v2 add (
    productpriceid varchar2(10),
    productpricescale varchar2(10),
    pricescale_description varchar2(50)
    );

update productdim_v2 set productpriceid = 'PL' where product_price < 10; 
update productdim_v2 set productpriceid = 'PM' where product_price >= 10 and product_price <=20; 
update productdim_v2 set productpriceid = 'PH' where product_price > 20;
update productdim_v2 set productpricescale = '<10' where productpriceid = 'PL'; 
update productdim_v2 set productpricescale = '10-20' where productpriceid = 'PM';
update productdim_v2 set productpricescale = '>20' where productpriceid = 'PH';
update productdim_v2 set pricescale_description = 'Low Price Product' where productpriceid = 'PL'; 
update productdim_v2 set pricescale_description = 'Medium Price Product' where productpriceid = 'PM';
update productdim_v2 set pricescale_description = 'High Price Product' where productpriceid = 'PH'; 

select * from productdim_v2;


-- Create Catering Orderline Bridge Dimension table
drop table ca_orderlinebridgedim_v2;
create table ca_orderlinebridgedim_v2 as
select distinct ca.ca_orderid, p.product_id, sr.starid
from ca_orderdim_v2 ca, productdim_v2 p, starratingdim_v2 sr;

select * from ca_orderlinebridgedim_v2;


-- Create Product Review Dimension
drop table ProductReviewDim_v2;
create table productreviewdim_v2 as 
select distinct review_no, review_text
from product_review;

select * from ProductReviewDim_v2;


-- Create Product Review Bridge Dimension
drop table ProductReviewBirdgeDim_v2;
create table ProductReviewBirdgeDim_v2 as
select distinct r.review_no, p.product_id
from productreviewdim_v2 r, productdim_v2 p;

select * from ProductReviewBirdgeDim_v2;


-- Create School Canteen Orderline Bridge Dimension table
drop table sc_orderlinebridgedim_v2;
create table sc_orderlinebridgedim_v2 as
select distinct sc.sc_orderid, p.product_id, sol.sol_lineprice
from sc_orderdim_v2 sc, productdim_v2 p, MONCHEF.school_canteen_orderline sol
where sc.sc_orderid = sol.sc_orderid;

select * from sc_orderlinebridgedim_v2;


-- FACT TABLES

-- ServiceCostDeliveryFact
select * from deliveryproviderdim_v2;
drop table tempservicedeliverycostfact_v2;
create table tempservicedeliverycostfact_v2 as select c.ca_orderdate, c.provider_id, c.ca_orderid, c.ca_totalprice, 
                                            d.provider_rate from catering_order c,
                                            monchef.delivery_provider d where c.provider_id = d.provider_id;
select * from tempservicedeliverycostfact_v2;

alter table tempservicedeliverycostfact_v2 add (OrderDateID varchar (10), DeliveryCost varchar(10));
update tempservicedeliverycostfact_v2 set orderdateid = to_char(ca_orderdate, 'DYYYMM');
update tempservicedeliverycostfact_v2 set deliverycost = round(ca_totalprice * provider_rate, 2);

drop table servicedeliverycostfact_v2;
create table servicedeliverycostfact_v2 as select s.orderdateid, s.provider_id, s.ca_orderid, 
                                        sum(s.deliverycost) as TotalServiceDeliveryCost from tempservicedeliverycostfact_v2 s
group by s.orderdateid, s.provider_id, s.ca_orderid;

select * from servicedeliverycostfact_v2;


-- Customer Fact
drop table customerfact_v2;
create table customerfact_v2 as select c.type_id as CustomerType_ID, a.address_id, c.customer_id, 
                                        count(a.address_id) as NumberofCustomers from monchef.customer_type ct, 
                                        customer c, monchef.address a 
where c.address_id = a.address_id and c.type_id = ct.type_id
group by c.type_id, a.address_id, c.customer_id;

select * from customerfact_v2;


-- CA Order Fact
drop table tempcaorderfact_v2;
create table tempcaorderfact_v2 as select c.ca_orderdate, co.col_lineprice, p.product_id, p.product_price, 
                                            c.provider_id, c.promo_code, c.ca_totalprice, c.ca_orderid, co.col_quantitysold
from catering_order c, monchef.delivery_provider d,  product p, catering_orderline co, product_review pr
where co.ca_orderid = c.ca_orderid and 
    d.provider_id = c.provider_id and
    co.product_id = p.product_id and
    co.product_id = pr.product_id;

select * from tempcaorderfact_v2;

alter table tempcaorderfact_v2 add (
    OrderDateID varchar (10)
);

update tempcaorderfact_v2 set orderdateid = to_char(ca_orderdate, 'DYYYMM');
select * from tempcaorderfact_v2;

drop table caorderfact_v2;
create table caorderfact_v2 as select c.orderdateid as Date_ID, c.promo_code, c.ca_orderid, c.provider_id, 
                            sum(c.col_lineprice) as TotalSales, count(distinct c.ca_orderid) as NumberofCateringOrders,
                            sum(c.col_quantitysold) as QuantitySold 
from tempcaorderfact_v2 c 
group by c.orderdateid, c.promo_code, c.ca_orderid, c.provider_id;

select * from caorderfact_v2;


-- Product Fact

-- Get average star rating for each product
drop table averagestarstable_v2;
create table averagestarstable_v2 as select pr.product_id, round(avg(pr.review_star), 0) as starid from product_review pr
group by pr.product_id;

select * from averagestarstable_v2;


drop table tempproductfact_v2;
create table tempproductfact_v2 as select p.product_id, p.product_price, a.starid from averagestarstable_v2 a, product p,
monchef.product_category pc
where p.product_id = a.product_id and
p.product_id = pc.product_id;

alter table tempproductfact_v2 add (productpriceid varchar (10));

update tempproductfact_v2 set productpriceid = 'PL' where product_price < 10; 
update tempproductfact_v2 set productpriceid = 'PM' where product_price >= 10 and product_price <=20; 
update tempproductfact_v2 set productpriceid = 'PH' where product_price > 20;

select * from tempproductfact_v2;


drop table productfact_v2;       
create table productfact_v2 as select p.starid, product_id, productpriceid, 
                                        count(product_id) as Numberofproducts from tempproductfact_v2 p
group by starid, product_id, productpriceid; 

select * from productfact_v2;


-- School Canteen Order Fact
drop table tempscorderfact_v2;
create table tempscorderfact_v2 as select a.address_id, c.sc_orderdate, co.sol_lineprice, p.product_id, p.product_price, 
                                            c.staff_id, c.status_id, c.type_id as paymenttypeid, c.customer_id, 
                                            cu.type_id as customertypeid, c.promo_code, c.sc_totalprice, 
                                            c.sc_orderid, co.sol_quantitysold
from monchef.address a, school_canteen_order c, monchef.delivery_type d,  product p, monchef.school_canteen_orderline co, 
        monchef.promotion pr, staff s, customer cu
where co.sc_orderid = c.sc_orderid and
    c.promo_code = pr.promo_code and
    d.delivery_id = c.delivery_id and
    co.product_id = p.product_id and
    c.staff_id = s.staff_id and
    c.customer_id = cu.customer_id and
    a.address_id = cu.address_id;
    
select * from tempscorderfact_v2;


alter table tempscorderfact_v2 add (
    OrderDateID varchar (10)
);
update tempscorderfact_v2 set orderdateid = to_char(sc_orderdate, 'DYYYMM');

select * from tempscorderfact_v2;


drop table scorderfact_v2;
create table scorderfact_v2 as select c.address_id, c.customer_id, c.orderdateid as Date_ID, c.paymenttypeid, c.customertypeid,
                                        c.staff_id, c.promo_code, c.sc_orderid, c.status_id, sum(c.sol_lineprice) as TotalSales,
                                        count(distinct c.sc_orderid) as NumberOfSchoolCanteenOrders, 
                                        sum(c.sol_quantitysold) as QuantitySold 
from tempscorderfact_v2 c 
group by c.address_id, c.customer_id, c.orderdateid, c.paymenttypeid, c.customertypeid, c.promo_code, c.sc_orderid, 
            c.staff_id, c.status_id;

select * from scorderfact_v2;



--------------------------------------------------------------------------
-- TASK 3A - OLAP with Level 0 Star Schema
--------------------------------------------------------------------------

-- Same queries but for lvl0 schema
-- What are the top 5 months that have the highest number of school canteen orders from a school customer? (LVL0)
SELECT *
FROM
    (SELECT od.month, ct.type_description, sum(f.NumberOfSchoolCanteenOrders) as Total_Number_Of_School_Canteen_Orders,
        DENSE_RANK() OVER (ORDER BY SUM(f.NumberOfSchoolCanteenOrders) DESC) AS Top_5_Months
    FROM scorderfact_v2 f, orderdatedim_v2 od, customertypedim_v2 ct
    WHERE f.Date_ID = od.Date_ID
    AND f.customertypeid = ct.type_id
    AND ct.type_description = 'School'
    GROUP BY od.month, ct.type_description)
WHERE Top_5_Months <= 5;


-- What is the top 10% of sales for orders in a school canteen order taken by male and female staff in March? (LVL0)
SELECT *
FROM(
    SELECT od.month, s.staff_gender, sum(f.TotalSales) as Total_Sales,
        PERCENT_RANK() OVER (ORDER BY SUM(f.TotalSales) DESC) AS "Percent Rank"
    FROM scorderfact_v2 f, orderdatedim_v2 od, staffdim_v2 s
    WHERE f.Date_ID = od.Date_ID
    AND f.staff_id = s.staff_id
    GROUP BY od.month, s.staff_gender)
WHERE "Percent Rank" < 0.1;


-- Show the total number of customers and the type of customers from different suburbs. (LVL0)
SELECT ct.type_description, a.suburb, sum(f.NumberOfCustomers) as Total_Number_Of_Customers
FROM customerfact_v2 f, addressdim_v2 a, customertypedim_v2 ct
WHERE f.customertype_id = ct.type_id
AND f.address_id = a.address_id
GROUP BY a.suburb, ct.type_description
ORDER BY Total_Number_Of_Customers DESC;



--------------------------------------------------------------------------
-- TASK 3B AND 3C - OLAP with Level 0 Star Schema
--------------------------------------------------------------------------

-- CUBE
SELECT 
 DECODE(GROUPING(p.promo_code), 1, 'All Promotion',
p.promo_code) As Promotion, 
 DECODE(GROUPING(od.month), 1, 'All Months',
od.month) AS Month,
 DECODE(GROUPING(dp.provider_description), 1, 'All Providers',
dp.provider_description) As Provider,
 SUM(ca.totalsales) as TotalSales
FROM caorderfact_v2 ca, promotiondim_v2 p, orderdatedim_v2 od, deliveryproviderdim_v2 dp 
WHERE ca.promo_code = p.promo_code
AND ca.date_id = od.date_id
AND ca.provider_id = dp.provider_id
GROUP BY CUBE (p.promo_code, od.month, dp.provider_description)
order by p.promo_code;


-- Partial Cube
SELECT
 DECODE(GROUPING(p.promo_code), 1, 'All Promotion',
p.promo_code) As Promotion, 
 DECODE(GROUPING(od.month), 1, 'All Months',
od.month) AS Month,
 DECODE(GROUPING(dp.provider_description), 1, 'All Providers',
dp.provider_description) As Provider,
 SUM(ca.totalsales) as TotalSales
FROM caorderfact_v2 ca, promotiondim_v2 p, orderdatedim_v2 od, deliveryproviderdim_v2 dp 
WHERE ca.promo_code = p.promo_code
AND ca.date_id = od.date_id
AND ca.provider_id = dp.provider_id
GROUP BY CUBE (od.month, dp.provider_description), p.promo_code
order by p.promo_code;



-- The total number of catering orders from each promotion, time period (year), and order price?
-- RollUp
SELECT
 DECODE(GROUPING(p.promo_code), 1, 'All Promotion',
p.promo_code) As Promotion, 
 DECODE(GROUPING(od.year), 1, 'All Years',
od.year) AS Year,
DECODE(GROUPING(cao.orderprice_description), 1, 'All Price Orders',
cao.orderprice_description) As OrderPrice, 
 SUM(caf.numberofcateringorders) as NumberOfCateringOrders
FROM caorderfact_v2 caf, promotiondim_v2 p, orderdatedim_v2 od, ca_orderdim_v2 cao
WHERE caf.promo_code = p.promo_code
AND caf.date_id = od.date_id
AND caf.ca_orderid = cao.ca_orderid
GROUP BY ROLLUP (od.year, cao.orderprice_description, p.promo_code)
order by p.promo_code;



-- Partial RollUp
SELECT
 DECODE(GROUPING(p.promo_code), 1, 'All Promotion',
p.promo_code) As Promotion, 
 DECODE(GROUPING(od.year), 1, 'All Years',
od.year) AS Year,
DECODE(GROUPING(cao.orderprice_description), 1, 'All Price Orders',
cao.orderprice_description) As OrderPrice, 
 SUM(caf.numberofcateringorders) as NumberOfCateringOrders
FROM caorderfact_v2 caf, promotiondim_v2 p, orderdatedim_v2 od, ca_orderdim_v2 cao
WHERE caf.promo_code = p.promo_code
AND caf.date_id = od.date_id
AND caf.ca_orderid = cao.ca_orderid
GROUP BY ROLLUP (od.year, cao.orderprice_description), p.promo_code
order by p.promo_code;



-- What are the total catering sales and cumulative total catering sales of Savoury dishes in each year?
--Cumulative aggregate
Select od.year,  SUM(caf.totalsales) as TotalCateringSales,
 TO_CHAR(SUM(SUM(caf.totalsales))
 OVER(ORDER BY od.year ROWS UNBOUNDED PRECEDING),
 '9,999,999.99') AS Cummulative_CateringSales
From caorderfact_v2 caf, orderdatedim_v2 od, categorydim_v2 c, ca_orderdim_v2 cad
Where caf.date_id = od.date_id
and caf.ca_orderid = cad.ca_orderid
and c.category_description = 'Savoury'
Group By od.year;


-- What are the total school canteen sales and cumulative total school canteen sales for business customer types every year?
-- Moving aggregate
Select od.year, c.type_description,  SUM(scf.totalsales) as TotalSchoolCanteenSales,
 TO_CHAR(AVG(SUM(scf.totalsales))
 OVER(ORDER BY od.year, c.type_description ROWS 2 PRECEDING),
 '9,999,999.99') AS Moving_1_Year_Avg
From scorderfact_v2 scf, orderdatedim_v2 od, customertypedim_v2 c
Where scf.date_id = od.date_id
and scf.customertypeid = c.type_id
and c.type_description = 'Business'
Group By od.year, c.type_description
order by od.year;


-- Cumulative aggregate
Select od.year, c.type_description,  SUM(scf.totalsales) as TotalSchoolCanteenSales,
 TO_CHAR(SUM(SUM(scf.totalsales))
 OVER(ORDER BY od.year, c.type_description ROWS UNBOUNDED PRECEDING),
 '9,999,999.99') AS Cummulative_CanteenSales
From scorderfact_v2 scf, orderdatedim_v2 od, customertypedim_v2 c
Where scf.date_id = od.date_id
and scf.customertypeid = c.type_id
and c.type_description = 'Business'
Group By od.year, c.type_description
order by od.year;

--------------------------------------------------------------------------
-- TASK 3D - OLAP with Level 0 Star Schema
--------------------------------------------------------------------------

-- ranking of each cuisine based on the monthly total number of sales for school canteen orders and the ranking of each 
-- customer type based on the monthly total number of sales for school canteen orders.
select cd.category_description, c.type_description,od.month,sum(s.totalsales) as SalesPerMonth,
rank() over (partition by cd.category_description order by sum(s.totalsales) desc) as SalesPerCategory,
rank() over (partition by c.type_description order by sum(s.totalsales) desc) as SalesPerCustomerType
from categorydim cd, productcategorybridgedim_v2 pcb, productdim_v2 p, sc_orderlinebridgedim_v2 sb, sc_orderdim_v2 so, 
        scorderfact_v2 s, orderdatedim_v2 od, customertypedim_v2 c
where s.sc_orderid = so.sc_orderid and
s.customertypeid = c.type_id and
so.sc_orderid = sb.sc_orderid and
sb.product_id = p.product_id and
p.product_id = pcb.product_id and 
pcb.category_id = cd.category_id and
s.date_id = od.date_id and
cd.category_description in ('Thai','Indonesian','Korean') 
group by cd.category_description, c.type_description,od.month;

select * from scorderfact_v2;

-- customertype with the highest number of orders by month
select c.type_description, od.month,sum(s.numberofschoolcanteenorders) as NumberOfOrders, 
dense_rank() over (partition by c.type_description order by sum(s.numberofschoolcanteenorders) desc) as rankbycustomertype,
rank() over (partition by od.month order by sum(s.numberofschoolcanteenorders) desc) as rankbymonth
from customertypedim_v2 c, scorderfact_v2 s, orderdatedim_v2 od
where s.customertypeid = c.type_id and
s.date_id = od.date_id
group by c.type_description, od.month;

--------------------------------------------------------------------------
-- END OF SQL FILE
--------------------------------------------------------------------------