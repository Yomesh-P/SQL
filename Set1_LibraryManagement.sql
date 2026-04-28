
/* =========================================
   CREATE DATABASE
========================================= */
CREATE DATABASE LibraryDB;
USE LibraryDB;

/* =========================================
   DROP TABLES (if already exist)
========================================= */
DROP TABLE IF EXISTS Issue;
DROP TABLE IF EXISTS Member;
DROP TABLE IF EXISTS Book;


/* =========================================
   CREATE BOOK TABLE
========================================= */
CREATE TABLE Book(
    Book_id VARCHAR(6) PRIMARY KEY,
    Title VARCHAR(50) NOT NULL,
    Author VARCHAR(30) NOT NULL,
    Category VARCHAR(20),
    Price DECIMAL(8,2) NOT NULL CHECK (Price > 0),
    Qty_available INT NOT NULL,
    CHECK(Book_id LIKE 'B%')
);

/* =========================================
   INSERT INTO BOOK
========================================= */
INSERT INTO Book VALUES
('B00001','Data Structures','Mark Allen','CS',450,10),
('B00002','DBMS Concepts','Korth','CS',550,8),
('B00003','Operating Systems','Galvin','CS',600,5),
('B00004','Computer Networks','Tanenbaum','CS',700,6),
('B00005','Algorithms','Cormen','CS',850,4),
('B00006','Discrete Math','Kenneth Rosen','Math',400,12),
('B00007','Python Programming','Lutz','CS',500,7);

/* =========================================
   CREATE MEMBER TABLE
========================================= */
CREATE TABLE Member(
    Member_id VARCHAR(6) PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    City VARCHAR(20),
    State VARCHAR(20),
    Phone BIGINT,
    Membership_type VARCHAR(10),
    CHECK(Member_id LIKE 'M%'),
    CHECK(Membership_type IN ('Gold','Silver','Basic'))
);

/* =========================================
   INSERT INTO MEMBER
========================================= */
INSERT INTO Member VALUES
('M00001','Rahul Sharma','Mumbai','Maharashtra',9876543210,'Gold'),
('M00002','Priya Mehta','Pune','Maharashtra',9876500001,'Silver'),
('M00003','Arun Kumar','Delhi','Delhi',9876500002,'Basic'),
('M00004','Sneha Patil','Bangalore','Karnataka',9876500003,'Gold'),
('M00005','Vijay Nair','Chennai','Tamil Nadu',9876500004,'Silver');

/* =========================================
   CREATE ISSUE TABLE
========================================= */
CREATE TABLE Issue(
    Issue_id VARCHAR(6) PRIMARY KEY,
    Book_id VARCHAR(6),
    Member_id VARCHAR(6),
    Issue_date DATE NOT NULL,
    Return_date DATE,
    Status VARCHAR(10),
    FOREIGN KEY(Book_id) REFERENCES Book(Book_id),
    FOREIGN KEY(Member_id) REFERENCES Member(Member_id),
    CHECK(Issue_id LIKE 'I%'),
    CHECK(Return_date >= Issue_date),
    CHECK(Status IN ('Issued','Returned','Overdue'))
);

/* =========================================
   INSERT INTO ISSUE
========================================= */
INSERT INTO Issue VALUES
('I00001','B00001','M00001','2024-01-01','2024-01-10','Returned'),
('I00002','B00002','M00002','2024-01-05','2024-01-15','Issued'),
('I00003','B00003','M00001','2024-01-10','2024-01-20','Overdue'),
('I00004','B00004','M00003','2024-02-15','2024-02-25','Returned'),
('I00005','B00005','M00004','2024-02-20','2024-03-01','Issued');


/* =========================================
   SET 1 SOLUTIONS
========================================= */

-- Q1
SELECT * FROM Book;

-- Q2
ALTER TABLE Book RENAME TO Book_Master;

-- Q3
SELECT COUNT(*) AS Total_Books
FROM Book_Master;

-- Q4
SELECT Name, City
FROM Member;


/* =========================================
   Rename back for next sets
========================================= */
ALTER TABLE Book_Master RENAME TO Book;


/* =========================================
   SET 2 SOLUTIONS
========================================= */

-- Q1
ALTER TABLE Issue
ADD Fine_amount DECIMAL(8,2);

-- Q2
SELECT m.Name
FROM Member m
JOIN Issue i
ON m.Member_id = i.Member_id
WHERE i.Status='Overdue';

-- Q3
SELECT MIN(Price), MAX(Price)
FROM Book;

-- Q4
SELECT Title,
(
    SELECT Name
    FROM Member
    WHERE Member.Member_id = Issue.Member_id
) AS Member_Name
FROM Book, Issue
WHERE Book.Book_id = Issue.Book_id
AND Issue.Status='Issued';


/* =========================================
   SET 3 SOLUTIONS
========================================= */

-- Q1
SELECT *
FROM Book
WHERE Category='CS';

-- Q2
SELECT Category, COUNT(*)
FROM Book
GROUP BY Category;

-- Q3
UPDATE Book
SET Price=500
WHERE Book_id='B00001';

-- Q4
CREATE VIEW Book_View AS
SELECT Book_id, Title, Author
FROM Book;

-- Q5
SELECT SUM(Qty_available)
FROM Book;


/* =========================================
   SET 4 FUNCTION
========================================= */

DELIMITER $$

CREATE FUNCTION Book_Category_Label(book_price DECIMAL(8,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(20);

    IF book_price < 400 THEN
        SET result='Budget';

    ELSEIF book_price BETWEEN 400 AND 700 THEN
        SET result='Mid-Range';

    ELSE
        SET result='Premium';

    END IF;

    RETURN result;
END $$

DELIMITER ;

-- TEST FUNCTION
SELECT Book_id, Title, Price,
Book_Category_Label(Price)
FROM Book;


/* =========================================
   SET 4 CURSOR
========================================= */

DELIMITER $$

CREATE PROCEDURE Show_Books()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE b_id VARCHAR(6);
    DECLARE b_title VARCHAR(50);

    DECLARE cur CURSOR FOR
    SELECT Book_id, Title FROM Book;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET done = TRUE;

    OPEN cur;

    read_loop: LOOP

        FETCH cur INTO b_id, b_title;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT b_id, b_title;

    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

-- CALL PROCEDURE
CALL Show_Books();


/* =========================================
   SET 5 TRIGGER
========================================= */

DELIMITER $$

CREATE TRIGGER Member_Name_Uppercase
BEFORE INSERT
ON Member
FOR EACH ROW
BEGIN
    SET NEW.Name = UPPER(NEW.Name);
END $$

DELIMITER ;


-- TEST TRIGGER
INSERT INTO Member VALUES
('M00006','rohit patil','Nashik','Maharashtra',9876500005,'Gold');


/* =========================================
   SET 5 PROCEDURE
========================================= */

DELIMITER $$

CREATE PROCEDURE Total_Issued_Books(
    IN mem_id VARCHAR(6)
)
BEGIN
    SELECT COUNT(*) AS Total_Books_Issued
    FROM Issue
    WHERE Member_id = mem_id
    AND Status='Issued';
END $$

DELIMITER ;

-- CALL PROCEDURE
CALL Total_Issued_Books('M00001');
