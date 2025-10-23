USE BookstoreDB;
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
