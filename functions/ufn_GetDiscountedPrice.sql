USE BookstoreDB;
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

