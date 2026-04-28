USE EmployeeDB;

DROP TABLE IF EXISTS Employee_Main;

CREATE TABLE Employee_Main(
    Employee_id VARCHAR(6) PRIMARY KEY,
    Name VARCHAR(30),
    Designation VARCHAR(30) NOT NULL,
    Branch VARCHAR(20),
    Date_of_joining DATE,
    Date_of_superannuation DATE,
    Salary DECIMAL(10,2),
    CHECK(Employee_id LIKE 'E%'),
    CHECK(Date_of_superannuation>Date_of_joining)
);

INSERT INTO Employee_Main VALUES
('E00001','Amit Shah','Manager','Mumbai','2015-01-01','2035-01-01',50000),
('E00002','Pooja Rao','Developer','Pune','2018-05-01','2038-05-01',45000),
('E00003','Rohit Das','Analyst','Mumbai','2019-06-01','2039-06-01',40000),
('E00004','Kiran Patil','Tester','Delhi','2020-07-01','2040-07-01',35000),
('E00005','Sneha Nair','HR','Pune','2021-08-01','2041-08-01',30000),
('E00006','Vikas Sharma','Manager','Mumbai','2017-09-01','2037-09-01',60000),
('E00007','Neha Joshi','Developer','Delhi','2022-10-01','2042-10-01',42000);

ALTER TABLE Employee_Main
ADD Department VARCHAR(30);

DESC Employee_Main;

CREATE TABLE Emp_Archive AS
SELECT * FROM Employee_Main;

DELIMITER $$

CREATE TRIGGER Employee_Name_Upper
BEFORE INSERT ON Employee_Main
FOR EACH ROW
BEGIN
    SET NEW.Name=UPPER(NEW.Name);
END $$

DELIMITER ;

CREATE VIEW Employee_Branch_View AS
SELECT Employee_id, Name, Branch, Salary
FROM Employee_Main;

DELIMITER $$

CREATE PROCEDURE Branch_Total_Salary(
    IN branch_name VARCHAR(20),
    OUT total_salary DECIMAL(12,2)
)
BEGIN
    SELECT SUM(Salary)
    INTO total_salary
    FROM Employee_Main
    WHERE Branch=branch_name;
END $$

DELIMITER ;

CALL Branch_Total_Salary('Mumbai', @salary);
SELECT @salary;