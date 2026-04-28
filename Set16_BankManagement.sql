
/* =========================================
   DATABASE INITIALIZATION
========================================= */
CREATE DATABASE IF NOT EXISTS BankDB;
USE BankDB;

/* Drop tables in correct order */
DROP TABLE IF EXISTS Transaction_Details;
DROP TABLE IF EXISTS Account;
DROP TABLE IF EXISTS Branch;


/* =========================================
   TABLE CREATION
========================================= */

CREATE TABLE Branch(
    Branch_code VARCHAR(6) PRIMARY KEY,
    Branch_name VARCHAR(30) NOT NULL,
    City VARCHAR(20) NOT NULL,
    State VARCHAR(20),
    IFSC VARCHAR(11) NOT NULL,
    Manager VARCHAR(30),
    CHECK(Branch_code LIKE 'B%')
);

CREATE TABLE Account(
    Account_no VARCHAR(10) PRIMARY KEY,
    Customer_name VARCHAR(30) NOT NULL,
    Account_type VARCHAR(10),
    Branch_code VARCHAR(6),
    Balance DECIMAL(12,2) NOT NULL,
    Open_date DATE NOT NULL,
    FOREIGN KEY(Branch_code) REFERENCES Branch(Branch_code),
    CHECK(Account_no LIKE 'A%'),
    CHECK(Account_type IN ('Savings','Current','FD')),
    CHECK(Balance >= 0)
);

CREATE TABLE Transaction_Details(
    Txn_id VARCHAR(8) PRIMARY KEY,
    Account_no VARCHAR(10),
    Txn_date DATE NOT NULL,
    Txn_type VARCHAR(10),
    Amount DECIMAL(10,2) NOT NULL,
    Description VARCHAR(50),
    FOREIGN KEY(Account_no) REFERENCES Account(Account_no),
    CHECK(Txn_id LIKE 'T%'),
    CHECK(Txn_type IN ('Credit','Debit')),
    CHECK(Amount > 0)
);


/* =========================================
   INSERT DATA
========================================= */

INSERT INTO Branch VALUES
('B00001','Andheri Branch','Mumbai','Maharashtra','SBIN0001234','Mr. Desai'),
('B00002','Connaught Place','Delhi','Delhi','SBIN0001235','Ms. Kapoor'),
('B00003','MG Road','Bangalore','Karnataka','SBIN0001236','Mr. Rao'),
('B00004','Anna Nagar','Chennai','Tamil Nadu','SBIN0001237','Ms. Iyer');

INSERT INTO Account VALUES
('A0001001','Sachin Tendulkar','Savings','B00001',250000.00,'2010-01-15'),
('A0001002','Sunita Sharma','Current','B00002',750000.00,'2015-03-20'),
('A0001003','Manish Gupta','Savings','B00001',85000.00,'2018-06-10'),
('A0001004','Rekha Nair','FD','B00003',1200000.00,'2020-08-05'),
('A0001005','Tanvir Ahmed','Savings','B00002',45000.00,'2021-11-12'),
('A0001006','Poonam Jain','Current','B00003',300000.00,'2022-01-01');

INSERT INTO Transaction_Details VALUES
('T0000001','A0001001','2024-03-01','Credit',50000.00,'Salary'),
('T0000002','A0001001','2024-03-05','Debit',10000.00,'EMI'),
('T0000003','A0001002','2024-03-10','Credit',200000.00,'Business'),
('T0000004','A0001003','2024-03-15','Debit',5000.00,'Shopping'),
('T0000005','A0001005','2024-03-20','Credit',20000.00,'Freelance'),
('T0000006','A0001006','2024-03-25','Debit',15000.00,'Rent');


/* =========================================
   SET 16 SOLUTIONS
========================================= */

-- Q1
SELECT Account_no, Customer_name, Balance
FROM Account;

-- Q2
SELECT *
FROM Branch
WHERE City='Mumbai';

-- Q3
SELECT COUNT(*) AS Total_Accounts
FROM Account;

-- Q4
ALTER TABLE Branch RENAME TO Branch_Details;

-- Rename back for next sets
ALTER TABLE Branch_Details RENAME TO Branch;


/* =========================================
   SET 17 SOLUTIONS
========================================= */

-- Q1
SELECT *
FROM Account
WHERE Balance > 200000;

-- Q2
SELECT *
FROM Account
WHERE Customer_name LIKE '_a%';

-- Q3
SELECT MAX(Balance) AS Maximum_Balance,
       MIN(Balance) AS Minimum_Balance
FROM Account;

-- Q4
SELECT Account_type, COUNT(*) AS Account_Count
FROM Account
GROUP BY Account_type;

-- Q5
CREATE VIEW Account_View AS
SELECT Account_no, Customer_name, Account_type
FROM Account;


/* =========================================
   SET 18 SOLUTIONS
========================================= */

-- Q1 Customer name and branch name using JOIN
SELECT a.Customer_name,
       b.Branch_name
FROM Account a
JOIN Branch b
ON a.Branch_code=b.Branch_code;

-- Q2 Customer name and balance using Nested Query
SELECT Customer_name, Balance
FROM Account
WHERE Account_no=
(
    SELECT Account_no
    FROM Transaction_Details
    WHERE Txn_id='T0000003'
);

-- Q3 Total credit and debit per account
SELECT Account_no,
       SUM(CASE WHEN Txn_type='Credit' THEN Amount ELSE 0 END) AS Total_Credit,
       SUM(CASE WHEN Txn_type='Debit' THEN Amount ELSE 0 END) AS Total_Debit
FROM Transaction_Details
GROUP BY Account_no;

-- Q4 Accounts with debit > 10000
SELECT DISTINCT Account_no
FROM Transaction_Details
WHERE Txn_type='Debit'
AND Amount > 10000;


/* =========================================
   SET 19 SOLUTIONS
========================================= */

-- Trigger for uppercase customer name
DELIMITER $$

CREATE TRIGGER Account_Name_Upper
BEFORE INSERT
ON Account
FOR EACH ROW
BEGIN
    SET NEW.Customer_name=UPPER(NEW.Customer_name);
END $$

DELIMITER ;

-- Copy table
CREATE TABLE Acc_Backup AS
SELECT * FROM Account;

-- Alter table
ALTER TABLE Account
ADD Email VARCHAR(40);

-- Cursor Procedure
DELIMITER $$

CREATE PROCEDURE Show_Accounts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE acc_no VARCHAR(10);
    DECLARE acc_balance DECIMAL(12,2);

    DECLARE cur CURSOR FOR
    SELECT Account_no, Balance FROM Account;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET done=TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO acc_no, acc_balance;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT acc_no, acc_balance;

    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

-- Test Cursor
CALL Show_Accounts();


/* =========================================
   SET 20 SOLUTIONS
========================================= */

-- Function for transaction label
DELIMITER $$

CREATE FUNCTION Transaction_Label(amount_value DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(20);

    IF amount_value > 50000 THEN
        SET result='High Value';

    ELSEIF amount_value BETWEEN 10000 AND 50000 THEN
        SET result='Mid Value';

    ELSE
        SET result='Low Value';

    END IF;

    RETURN result;
END $$

DELIMITER ;

-- Test function
SELECT Txn_id, Amount,
Transaction_Label(Amount)
FROM Transaction_Details;


-- Procedure using IN and OUT
DELIMITER $$

CREATE PROCEDURE Total_Credit_Amount(
    IN acc_num VARCHAR(10),
    OUT total_credit DECIMAL(12,2)
)
BEGIN
    SELECT SUM(Amount)
    INTO total_credit
    FROM Transaction_Details
    WHERE Account_no=acc_num
    AND Txn_type='Credit';
END $$

DELIMITER ;

-- Test Procedure
CALL Total_Credit_Amount('A0001001', @total);
SELECT @total;