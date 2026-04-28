CREATE DATABASE IF NOT EXISTS StudentDB;
USE StudentDB;

DROP TABLE IF EXISTS Student;

CREATE TABLE Student(
    Student_id VARCHAR(6) PRIMARY KEY,
    First_name VARCHAR(20) NOT NULL,
    Last_name VARCHAR(20) NOT NULL,
    DOB DATE NOT NULL,
    Address VARCHAR(50),
    CGPA DECIMAL(4,2) NOT NULL,
    Class VARCHAR(10)
);

INSERT INTO Student VALUES
('S00001','Anjali','Patil','2002-01-01','Mumbai',9.20,'IT'),
('S00002','Rahul','Sharma','2001-02-02','Pune',8.10,'CS'),
('S00003','Sneha','Joshi','2002-03-03','Delhi',7.50,'EC'),
('S00004','Amit','Rao','2001-04-04','Mumbai',6.80,'ME'),
('S00005','Pooja','Nair','2002-05-05','Chennai',8.50,'IT'),
('S00006','Rohan','Patel','2001-06-06','Bangalore',7.80,'CS'),
('S00007','Kiran','Das','2002-07-07','Hyderabad',9.50,'IT');

SELECT * FROM Student;

SELECT Student_id, CGPA
FROM Student;

SELECT AVG(CGPA)
FROM Student;

SELECT COUNT(*)
FROM Student;

SELECT Class,
       SUM(CGPA) AS Total_CGPA,
       COUNT(*) AS Total_Students
FROM Student
GROUP BY Class;

SELECT *
FROM Student
WHERE CGPA>8.0;

SELECT *
FROM Student
ORDER BY First_name DESC;

SELECT *
FROM Student
WHERE First_name='Anjali'
AND CGPA>7.5;

DELIMITER $$

CREATE FUNCTION Student_Grade(cgpa_value DECIMAL(4,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(20);

    IF cgpa_value>=9 THEN
        SET result='Outstanding';
    ELSEIF cgpa_value>=8 THEN
        SET result='Excellent';
    ELSEIF cgpa_value>=7 THEN
        SET result='Good';
    ELSE
        SET result='Average';
    END IF;

    RETURN result;
END $$

DELIMITER ;

SELECT Student_id, First_name, CGPA,
Student_Grade(CGPA)
FROM Student;

DELIMITER $$

CREATE PROCEDURE Student_Full_Name()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE fname VARCHAR(20);
    DECLARE lname VARCHAR(20);

    DECLARE cur CURSOR FOR
    SELECT First_name, Last_name FROM Student;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET done=TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO fname, lname;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT CONCAT(fname,' ',lname) AS Full_Name;

    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

CALL Student_Full_Name();