use BookstoreDB
go

-- Admin
CREATE ROLE dbAdmin;
GRANT CONTROL ON DATABASE::BookstoreDB TO dbAdmin;

-- Manager
create role dbManager;
grant select, insert,update on dbo.Supplier to dbManager;
grant select, insert,update on dbo.PurchaseOrder to dbManager;
grant select, update on dbo.Inventory to dbManager;
grant select on dbo.vSalesReport  to dbManager;
grant select on dbo.vBookCatalog to dbManager;

-- Clerk
CREATE ROLE dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.SalesOrder TO dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.SalesOrderLine TO dbClerk;
GRANT SELECT, INSERT, UPDATE ON dbo.Customer TO dbClerk;
GRANT SELECT ON dbo.Book TO dbClerk;

/* REVOKE  */
REVOKE DELETE ON dbo.Customer FROM dbClerk;

-- Customer
CREATE ROLE dbCustomer;
GRANT SELECT ON dbo.vBookCatalog    TO dbCustomer;
GRANT SELECT ON dbo.vCustomerOrders TO dbCustomer;

/* DENY */
DENY INSERT, UPDATE, DELETE ON DATABASE::BookstoreDB TO dbCustomer;


-- 3. Create Test Users
CREATE USER testAdmin WITHOUT LOGIN;
CREATE USER testManager WITHOUT LOGIN;
CREATE USER testClerk WITHOUT LOGIN;
CREATE USER testCustomer WITHOUT LOGIN;
EXEC sp_addrolemember 'dbAdmin', 'testAdmin';
EXEC sp_addrolemember 'dbManager', 'testManager';
EXEC sp_addrolemember 'dbClerk', 'testClerk';
EXEC sp_addrolemember 'dbCustomer', 'testCustomer';
PRINT 'Roles and test users created successfully.';
GO









