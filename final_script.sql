
--Create schema
CREATE DATABASE BookstoreDB;
GO
USE BookstoreDB;
GO

--create table
/* TABLE 1: Supplier */
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

/* TABLE 2: Book */
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

/*TABLE 3: Inventory */
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

/*TABLE 4: Customer*/
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

/* TABLE 5: SalesOrder (Header) */
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

/*  TABLE 6: SalesOrderLine (Detail) */
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

/* TABLE 7: PurchaseOrder */
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

/* INDEXING */
CREATE NONCLUSTERED INDEX IX_Inventory_BookID ON dbo.Inventory(BookID);
CREATE NONCLUSTERED INDEX IX_SalesOrder_Cust  ON dbo.SalesOrder(CustomerID);
CREATE NONCLUSTERED INDEX IX_SalesLine_Order  ON dbo.SalesOrderLine(OrderID);
GO

--insert data to table


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
DECLARE @OrderID INT, @BookCount INT, @BookID INT, @UnitPrice DECIMAL(10,2);

DECLARE OrderCursor CURSOR FOR
SELECT OrderID FROM dbo.SalesOrder;

OPEN OrderCursor
FETCH NEXT FROM OrderCursor INTO @OrderID;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @BookCount = FLOOR(RAND(CHECKSUM(NEWID()))*5) + 1;  -- 1¡V5 ¥»®Ñ
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



--schema information
EXEC sp_help 'dbo.Book';
GO

UPDATE so
SET so.TotalAmount = (
    SELECT SUM(LineTotal)
    FROM dbo.SalesOrderLine sol
    WHERE sol.OrderID = so.OrderID
)
FROM dbo.SalesOrder so;

--view
CREATE OR ALTER VIEW vBookCatalog AS
SELECT b.BookID, b.Title, b.Author, b.UnitPrice, i.QuantityInStock AS Stock
FROM Book b
LEFT JOIN Inventory i ON b.BookID = i.BookID;
GO

CREATE OR ALTER VIEW vCustomerOrders AS
SELECT c.CustomerID, c.CustomerName, s.OrderID, s.OrderDate,
       SUM(sl.Quantity * sl.UnitPrice) AS TotalAmount
FROM Customer c
JOIN SalesOrder s ON c.CustomerID = s.CustomerID
JOIN SalesOrderLine sl ON s.OrderID = sl.OrderID
GROUP BY c.CustomerID, c.CustomerName, s.OrderID, s.OrderDate;
GO

CREATE OR ALTER VIEW vSalesReport AS
SELECT b.BookID, b.Title,
       SUM(sl.Quantity) AS TotalSold,
       SUM(sl.Quantity * sl.UnitPrice) AS TotalRevenue
FROM Book b
JOIN SalesOrderLine sl ON b.BookID = sl.BookID
GROUP BY b.BookID, b.Title;
GO

--function
CREATE OR ALTER FUNCTION ufn_GetBookStock (@BookID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Stock INT;
    SELECT @Stock = QuantityInStock
    FROM Inventory
    WHERE BookID = @BookID;
    RETURN @Stock;
END;
GO

CREATE OR ALTER FUNCTION ufn_GetDiscountedPrice (@BookID INT, @DiscountRate DECIMAL(5,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Price DECIMAL(10,2);
    SELECT @Price = UnitPrice FROM Book WHERE BookID = @BookID;
    RETURN @Price * (1 - @DiscountRate);
END;
GO

--Procedure
/* ============================================================
   Procedure: usp_AddNewBook
   Description: Adds a new book record with validation checks.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_AddNewBook
    @ISBN NVARCHAR(20),
    @Title NVARCHAR(200),
    @Author NVARCHAR(100),
    @Publisher NVARCHAR(100),
    @PublishYear INT,
    @Genre NVARCHAR(50),
    @UnitPrice DECIMAL(10,2),
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM dbo.Book WHERE ISBN = @ISBN)
        BEGIN
            RAISERROR('Book with this ISBN already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO dbo.Book (ISBN, Title, Author, Publisher, PublishYear, Genre, UnitPrice, SupplierID)
        VALUES (@ISBN, @Title, @Author, @Publisher, @PublishYear, @Genre, @UnitPrice, @SupplierID);

        COMMIT TRANSACTION;
        PRINT '✅ Book added successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '❌ Error adding book: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/* ============================================================
   Procedure: usp_UpdateStockAfterSale
   Description: Updates inventory after a sale and adjusts reorder logic.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_UpdateStockAfterSale
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @BookID INT, @Qty INT;

        DECLARE SaleCursor CURSOR FOR
        SELECT BookID, Quantity FROM dbo.SalesOrderLine WHERE OrderID = @OrderID;

        OPEN SaleCursor;
        FETCH NEXT FROM SaleCursor INTO @BookID, @Qty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE dbo.Inventory
            SET QuantityInStock = QuantityInStock - @Qty
            WHERE BookID = @BookID;

            FETCH NEXT FROM SaleCursor INTO @BookID, @Qty;
        END

        CLOSE SaleCursor;
        DEALLOCATE SaleCursor;

        -- Update TotalAmount of order
        UPDATE so
        SET TotalAmount = (
            SELECT SUM(LineTotal) FROM dbo.SalesOrderLine sol WHERE sol.OrderID = so.OrderID
        )
        FROM dbo.SalesOrder so WHERE so.OrderID = @OrderID;

        COMMIT TRANSACTION;
        PRINT '✅ Inventory and total updated successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '❌ Error updating inventory: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/* ============================================================
   Procedure: usp_CreatePurchaseOrder
   Description: Creates a purchase order and updates inventory after receiving.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_CreatePurchaseOrder
    @SupplierID INT,
    @BookID INT,
    @Quantity INT,
    @CostPerUnit DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TotalCost DECIMAL(10,2) = @Quantity * @CostPerUnit;

        INSERT INTO dbo.PurchaseOrder (SupplierID, OrderDate, TotalCost, ReceivedDate)
        VALUES (@SupplierID, GETDATE(), @TotalCost, NULL);

        DECLARE @PurchaseID INT = SCOPE_IDENTITY();

        UPDATE dbo.Inventory
        SET QuantityInStock = QuantityInStock + @Quantity,
            LastRestockDate = GETDATE()
        WHERE BookID = @BookID;

        COMMIT TRANSACTION;
        PRINT '✅ Purchase order created successfully (ID: ' + CAST(@PurchaseID AS NVARCHAR(10)) + ').';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '❌ Error creating purchase order: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/* ============================================================
   Procedure: usp_GetBooksByGenre_DynamicSQL
   Description: Returns book list dynamically filtered by genre.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_GetBooksByGenre_DynamicSQL
    @Genre NVARCHAR(50)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'SELECT BookID, Title, Author, Genre, UnitPrice
                 FROM dbo.Book
                 WHERE Genre = @GenreParam';

    EXEC sp_executesql @sql, N'@GenreParam NVARCHAR(50)', @GenreParam = @Genre;
END;
GO

/* ============================================================
   Procedure: usp_GetCustomerOrderSummary
   Description: Returns total orders, total amount, and last order date for a customer.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_GetCustomerOrderSummary
    @CustomerID INT
AS
BEGIN
    SELECT 
        c.CustomerName,
        COUNT(o.OrderID) AS TotalOrders,
        SUM(o.TotalAmount) AS TotalSpent,
        MAX(o.OrderDate) AS LastOrderDate
    FROM dbo.Customer c
    INNER JOIN dbo.SalesOrder o ON c.CustomerID = o.CustomerID
    WHERE c.CustomerID = @CustomerID
    GROUP BY c.CustomerName;
END;
GO


--trigger
CREATE OR ALTER TRIGGER trg_PreventBookDelete
ON Book
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Deletion of books is not allowed.';
END;
GO

CREATE OR ALTER TRIGGER trg_UpdateStockAfterOrder
ON SalesOrderLine
AFTER INSERT
AS
BEGIN
    UPDATE i
    SET i.QuantityInStock = i.QuantityInStock - ins.Quantity
    FROM Inventory i
    JOIN inserted ins ON i.BookID = ins.BookID;
END;
GO

CREATE OR ALTER TRIGGER trg_UpdateTotalAmount
ON SalesOrderLine
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE s
    SET s.TotalAmount = (
        SELECT SUM(sl.Quantity * sl.UnitPrice)
        FROM SalesOrderLine sl
        WHERE sl.OrderID = s.OrderID
    )
    FROM SalesOrder s;
END;
GO

--cursor
/*reorder low-stock books*/
declare @BookID INT, @SupplierID INT, @Qty INT;

declare crs_ReorderBooks cursor for
select b.BookID, b.SupplierID, i.QuantityInStock from dbo.book b
join dbo.Inventory i on b.BookID =i.BookID where i.QuantityInStock <i.ReorderLevel

open crs_ReorderBooks;
fetch next from crs_ReorderBooks into @BookID, @SupplierID, @Qty;
while @@FETCH_STATUS=0
begin
	insert into dbo.PurchaseOrder(SupplierID,TotalCost,ReceivedDate) values (@SupplierID,0,null);
	print'Reorder created for BookID=' + cast(@BookID as nvarchar(10));
	fetch next from crs_ReorderBooks into  @BookID, @SupplierID, @Qty;
end

close crs_ReorderBooks;
Deallocate crs_ReorderBooks;
go

/*customer sales summary*/
declare @customerID int, @customerName nvarchar(50), @totalSales decimal(10,2);
declare crs_saleSummary cursor dynamic for
select CustomerID, CustomerName from dbo.Customer;

open crs_saleSummary;
fetch next from crs_saleSummary into @customerId, @customerName;
while @@fetch_status=0
begin
	select @totalSales =isnull(sum(TotalAmount),0) from dbo.SalesOrder where CustomerID =@customerID;
	print 'Customer: '+@customerName +', Total Sales: $'+cast(@totalSales as nvarchar(20));
	fetch next from crs_saleSummary into @customerId, @customerName;
end
close crs_saleSummary;
deallocate crs_saleSummary;
go

--security

-- Admin
CREATE ROLE dbAdmin;
GRANT CONTROL ON DATABASE::BookstoreDB TO dbAdmin;

-- Manager
create role dbManager;
grant select, insert,update on dbo.Supplier to dbManager;
grant select, insert,update on dbo.PurchaseOrder to dbManager;
grant select, update on dbo.Inventory to dbManager;
grant select on dbo.vSalesReport  to dbManager;
grant select on dbo.vBookCatalog to dbManager;

-- Clerk
CREATE ROLE dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.SalesOrder TO dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.SalesOrderLine TO dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.Customer TO dbClerk;
GRANT SELECT ON dbo.Book TO dbClerk;

/* REVOKE  */
REVOKE DELETE ON dbo.Customer FROM dbClerk;

-- Customer
CREATE ROLE dbCustomer;
GRANT SELECT ON dbo.vBookCatalog    TO dbCustomer;
GRANT SELECT ON dbo.vCustomerOrders TO dbCustomer;

/* DENY */
DENY INSERT, UPDATE, DELETE ON DATABASE::BookstoreDB TO dbCustomer;

-- 3. Create Test Users
CREATE USER testAdmin WITHOUT LOGIN;
CREATE USER testManager WITHOUT LOGIN;
CREATE USER testClerk WITHOUT LOGIN;
CREATE USER testCustomer WITHOUT LOGIN;
EXEC sp_addrolemember 'dbAdmin', 'testAdmin';
EXEC sp_addrolemember 'dbManager', 'testManager';
EXEC sp_addrolemember 'dbClerk', 'testClerk';
EXEC sp_addrolemember 'dbCustomer', 'testCustomer';
PRINT 'Roles and test users created successfully.';
GO

--test
/* Test case:Successful Transaction (COMMIT)
   Purpose : Insert a new Sales Order and Order Line correctly */
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @OrderID INT;

    INSERT INTO dbo.SalesOrder (CustomerID, OrderDate, PaymentStatus, ShippingStatus)
    VALUES (1, GETDATE(), 'Pending', 'Pending');

    SET @OrderID = SCOPE_IDENTITY();

    INSERT INTO dbo.SalesOrderLine (OrderID, BookID, Quantity, UnitPrice)
    VALUES (@OrderID, 1, 2, 29.99);

    COMMIT TRANSACTION;
    PRINT ' Transaction committed successfully. OrderID: ' + CAST(@OrderID AS NVARCHAR(10));
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ' Transaction failed: ' + ERROR_MESSAGE();
END CATCH;
GO


/*Test case:Failed Transaction (ROLLBACK)
   Purpose : Trigger error by inserting invalid BookID */
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.SalesOrderLine (OrderID, BookID, Quantity, UnitPrice)
    VALUES (9999, 9999, 1, 10.00);  -- Invalid FK reference

    COMMIT TRANSACTION;
    PRINT 'Transaction committed.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back due to error: ' + ERROR_MESSAGE();
END CATCH;
GO


/*Test case: Error Handling with Nested TRY...CATCH
   Purpose : Demonstrate multiple layers of error control*/
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT 'Processing Inventory Update...';

    BEGIN TRY
        -- simulate logic error: negative quantity
        UPDATE dbo.Inventory
        SET QuantityInStock = QuantityInStock - 1000
        WHERE BookID = 1;

        IF (SELECT QuantityInStock FROM dbo.Inventory WHERE BookID = 1) < 0
            THROW 50001, 'Invalid inventory quantity: below zero.', 1;

        COMMIT TRANSACTION;
        PRINT 'Inventory updated successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Inner CATCH triggered: ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH;
END TRY
BEGIN CATCH
    PRINT 'Outer CATCH triggered: ' + ERROR_MESSAGE();
END CATCH;
GO


/* Test case:Optional Isolation-Level Demonstration
   Purpose : Show READ UNCOMMITTED vs READ COMMITTED*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
PRINT 'Current isolation level: READ UNCOMMITTED (dirty reads allowed)';
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT 'Current isolation level: READ COMMITTED (default, safer)';
GO

/*Stored Procedure Tests*/
PRINT 'Testing Stored Procedure: usp_AddNewBook';
EXEC dbo.usp_AddNewBook 
    @ISBN='999-999',
    @Title='Test Book',
    @Author='Test A',
    @Publisher='Test P',
    @PublishYear=2024,
    @Genre='Testing',
    @UnitPrice=25.00,
    @SupplierID=1;
GO

PRINT 'Testing Dynamic SQL Procedure: usp_GetBooksByGenre_DynamicSQL';
EXEC dbo.usp_GetBooksByGenre_DynamicSQL 'Science';
GO

/*View Test*/
PRINT 'Testing View: vBookCatalog';
SELECT TOP 5 * FROM dbo.vBookCatalog;

PRINT 'Testing View: vCustomerOrders';
SELECT TOP 5 * FROM dbo.vCustomerOrders;

PRINT 'Testing View: vSalesReport';
SELECT TOP 5 * FROM dbo.vSalesReport;
GO

/*Function Tests*/
PRINT 'Testing Function: ufn_GetBookStock';
SELECT dbo.ufn_GetBookStock(1) AS Stock;

PRINT 'Testing Function: ufn_GetDiscountedPrice';
SELECT dbo.ufn_GetDiscountedPrice(50, 0.10) AS DiscountedPrice;
GO

/*Trigger Tests*/
--Prevent Book Delete
PRINT 'Testing Trigger: trg_PreventBookDelete';
BEGIN TRY
    DELETE FROM dbo.Book WHERE BookID = 1;
END TRY
BEGIN CATCH
    PRINT 'Book delete prevented as expected: ' + ERROR_MESSAGE();
END CATCH;
GO

--Update Total Amount
PRINT 'Testing Trigger: trg_UpdateTotalAmount';
INSERT INTO dbo.SalesOrder (CustomerID) VALUES (1);
DECLARE @Order INT = SCOPE_IDENTITY();

INSERT INTO dbo.SalesOrderLine (OrderID, BookID, Quantity, UnitPrice)
VALUES (@Order, 1, 1, 29.99);

SELECT OrderID, TotalAmount FROM dbo.SalesOrder WHERE OrderID = @Order;
GO

--update stock after order
PRINT 'Testing Trigger: trg_UpdateStockAfterOrder';

INSERT INTO dbo.SalesOrder (CustomerID) VALUES (1);
DECLARE @OID INT = SCOPE_IDENTITY();

-- Insert an order line to reduce inventory
INSERT INTO dbo.SalesOrderLine (OrderID, BookID, Quantity, UnitPrice)
VALUES (@OID, 1, 2, 29.99);

PRINT 'Inventory after placing order:';
SELECT BookID, QuantityInStock FROM dbo.Inventory WHERE BookID = 1;
GO


/*cursor test*/
 -- Reorder Low-Stock Books

-- Before running cursor, show current PurchaseOrder count
PRINT 'PurchaseOrder count BEFORE cursor run:';
SELECT COUNT(*) AS BeforeCount FROM dbo.PurchaseOrder;

BEGIN
    DECLARE @BookID INT, @SupplierID INT, @Qty INT;

    DECLARE crs_ReorderBooks CURSOR FOR
    SELECT b.BookID, b.SupplierID, i.QuantityInStock
    FROM dbo.Book b
    JOIN dbo.Inventory i ON b.BookID = i.BookID
    WHERE i.QuantityInStock < i.ReorderLevel;

    OPEN crs_ReorderBooks;
    FETCH NEXT FROM crs_ReorderBooks INTO @BookID, @SupplierID, @Qty;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.PurchaseOrder (SupplierID, TotalCost, ReceivedDate)
        VALUES (@SupplierID, 0, NULL);

        PRINT 'Reorder created for BookID = ' + CAST(@BookID AS NVARCHAR(10));

        FETCH NEXT FROM crs_ReorderBooks INTO @BookID, @SupplierID, @Qty;
    END

    CLOSE crs_ReorderBooks;
    DEALLOCATE crs_ReorderBooks;
END;
GO

-- After running cursor, show updated PurchaseOrders
PRINT 'PurchaseOrder count AFTER cursor run:';
SELECT COUNT(*) AS AfterCount FROM dbo.PurchaseOrder;

PRINT 'Recent PurchaseOrders created:';
SELECT TOP 5 * 
FROM dbo.PurchaseOrder
ORDER BY PurchaseID DESC;
GO


/* Test Cursor 2: Customer Sales Summary (Dynamic Cursor)*/

BEGIN
    DECLARE @CustomerID INT, @CustomerName NVARCHAR(50), @TotalSales DECIMAL(10,2);

    DECLARE crs_SaleSummary CURSOR DYNAMIC FOR
    SELECT CustomerID, CustomerName
    FROM dbo.Customer;

    OPEN crs_SaleSummary;
    FETCH NEXT FROM crs_SaleSummary INTO @CustomerID, @CustomerName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @TotalSales = ISNULL(SUM(TotalAmount), 0)
        FROM dbo.SalesOrder
        WHERE CustomerID = @CustomerID;

        PRINT ' Customer: ' + @CustomerName + 
              '  Total Sales: $' + CAST(@TotalSales AS NVARCHAR(20));

        FETCH NEXT FROM crs_SaleSummary INTO @CustomerID, @CustomerName;
    END

    CLOSE crs_SaleSummary;
    DEALLOCATE crs_SaleSummary;
END;
GO

/*user　permission test*/

PRINT '--- Testing Manager (allowed) ---';
EXECUTE AS USER = 'testManager';
SELECT TOP 3 * FROM dbo.vSalesReport;
REVERT;
GO

PRINT '--- Testing Clerk (allowed) ---';
EXECUTE AS USER = 'testClerk';
SELECT TOP 3 * FROM dbo.SalesOrder;
REVERT;
GO

PRINT '--- Testing Customer (allowed SELECT only) ---';
EXECUTE AS USER = 'testCustomer';
SELECT TOP 3 * FROM dbo.vBookCatalog;
REVERT;
GO

/* REVOKE test */
PRINT '--- Testing REVOKE (Clerk delete should fail) ---';
EXECUTE AS USER = 'testClerk';
DELETE FROM dbo.Customer WHERE CustomerID = 1;  -- expected failure
REVERT;
GO

/* DENY test */
PRINT '--- Testing DENY (Customer insert should fail) ---';
EXECUTE AS USER = 'testCustomer';
INSERT INTO dbo.Customer (CustomerName, Email, City)
VALUES ('FailTest', 'fail@mail.com', 'Toronto'); -- expected failure
REVERT;
GO


--index test
/* Step 1️ – Baseline Query (No Index)*/
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

PRINT 'Query 1: Find books with UnitPrice > 30 (no index)';
SELECT BookID, Title, Author, UnitPrice
FROM dbo.Book
WHERE UnitPrice > 30;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* Step 2️ – Create Indexes */

-- 1.SalesOrder already has a clustered index on OrderID, created automatically by the PRIMARY KEY constraint.
PRINT 'Clustered Index exists on SalesOrder(OrderID) via Primary Key.';
GO

-- 2️.Nonclustered Index (optimize city-based search)
CREATE NONCLUSTERED INDEX IX_Customer_City
ON dbo.Customer(City);
PRINT 'Created nonclustered index IX_Customer_City on Customer.City';

-- 3️.Filtered Index (optimize queries for higher-priced books)
CREATE NONCLUSTERED INDEX IX_Book_PriceFiltered
ON dbo.Book(UnitPrice)
WHERE UnitPrice > 30;
PRINT 'Created filtered index IX_Book_PriceFiltered on Book.UnitPrice (WHERE > 30)';
GO

/*　Step 3️ – Post-Index Query (After Optimization)*/
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

PRINT ' Query 2: Find books with UnitPrice > 30 (after index)';
SELECT BookID, Title, Author, UnitPrice
FROM dbo.Book
WHERE UnitPrice > 30;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
/* Step 4️ – Additional Test for Step2 */
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

PRINT 'Query 3: Find customers in Toronto (after index)';
SELECT CustomerID, CustomerName, City
FROM dbo.Customer
WHERE City = 'Toronto';

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* Step 5️ – Execution Plan Capture */
SET SHOWPLAN_TEXT ON;
go
PRINT 'Displaying estimated execution plan for Query 2...';
SELECT BookID, Title, Author, UnitPrice　FROM dbo.Book
WHERE UnitPrice > 30;
go
SET SHOWPLAN_TEXT OFF;
GO