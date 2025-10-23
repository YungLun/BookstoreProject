USE BookstoreDB;
GO
/* ============================================================
   Procedure: usp_UpdateStockAfterSale
   Description: Updates inventory after a sale and adjusts reorder logic.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_UpdateStockAfterSale
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @BookID INT, @Qty INT;

        DECLARE SaleCursor CURSOR FOR
        SELECT BookID, Quantity FROM dbo.SalesOrderLine WHERE OrderID = @OrderID;

        OPEN SaleCursor;
        FETCH NEXT FROM SaleCursor INTO @BookID, @Qty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE dbo.Inventory
            SET QuantityInStock = QuantityInStock - @Qty
            WHERE BookID = @BookID;

            FETCH NEXT FROM SaleCursor INTO @BookID, @Qty;
        END

        CLOSE SaleCursor;
        DEALLOCATE SaleCursor;

        -- Update TotalAmount of order
        UPDATE so
        SET TotalAmount = (
            SELECT SUM(LineTotal) FROM dbo.SalesOrderLine sol WHERE sol.OrderID = so.OrderID
        )
        FROM dbo.SalesOrder so WHERE so.OrderID = @OrderID;

        COMMIT TRANSACTION;
        PRINT '✅ Inventory and total updated successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '❌ Error updating inventory: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
