USE BookstoreDB;
GO
/* ============================================================
   Procedure: usp_CreatePurchaseOrder
   Description: Creates a purchase order and updates inventory after receiving.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_CreatePurchaseOrder
    @SupplierID INT,
    @BookID INT,
    @Quantity INT,
    @CostPerUnit DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TotalCost DECIMAL(10,2) = @Quantity * @CostPerUnit;

        INSERT INTO dbo.PurchaseOrder (SupplierID, OrderDate, TotalCost, ReceivedDate)
        VALUES (@SupplierID, GETDATE(), @TotalCost, NULL);

        DECLARE @PurchaseID INT = SCOPE_IDENTITY();

        UPDATE dbo.Inventory
        SET QuantityInStock = QuantityInStock + @Quantity,
            LastRestockDate = GETDATE()
        WHERE BookID = @BookID;

        COMMIT TRANSACTION;
        PRINT '✅ Purchase order created successfully (ID: ' + CAST(@PurchaseID AS NVARCHAR(10)) + ').';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '❌ Error creating purchase order: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
