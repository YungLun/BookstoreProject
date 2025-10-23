USE BookstoreDB;
GO
/* ============================================================
   Procedure: usp_GetBooksByGenre_DynamicSQL
   Description: Returns book list dynamically filtered by genre.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_GetBooksByGenre_DynamicSQL
    @Genre NVARCHAR(50)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'SELECT BookID, Title, Author, Genre, UnitPrice
                 FROM dbo.Book
                 WHERE Genre = @GenreParam';

    EXEC sp_executesql @sql, N'@GenreParam NVARCHAR(50)', @GenreParam = @Genre;
END;
GO
