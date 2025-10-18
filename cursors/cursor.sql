use BookstoreDB
go

/*reorder low-stock books*/
declare @BookID INT, @SupplierID INT, @Qty INT;

declare crs_ReorderBooks cursor for
select b.BookID, b.SupplierID, i.QuantityInStock from dbo.book b
join dbo.Inventory i on b.BookID =i.BookID where i.QuantityInStock <i.ReorderLevel

open crs_ReorderBooks;
fetch next from crs_ReorderBooks into @BookID, @SupplierID, @Qty;
while @@FETCH_STATUS=0
begin
	insert into dbo.PurchaseOrder(SupplierID,TotalCost,ReceivedDate) values (@SupplierID,0,null);
	print'Reorder created for BookID=' + cast(@BookID as nvarchar(10));
	fetch next from crs_ReorderBooks into  @BookID, @SupplierID, @Qty;
end

close crs_ReorderBooks;
Deallocate crs_ReorderBooks;
go

/*customer sales summary*/
declare @customerID int, @customerName nvarchar(50), @totalSales decimal(10,2);
declare crs_saleSummary cursor dynamic for
select CustomerID, CustomerName from dbo.Customer;

open crs_saleSummary;
fetch next from crs_saleSummary into @customerId, @customerName;
while @@fetch_status=0
begin
	select @totalSales =isnull(sum(TotalAmount),0) from dbo.SalesOrder where CustomerID =@customerID;
	print 'Customer: '+@customerName +', Total Sales: $'+cast(@totalSales as nvarchar(20));
	fetch next from crs_saleSummary into @customerId, @customerName;
end
close crs_saleSummary;
deallocate crs_saleSummary;
go

