use northwind
-----------------------------------------------------------------------
--------project sql for data anlays by using norhwind database--------------
-----
-- select  number of product,avergeprice ,slaes by qutitiy , income 

select  count(DISTINCT Products.ProductName) as num_products, 
--DISTINCT ---> we use it with agregate function to summarize only unique values
--and eliminate duplicate values ,not rows

avg(Products.UnitPrice) as avg_price ,
sum(Quantity) as quntity_orderd,
sum(Quantity*Products.UnitPrice) as money_order
from Products join [Order Details]
on [Products].ProductID =[Order Details].ProductID
--notes --> in outer join we can handle null value
go

-- same result to test 
select  count(Products.ProductID) from Products 
select  avg(Products.UnitPrice) from Products
select  sum(Quantity) from [Order Details]
select  sum(Quantity*UnitPrice) from [Order Details]
go

--select product name finsh with d 
select ProductName from Products where ProductName like '%d'
go
-- creat backap table 
select *into productstablebuckap from Products

--dell table 
delete  productstablebuckap

--truncate 
truncate table productstablebuckap

--drop table 
drop table productstablebuckap
go
-- insert in table 
select *from [Order Details]
INSERT INTO [Order Details] values 
(1048,12,14,12,0) --> must all colums inserted
INSERT INTO [Order Details](OrderID,UnitPrice) 
values(1047,14) --> insert some of colums

go
--test
select  ProductName from Products where unitprice=14
--update table 
update Products set ProductName = 'kadry ' ,UnitPrice =50 where ProductID=1
--to test
select  ProductName from Products where ProductID=1
--select price of product an if > 50 return high else return low 
select UnitPrice, iif(UnitPrice>50,'high','low') from Products as high_low
go
-- other method
/*select UnitPrice 
    CASE
     when UnitPrice >50 then 'high'
     when UnitPrice <50 then 'low'
     else 'equal' 
	 as unitprice
from Products  */
go
--seelcet all cities &country which coverd  
select ShipCity 
from Orders as coverd_cities 
select ShipCountry 
from Orders as country_coverd 
select count(ShipCountry)
 from Orders as num_country_coverd 
select count(ShipCity)
 from Orders as num_coverd_cities 
 
 --- creat non cluster index to products table
 use northwind
  CREATE NONCLUSTERED INDEX non4name ON [dbo].[Products]([ProductName] asc)
  
  go
  -- creat view show the number of unit availble sell && quntitity of this product had sold
   
  create view view_aviornot 
  as
 select Products.ProductName ,UnitsInStock as avilable , Quantity as sold 
 from products join [Order Details] 
 on Products.ProductID =[Order Details].ProductID

 go--> go is a batch seperator 
 --to alter view
 alter view view_aviornot 
 as 
 --we alterd this view by add categry name for all products 
 select Products.ProductName ,UnitsInStock ,Categories.CategoryName , Quantity as sold 
 from products join [Order Details] 
 on Products.ProductID =[Order Details].ProductID
 join Categories on Categories.CategoryID = Products.CategoryID
 go
 --to call the ciew
 select *from view_aviornot order by ProductName --> we can use order by only if in calling view not in creating it
 go
 --using sub query to compare betwwen the prict and avg of price
 select ProductName ,
 UnitPrice as ourprice
 ,UnitPrice -(select avg(UnitPrice) from Products) as comparebyavg
  from Products
  -- get avg to each product by using while loop , declare variable , subquery
  declare @counter int =1  , @avg_eachp as nvarchar(100) ,@product_name as nvarchar(100)
  while @counter >0
  begin
    select @avg_eachp =( select avg(UnitPrice) from Products where @counter= Products.ProductID )
	select @product_name = (select Products.ProductName from Products where ProductID =@counter)
	print  @product_name	print @avg_eachp 
    set @counter+=1
    end

go
--get avg to each product by using while loop , declare variable , subquery for first 10 products and put them in procdure
 
create proc avg_pro --> create procdure
as --> body of proc
declare @counter int =1  , @avg_eachp as nvarchar(100) , @product_name as nvarchar(100)
while @counter <10
  begin
    select @avg_eachp =( select avg(UnitPrice)  from Products 
	where @counter= Products.ProductID )
	select @product_name = (select Products.ProductName from Products where ProductID =@counter)
	print  @product_name 
	print @avg_eachp 
    set @counter+=1
    end
go 
--execute proc 
exec avg_pro --> will show avg to first (10)product with their name  

--notes--> we can insert an del in store procedure  oppositte of view
go
--- create trriger to handle quntities are sold and quntitie in stock 
--trigger --> event action
create trigger up_stpock  
on [order details] for insert --> we can makit for dell also
as 
--inserted is existed table in stead order details here and have his properties

declare @unitinorders int , @prodinorderid int
set @unitinorders = (select Quantity from inserted)
set @prodinorderid = (select ProductID from inserted)
update Products set UnitsInStock = (UnitsInStock-@unitinorders)
where Products.ProductID = @prodinorderid

go 
--alter 
alter trigger up_stpock  --> we used alter in stead of craete to edit in trigger 
on [order details] for insert --> we can makit for dell also
as 
--inserted is existed table in stead order details here and have his properties

declare @unitinorders int , @prodinorderid int
set @unitinorders = (select Quantity from inserted)
set @prodinorderid = (select ProductID from inserted)
update Products set UnitsInStock = (UnitsInStock-@unitinorders)
where Products.ProductID = @prodinorderid

go
--o test  trigger 
select *from Products where ProductID =25
  insert [Order Details] values ('10248',25,14,6,0)
  select *from Products where ProductID =25 
 go

 --to drop trigger 
 drop trigger up_stpock 
 go 
 --use transaction with try and catch and got same ruslt like triggger but in specific product
 -- in transaction do all or nothing 

 select*from [Order Details]
 begin try 
 begin transaction 
      insert [Order Details] values ('10249',25,14,6,0)
      update Products set UnitsInStock = (UnitsInStock-6) where Products.ProductID =25
 commit transaction 
 end try   
 begin catch
      print 'nothing executed '
      rollback transaction --> to make any transaction work undone 
 end catch 
--to test  transaction 
-- if printed nothing this mean transaction no done 
go 
-- make discount if price more than 10% for all product with use while loop and if statments and store proc

create proc disscout
as
declare @counter int =1 , @after_Des int ,
 @unitprice int , @productnamediscounted nvarchar(50)
while @counter >0 --> to loop on all products and test it if more 50 will made discount
begin 
 set @unitprice = (select Products.UnitPrice from Products where ProductID =@counter) 
 if (@unitprice>20)
	begin
	set @after_Des = (@unitprice-@unitprice*0.10 ) 
	update Products set Discontinued = @after_Des where ProductID =@counter
	--update [Order Details] set Discount = @after_Des where ProductID =@counter
	set @productnamediscounted =  (select Products.ProductName from Products where ProductID =@counter) 
	print ('the final price afetr discount')+' to  '+ @productnamediscounted 
	print @after_Des  
	end ;
 --else  begin print 'theris no discount to ' + @productnamediscounted   end 
set @counter+=1
end;
go 
-- execute proc 
exec disscout

---- show sum of units to each product ordered to each cities
 
use northwind
select Orders.ShipCity , sum([Order Details].Quantity) as sold , ProductName
 from orders join [Order Details]
  on Orders.OrderID = [Order Details].OrderID 
 join Products on Products.ProductID = [Order Details].ProductID
 group by Orders.ShipCity , ProductName
 order by sum([Order Details].Quantity) desc

 go
-- show top 3 product orderd and top 3 got money in view 

create view topsold 
as
select top(3) [Order Details].Quantity*[Order Details].UnitPrice as topreturnedmoney ,
[Order Details].Quantity as topunisold , Products.ProductName 
from [Order Details] join Products on Products.ProductID =[Order Details].ProductID 
order by [Order Details].Quantity desc 
-- 
--call view
select *from topsold
go--> batch seprator

-- get avg of each product incom in specific date for example in specific date days  

select avg([Order Details].Quantity*[Order Details].UnitPrice )as avg_of_eturned_income, 
Products.ProductName ,Orders.OrderDate
from [Order Details] join Products on Products.ProductID =[Order Details].ProductID 
join orders on Orders.OrderID =[Order Details].OrderID
GROUP BY Products.ProductName , orders.OrderDate
--if we used in we must write all days we want
HAVING Orders.OrderDate in( '1996-07-15' ,'1996-07-16','1996-07-17') 

go
--get avg of each product incom in specific date for example in specific date 4ex'month' 
 
select avg([Order Details].Quantity*[Order Details].UnitPrice )as avg_of_eturned_income, 
Products.ProductName ,Orders.OrderDate
from [Order Details] join Products on Products.ProductID =[Order Details].ProductID 
join orders on Orders.OrderID =[Order Details].OrderID
GROUP BY Products.ProductName , orders.OrderDate
--in using between we write first & final date only
HAVING Orders.OrderDate between'1996-07-01' and '1996-07-30'; 
 
go

--show total income for each product 

create view total_income_4each__Product
as
select sum([Order Details].Quantity*[Order Details].UnitPrice )as total_income, 
Products.ProductName from [Order Details] join Products on Products.ProductID =[Order Details].ProductID 
GROUP BY Products.ProductName 
--order by ProductName desc --> we can not use order by in creating a view 
go

--call view
select *from total_income_4each__Product
go

-- show percentage of quntity sold for each product 

select sum([Order Details].Quantity) as sold , sum(Products.UnitsInStock) as stay ,ProductName, 
sum([Order Details].Quantity)*100/(sum(Products.UnitsInStock+1)+sum([Order Details].Quantity)) as persentage_of_sold
from [Order Details] join Products 
on [Order Details].ProductID=Products.ProductID
group by ProductName
 
go
--intersect -->return rows which existes in both table
select * from Products
intersect
select * from Products

go
--union --> make union and remove duplictaed data -- union all--> union all rows without removing any thing 

select * from Orders
union all
select *  from Products

go
--excepet -->return rows which existes in first table and not exist in other table
select * from Orders
except	
select * from products

go
--synonym -->we use to giv alias or link to object , function, procedure view
----
-- show the top 3 citiy which best sales for quntitiy or income

select top(3)ShipCity as city, sum(([Order Details].Quantity)) as best_quntity_sold,
sum(([Order Details].UnitPrice)) as best_income
from Orders join [Order Details] on [Order Details].OrderID = Orders.OrderID
join Products on [Order Details].ProductID = Products.ProductID
group by ShipCity
order by sum(([Order Details].Quantity)) desc

go
--notes-->select count(([Order Details].ProductID)) from [Order Details]==select count(([Order Details].Quantity)) from [Order Details]
/*select count(([Order Details].ProductID)) from [Order Details]
select sum(([Order Details].Quantity)) from [Order Details]
select sum(([Order Details].UnitPrice)) from [Order Details]
select count((Products.ProductID)) from Products*/

--- show the best categories income by quntitiy 

use northwind
select top(20) Categories.CategoryName , count([Order Details].Quantity) as total_quntitiy_products_sold , count(Products.ProductName) as total_product
 from Categories join Products
 on Products.CategoryID=Categories.CategoryID 
 join [Order Details] on [Order Details].ProductID = Products.ProductID
 group by Categories.CategoryName --, Products.ProductName 
 order by count([Order Details].Quantity) desc

 go
--- show the best categories income  by money 

 select top(20) Categories.CategoryName , sum([Order Details].UnitPrice) as total_price_products_sold , count(Products.ProductName) as total_product
 from Categories join Products
 on Products.CategoryID=Categories.CategoryID 
 join [Order Details] on [Order Details].ProductID = Products.ProductID
 group by Categories.CategoryName --, Products.ProductName 
 order by sum([Order Details].UnitPrice) desc

 -------------  
 --- 
go
-- show quntity had sold for each product in each year

 select count(ProductName) as count_of_product , datepart(year,Orders.OrderDate)  as the_year
 , sum([Order Details].Quantity) as quntity_sold
 from Products join [Order Details] 
 on Products.ProductID =[Order Details].ProductID
 join Orders on Orders.OrderID = [Order Details].OrderID
 group by --ProductName ,
  datepart(year,Orders.OrderDate)
  order by datepart(year,Orders.OrderDate)

 go

-- show quntity had sold for each product in each month

select count(ProductName) as count_of_product , datepart(month,Orders.OrderDate)  as the_year
 , sum([Order Details].Quantity) as quntity_sold
 from Products join [Order Details] 
 on Products.ProductID =[Order Details].ProductID
 join Orders on Orders.OrderID = [Order Details].OrderID
 group by --ProductName ,
  datepart(month,Orders.OrderDate)
  order by datepart(month,Orders.OrderDate)

go
 -- show the best sales in specific time 4ex in month or year or weak

 select top(4) count(ProductName) as count_of_product , datepart(year,Orders.OrderDate)  as the_year
 , sum([Order Details].Quantity) as quntity_sold
 from Products join [Order Details] 
 on Products.ProductID =[Order Details].ProductID
 join Orders on Orders.OrderID = [Order Details].OrderID
 group by --ProductName ,
  datepart(year,Orders.OrderDate)
  order by sum([Order Details].Quantity) desc

 go
 use northwind
 go
 -- create function to get name if price > 20
 create function dbo.checkpricemax(@poroduct_n nvarchar(50)) 
	returns int
 as  
 begin 
 declare @result int
 set @result = ( select products.UnitPrice 
 from products where Products.ProductName = @poroduct_n 
 and Products.UnitPrice>20
 )
return isnull(@result,0)

 end 
 go

 -- we used function to get name which price we declared 

 select Products.ProductName ,Products.UnitPrice 
 from Products
  where dbo.checkpricemax(Products.ProductName)!=0
 go
 -- rank -- dense_rank -- row_number_ntile 
select UnitPrice, Quantity,
 rank () over(partition by productid order by Quantity desc) as rankk
 ,dense_rank () over(partition by productid order by Quantity desc) as denis_rankk
 ,row_number () over(partition by productid order by Quantity desc) as row_rankk
 ,NTILE (2) over(partition by productid order by Quantity desc) as NTILEE
 from [Order Details];
 
 
 










