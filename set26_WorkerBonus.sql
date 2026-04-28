CREATE DATABASE IF NOT EXISTS WorkerDB;
USE WorkerDB;

DROP TABLE IF EXISTS Bonus;
DROP TABLE IF EXISTS Worker;

CREATE TABLE Worker(
    Worker_id INT PRIMARY KEY,
    First_name VARCHAR(20),
    Last_name VARCHAR(20),
    Salary DECIMAL(10,2),
    Joining_date DATE,
    Department VARCHAR(20)
);

CREATE TABLE Bonus(
    Worker_id INT,
    Bonus_date DATE,
    Bonus_amount DECIMAL(10,2),
    FOREIGN KEY(Worker_id) REFERENCES Worker(Worker_id)
);

INSERT INTO Worker VALUES
(1,'Rohan','Mehta',120000,'2019-03-15','HR'),
(2,'Swati','Joshi',95000,'2020-07-22','IT'),
(3,'Anil','Nair',250000,'2018-01-10','IT'),
(4,'Deepa','Sharma',450000,'2017-06-01','Finance'),
(5,'Vikas','Rao',450000,'2020-11-30','Finance'),
(6,'Kavya','Patel',175000,'2021-03-05','Ops'),
(7,'Suraj','Das',70000,'2016-09-20','Ops'),
(8,'Neha','Bhat',88000,'2022-04-11','HR');

INSERT INTO Bonus VALUES
(1,'2023-03-15',7000),
(2,'2023-07-22',4500),
(3,'2023-01-10',6000),
(1,'2023-09-01',5500),
(4,'2023-06-01',8000);

SELECT First_name FROM Worker;

SELECT * FROM Worker
ORDER BY First_name ASC;

SELECT *
FROM Worker
WHERE First_name IN ('Kavya','Suraj');

SELECT *
FROM Worker
WHERE Department='IT';

SELECT Department, COUNT(*) AS Total_Workers
FROM Worker
GROUP BY Department
ORDER BY Total_Workers DESC;