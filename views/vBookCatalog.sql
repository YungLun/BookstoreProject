USE BookstoreDB;
GO

CREATE OR ALTER VIEW vBookCatalog AS
SELECT b.BookID, b.Title, b.Author, b.UnitPrice, i.QuantityInStock AS Stock
FROM Book b
LEFT JOIN Inventory i ON b.BookID = i.BookID;
GO
