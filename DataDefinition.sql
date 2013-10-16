

create table Customers(
	CustomerId 	int 		not null,
	Name 		varchar		not null,
	Address		varchar		not null
);

create table Products(
	ProductId 	int 		not null,
	Brand		varchar		not null,
	Model 		varchar 	not null,
	Style		varchar		not null,
	Price 		real 		not null
);

create table Orders(
	CustomerId 	int 		not null,
	ProductId 	int 		not null,
	Quantity	int 		not null,
	OrderDate	date 		not null
);

