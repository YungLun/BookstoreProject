use BookstoreDB
go

/*Admin - Full control over the database*/
create role dbAdmin;
grant control on database::BookstoreDB to dbAdmin;

/* Manager - suppliers, inventory, purchases, reports*/
create role dbManager;
grant select, insert,update on dbo.Supplier to dbManager;
grant select, insert,update on dbo.PurchaseOrder to dbManager;
grant select, update on dbo.Inventory to dbManager;
grant select on dbo.vSalesReport  to dbManager;
grant select on dbo.vBookCatalog to dbManager;


/*Clerk-Handle sales and customers*/
CREATE ROLE dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.SalesOrder     TO dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.SalesOrderLine TO dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.Customer       TO dbClerk;
GRANT SELECT ON dbo.Book                           TO dbClerk;
REVOKE DELETE ON dbo.Customer FROM dbClerk;

/* Customer - Read-only access to catalog and their orders*/
CREATE ROLE dbCustomer;
GRANT SELECT ON dbo.vBookCatalog     TO dbCustomer;
GRANT SELECT ON dbo.vCustomerOrders  TO dbCustomer;
DENY INSERT, UPDATE, DELETE ON DATABASE::BookstoreDB TO dbCustomer;


/*test user  */
CREATE USER testAdmin WITHOUT LOGIN;
CREATE USER testManager WITHOUT LOGIN;
CREATE USER testClerk WITHOUT LOGIN;
CREATE USER testCustomer WITHOUT LOGIN;
EXEC sp_addrolemember 'dbAdmin', 'testAdmin';
EXEC sp_addrolemember 'dbManager', 'testManager';
EXEC sp_addrolemember 'dbClerk', 'testClerk';
EXEC sp_addrolemember 'dbCustomer', 'testCustomer';
PRINT ' Roles and test users created successfully.';
GO

/*test permissions  */
PRINT '--- Testing Manager role ---';
EXECUTE AS USER = 'testManager';
SELECT TOP 3 * FROM dbo.vSalesReport;
REVERT;
GO

PRINT '--- Testing Clerk role ---';
EXECUTE AS USER = 'testClerk';
SELECT TOP 3 * FROM dbo.SalesOrder;
REVERT;
GO

PRINT '--- Testing Customer role ---';
EXECUTE AS USER = 'testCustomer';
SELECT TOP 3 * FROM dbo.vBookCatalog;
REVERT;
GO

