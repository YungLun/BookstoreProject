USE BookstoreDB;
GO

CREATE OR ALTER VIEW vSalesReport AS
SELECT b.BookID, b.Title,
       SUM(sl.Quantity) AS TotalSold,
       SUM(sl.Quantity * sl.UnitPrice) AS TotalRevenue
FROM Book b
JOIN SalesOrderLine sl ON b.BookID = sl.BookID
GROUP BY b.BookID, b.Title;
GO
