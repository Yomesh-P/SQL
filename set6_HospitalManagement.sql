
/* =========================================
   DATABASE INITIALIZATION
========================================= */
CREATE DATABASE IF NOT EXISTS HospitalDB;
USE HospitalDB;

/* Drop tables in correct order */
DROP TABLE IF EXISTS Appointment;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS Doctor;


/* =========================================
   TABLE CREATION
========================================= */

CREATE TABLE Patient(
    Patient_id VARCHAR(6) PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Age INT NOT NULL CHECK(Age > 0),
    Gender CHAR(1),
    City VARCHAR(20),
    Blood_group VARCHAR(5),
    Contact BIGINT,
    CHECK(Patient_id LIKE 'P%'),
    CHECK(Gender IN ('M','F'))
);

CREATE TABLE Doctor(
    Doctor_id VARCHAR(6) PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Specialization VARCHAR(30) NOT NULL,
    Department VARCHAR(20),
    Fees DECIMAL(8,2) NOT NULL CHECK(Fees > 0),
    Experience_yrs INT,
    CHECK(Doctor_id LIKE 'D%')
);

CREATE TABLE Appointment(
    Appt_id VARCHAR(6) PRIMARY KEY,
    Patient_id VARCHAR(6),
    Doctor_id VARCHAR(6),
    Appt_date DATE NOT NULL,
    Appt_time VARCHAR(10) NOT NULL,
    Status VARCHAR(15),
    FOREIGN KEY(Patient_id) REFERENCES Patient(Patient_id),
    FOREIGN KEY(Doctor_id) REFERENCES Doctor(Doctor_id),
    CHECK(Appt_id LIKE 'A%'),
    CHECK(Status IN ('Scheduled','Completed','Cancelled'))
);


/* =========================================
   INSERT DATA
========================================= */

INSERT INTO Patient VALUES
('P00001','Aarav Joshi',35,'M','Mumbai','A+',9900001111),
('P00002','Meena Rao',28,'F','Pune','B+',9900002222),
('P00003','Suresh Pillai',45,'M','Chennai','O+',9900003333),
('P00004','Kavita Singh',32,'F','Delhi','AB+',9900004444),
('P00005','Rohit Gupta',52,'M','Kolkata','A-',9900005555),
('P00006','Lata Desai',40,'F','Mumbai','B-',9900006666);

INSERT INTO Doctor VALUES
('D00001','Dr. Kapoor','Cardiology','Cardio',1500,15),
('D00002','Dr. Reddy','Neurology','Neuro',2000,20),
('D00003','Dr. Iyer','Orthopedics','Ortho',1200,10),
('D00004','Dr. Sharma','Dermatology','Skin',800,8),
('D00005','Dr. Bose','Pediatrics','Paeds',900,12);

INSERT INTO Appointment VALUES
('A00001','P00001','D00001','2024-01-10','10:00 AM','Completed'),
('A00002','P00002','D00003','2024-01-11','11:30 AM','Scheduled'),
('A00003','P00003','D00002','2024-01-12','09:00 AM','Cancelled'),
('A00004','P00004','D00004','2024-01-15','02:00 PM','Completed'),
('A00005','P00005','D00001','2024-01-20','03:30 PM','Scheduled'),
('A00006','P00006','D00005','2024-01-22','10:00 AM','Completed');


/* =========================================
   SET 6 SOLUTIONS
========================================= */

-- Q1
SELECT Name, Age, Blood_group
FROM Patient;

-- Q2
SELECT *
FROM Doctor
WHERE Specialization='Cardiology';

-- Q3
SELECT COUNT(*) AS Total_Patients
FROM Patient;

-- Q4
ALTER TABLE Doctor RENAME TO Doctor_Info;

-- Rename back for next sets
ALTER TABLE Doctor_Info RENAME TO Doctor;


/* =========================================
   SET 7 SOLUTIONS
========================================= */

-- Q1
SELECT *
FROM Patient
WHERE City IN ('Mumbai','Delhi');

-- Q2
SELECT *
FROM Patient
WHERE Name LIKE '%an%';

-- Q3
UPDATE Patient
SET Contact=9811223344
WHERE Patient_id='P00003';

-- Q4
SELECT MIN(Fees) AS Minimum_Fees
FROM Doctor;

-- Q5
CREATE VIEW Doctor_View AS
SELECT Doctor_id, Name, Specialization
FROM Doctor;


/* =========================================
   SET 8 SOLUTIONS
========================================= */

-- Q1 Join
SELECT p.Name AS Patient_Name,
       d.Name AS Doctor_Name
FROM Patient p
JOIN Appointment a
ON p.Patient_id=a.Patient_id
JOIN Doctor d
ON d.Doctor_id=a.Doctor_id
WHERE a.Status='Completed';

-- Q2 Nested Query
SELECT Name, City
FROM Patient
WHERE Patient_id=
(
    SELECT Patient_id
    FROM Appointment
    WHERE Appt_id='A00003'
);

-- Q3 Count appointments per doctor descending
SELECT Doctor_id, COUNT(*) AS Total_Appointments
FROM Appointment
GROUP BY Doctor_id
ORDER BY Total_Appointments DESC;

-- Q4 Doctors above average fees
SELECT *
FROM Doctor
WHERE Fees >
(
    SELECT AVG(Fees)
    FROM Doctor
);


/* =========================================
   SET 9 TRIGGER + TABLE COPY + ALTER + DESC
========================================= */

-- Trigger
DELIMITER $$

CREATE TRIGGER Doctor_Specialization_Title
BEFORE INSERT ON Doctor
FOR EACH ROW
BEGIN
    SET NEW.Specialization =
    CONCAT(
        UPPER(LEFT(NEW.Specialization,1)),
        LOWER(SUBSTRING(NEW.Specialization,2))
    );
END $$

DELIMITER ;

-- Copy table
CREATE TABLE Doctor_Backup AS
SELECT * FROM Doctor;

-- Alter table
ALTER TABLE Doctor
ADD Qualification VARCHAR(50);

-- Describe table
DESC Doctor;


/* =========================================
   SET 10 FUNCTION
========================================= */

DELIMITER $$

CREATE FUNCTION Appointment_Priority(appt_status VARCHAR(20))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(20);

    IF appt_status='Cancelled' THEN
        SET result='Urgent';

    ELSEIF appt_status='Completed' THEN
        SET result='Normal';

    ELSE
        SET result='Pending';

    END IF;

    RETURN result;
END $$

DELIMITER ;

-- Test function
SELECT Appt_id, Status,
Appointment_Priority(Status)
FROM Appointment;


/* =========================================
   SET 10 PROCEDURE
========================================= */

DELIMITER $$

CREATE PROCEDURE Doctor_Appointment_Count(
    IN doc_id VARCHAR(6),
    OUT total_count INT
)
BEGIN
    SELECT COUNT(*)
    INTO total_count
    FROM Appointment
    WHERE Doctor_id=doc_id;
END $$

DELIMITER ;

-- Test procedure
CALL Doctor_Appointment_Count('D00001', @count);
SELECT @count;