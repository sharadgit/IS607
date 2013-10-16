
select 	C.Name,
	O.OrderDate,
	P.Brand,
	P.Model,
	P.Style,
	O.Quantity,
	P.Price,
	P.Price * O.Quantity as Total
  from Orders O 
	inner join Customers C on O.CustomerId = C.CustomerId
	inner join Products P on O.ProductId = P.ProductId
order by C.Name asc, O.OrderDate desc

