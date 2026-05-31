create database banks;
use dcd;
select count(*) from dbd;
SELECT * FROM DBD;

#-----KPI'S----------
#----------1.TOTAL-CREDIT AMOUNT----------
create view KPI_1 AS(
select `Transaction Type`,concat(round(sum(amount/1000000),2)," M")Total_Credit_Amount from dbd
where `transaction type`="credit"
group by 1);

#----------2.TOTAL-DEBIT AMOUNT----------
create view KPI_2 AS(
select `Transaction Type`,concat(round(sum(amount/1000000),2)," M")Total_Debit_Amount from dbd
where `transaction type`="Debit"
group by 1);

#----------3.CREDIT-DEBIT-RATIO----------
create view KPI_3 AS(
SELECT 
   round(SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END) /
	SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END),4) AS Credit_to_Debit_Ratio
FROM dbd);

#----------4.Net-Transaction Amount----------
create view KPI_4 AS(
SELECT 
  concat(round((SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END) -
    SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END))/1000,2)," K") AS `Net Transaction Amount`
FROM dbd);

#---------5.Account Activiy Ratio--------
create view KPI_5 AS(
select `Account Number`,
    round(COUNT(*) / MAX(Balance),6) AS Account_Activity_Ratio from dbd
    group by 1);
    
    
#---------6.1.Transactions Per Day----------
create view `KPI_6.1` AS(
select date(`Transaction Date`)Dates,count(*) AS Transactions_Per_Day from dbd
group by 1
order by 1);
 
 #---------6.2.Transactions Per Week----------
 create view `KPI_6.2` AS(
 select week(`Transaction Date`)Week_Wise_Transactions,count(*)Transactions_Per_Week from dbd
 group by 1
 order by 1); 
 
#---------6.3.Transactions Per Month----------
create view `KPI_6.3` AS(
select months,Transactions_Per_Month from
(select month(`Transaction Date`),monthname(`Transaction Date`)Months,count(*)Transactions_Per_Month from dbd
group by 1,2
order by 1)as abc
order by 2 desc);
#------or------
SELECT 
    DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Transaction_Month,
    COUNT(*) AS Transactions_Per_Month
FROM dbd
GROUP BY 1
order by 2;

#-------7.Transaction Amount By Branch-----
create view KPI_7 AS(
select ifnull(Branch,"Grand Total")as Branch,
concat(round(sum(amount/1000000),2)," M")Transaction_Volume from dbd
group by Branch with rollup
order by 2 desc);
SELECT * FROM KPI_7;

#-----8.Transaction Amount By Bank-----
create view KPI_8 AS(
select ifnull(`Bank Name`,"Grand Total") as `Bank Name`,
concat(round(sum(amount/1000000),2)," M")Transaction_Volume from dbd
group by `Bank Name` with rollup
order by 2 desc);

#-----9.Transaction Method Distribution----
create view KPI_9 AS(
select `Transaction Method`,count(*) as trans_count from dbd
group by 1
order by 2 desc);

#-----10.Branch Transaction Growth----
create view KPI_10 AS(
SELECT 
Branch,
DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Month,
concat(round(sum(amount/1000000),2)," M") AS Total_Transaction_Amount,
ifnull(concat(round(LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY
DATE_FORMAT(`Transaction Date`, '%Y-%m'))/1000000,2),"M"),"No Previous Year Data") AS Prev_Month_Amount,
ifnull(concat(ROUND(
(SUM(Amount) - LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(`Transaction Date`, '%Y-%m')))/
NULLIF(LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(`Transaction Date`, '%Y-%m')), 0)*100, 
2),"%"),"No Previous Year Data") AS Growth_Percentage
FROM dbd
GROUP BY 1,2
ORDER BY 1,2);

#-----11.High Risk Transaction Flag----
create view KPI_11 AS(
select `Account Number`,Branch,Amount,`Transaction Type`,
case 
when Amount>4000 THEN "High Risk"
else "Normal"
end "Risk Flag"
from dbd
ORDER BY AMOUNT DESC);

#-----12.Suspicious Transaction Frequency-----
create view KPI_12 AS(
select Transaction_Month,count(*)as cnt from
(SELECT 
DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Transaction_Month,
case 
when Amount>4000 THEN "High Risk"
else "Normal"
end "Risk Flag"
from dbd)as abc
where `Risk Flag`="High Risk"
group by 1
order by 1);
    


