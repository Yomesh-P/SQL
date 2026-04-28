
/* =========================================
   DATABASE INITIALIZATION
========================================= */
CREATE DATABASE IF NOT EXISTS HotelDB;
USE HotelDB;

/* Drop tables in proper order */
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Guest;
DROP TABLE IF EXISTS Room;


/* =========================================
   TABLE CREATION
========================================= */

CREATE TABLE Room(
    Room_no VARCHAR(5) PRIMARY KEY,
    Room_type VARCHAR(15),
    Floor_no INT NOT NULL,
    Capacity INT NOT NULL,
    Rate_per_night DECIMAL(8,2) NOT NULL CHECK(Rate_per_night > 0),
    Status VARCHAR(15),
    CHECK(Room_no LIKE 'R%'),
    CHECK(Room_type IN ('Standard','Deluxe','Suite')),
    CHECK(Status IN ('Available','Occupied','Maintenance'))
);

CREATE TABLE Guest(
    Guest_id VARCHAR(6) PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    City VARCHAR(20),
    Country VARCHAR(20) DEFAULT 'India',
    Phone BIGINT NOT NULL,
    Email VARCHAR(30),
    CHECK(Guest_id LIKE 'G%')
);

CREATE TABLE Booking(
    Booking_id VARCHAR(6) PRIMARY KEY,
    Guest_id VARCHAR(6),
    Room_no VARCHAR(5),
    Check_in DATE NOT NULL,
    Check_out DATE,
    Total_amount DECIMAL(10,2) NOT NULL,
    Payment_status VARCHAR(10),
    FOREIGN KEY(Guest_id) REFERENCES Guest(Guest_id),
    FOREIGN KEY(Room_no) REFERENCES Room(Room_no),
    CHECK(Booking_id LIKE 'K%'),
    CHECK(Check_out >= Check_in),
    CHECK(Payment_status IN ('Paid','Pending','Partial'))
);


/* =========================================
   INSERT DATA
========================================= */

INSERT INTO Room VALUES
('R0101','Standard',1,2,2500.00,'Available'),
('R0102','Standard',1,2,2500.00,'Occupied'),
('R0201','Deluxe',2,3,5000.00,'Available'),
('R0202','Deluxe',2,3,5000.00,'Maintenance'),
('R0301','Suite',3,4,10000.00,'Occupied'),
('R0302','Suite',3,4,10000.00,'Available');

INSERT INTO Guest VALUES
('G00001','Nidhi Kapoor','Mumbai','India',9811001100,'nidhi@mail.com'),
('G00002','James Smith','London','UK',9811002200,'james@mail.com'),
('G00003','Akira Tanaka','Tokyo','Japan',9811003300,'akira@mail.com'),
('G00004','Rashida Khan','Dubai','UAE',9811004400,'rashida@mail.com'),
('G00005','Priyanka Sen','Kolkata','India',9811005500,'priya@mail.com');

INSERT INTO Booking VALUES
('K00001','G00001','R0101','2024-01-10','2024-01-14',10000.00,'Paid'),
('K00002','G00002','R0301','2024-01-12','2024-01-15',30000.00,'Pending'),
('K00003','G00003','R0201','2024-01-20','2024-01-22',10000.00,'Paid'),
('K00004','G00004','R0102','2024-02-01','2024-02-03',5000.00,'Partial'),
('K00005','G00005','R0302','2024-02-10','2024-02-13',30000.00,'Paid');


/* =========================================
   SET 21 SOLUTIONS
========================================= */

-- Q1 Retrieve all room details
SELECT * FROM Room;

-- Q2 List all guests from India
SELECT *
FROM Guest
WHERE Country='India';

-- Q3 Total number of rooms available
SELECT COUNT(*) AS Total_Available_Rooms
FROM Room
WHERE Status='Available';

-- Q4 Rename Guest table
ALTER TABLE Guest RENAME TO Guest_Register;

-- Rename back for next sets
ALTER TABLE Guest_Register RENAME TO Guest;


/* =========================================
   SET 22 SOLUTIONS
========================================= */

-- Q1 Available Suite rooms
SELECT *
FROM Room
WHERE Room_type='Suite'
AND Status='Available';

-- Q2 Max and Min rate
SELECT MAX(Rate_per_night) AS Maximum_Rate,
       MIN(Rate_per_night) AS Minimum_Rate
FROM Room;

-- Q3 Count rooms by room type
SELECT Room_type, COUNT(*) AS Room_Count
FROM Room
GROUP BY Room_type;

-- Q4 Order by rate descending
SELECT *
FROM Room
ORDER BY Rate_per_night DESC;

-- Q5 Create View
CREATE VIEW Room_View AS
SELECT Room_no, Room_type, Status
FROM Room;


/* =========================================
   SET 23 SOLUTIONS
========================================= */

-- Q1 Guest name and room type (join)
SELECT g.Name AS Guest_Name,
       r.Room_type
FROM Guest g
JOIN Booking b
ON g.Guest_id=b.Guest_id
JOIN Room r
ON r.Room_no=b.Room_no;

-- Q2 Guest name and country for booking K00002 (nested query)
SELECT Name, Country
FROM Guest
WHERE Guest_id=
(
    SELECT Guest_id
    FROM Booking
    WHERE Booking_id='K00002'
);

-- Q3 Total revenue per room type
SELECT r.Room_type,
       SUM(b.Total_amount) AS Total_Revenue
FROM Room r
JOIN Booking b
ON r.Room_no=b.Room_no
GROUP BY r.Room_type;

-- Q4 Guests with pending payment
SELECT Name
FROM Guest
WHERE Guest_id IN
(
    SELECT Guest_id
    FROM Booking
    WHERE Payment_status='Pending'
);


/* =========================================
   SET 24 SOLUTIONS
========================================= */

-- Audit Table
CREATE TABLE Guest_Audit(
    Audit_id INT AUTO_INCREMENT PRIMARY KEY,
    Guest_id VARCHAR(6),
    Old_Name VARCHAR(30),
    New_Name VARCHAR(30),
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for audit
DELIMITER $$

CREATE TRIGGER Guest_Update_Audit
AFTER UPDATE
ON Guest
FOR EACH ROW
BEGIN
    INSERT INTO Guest_Audit(Guest_id, Old_Name, New_Name)
    VALUES(OLD.Guest_id, OLD.Name, NEW.Name);
END $$

DELIMITER ;

-- Copy table
CREATE TABLE Guest_Backup AS
SELECT * FROM Guest;

-- Alter table
ALTER TABLE Guest
ADD Loyalty_points INT;

-- Cursor Procedure
DELIMITER $$

CREATE PROCEDURE Show_Guest_Details()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE g_name VARCHAR(30);
    DECLARE g_email VARCHAR(30);

    DECLARE cur CURSOR FOR
    SELECT Name, Email FROM Guest;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET done=TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO g_name, g_email;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT CONCAT(g_name,' - ',g_email) AS Guest_Details;

    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

-- Test Cursor
CALL Show_Guest_Details();


/* =========================================
   SET 25 SOLUTIONS
========================================= */

-- Function for billing category
DELIMITER $$

CREATE FUNCTION Billing_Category(total_amt DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(20);

    IF total_amt > 20000 THEN
        SET result='Premium';

    ELSEIF total_amt BETWEEN 5000 AND 20000 THEN
        SET result='Standard';

    ELSE
        SET result='Budget';

    END IF;

    RETURN result;
END $$

DELIMITER ;

-- Test Function
SELECT Booking_id, Total_amount,
Billing_Category(Total_amount)
FROM Booking;


-- Procedure: total amount spent by guest
DELIMITER $$

CREATE PROCEDURE Guest_Total_Spent(
    IN guestid VARCHAR(6),
    OUT total_spent DECIMAL(12,2)
)
BEGIN
    SELECT SUM(Total_amount)
    INTO total_spent
    FROM Booking
    WHERE Guest_id=guestid;
END $$

DELIMITER ;

-- Test Procedure
CALL Guest_Total_Spent('G00001', @amount);
SELECT @amount;