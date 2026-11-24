CREATE DATABASE IF NOT EXISTS bank_loan_db;

USE bank_loan_db;

CREATE TABLE IF NOT EXISTS bank_loan (
    Loan_ID VARCHAR(30) PRIMARY KEY,
    State VARCHAR(50),
    Application_Type VARCHAR(50),
    Emp_Length VARCHAR(30),
    Emp_Title VARCHAR(150),
    Loan_Grade VARCHAR(10),
    Home_Ownership VARCHAR(50),
    Issue_Date DATE,
    Last_Credit_Pull_Date DATE,
    Last_Payment_Date DATE,
    Loan_Status VARCHAR(50),
    Next_Payment_Date DATE,
    Member_ID BIGINT,
    Purpose VARCHAR(100),
    Loan_Sub_Grade VARCHAR(10),
    Loan_Term VARCHAR(30),
    Verification_Status VARCHAR(50),
    Annual_Income DECIMAL(15,2),
    Debt_To_Income_Ratio DECIMAL(10,2),
    Monthly_Installment DECIMAL(15,2),
    Interest_Rate DECIMAL(10,2),
    Loan_Amount DECIMAL(15,2),
    Total_Accounts INT,
    Total_Amount_Paid DECIMAL(15,2),
    Loan_Category VARCHAR(30)
);


-- ============================================================
-- 1. DATA VALIDATION
-- ============================================================

-- Total records
SELECT COUNT(*) AS Total_Applications
FROM bank_loan;

-- View sample records
SELECT *
FROM bank_loan
LIMIT 10;

-- Table structure
DESCRIBE bank_loan;

-- Duplicate Loan IDs
SELECT Loan_ID, COUNT(*) AS Duplicate_Count
FROM bank_loan
GROUP BY Loan_ID
HAVING COUNT(*) > 1;

-- Missing values
SELECT
    SUM(Loan_ID IS NULL) AS Missing_Loan_ID,
    SUM(State IS NULL) AS Missing_State,
    SUM(Loan_Status IS NULL) AS Missing_Loan_Status,
    SUM(Annual_Income IS NULL) AS Missing_Income,
    SUM(Loan_Amount IS NULL) AS Missing_Loan_Amount,
    SUM(Interest_Rate IS NULL) AS Missing_Interest_Rate,
    SUM(Debt_To_Income_Ratio IS NULL) AS Missing_DTI
FROM bank_loan;

-- Loan status distribution
SELECT Loan_Status, COUNT(*) AS Applications
FROM bank_loan
GROUP BY Loan_Status
ORDER BY Applications DESC;

-- Date range
SELECT
    MIN(Issue_Date) AS First_Loan_Date,
    MAX(Issue_Date) AS Last_Loan_Date
FROM bank_loan;


-- ============================================================
-- 2. MAIN BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(*) AS Total_Loan_Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(SUM(Total_Amount_Paid), 2) AS Total_Amount_Received,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate,
    ROUND(AVG(Debt_To_Income_Ratio), 2) AS Average_DTI,
    ROUND(AVG(Annual_Income), 2) AS Average_Annual_Income,
    ROUND(AVG(Loan_Amount), 2) AS Average_Loan_Amount
FROM bank_loan;

-- Median loan amount
SELECT ROUND(AVG(Loan_Amount), 2) AS Median_Loan_Amount
FROM (
    SELECT
        Loan_Amount,
        ROW_NUMBER() OVER (ORDER BY Loan_Amount) AS Row_Num,
        COUNT(*) OVER () AS Total_Rows
    FROM bank_loan
    WHERE Loan_Amount IS NOT NULL
) AS Median_Data
WHERE Row_Num IN (
    FLOOR((Total_Rows + 1) / 2),
    FLOOR((Total_Rows + 2) / 2)
);


-- ============================================================
-- 3. GOOD LOAN AND BAD LOAN ANALYSIS
-- ============================================================

-- Good loan applications
SELECT COUNT(*) AS Good_Loan_Applications
FROM bank_loan
WHERE Loan_Status = 'Fully Paid';

-- Bad loan applications
SELECT COUNT(*) AS Bad_Loan_Applications
FROM bank_loan
WHERE Loan_Status = 'Charged Off';

-- Good loan amount
SELECT ROUND(SUM(Loan_Amount), 2) AS Good_Loan_Amount
FROM bank_loan
WHERE Loan_Status = 'Fully Paid';

-- Bad loan amount
SELECT ROUND(SUM(Loan_Amount), 2) AS Bad_Loan_Amount
FROM bank_loan
WHERE Loan_Status = 'Charged Off';

-- Good loan percentage
SELECT
    ROUND(
        100.0 * SUM(Loan_Status = 'Fully Paid') / COUNT(*),
        2
    ) AS Good_Loan_Percentage
FROM bank_loan;

-- Bad loan percentage among closed loans
SELECT
    ROUND(
        100.0 * SUM(Loan_Status = 'Charged Off') /
        NULLIF(SUM(Loan_Status IN ('Fully Paid', 'Charged Off')), 0),
        2
    ) AS Bad_Loan_Percentage
FROM bank_loan;

-- Good and bad loan summary
SELECT
    CASE
        WHEN Loan_Status = 'Fully Paid' THEN 'Good Loan'
        WHEN Loan_Status = 'Charged Off' THEN 'Bad Loan'
        WHEN Loan_Status = 'Current' THEN 'Current Loan'
        ELSE 'Other'
    END AS Loan_Type,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Loan_Amount
FROM bank_loan
GROUP BY Loan_Type;


-- ============================================================
-- 4. LOAN STATUS ANALYSIS
-- ============================================================

SELECT
    Loan_Status,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(SUM(Total_Amount_Paid), 2) AS Total_Amount_Received,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate
FROM bank_loan
GROUP BY Loan_Status
ORDER BY Applications DESC;


-- ============================================================
-- 5. LOAN CATEGORY ANALYSIS
-- ============================================================

SELECT
    Loan_Category,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(AVG(Loan_Amount), 2) AS Average_Loan_Amount
FROM bank_loan
GROUP BY Loan_Category
ORDER BY Applications DESC;


-- ============================================================
-- 6. LOAN TERM ANALYSIS
-- ============================================================

SELECT
    Loan_Term,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate
FROM bank_loan
GROUP BY Loan_Term
ORDER BY Applications DESC;


-- ============================================================
-- 7. PURPOSE-WISE ANALYSIS
-- ============================================================

SELECT
    Purpose,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate
FROM bank_loan
GROUP BY Purpose
ORDER BY Total_Loan_Amount DESC;


-- ============================================================
-- 8. HOME OWNERSHIP ANALYSIS
-- ============================================================

SELECT
    Home_Ownership,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(AVG(Annual_Income), 2) AS Average_Income
FROM bank_loan
GROUP BY Home_Ownership
ORDER BY Applications DESC;


-- ============================================================
-- 9. VERIFICATION STATUS ANALYSIS
-- ============================================================

SELECT
    Verification_Status,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(AVG(Annual_Income), 2) AS Average_Income,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate
FROM bank_loan
GROUP BY Verification_Status;


-- ============================================================
-- 10. LOAN GRADE ANALYSIS
-- ============================================================

SELECT
    Loan_Grade,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate
FROM bank_loan
GROUP BY Loan_Grade
ORDER BY Loan_Grade;

-- Bad loans by grade
SELECT
    Loan_Grade,
    COUNT(*) AS Bad_Loan_Applications,
    ROUND(SUM(Loan_Amount), 2) AS Bad_Loan_Amount
FROM bank_loan
WHERE Loan_Status = 'Charged Off'
GROUP BY Loan_Grade
ORDER BY Bad_Loan_Applications DESC;

-- Bad loan rate by grade among closed loans
SELECT
    Loan_Grade,
    COUNT(*) AS Total_Applications,
    SUM(Loan_Status = 'Charged Off') AS Bad_Loans,
    ROUND(
        100.0 * SUM(Loan_Status = 'Charged Off') /
        NULLIF(
            SUM(Loan_Status IN ('Fully Paid', 'Charged Off')),
            0
        ),
        2
    ) AS Bad_Loan_Rate
FROM bank_loan
GROUP BY Loan_Grade
ORDER BY Bad_Loan_Rate DESC;

-- Sub-grade analysis
SELECT
    Loan_Sub_Grade,
    COUNT(*) AS Applications,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate,
    SUM(Loan_Status = 'Charged Off') AS Bad_Loans
FROM bank_loan
GROUP BY Loan_Sub_Grade
ORDER BY Loan_Sub_Grade;


-- ============================================================
-- 11. STATE-WISE ANALYSIS
-- ============================================================

-- Applications by state
SELECT
    State,
    COUNT(*) AS Applications
FROM bank_loan
GROUP BY State
ORDER BY Applications DESC;

-- Loan amount by state
SELECT
    State,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount
FROM bank_loan
GROUP BY State
ORDER BY Total_Loan_Amount DESC;

-- Bad loans by state
SELECT
    State,
    COUNT(*) AS Bad_Loan_Applications,
    ROUND(SUM(Loan_Amount), 2) AS Bad_Loan_Amount
FROM bank_loan
WHERE Loan_Status = 'Charged Off'
GROUP BY State
ORDER BY Bad_Loan_Applications DESC;

-- State-wise bad loan percentage among closed loans
SELECT
    State,
    COUNT(*) AS Total_Applications,
    SUM(Loan_Status = 'Charged Off') AS Bad_Loans,
    ROUND(
        100.0 * SUM(Loan_Status = 'Charged Off') /
        NULLIF(
            SUM(Loan_Status IN ('Fully Paid', 'Charged Off')),
            0
        ),
        2
    ) AS Bad_Loan_Rate
FROM bank_loan
GROUP BY State
ORDER BY Bad_Loan_Rate DESC;


-- ============================================================
-- 12. MONTHLY LOAN ANALYSIS
-- ============================================================

-- Monthly applications
SELECT
    DATE_FORMAT(Issue_Date, '%Y-%m') AS Issue_Month,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount
FROM bank_loan
WHERE Issue_Date IS NOT NULL
GROUP BY DATE_FORMAT(Issue_Date, '%Y-%m')
ORDER BY Issue_Month;

-- Monthly loan status
SELECT
    DATE_FORMAT(Issue_Date, '%Y-%m') AS Issue_Month,
    Loan_Status,
    COUNT(*) AS Applications
FROM bank_loan
WHERE Issue_Date IS NOT NULL
GROUP BY DATE_FORMAT(Issue_Date, '%Y-%m'), Loan_Status
ORDER BY Issue_Month, Loan_Status;

-- Year-wise analysis
SELECT
    YEAR(Issue_Date) AS Issue_Year,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount
FROM bank_loan
WHERE Issue_Date IS NOT NULL
GROUP BY YEAR(Issue_Date)
ORDER BY Issue_Year;


-- ============================================================
-- 13. BORROWER INCOME ANALYSIS
-- ============================================================

-- Income statistics
SELECT
    ROUND(MIN(Annual_Income), 2) AS Minimum_Income,
    ROUND(MAX(Annual_Income), 2) AS Maximum_Income,
    ROUND(AVG(Annual_Income), 2) AS Average_Income
FROM bank_loan
WHERE Annual_Income IS NOT NULL;

-- Income bands
SELECT
    CASE
        WHEN Annual_Income < 25000 THEN 'Below 25K'
        WHEN Annual_Income < 50000 THEN '25K-50K'
        WHEN Annual_Income < 75000 THEN '50K-75K'
        WHEN Annual_Income < 100000 THEN '75K-100K'
        ELSE '100K+'
    END AS Income_Band,
    COUNT(*) AS Applications,
    ROUND(AVG(Loan_Amount), 2) AS Average_Loan_Amount,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate
FROM bank_loan
WHERE Annual_Income IS NOT NULL
GROUP BY Income_Band
ORDER BY MIN(Annual_Income);


-- ============================================================
-- 14. DEBT-TO-INCOME RATIO ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN Debt_To_Income_Ratio < 10 THEN 'Low DTI'
        WHEN Debt_To_Income_Ratio < 20 THEN 'Moderate DTI'
        WHEN Debt_To_Income_Ratio < 30 THEN 'High DTI'
        ELSE 'Very High DTI'
    END AS DTI_Band,
    COUNT(*) AS Applications,
    ROUND(AVG(Annual_Income), 2) AS Average_Income,
    ROUND(AVG(Loan_Amount), 2) AS Average_Loan_Amount,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate
FROM bank_loan
WHERE Debt_To_Income_Ratio IS NOT NULL
GROUP BY DTI_Band
ORDER BY MIN(Debt_To_Income_Ratio);


-- ============================================================
-- 15. EMPLOYMENT ANALYSIS
-- ============================================================

-- Employment length
SELECT
    Emp_Length,
    COUNT(*) AS Applications,
    ROUND(AVG(Annual_Income), 2) AS Average_Income,
    ROUND(AVG(Loan_Amount), 2) AS Average_Loan_Amount
FROM bank_loan
GROUP BY Emp_Length
ORDER BY Applications DESC;

-- Top 10 employment titles
SELECT
    Emp_Title,
    COUNT(*) AS Applications,
    ROUND(AVG(Annual_Income), 2) AS Average_Income
FROM bank_loan
WHERE Emp_Title IS NOT NULL
  AND TRIM(Emp_Title) <> ''
GROUP BY Emp_Title
ORDER BY Applications DESC
LIMIT 10;


-- ============================================================
-- 16. APPLICATION TYPE ANALYSIS
-- ============================================================

SELECT
    Application_Type,
    COUNT(*) AS Applications,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate
FROM bank_loan
GROUP BY Application_Type
ORDER BY Applications DESC;


-- ============================================================
-- 17. INTEREST RATE ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN Interest_Rate < 10 THEN 'Below 10%'
        WHEN Interest_Rate < 15 THEN '10%-15%'
        WHEN Interest_Rate < 20 THEN '15%-20%'
        ELSE '20%+'
    END AS Interest_Rate_Band,
    COUNT(*) AS Applications,
    ROUND(AVG(Loan_Amount), 2) AS Average_Loan_Amount
FROM bank_loan
WHERE Interest_Rate IS NOT NULL
GROUP BY Interest_Rate_Band
ORDER BY MIN(Interest_Rate);


-- ============================================================
-- 18. TOP 10 LOANS
-- ============================================================

SELECT
    Loan_ID,
    State,
    Loan_Grade,
    Loan_Amount,
    Interest_Rate,
    Loan_Status
FROM bank_loan
ORDER BY Loan_Amount DESC
LIMIT 10;


-- ============================================================
-- 19. TOP 10 STATES BY APPLICATIONS
-- ============================================================

SELECT
    State,
    COUNT(*) AS Applications,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM bank_loan),
        2
    ) AS Application_Share_Percentage
FROM bank_loan
GROUP BY State
ORDER BY Applications DESC
LIMIT 10;


-- ============================================================
-- 20. RANKING ANALYSIS
-- ============================================================

-- Rank states by loan applications
SELECT
    State,
    COUNT(*) AS Applications,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS State_Rank
FROM bank_loan
GROUP BY State;

-- Rank loan grades by loan amount
SELECT
    Loan_Grade,
    SUM(Loan_Amount) AS Total_Loan_Amount,
    DENSE_RANK() OVER (
        ORDER BY SUM(Loan_Amount) DESC
    ) AS Grade_Rank
FROM bank_loan
GROUP BY Loan_Grade;


-- ============================================================
-- 21. MONTH-OVER-MONTH GROWTH
-- ============================================================

WITH Monthly_Data AS (
    SELECT
        DATE_FORMAT(Issue_Date, '%Y-%m') AS Issue_Month,
        COUNT(*) AS Applications
    FROM bank_loan
    WHERE Issue_Date IS NOT NULL
    GROUP BY DATE_FORMAT(Issue_Date, '%Y-%m')
),
Monthly_Comparison AS (
    SELECT
        Issue_Month,
        Applications,
        LAG(Applications) OVER (
            ORDER BY Issue_Month
        ) AS Previous_Month_Applications
    FROM Monthly_Data
)
SELECT
    Issue_Month,
    Applications,
    Previous_Month_Applications,
    ROUND(
        100.0 * (Applications - Previous_Month_Applications) /
        NULLIF(Previous_Month_Applications, 0),
        2
    ) AS Monthly_Growth_Percentage
FROM Monthly_Comparison
ORDER BY Issue_Month;


-- ============================================================
-- 22. LOAN AMOUNT SHARE BY PURPOSE
-- ============================================================

SELECT
    Purpose,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(
        100.0 * SUM(Loan_Amount) /
        (SELECT SUM(Loan_Amount) FROM bank_loan),
        2
    ) AS Loan_Amount_Share
FROM bank_loan
GROUP BY Purpose
ORDER BY Total_Loan_Amount DESC;


-- ============================================================
-- 23. BORROWER RISK ANALYSIS
-- ============================================================

SELECT
    Loan_Grade,
    Home_Ownership,
    COUNT(*) AS Applications,
    SUM(Loan_Status = 'Charged Off') AS Bad_Loans,
    ROUND(
        100.0 * SUM(Loan_Status = 'Charged Off') /
        NULLIF(
            SUM(Loan_Status IN ('Fully Paid', 'Charged Off')),
            0
        ),
        2
    ) AS Bad_Loan_Rate
FROM bank_loan
GROUP BY Loan_Grade, Home_Ownership
ORDER BY Bad_Loan_Rate DESC;


-- ============================================================
-- 24. LOAN PAYMENT ANALYSIS
-- ============================================================

SELECT
    Loan_Status,
    COUNT(*) AS Applications,
    ROUND(AVG(Monthly_Installment), 2) AS Average_Monthly_Installment,
    ROUND(AVG(Total_Amount_Paid), 2) AS Average_Amount_Paid,
    ROUND(SUM(Total_Amount_Paid), 2) AS Total_Amount_Paid
FROM bank_loan
GROUP BY Loan_Status;


-- ============================================================
-- 25. FINAL DATA VALIDATION
-- ============================================================

-- Final record count
SELECT COUNT(*) AS Final_Total_Records
FROM bank_loan;

-- Total unique loans
SELECT COUNT(DISTINCT Loan_ID) AS Unique_Loans
FROM bank_loan;

-- Final KPI summary
SELECT
    COUNT(*) AS Total_Applications,
    SUM(Loan_Status = 'Fully Paid') AS Fully_Paid,
    SUM(Loan_Status = 'Charged Off') AS Charged_Off,
    SUM(Loan_Status = 'Current') AS Current_Loans,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    ROUND(SUM(Total_Amount_Paid), 2) AS Total_Amount_Received,
    ROUND(AVG(Annual_Income), 2) AS Average_Annual_Income,
    ROUND(AVG(Interest_Rate), 2) AS Average_Interest_Rate,
    ROUND(AVG(Debt_To_Income_Ratio), 2) AS Average_DTI
FROM bank_loan;

-- ============================================================
-- END OF BANK LOAN PORTFOLIO ANALYSIS
-- ============================================================




















