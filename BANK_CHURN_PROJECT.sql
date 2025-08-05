---------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------ALL CASE STUDY QUETIONS ----------------------------------------------------------------------



-- overall churn percentage
 select round(COUNT(*)*100.0/(select COUNT(*) from bank_churn),2) as churn_rate from bank_churn
 where exited =1



 --Q1-- basing of geographical area chrun anaysis
 select geography,count(*)as geography,sum(case when exited =1 then  1 else 0 end)  as churned,
 round(sum(case when exited =1 then  1 else 0 end)*100.0/count(*),3) as churn_rate
 from bank_churn
 group by geography


  --Q2-- Effect of customer loyality point earned by customers  on churn
select * from 
(select rownumber,customerid,point_earned,
 DENSE_RANK() over(order by point_earned desc) as ranked from bank_churn
 where exited =1)  ttt
 where ranked <20


 --Q3-- impact  of customer satisfaction rate
select Satisfaction_Score,count(*) as total ,sum(case when exited =1 then 1 else 0 end) as churned 
,round(sum(case when exited =1 then 1 else 0 end)*100.0/ count(*),3) as churn_percentage from bank_churn
group by Satisfaction_Score
order by Satisfaction_Score


--Q4-- finding churn basing on  tenure of customers
select tenure,sum(case when exited =1 then 1 else 0 end) as customer_churn from bank_churn
group by tenure
order by tenure


--Q5--  Finding  customers who have high probability of leaving the bank basing on parramters like
    --   is a activemember, satisfaction score and compaints  
  CREATE PROCEDURE HighRisky_Customers
AS
BEGIN
    WITH RiskyCustomers AS (
        SELECT *
        FROM bank_churn
        WHERE 
            IsActiveMember = 0
            AND Satisfaction_Score <= 2
            AND Complain = 1
            AND Exited = 0
    )
    SELECT CustomerId, Age, Geography, Balance, Point_Earned
    FROM RiskyCustomers;
END;

exec  HighRisky_Customers


--Q6-- basing on differnet age groups finding churn rate
-- churn rate basing  on age group
select 
   case 
      when age  between 18 and 30 then  '18-30'
	  when age  between 31 and 45 then  '31-45'
	   when age  between 46 and 60 then  '46-60'
	   else '60+'
   end as  age_group,
   count(*) as total,
   sum( case when exited =1 then 1 else 0 end) as churned,
   round(sum( case when exited =1 then 1 else 0 end)*100.0/ count(*),2) as rate_of_churn from bank_churn
   group by   case 
      when age  between 18 and 30 then  '18-30'
	  when age  between 31 and 45 then  '31-45'
	   when age  between 46 and 60 then  '46-60'
	   else '60+'
   end


-- Q7-- classifying customers as below and above average  on avg credit score 
select credit_range,count(*) as total from
(select  exited,customerid,creditscore,
         case
		    when CreditScore >= (select  avg(creditscore) as avg_c from bank_churn) then 'below avg'
			else 'above avg'  end  as  credit_range from bank_churn) ttt
			where exited =1
			group by credit_range 
 (select  avg(creditscore) as avg_c from bank_churn)


 --8-- checking churn rate for customers with and without  credit card


select hascrcard,count(*) as total_customers, sum(case  when exited =1 then 1 else 0 end) as churned,
round(sum(case  when exited =1 then 1 else 0 end)*100.0/count(*),2) as churn_rate
from bank_churn
group by  hascrcard


-- 9-- gender wise churn analysis in different geographical areas 
select
    Geography,
    Gender,
    count(*) AS Total_Customers,
    sum(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
   round(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) /count(*), 2) AS Churn_Rate_Percent
from 
    bank_churn
group by
    Geography, Gender
order by 
    Geography, Gender;
