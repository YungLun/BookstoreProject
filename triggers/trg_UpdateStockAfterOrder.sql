USE BookstoreDB;
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
