/* =========================================
   DATABASE INITIALIZATION
========================================= */
CREATE DATABASE IF NOT EXISTS CollegeDB;
USE CollegeDB;

/* Drop tables in proper order to handle Foreign Key constraints */
DROP TABLE IF EXISTS Student_Audit; -- Extra table for Set 15
DROP TABLE IF EXISTS Enrollment;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Student;

/* =========================================
   TABLE CREATION (Sets 11, 13, 15)
========================================= */

-- Set 11, 15: Student Table
CREATE TABLE Student(
    Student_id VARCHAR(6) PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    Branch VARCHAR(20) NOT NULL,
    Semester INT CHECK(Semester BETWEEN 1 AND 8), -- [cite: 128]
    City VARCHAR(20),
    CGPA DECIMAL(4,2) NOT NULL CHECK(CGPA BETWEEN 0 AND 10), -- [cite: 187]
    Email VARCHAR(30) NOT NULL,
    CONSTRAINT chk_stud_id CHECK(Student_id LIKE 'S%') -- [cite: 128, 186]
);

-- Set 11, 13: Course Table
CREATE TABLE Course(
    Course_id VARCHAR(6) PRIMARY KEY,
    Course_name VARCHAR(30) NOT NULL,
    Credits INT NOT NULL CHECK(Credits > 0), -- [cite: 132]
    Department VARCHAR(20) NOT NULL,
    Faculty VARCHAR(30) NOT NULL,
    Max_students INT NOT NULL,
    CONSTRAINT chk_course_id CHECK(Course_id LIKE 'C%') -- [cite: 132]
);

-- Set 13, 14: Enrollment Table
CREATE TABLE Enrollment(
    Enroll_id VARCHAR(6) PRIMARY KEY,
    Student_id VARCHAR(6),
    Course_id VARCHAR(6),
    Enroll_date DATE NOT NULL,
    Grade VARCHAR(2),
    Attendance INT,
    FOREIGN KEY(Student_id) REFERENCES Student(Student_id),
    FOREIGN KEY(Course_id) REFERENCES Course(Course_id),
    CONSTRAINT chk_enroll_id CHECK(Enroll_id LIKE 'E%'), -- [cite: 161]
    CONSTRAINT chk_grade CHECK(Grade IN ('AA','AB','BB','BC','CC','FF')), -- [cite: 161]
    CONSTRAINT chk_attendance CHECK(Attendance BETWEEN 0 AND 100) -- [cite: 161]
);

/* =========================================
   DATA INSERTION (Sample Data from Sets 11 & 13)
========================================= */

INSERT INTO Student (Student_id, Name, Branch, Semester, City, CGPA, Email) VALUES
('S00001','Ananya Tiwari','IT',6,'Mumbai',8.50,'ananya@college.edu'),
('S00002','Rohan Verma','CS',4,'Pune',7.80,'rohan@college.edu'),
('S00003','Pooja Nair','EC',6,'Bangalore',9.10,'pooja@college.edu'),
('S00004','Karan Shah','ME',8,'Delhi',6.90,'karan@college.edu'),
('S00005','Divya Pillai','CS',2,'Chennai',8.20,'divya@college.edu'),
('S00006','Arjun Menon','IT',4,'Mumbai',7.50,'arjun@college.edu'),
('S00007','Yjhbcdjbcjl','AI & DS',4,'Mumbai',9.20,'ykdcbcdbjnK@.edu'); -- Additional tuple [cite: 188]

INSERT INTO Course VALUES
('C00001','Database Systems',4,'IT','Prof. Joshi',60),
('C00002','Computer Networks',4,'CS','Prof. Reddy',60),
('C00003','Software Engineering',3,'IT','Prof. Patil',55),
('C00004','Machine Learning',4,'CS','Prof. Kumar',50),
('C00005','Digital Electronics',4,'EC','Prof. Bhat',65);

INSERT INTO Enrollment (Enroll_id, Student_id, Course_id, Enroll_date, Grade, Attendance) VALUES
('E00001','S00001','C00001','2023-07-01','AA',92),
('E00002','S00001','C00003','2023-07-01','AB',88),
('E00003','S00002','C00002','2023-07-01','BB',75),
('E00004','S00003','C00005','2023-07-01','AA',95),
('E00005','S00004','C00003','2023-07-01','BC',60),
('E00006','S00005','C00004','2023-07-01','AB',85),
('E00007','S00006','C00001','2023-07-01','BB',78);

/* =========================================
   SOLUTIONS: SET 11 & 12
========================================= */

-- Set 11 Q1-Q3: Basic Select & Aggregation [cite: 136, 137, 138]
SELECT Name, Branch, CGPA FROM Student;
SELECT * FROM Course WHERE Department='CS';
SELECT COUNT(*) AS Total_Students FROM Student;

-- Set 11 Q4: Rename Table [cite: 139]
ALTER TABLE Course RENAME TO Course_Catalog;
ALTER TABLE Course_Catalog RENAME TO Course; -- Revert for subsequent sets

-- Set 12 Q1-Q4: Filtering & Ordering [cite: 146, 147, 148, 149]
SELECT * FROM Student WHERE City IN ('Mumbai','Pune');
SELECT * FROM Student WHERE Name LIKE '%i' AND LENGTH(Name) >= 6;
SELECT * FROM Student WHERE CGPA BETWEEN 7.5 AND 9.0;
SELECT Branch, COUNT(*) AS Student_Count FROM Student GROUP BY Branch ORDER BY Student_Count DESC;

/* =========================================
   SOLUTIONS: SET 13 & 14
========================================= */

-- Set 13 Q1: Join [cite: 165]
SELECT s.Name AS Student_Name, c.Course_name 
FROM Student s 
JOIN Enrollment e ON s.Student_id = e.Student_id 
JOIN Course c ON e.Course_id = c.Course_id;

-- Set 13 Q2: Nested Query [cite: 166]
SELECT Name, Branch FROM Student 
WHERE Student_id = (SELECT Student_id FROM Enrollment WHERE Enroll_id = 'E00003');

-- Set 13 Q3-Q4: Grouping & Subqueries [cite: 167, 168]
SELECT s.Name, SUM(c.Credits) AS Total_Credits 
FROM Student s 
JOIN Enrollment e ON s.Student_id = e.Student_id 
JOIN Course c ON e.Course_id = c.Course_id GROUP BY s.Name;

SELECT Name FROM Student WHERE Student_id IN (SELECT Student_id FROM Enrollment WHERE Grade = 'AA');

-- Set 14 Q2-Q5: Alter, Having & View [cite: 180, 181, 182, 183]
ALTER TABLE Enrollment ADD Remarks VARCHAR(50);
SELECT Course_id FROM Enrollment GROUP BY Course_id HAVING AVG(Attendance) > 80;
SELECT MAX(CGPA) AS Max_CGPA, MIN(CGPA) AS Min_CGPA FROM Student;
CREATE VIEW Enrollment_Summary AS SELECT Enroll_id, Student_id, Course_id FROM Enrollment;

/* =========================================
   SOLUTIONS: SET 15 (Function & Trigger)
========================================= */

-- Set 15 Q1: Ranking Function 
DELIMITER $$
CREATE FUNCTION Student_Class_Assign(cgpa_val DECIMAL(4,2)) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF cgpa_val >= 9 THEN RETURN 'Distinction';
    ELSEIF cgpa_val >= 7 THEN RETURN 'First Class';
    ELSEIF cgpa_val >= 5.5 THEN RETURN 'Second Class';
    ELSEIF cgpa_val >= 4 THEN RETURN 'Pass';
    ELSE RETURN 'Fail';
    END IF;
END $$
DELIMITER ;

-- Set 15 Q2: Audit Trigger 
CREATE TABLE IF NOT EXISTS Student_Audit (
    Audit_id INT AUTO_INCREMENT PRIMARY KEY,
    Student_id VARCHAR(6),
    Old_CGPA DECIMAL(4,2),
    New_CGPA DECIMAL(4,2),
    Action_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
CREATE TRIGGER Student_Audit_Log
AFTER UPDATE ON Student
FOR EACH ROW
BEGIN
    INSERT INTO Student_Audit (Student_id, Old_CGPA, New_CGPA) 
    VALUES (OLD.Student_id, OLD.CGPA, NEW.CGPA);
END $$
DELIMITER ;
