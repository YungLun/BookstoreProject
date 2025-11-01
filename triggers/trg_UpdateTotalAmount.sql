USE BookstoreDB;
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
