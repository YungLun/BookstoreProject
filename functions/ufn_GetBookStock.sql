USE BookstoreDB;
GO

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

