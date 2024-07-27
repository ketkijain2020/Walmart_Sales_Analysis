create database if not exists WalmartSaleData;

create table if not exists Sales(
    invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(20) not null,
    customer_type varchar(20) not null,
    gender varchar(10) not null,
    product_line varchar(50) not null,
    unit_price DECIMAL(10, 2) not null,
    quantity int not null,
    tax FLOAT(6, 4) not null,
    total DECIMAL(10, 2) not null,
    d_date date not null,
    T_time time not null,
    payment_method varchar(20) not null,
    cogs DECIMAL(10, 2) not null,
    gross_margin_percentage FLOAT(11,9),
    gross_income DECIMAL(10,2) not null,
    rating FLOAT(2,1)
);

-- ---------------------------------------------------------------------
-- ---------FEATURE ENGINEERING-----------------------------------------

SELECT 
     T_time,
     (Case 
		  when `T_time` BETWEEN "00:00:00" and "12:00:00" then "Morning"
          when `T_time` BETWEEN "12:01:00" and "18:00:00" then "Afternoon"
          else "Evening"
	End )  As time_of_date
from Sales;
-- -------------------------------------------------------------------
-- ----------time_of_day---------------------------------------------
ALTER TABLE Sales add column time_of_day varchar(20);

update Sales
set time_of_day = (
    Case 
		  when `T_time` BETWEEN "00:00:00" and "12:00:00" then "Morning"
          when `T_time` BETWEEN "12:01:00" and "18:00:00" then "Afternoon"
          else "Evening"
	End
);
-- ------------------------------------------------------------------------
-- ----------day_name---------------------------------------------

alter table sales add column day_name varchar(20);

update Sales
set day_name = dayname(d_date);

-- ---------------------------------------------------------------------
-- -----------month_name-----------------------------------------------

alter table sales add column month_name varchar(15);

update Sales
set month_name = monthname(d_date);

-- ------------------------------------------------
-- --------------EDA------------------------------

-- How many unique cities does the data have?

select 
   distinct city 
from Sales;

-- In which city is each branch?

select 
   distinct city , branch
from Sales;

-- ---------------------------------------------------
-- ----------PRODUCT---------------------------------

-- How many unique product lines does the data have?
 select
     count(distinct product_line)
from sales;

-- What is the most common payment method?

select  payment_method ,count(payment_method) as Count
from sales group by payment_method order by Count Desc;

-- Most common method is cash

-- What is the most selling product line?
select product_line , count(product_line) as count
from Sales group by product_line order by count desc;

-- Fashion Accessories are most sold product line

-- What is the total revenue by month?

select month_name as month , sum(total) as total_revenue
from Sales group by month_name;

-- What month had the largest COGS?

select month_name as month , sum(cogs) as cogs from Sales 
group by month_name order by cogs desc;

-- What product line had the largest revenue?

select product_line , sum(total) as total_revenue
from Sales group by product_line order by total_revenue desc;

-- What is the city with the largest revenue?

select city , sum(total) as total_revenue
from sales group by city order by total_revenue desc; 

-- What product line had the largest VAT?

select product_line , avg(tax) as VAT from sales
group by product_line order by VAT desc;

-- Which branch sold more products than average product sold?

select branch , sum(quantity) as product_sold from Sales group by branch
having sum(quantity) > (select avg(quantity) from Sales);

-- What is the most common product line by gender?

select gender , product_line , count(gender) as gcount from Sales
group by gender , product_line order by gcount desc;

-- What is the average rating of each product line?

select product_line , round(avg(rating),2) as Avg_ratings from Sales
group by product_line order by Avg_ratings desc;

-- ---------------------------------Sales---------------------------------------------
-- Number of sales made in each time of the day per weekday

select time_of_day , count(*) as total_Sale from Sales
where day_name = "friday" -- can have any day--
group by time_of_day order by total_Sale desc;

-- Which of the customer types brings the most revenue?
select customer_type , sum(total) as revenue from Sales
group by customer_type order by revenue desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
Select city , avg(tax) as VAT from Sales 
group by city order by VAT desc;

-- Which customer type pays the most in VAT?
select customer_type , count(customer_type) as customer_count , avg(tax) as vat  from Sales
group by customer_type 
order by vat desc;



-- ------------------------Customer--------------------
-- How many unique customer types does the data have?

select count(distinct customer_type) from Sales;

-- How many unique payment methods does the data have?
select distinct payment_method from Sales;

-- What is the most common customer type?

select customer_type , count(*) as customer_count from Sales 
group by customer_type 
order by customer_count desc;

-- Which customer type buys the most?

select customer_type , sum(quantity) as buy from Sales
group by customer_type 
order by buy desc;

-- What is the gender of most of the customers?
select gender , count(gender) as customer_count from Sales
group by gender

-- What is the gender distribution per branch?

SELECT branch , gender , count(gender) as customer_count 
from Sales Group by branch , gender 
order by branch asc;

-- Which time of the day do customers give most ratings?

Select time_of_day , count(rating) as ratings_count from Sales
group by time_of_day
order by ratings_count desc;

-- Which time of the day do customers give most ratings per branch?

Select branch, time_of_day , count(rating) as ratings_count from Sales
group by branch , time_of_day
order by branch asc, ratings_count desc;

-- Which day fo the week has the best avg ratings?

Select day_name , round(avg(rating),2) as avg_ratings from Sales
group by day_name
order by avg_ratings desc;

-- Which day of the week has the best average ratings per branch?
Select branch, day_name , avg(rating) as avg_ratings from Sales
group by branch , day_name
order by branch asc, avg_ratings desc;

