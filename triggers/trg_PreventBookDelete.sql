USE BookstoreDB;
GO

CREATE OR ALTER TRIGGER trg_PreventBookDelete
ON Book
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Deletion of books is not allowed.';
END;
GO
