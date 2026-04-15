create database sqlpro;
use sqlpro;
create table zomato(
restaurantid int,
restaurantname varchar(300),
countrycode int,
city varchar(100),
cuisines varchar(100),
has_table_booking varchar(10),
has_online_delivery varchar(100),
is_delivering_now varchar(10),
price_range varchar(20),
votes int,
avg_cost_for_two int,
rating int,
datekey_opening varchar(20),
datef text);



  LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/zomato.csv'
INTO TABLE zomato
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
  restaurantid,
  restaurantname,
  countrycode,
  city,
  cuisines,
  has_table_booking,
  has_online_delivery,
  is_delivering_now,
  price_range,
  votes,
  avg_cost_for_two,
  rating,
  @datekey_opening,
  @datef,
  @extra1,
  @extra2
)
SET
  datekey_opening = NULLIF(@datekey_opening, ''),
  datef = NULLIF(@datef, '');
  
select * from zomato;

-- KPI QUERIES

-- TOTAL RESTAURANTS

SELECT COUNT(RESTAURANTID) FROM zomato;

-- TOTAL COUNTRY COUNT

select count(distinct Countryname) from zomato;

-- TOTAL CITY COUNT

select count(distinct city) from zomato;

-- TOTAL CUISINES 

select count(distinct cuisines) from zomato;

-- AVG RATING

select round(avg(rating),1) from zomato;

-- Q1 COUNTRY MAP TABLE

-- CREATING COUNTRYMAP TABLE 

create table country_map(
Countrycode int primary key,
Countryname varchar(50)); 

insert into country_map values(1,"India"),
(14,"Australia"),
(30,"Brazil"),
(37,"Canada"),
(94,"Indonesia"),
(148,"New Zealand"),
(162,"Phillipines"),
(166,"Qatar"),
(184,"Singapore"),
(189,"South Africa"),
(191,"Sri Lanka"),
(208,"Turkey"),
(214,"UAE"),
(215,"United Kingdom"),
(216, "United States");
select * from country_map;

-- ADDING A COLUMN COUNTRYNAME IN ZOMATO 

ALTER TABLE zomato
ADD countryname VARCHAR(50);

-- UPDATING THE COUNTRYNAME COLUMN IN ZOMATO TABLE

UPDATE zomato as z
JOIN country_map as c
ON z.countrycode = c.countrycode
SET z.countryname = c.countryname;
select * from zomato;
-- Q2
-- A.YEAR
-- B.MONTHNUMBER
-- C.MONTHNAME
-- D.QUARTER(Q1,Q2,..)
-- E.YEARMONTH
-- F.WEEKNUMBER
-- G.WEEKDAYNAME
-- H.FINANCIAL MONTH(FM1,FM2,..)
-- I.FINANCIAL QUARTER

-- CREATING COLUMNS

alter table zomato 
add column yearno int,
add column monthno int,
add column monthname varchar(20),
add column quarterno varchar(20),
add column yearmon varchar(40),
add column weekdayno int,
add column weekdayname varchar(30),
add column finmonth varchar(30),
add column finquarter varchar(30);

update zomato set datef=str_to_date(datef,"%d-%m-%Y");

-- UPDATING THE TABLE BASED ON CONDITIONS

update zomato set yearno=year(datef),
monthno=month(datef),
monthname=monthname(datef),
quarterno=concat('Q',quarter(datef)),
yearmon=date_format(datef,'%Y-%b'),
weekdayno=weekday(datef),
weekdayname=dayname(datef),
finmonth =
    CASE
        WHEN MONTH(datef) >= 4 THEN CONCAT('FM', MONTH(datef) - 3)
        ELSE CONCAT('FM', MONTH(datef) + 9)
    END,
finquarter =
    CASE
        WHEN MONTH(datef) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(datef) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(datef) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END;
 select * from zomato;   
    -- Q3 NUMBER OF RESTAURANTS BASED ON CITY AND COUNTRY
    
    -- COUNT OF RESTAURANTS BASED ON COUNTRYNAME
    
    select countryname,count(restaurantid) as Total_count from zomato group by countryname;
    
    -- TOP 5 COUNTRIES BASED ON COUNT OF RESTAURANTS
    
    select countryname,ct from 
    (select countryname,count(*) as ct,dense_rank() over(order by count(*) desc) as dr from zomato group by countryname) as t
    where dr<=5;
    
    -- COUNT OF RESTAURANTS BASED ON CITY
    
    select city,count(restaurantid) as res_count from zomato group by city;
    
    --  TOP 10 CITIES BASED ON COUNT OF RESTAURANTS 
    
     select city,total_ct from
     (select city,count(*) as total_ct,dense_rank() over(order by count(*) desc) as dr from zomato group by city)
     as temp
     where dr<=10 limit 10;
     
     -- Q4 NUMBER OF RESTAURANTS BASED ON YEAR,QUARTER,MONTH
     
     -- COUNT OF RESTAURANTS CALENDER-WISE(YEAR,MONTHNAME,QUARTER)
     
     select yearno,quarterno,monthname,count(*) as total_ct from zomato group by yearno,quarterno,monthname;
     
     -- COUNT OF RESTAURANTS BASED ON YEAR
     
     select yearno,count(*) as ct from zomato group by yearno order by yearno;
     
     -- COUNT OF RESTAURANTS BASED ON QUARTER
     
     select quarterno,count(*) as ct from zomato group by quarterno order by quarterno;
     
     -- COUNT OF RESTAURANTS BASED ON MONTHNAME
     
     select monthname,count(*) as ct from zomato group by monthname;
     
     -- Q5 COUNT OF RESTAURANTS BASED ON AVG RATING
	
     select rating,COUNT(*) AS restaurant_count FROM zomato group by rating order by rating DESC;
     
     -- Q6 CREATING BUCKET BASED ON AVG RATING
     
     select case 
     when avg_cost_for_two < 1000 then "Low-cost"
     when avg_cost_for_two between 1000 and 2000 then "Mid-cost"
     when avg_cost_for_two between 2001 and 3000 then "High-cost"
     when avg_cost_for_two between 3001 and 6000 then "Expensive"
     when avg_cost_for_two between 6001 and 200000 then "Most Expensive"
     else "First-class" end as avg_bucket_price,count(*) as total_res from zomato group by avg_bucket_price;
     
     -- Q7 PERCENTAGE OF RESTAURANTS BASED ON HAS_TABLE_BOOKING
     
     select has_table_booking,round(count(*) *100.0/(select count(*) from zomato),2) as percentage from zomato group by has_table_booking;
     
     -- Q8 PERCENTAGE OF RESTAURANTS BASED ON HAS_ONLINE_DELIVERY
     
     select has_online_delivery,round(count(*) *100.0/(select count(*) from zomato),2) as percentage from zomato group by has_online_delivery;
     
     -- Q9 DEVELOP CHARTS BASED ON CUISINES,CITY,RATING
     
     -- CUISINES BASED ON SUM OF RATING HAVING SUM OF RATING GREATER THAN 1000
     
     select cuisines,sum(rating) as total_rating from zomato group by cuisines having total_rating >1000;
     
     -- CUISINES BASED ON TOP 10 AVG RATING
     
     select cuisines,avg(rating) as avg_rating from zomato group by cuisines order by avg_rating desc limit 10;
     
     -- AVG RATING BASED ON CITY 
     
     select city,avg(rating) as avg_rating from zomato group by city;
     
     -- TOP 10 CITIES BASED ON AVG RATING HAVING AVG RATING GREATER THAN 4
     
     select city,round(avg(rating),2) as avg_rating from zomato group by city having avg_rating> 4 order by avg_rating desc limit 10;