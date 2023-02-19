/*
SQL porfolio project1.
download credit card transactions dataset from below link :
https://www.kaggle.com/datasets/thedevastator/analyzing-credit-card-spending-habits-in-india
*/

select min(transaction_date) as first_transaction_date,
max(transaction_date) as last_transaction_date
from credit_card_transactions;
--2013-10-04 to	2015-05-26

select distinct card_type
from credit_card_transactions;
--Silver
--Signature
--Gold
--Platinum

select distinct exp_type
from credit_card_transactions;
--Entertainment
--Food
--Bills
--Fuel
--Travel
--Grocery

select count(distinct city) 
from credit_card_transactions
--986 distinct cities

select * 
from credit_card_transactions;


--1- write a query to print top 5 cities with highest spends and their percentage 
--   contribution of total credit card spends 
with city_table as
(select city, sum(amount) as total_spend
from credit_card_transactions
group by city),
total_table as
(select SUM(amount) as total_amount
from credit_card_transactions)
select top 5 city_table.*,
ROUND(city_table.total_spend*1.0/total_table.total_amount*100,2) as percentage_contribution
from city_table
inner join total_table on 1=1
order by city_table.total_spend desc;

--2- write a query to print highest spend month and amount spent in that month 
--   for each card type
with year_month as 
(select card_type, 
DATEPART(YEAR, transaction_date) as year, 
DATEPART(MONTH, transaction_date) as month,
SUM(amount) as total_spend
from credit_card_transactions
group by card_type, DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date)
)
select * from
(select *, RANK() over(partition by card_type order by total_spend desc) as rn from year_month) ranked_table
where rn = 1;

--3- write a query to print the transaction details(all columns from the table)
--   for each card type when it reaches a cumulative of 1000000 total spends
--   (We should have 4 rows in the o/p one for each card type)
with transaction_table as
(select *,
sum(amount) over(partition by card_type order by transaction_date, transaction_id) as total_spend
from credit_card_transactions)
select * from (select *, rank() over(partition by card_type order by total_spend) as rn from transaction_table where total_spend >= 1000000) A
where rn = 1;

--4- write a query to find city which had lowest percentage spend 
--   for gold card type
with card_table as
(select city, card_type, sum(amount) as amount,
sum(case when card_type = 'Gold' then amount end) as gold_amount
from credit_card_transactions
group by city, card_type
)
select top 1 city, 
sum(gold_amount)*1.0/sum(amount) as gold_ratio
from card_table
group by city
having sum(gold_amount) is not null
order by gold_ratio;


--5- write a query to print 3 columns:  
--city, highest_expense_type , lowest_expense_type 
--(example format : Delhi , bills, Fuel)
with exp_table as
(select city, exp_type, SUM(amount) as total_amount
from credit_card_transactions
group by city, exp_type
)
select city,
max(case when rn_desc=1 then exp_type end) as highest_exp_type,
max(case when rn_asc=1 then exp_type end) as lowest_exp_type
from
(select *,
RANK() over(partition by city order by total_amount desc) as rn_desc,
RANK() over(partition by city order by total_amount asc) as rn_asc
from exp_table) A
group by city;


--6- write a query to find percentage contribution of spends by 
--   females for each expense type
with expense_type_table as
(select gender, exp_type, 
sum(amount) as total_amount,
sum(case when gender = 'F' then amount end) as total_female_amount
from credit_card_transactions
group by gender, exp_type
)
select exp_type,
sum(total_female_amount)*1.0/SUM(total_amount)*100 as percentage_contribution_by_females
from expense_type_table
group by exp_type
having sum(total_female_amount) is not null
order by percentage_contribution_by_females desc;

--alternate solution
select exp_type,
sum(case when gender='F' then amount else 0 end)*1.0/sum(amount)*100 as percentage_female_contribution
from credit_card_transactions
group by exp_type
order by percentage_female_contribution desc;

--7- which card and expense type combination saw 
--   highest month over month growth in Jan-2014
with card_table as
(select card_type, exp_type,
DATEPART(YEAR, transaction_date) as year,
DATEPART(MONTH, transaction_date) as month,
SUM(amount) as total_spend
from credit_card_transactions
group by card_type, exp_type, DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date)
)
select top 1 *, (total_spend - prev_month_spend) as mom_growth
from
(select *,
lag(total_spend, 1) over(partition by card_type, exp_type order by year, month) as prev_month_spend
from card_table) A
where prev_month_spend is not null and year = 2014 and month = 1
order by mom_growth desc;

--8- during weekends which city has highest total spend to total no of transcations ratio 
select top 1 city , sum(amount)*1.0/count(1) as ratio
from credit_card_transactions
where datepart(weekday,transaction_date) in (1,7)
--where datename(weekday,transaction_date) in ('Saturday','Sunday')
group by city
order by ratio desc;

--10- which city took least number of days to reach its 500th transaction 
--    after the first transaction in that city
with card_table as (
select *
,row_number() over(partition by city order by transaction_date,transaction_id) as rn
from credit_card_transactions)
select top 1 city,datediff(day,min(transaction_date),max(transaction_date)) as datediff1
from card_table
where rn=1 or rn=500
group by city
having count(1)=2
order by datediff1 








select * ,
ROW_NUMBER() over(partition by city order by transaction_date) as rn
from credit_card_transactions





select * 
from credit_card_transactions
order by transaction_id asc;

