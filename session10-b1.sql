CREATE schema InventoryManagement;
USE InventoryManagement;

CREATE TABLE Products (
ProductID INT PRIMARY KEY AUTO_INCREMENT,
ProductName VARCHAR(100),
Quantity INT
);
INSERT INTO Products (ProductID, ProductName, Quantity)
VALUES (1, 'giày', 10),
	   (2, 'dép', 20),
       (3, 'áo', 15);
CREATE TABLE InventoryChanges (
ChangeID INT Primary Key AUTO_INCREMENT,
ProductID INT, 
OldQuantity INT,
NewQuantity INT,
ChangeDate DATETIME,
Foreign Key (ProductID) REFERENCES Products(ProductID)
);
DELIMITER $$
CREATE TRIGGER AfterProductUpdate
AFTER UPDATE 
ON Products
FOR EACH ROW
BEGIN
	 INSERT INTO  InventoryChanges (ProductID, OldQuantity, NewQuantity, ChangeDate)
     VALUES (NEW.ProductID, OLD.Quantity, NEW.Quantity, NOW());
END $$
DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
UPDATE Products 
SET Quantity = 50
WHERE Quantity = 15;

UPDATE Products 
SET Quantity = 30
WHERE Quantity = 10;

-- 
DELIMITER $$
CREATE TRIGGER BeforeProductDelete
BEFORE DELETE
ON Products
FOR EACH ROW
BEGIN
     IF OLD.Quantity > 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Can not delete product';
	 END IF;
END $$
DELIMITER ;

-- 
ALTER TABLE Products
ADD LastUpdated DATETIME DEFAULT NOW();

DELIMITER $$
CREATE TRIGGER AfterProductUpdateSetDate
AFTER UPDATE 
ON Products
FOR EACH ROW
BEGIN
	 UPDATE Products 
     SET LastUpdated = Now()
     WHERE ProductID = NEW.ProductID;
END $$
DELIMITER ;
UPDATE Products
SET Quantity = 100
WHERE ProductID = 1;

-- b5
CREATE TABLE InventoryChangeHistory (
HistoryID INT Primary Key AUTO_INCREMENT,
ProductID INT,
OldQuantity INT,
NewQuantity INT,
ChangeType ENUM('INSERT', 'UPDATE', 'DELETE'),
ChangeDate DATETIME,
Foreign Key (ProductID) REFERENCES Products(ProductID)
);

DELIMITER $$
CREATE TRIGGER AfterProductUpdateHistory 
AFTER UPDATE 
ON Products
FOR EACH ROW
BEGIN
	 INSERT INTO  InventoryChangeHistory (ProductID, OldQuantity, NewQuantity, ChangeType, ChangeDate)
     VALUES (NEW.ProductID, OLD.Quantity, NEW.Quantity,'UPDATE', NOW());
END $$
DELIMITER ;

-- b4
CREATE TABLE ProductSummary (
SummaryID INT Primary Key, 
TotalQuantity INT
);

DELIMITER $$
CREATE TRIGGER AfterProductUpdateSummary
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
	UPDATE ProductSummary
    SET TotalQuantity = (SELECT SUM(Quantity) FROM Products);
END $$
DELIMITER ;
DROP TRIGGER AfterProductUpdateSummary;
SET SQL_SAFE_UPDATES = 0;
UPDATE Products
SET Quantity = 90
WHERE ProductID = 1;
