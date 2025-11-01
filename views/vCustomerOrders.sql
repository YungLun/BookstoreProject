USE BookstoreDB;
GO

CREATE OR ALTER VIEW vCustomerOrders AS
SELECT c.CustomerID, c.CustomerName, s.OrderID, s.OrderDate,
       SUM(sl.Quantity * sl.UnitPrice) AS TotalAmount
FROM Customer c
JOIN SalesOrder s ON c.CustomerID = s.CustomerID
JOIN SalesOrderLine sl ON s.OrderID = sl.OrderID
GROUP BY c.CustomerID, c.CustomerName, s.OrderID, s.OrderDate;
GO

