/* ============================================================
   PROJECT:   Bookstore Management System
   AUTHOR:    Group YMY  | Course: SQL Server Database Development
   DATE:      Fall 2025
   ============================================================ */

CREATE DATABASE BookstoreDB;
GO
USE BookstoreDB;
GO

/* ============================================================
   TABLE 1: Supplier
   ============================================================ */
CREATE TABLE dbo.Supplier (
    SupplierID     INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName   NVARCHAR(100)  NOT NULL,
    ContactName    NVARCHAR(100),
    Phone          NVARCHAR(20),
    Email          NVARCHAR(100),
    City           NVARCHAR(50),
    Country        NVARCHAR(50),
    Status         BIT NOT NULL DEFAULT 1,         -- 1 = active
    DateCreated    DATETIME DEFAULT GETDATE()
);
GO

/* ============================================================
   TABLE 2: Book
   ============================================================ */
CREATE TABLE dbo.Book (
    BookID         INT IDENTITY(1,1) PRIMARY KEY,
    ISBN           NVARCHAR(20) UNIQUE NOT NULL,
    Title          NVARCHAR(200) NOT NULL,
    Author         NVARCHAR(100),
    Publisher      NVARCHAR(100),
    PublishYear    INT CHECK (PublishYear >= 1900),
    Genre          NVARCHAR(50),
    UnitPrice      DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    SupplierID     INT NOT NULL,
    Discontinued   BIT DEFAULT 0,
    CONSTRAINT FK_Book_Supplier FOREIGN KEY (SupplierID)
        REFERENCES dbo.Supplier(SupplierID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

/* ============================================================
   TABLE 3: Inventory
   ============================================================ */
CREATE TABLE dbo.Inventory (
    InventoryID       INT IDENTITY(1,1) PRIMARY KEY,
    BookID            INT NOT NULL,
    QuantityInStock   INT DEFAULT 0 CHECK (QuantityInStock >= 0),
    ReorderLevel      INT DEFAULT 10 CHECK (ReorderLevel >= 0),
    LastRestockDate   DATE,
    CONSTRAINT FK_Inventory_Book FOREIGN KEY (BookID)
        REFERENCES dbo.Book(BookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO

/* ============================================================
   TABLE 4: Customer
   ============================================================ */
CREATE TABLE dbo.Customer (
    CustomerID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName   NVARCHAR(100) NOT NULL,
    Email          NVARCHAR(100) UNIQUE,
    Phone          NVARCHAR(20),
    Address        NVARCHAR(200),
    City           NVARCHAR(50),
    Country        NVARCHAR(50),
    MemberSince    DATE DEFAULT GETDATE()
);
GO

/* ============================================================
   TABLE 5: SalesOrder (Header)
   ============================================================ */
CREATE TABLE dbo.SalesOrder (
    OrderID          INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID       INT NOT NULL,
    OrderDate        DATE NOT NULL DEFAULT GETDATE(),
    TotalAmount      DECIMAL(10,2) DEFAULT 0 CHECK (TotalAmount >= 0),
    PaymentStatus    NVARCHAR(20) DEFAULT 'Pending',   -- Paid / Pending / Refunded
    ShippingStatus   NVARCHAR(20) DEFAULT 'Pending',   -- Shipped / Delivered
    CONSTRAINT FK_SalesOrder_Customer FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customer(CustomerID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

/* ============================================================
   TABLE 6: SalesOrderLine (Detail)
   ============================================================ */
CREATE TABLE dbo.SalesOrderLine (
    OrderLineID   INT IDENTITY(1,1) PRIMARY KEY,
    OrderID       INT NOT NULL,
    BookID        INT NOT NULL,
    Quantity      INT NOT NULL CHECK (Quantity > 0),
    UnitPrice     DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    LineTotal     AS (Quantity * UnitPrice) PERSISTED,
    CONSTRAINT FK_SalesOrderLine_Order FOREIGN KEY (OrderID)
        REFERENCES dbo.SalesOrder(OrderID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_SalesOrderLine_Book FOREIGN KEY (BookID)
        REFERENCES dbo.Book(BookID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

/* ============================================================
   TABLE 7: PurchaseOrder
   ============================================================ */
CREATE TABLE dbo.PurchaseOrder (
    PurchaseID     INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID     INT NOT NULL,
    OrderDate      DATE NOT NULL DEFAULT GETDATE(),
    TotalCost      DECIMAL(10,2) DEFAULT 0 CHECK (TotalCost >= 0),
    ReceivedDate   DATE,
    CONSTRAINT FK_PurchaseOrder_Supplier FOREIGN KEY (SupplierID)
        REFERENCES dbo.Supplier(SupplierID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO

/* ============================================================
   INDEXING STRATEGY
   ============================================================ */
CREATE NONCLUSTERED INDEX IX_Inventory_BookID ON dbo.Inventory(BookID);
CREATE NONCLUSTERED INDEX IX_SalesOrder_Cust  ON dbo.SalesOrder(CustomerID);
CREATE NONCLUSTERED INDEX IX_SalesLine_Order  ON dbo.SalesOrderLine(OrderID);
GO


USE BookstoreDB;
GO

/* ============================================================
   INSERT data to Table
   ============================================================ */

/* -----------------------
   1. Supplier
-------------------------*/
INSERT INTO dbo.Supplier (SupplierName, ContactName, Phone, Email, City, Country)
VALUES 
('Global Books', 'Alice Wong', '123-4567', 'alice@globalbooks.com', 'Toronto', 'Canada'),
('Maple Publications', 'Bob Lee', '234-5678', 'bob@maplepub.com', 'Vancouver', 'Canada'),
('Oceanic Press', 'Carol Chan', '345-6789', 'carol@oceanic.com', 'Montreal', 'Canada'),
('Northern Reads', 'David Ng', '456-7890', 'david@northernreads.com', 'Ottawa', 'Canada'),
('Sunshine Books', 'Eve Tan', '567-8901', 'eve@sunshine.com', 'Calgary', 'Canada');
GO

/* -----------------------
   2. Book
-------------------------*/
-- 每個供應商 4–6 本書
INSERT INTO dbo.Book (ISBN, Title, Author, Publisher, PublishYear, Genre, UnitPrice, SupplierID)
VALUES
('978-0-001', 'SQL Basics', 'John Doe', 'Global Books', 2020, 'Technology', 29.99, 1),
('978-0-002', 'Advanced SQL', 'Jane Smith', 'Global Books', 2021, 'Technology', 39.99, 1),
('978-0-003', 'Database Design', 'Peter Pan', 'Maple Publications', 2019, 'Education', 25.50, 2),
('978-0-004', 'Data Analytics 101', 'Mary Sue', 'Maple Publications', 2022, 'Technology', 32.00, 2),
('978-0-005', 'Modern Databases', 'Alan Turing', 'Oceanic Press', 2018, 'Technology', 45.00, 3),
('978-0-006', 'AI and Data', 'Grace Hopper', 'Oceanic Press', 2021, 'Science', 50.00, 3),
('978-0-007', 'Literature Classics', 'William Shakespeare', 'Northern Reads', 2015, 'Fiction', 15.00, 4),
('978-0-008', 'Poetry Anthology', 'Emily Dickinson', 'Northern Reads', 2016, 'Poetry', 18.00, 4),
('978-0-009', 'Children Stories', 'Dr. Seuss', 'Sunshine Books', 2017, 'Children', 20.00, 5),
('978-0-010', 'Science Experiments', 'Isaac Newton', 'Sunshine Books', 2020, 'Science', 28.50, 5);
GO

/* -----------------------
   3. Inventory
-------------------------*/
INSERT INTO dbo.Inventory (BookID, QuantityInStock, ReorderLevel, LastRestockDate)
SELECT BookID, FLOOR(RAND(CHECKSUM(NEWID()))*50 + 10), 10, GETDATE()
FROM dbo.Book;
GO

/* -----------------------
   4. Customer
-------------------------*/
INSERT INTO dbo.Customer (CustomerName, Email, Phone, Address, City, Country)
VALUES
('Alice Brown', 'alice.brown@example.com', '111-1111', '123 Maple St', 'Toronto', 'Canada'),
('Bob White', 'bob.white@example.com', '222-2222', '456 Oak St', 'Vancouver', 'Canada'),
('Carol Green', 'carol.green@example.com', '333-3333', '789 Pine St', 'Montreal', 'Canada'),
('David Black', 'david.black@example.com', '444-4444', '321 Birch St', 'Ottawa', 'Canada'),
('Eve Gray', 'eve.gray@example.com', '555-5555', '654 Cedar St', 'Calgary', 'Canada'),
('Frank Blue', 'frank.blue@example.com', '666-6666', '987 Spruce St', 'Edmonton', 'Canada'),
('Grace Yellow', 'grace.yellow@example.com', '777-7777', '111 Willow St', 'Winnipeg', 'Canada'),
('Hank Purple', 'hank.purple@example.com', '888-8888', '222 Ash St', 'Quebec', 'Canada'),
('Ivy Orange', 'ivy.orange@example.com', '999-9999', '333 Elm St', 'Halifax', 'Canada'),
('Jack Red', 'jack.red@example.com', '000-0000', '444 Fir St', 'London', 'Canada');
GO

/* -----------------------
   5. SalesOrder
-------------------------*/
-- 每個客戶 1–3 筆訂單
DECLARE @CustomerID INT;
DECLARE @OrderCount INT;
DECLARE CustomerCursor CURSOR FOR SELECT CustomerID FROM dbo.Customer;

OPEN CustomerCursor;
FETCH NEXT FROM CustomerCursor INTO @CustomerID;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @OrderCount = FLOOR(RAND(CHECKSUM(NEWID()))*3) + 1;
    DECLARE @i INT = 1;
    WHILE @i <= @OrderCount
    BEGIN
        INSERT INTO dbo.SalesOrder (CustomerID, OrderDate, PaymentStatus, ShippingStatus)
        VALUES (@CustomerID,
                DATEADD(day, -FLOOR(RAND(CHECKSUM(NEWID()))*30), GETDATE()),
                CASE WHEN RAND() > 0.5 THEN 'Paid' ELSE 'Pending' END,
                'Pending');
        SET @i = @i + 1;
    END
    FETCH NEXT FROM CustomerCursor INTO @CustomerID;
END

CLOSE CustomerCursor;
DEALLOCATE CustomerCursor;
GO

/* -----------------------
   6. SalesOrderLine
-------------------------*/
-- 每筆訂單隨機 1–5 本書
DECLARE @OrderID INT, @BookCount INT, @BookID INT, @UnitPrice DECIMAL(10,2);

DECLARE OrderCursor CURSOR FOR
SELECT OrderID FROM dbo.SalesOrder;

OPEN OrderCursor
FETCH NEXT FROM OrderCursor INTO @OrderID;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @BookCount = FLOOR(RAND(CHECKSUM(NEWID()))*5) + 1;  -- 1–5 本書
    DECLARE @i INT = 1;
    WHILE @i <= @BookCount
    BEGIN
        SELECT TOP 1 @BookID = BookID, @UnitPrice = UnitPrice
        FROM dbo.Book
        ORDER BY NEWID();
        
        INSERT INTO dbo.SalesOrderLine (OrderID, BookID, Quantity, UnitPrice)
        VALUES (@OrderID, @BookID, FLOOR(RAND(CHECKSUM(NEWID()))*5)+1, @UnitPrice);
        
        SET @i = @i + 1;
    END
    FETCH NEXT FROM OrderCursor INTO @OrderID;
END

CLOSE OrderCursor;
DEALLOCATE OrderCursor;
GO

/* -----------------------
   7. PurchaseOrder
-------------------------*/
-- 每個供應商 1–4 筆採購單
DECLARE @SupplierID INT;
DECLARE SupplierCursor CURSOR FOR
SELECT SupplierID FROM dbo.Supplier;

OPEN SupplierCursor
FETCH NEXT FROM SupplierCursor INTO @SupplierID;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @POCount INT = FLOOR(RAND(CHECKSUM(NEWID()))*4)+1;
    DECLARE @j INT = 1;
    WHILE @j <= @POCount
    BEGIN
        INSERT INTO dbo.PurchaseOrder (SupplierID, OrderDate, TotalCost, ReceivedDate)
        VALUES (
            @SupplierID,
            DATEADD(day, -FLOOR(RAND(CHECKSUM(NEWID()))*60), GETDATE()),
            FLOOR(RAND(CHECKSUM(NEWID()))*500 + 50),
            CASE WHEN RAND() > 0.5 THEN DATEADD(day, FLOOR(RAND(CHECKSUM(NEWID()))*10), GETDATE()) ELSE NULL END
        );
        SET @j = @j + 1;
    END
    FETCH NEXT FROM SupplierCursor INTO @SupplierID;
END

CLOSE SupplierCursor;
DEALLOCATE SupplierCursor;
GO




EXEC sp_help 'dbo.Book';

GO


/*update dbo.SalesOrder totalAMount*/
UPDATE so
SET TotalAmount = (
    SELECT SUM(LineTotal)
    FROM dbo.SalesOrderLine sol
    WHERE sol.OrderID = so.OrderID
)
FROM dbo.SalesOrder so;
