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