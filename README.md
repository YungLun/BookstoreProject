#Team Members
1.Maria Catherine Jaramillo:
-Role:Schema Designer
-Student ID: n01740036
-Github Name:rogueflick22
2.Yung-Lun Lee
-Role:Logic Developer
-Student ID: n01721599
-Github Name:YungLun
3.Yi-Chun Lien
-Role:Security & Optimization Lead
-Student ID: n01745009
-Github Name:AllisonLien

#Overview:
The Bookstore Management System is designed to handle all core operations for a small-to-medium retail bookstoreI.
Its goal is to maintain accurate inventory, track suppliers and purchases, manage sales transactions, and keep customer information securely.
Everything revolves around books as the main product and connects suppliers (who provide them) to customers (who buy them) through orders, sales, and stock management.

#Problem Domain:
Traditional bookstores often maintain inventory and supplier data manually, leading to:
1.Inconsistent stock information and delayed restocking
2.Duplicate or incomplete order records
3.Poor coordination between sales, purchasing, and suppliers
Bookstore Management System can do:
1.Centralizing all operational data into one relational schema
2.Enforcing referential integrity through foreign keys
3.Automating updates using triggers and stored procedures
4.Enabling secure, role-based access for different staff groups
5.Maintain accurate book and supplier records  
6.Track inventory and automatically trigger restocking  
7.Manage customer orders and payments

#Schema overview：
Table Name:
1.Supplier:Stores information about book suppliers and their contact details.
2.Book:Represents all books available in the store, including author, publisher, price, and supplier.
3.Inventory:Tracks the current stock quantity, reorder level, and restock date of each book.
4.Customer:Contains customer information such as contact details and membership date.
5.SalesOrder:Header table for customer purchase transactions.
6.SalesOrderLine:Detail table for each book sold in an order. Automatically calculates line total (Quantity * UnitPrice).
7.PurchaseOrder:Records purchase transactions made to suppliers for restocking purposes.


#User Roles and Operations
1.Admin:
- Create / update roles and permissions
- Manage backups and indexing
- Audit transactions
2.Manager:
- Approve purchase orders
- Review sales reports and stock levels
- Authorize discounts or refunds
3.Clerk:
- Create new customer records
- Process sales orders and payments
- Update inventory after sales
4.Customer:
- View book catalog
- Check order status
- Request refund or return

#Business Workflows:
Workflow 1: Customer Purchase Transaction
Workflow 2: Inventory Reorder and Purchase Process
Workflow 3: Refund or Payment Adjustment

#Business Rules:
1.Cannot insert a Book without valid SupplierID.
2.QuantityInStock and ReorderLevel must be non-negative.
3.QuantityInStock and ReorderLevel cannot be less than zero
4.PaymentStatus limited to ('Pending','Paid','Refunded').
5.ReceivedDate must be after OrderDate.
6.
