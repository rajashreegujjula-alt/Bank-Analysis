create database BANK_ANALYTICS;

use bank_analytics;

select * from finance_1;
select * from finance_2;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- total  opening accounts
select count(open_acc) from finance_2;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- total payment
select CONCAT(ROUND(SUM(TOTAL_PYMNT) / 1000000), 'M')AS Total_pymnt from finance_2;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- loan amount 
select CONCAT(ROUND(SUM(LOAN_AMNT) / 1000000), 'M') AS LOAN_AMOUNT from finance_1;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- funded amount 
select CONCAT(ROUND(SUM(FUNDED_AMNT) / 1000000), 'M') AS FUNDED_AMOUNT from finance_1;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TOTAL FUNDED AMOUNT BY HOME OWNERSHIP
select HOME_OWNERSHIP , concat(ROUND(SUM(funded_amnt) /1000000),'M') AS TOTAL_FUNDED_AMT
FROM finance_1
JOIN
finance_2
ON finance_1.ID=finance_2.ID
group by home_ownership;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KPI-1
-- year wise loan amount 

SELECT RIGHT(LAST_PYMNT_D, 2) AS YEAR, CONCAT(ROUND(SUM(LOAN_AMNT) / 1000000,1), 'M') AS LOAN_AMOUNT
FROM finance_2
JOIN 
finance_1
ON finance_2.ID = finance_1.ID
GROUP BY RIGHT(LAST_PYMNT_D, 2)
ORDER BY RIGHT(LAST_PYMNT_D, 2);

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KPI-2
-- Total Payment for Verified Status Vs Total Payment for Non Verified Status

select * from finance_1;
select * from finance_2;

SELECT VERIFICATION_STATUS, CONCAT(ROUND(SUM(TOTAL_PYMNT) / (SELECT SUM(TOTAL_PYMNT) FROM finance_2) * 100, 2), '%') AS TOTAL_PYMNT
FROM 
finance_1
JOIN 
finance_2
ON finance_1.ID = finance_2.ID
WHERE VERIFICATION_STATUS IN ('Verified', 'Not Verified')
GROUP BY VERIFICATION_STATUS
ORDER BY VERIFICATION_STATUS;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
-- KPI-3
-- Grade and sub grade wise revol_bal

select * from finance_1;
select * from finance_2;

-- GRADE WISE REVOL_BAL
select GRADE , concat(ROUND( SUM(REVOL_BAL)/1000000,1),"M") AS REVOL_BAL
FROM finance_1
JOIN
finance_2
ON finance_1.ID=finance_2.ID
group by grade
order by grade;

-- Grade and sub grade wise revol_bal
select grade,sub_grade , concat(ROUND( SUM(REVOL_BAL)/1000000,1),"M") AS REVOL_BAL
FROM finance_1
JOIN
finance_2
ON finance_1.ID=finance_2.ID
group by grade, sub_grade
order by grade,sub_grade;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- KPI-4
-- State wise and month wise loan status

select * from finance_1;
select * from finance_2;

SELECT 
    f1.ADDR_STATE AS STATE,
    SUBSTRING(f2.LAST_PYMNT_D, 1, 3) AS MONTH,  -- Extracts the first three characters for the month
    COUNT(CASE WHEN f1.LOAN_STATUS = 'FULLY PAID' THEN 1 END) AS FULLY_PAID_COUNT,
    COUNT(CASE WHEN f1.LOAN_STATUS = 'CHARGE OFF' THEN 1 END) AS CHARGE_OFF_COUNT,
    COUNT(CASE WHEN f1.LOAN_STATUS = 'CURRENT' THEN 1 END) AS CURRENT_COUNT,
    COUNT(f1.LOAN_STATUS) AS TOTAL_LOAN_COUNT  -- Total loan count
FROM 
    finance_1 f1
JOIN 
    finance_2 f2 ON f1.ID = f2.ID
WHERE 
    f2.LAST_PYMNT_D IS NOT NULL  -- Ensure we are not counting NULL values
GROUP BY 
    f1.ADDR_STATE, MONTH
ORDER BY 
    f1.ADDR_STATE, MONTH;
------------------------------------------------------------------------------------    
-- STATES WSIE LOAN STATUS
 SELECT 
    f1.ADDR_STATE,
    COUNT(CASE WHEN f1.LOAN_STATUS = 'FULLY PAID' THEN 1 END) AS FULLY_PAID_COUNT,
    COUNT(CASE WHEN f1.LOAN_STATUS = 'CHARGE OFF' THEN 1 END) AS CHARGE_OFF_COUNT,
    COUNT(CASE WHEN f1.LOAN_STATUS = 'CURRENT' THEN 1 END) AS CURRENT_COUNT,
    COUNT(f1.LOAN_STATUS) AS TOTAL_LOAN_COUNT  -- Total loan count
FROM 
    finance_1 f1
JOIN 
    finance_2 f2 ON f1.ID = f2.ID
WHERE 
    f2.LAST_PYMNT_D IS NOT NULL  -- Ensure we are not counting NULL values
GROUP BY 
    f1.ADDR_STATE
ORDER BY 
    f1.ADDR_STATE;
    ------------------------------------------------
    -- MONTH WISE LOAN STAUES 
    WITH LoanStatusCounts AS (
    SELECT 
        f1.ADDR_STATE,
        SUBSTRING(f2.LAST_PYMNT_D, 1, 3) AS MONTH,
        COUNT(CASE WHEN f1.LOAN_STATUS = 'FULLY PAID' THEN 1 END) AS FULLY_PAID_COUNT,
        COUNT(CASE WHEN f1.LOAN_STATUS = 'CHARGE OFF' THEN 1 END) AS CHARGE_OFF_COUNT,
        COUNT(CASE WHEN f1.LOAN_STATUS = 'CURRENT' THEN 1 END) AS CURRENT_COUNT,
        COUNT(f1.LOAN_STATUS) AS TOTAL_LOAN_COUNT
    FROM 
        finance_1 f1
    JOIN 
        finance_2 f2 ON f1.ID = f2.ID
    WHERE 
        f2.LAST_PYMNT_D IS NOT NULL  -- Ensure we are not counting NULL values
    GROUP BY 
        f1.ADDR_STATE, MONTH
)

SELECT 
    MONTH,
    SUM(FULLY_PAID_COUNT) AS TOTAL_FULLY_PAID_COUNT,
    SUM(CHARGE_OFF_COUNT) AS TOTAL_CHARGE_OFF_COUNT,
    SUM(CURRENT_COUNT) AS TOTAL_CURRENT_COUNT,
    SUM(TOTAL_LOAN_COUNT) AS TOTAL_LOAN_COUNT
FROM 
    LoanStatusCounts
GROUP BY 
    MONTH
ORDER BY 
    MONTH asc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KPI-5
-- Home ownership Vs last payment date stats

select * from finance_1;
select * from finance_2;

select HOME_OWNERSHIP, count(LAST_PYMNT_D) AS LAST_PAYMENT_DATE
FROM finance_1
join
finance_2
ON finance_1.ID=finance_2.ID
group by home_ownership
order by home_ownership;

---------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- THE   END---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
