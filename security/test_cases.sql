use BookstoreDB
go

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

