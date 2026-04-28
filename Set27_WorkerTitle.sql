USE WorkerDB;

DROP TABLE IF EXISTS Title;

CREATE TABLE Title(
    Worker_id INT,
    Worker_title VARCHAR(30),
    Affected_from DATE,
    FOREIGN KEY(Worker_id) REFERENCES Worker(Worker_id)
);

INSERT INTO Title VALUES
(1,'Senior Manager','2022-01-01'),
(2,'Tech Lead','2022-06-11'),
(8,'Executive','2023-01-01'),
(5,'Manager','2022-11-11'),
(4,'Director','2021-06-01'),
(7,'Senior Exec','2023-04-01'),
(6,'Lead Analyst','2022-03-01'),
(3,'Architect','2021-01-10');

SELECT *
FROM Worker
WHERE First_name LIKE '%a'
AND LENGTH(First_name)>=5;

SELECT *
FROM Worker
WHERE Salary BETWEEN 90000 AND 450000;

SELECT COUNT(*) AS Ops_Count
FROM Worker
WHERE Department='Ops';

SELECT w.*
FROM Worker w
JOIN Title t
ON w.Worker_id=t.Worker_id
WHERE t.Worker_title IN ('Manager','Senior Manager');

DESC Bonus;