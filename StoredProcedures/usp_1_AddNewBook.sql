USE BookstoreDB;
GO
/* ============================================================
   Procedure: usp_AddNewBook
   Description: Adds a new book record with validation checks.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_AddNewBook
    @ISBN NVARCHAR(20),
    @Title NVARCHAR(200),
    @Author NVARCHAR(100),
    @Publisher NVARCHAR(100),
    @PublishYear INT,
    @Genre NVARCHAR(50),
    @UnitPrice DECIMAL(10,2),
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM dbo.Book WHERE ISBN = @ISBN)
        BEGIN
            RAISERROR('Book with this ISBN already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO dbo.Book (ISBN, Title, Author, Publisher, PublishYear, Genre, UnitPrice, SupplierID)
        VALUES (@ISBN, @Title, @Author, @Publisher, @PublishYear, @Genre, @UnitPrice, @SupplierID);

        COMMIT TRANSACTION;
        PRINT '✅ Book added successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '❌ Error adding book: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
