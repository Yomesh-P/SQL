CREATE DATABASE IF NOT EXISTS EmployeeDB;
USE EmployeeDB;

DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department(
    Dept_no VARCHAR(5) PRIMARY KEY,
    Dept_name VARCHAR(30) NOT NULL,
    Location VARCHAR(30) NOT NULL
);

CREATE TABLE Employee(
    Emp_no VARCHAR(5) PRIMARY KEY,
    Emp_name VARCHAR(30) NOT NULL,
    Job VARCHAR(20),
    Hire_date DATE,
    Dept_no VARCHAR(5),
    Salary DECIMAL(10,2),
    FOREIGN KEY(Dept_no) REFERENCES Department(Dept_no)
);

INSERT INTO Department VALUES
('D01','Research','Hyderabad'),
('D02','Development','Pune'),
('D03','Quality Assurance','Noida');

INSERT INTO Employee VALUES
('E001','Aarav Shah','Analyst','2020-01-15','D01',55000),
('E002','Priya Iyer','Developer','2021-03-20','D02',65000),
('E003','Neeraj Bose','Manager','2018-06-10','D01',90000),
('E004','Sunita Roy','Tester','2022-08-01','D03',45000),
('E005','Rahul Sinha','Developer','2020-11-15','D02',70000);

SELECT * FROM Employee;

SELECT *
FROM Employee
WHERE Job!='Manager'
AND Dept_no='D01';

SELECT COUNT(*) AS Total_Employees
FROM Employee;

SELECT COUNT(*) AS Developer_Count
FROM Employee
WHERE Job='Developer'
AND Hire_date>'2020-01-01';

CREATE VIEW Employee_View AS
SELECT Emp_no, Emp_name, Dept_no
FROM Employee;