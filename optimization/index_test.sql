USE BookstoreDB;
GO

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