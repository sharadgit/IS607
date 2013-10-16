insert into Customers
	(CustomerId,	Name,			Address)
values
	(1,		'Adam McKay',		'765 Park Ave, NY NY 10010'),
	(2,		'Bill Moyer',		'34 Main St, NY NY 10011'),
	(3,		'Chris Murphy',		'77 W 56 St, NY NY 10012'),
	(4,		'Doris Moore',		'201 Rector St, NY NY 10001'),
	(5,		'Eugene McCarthy',	'65 Water St, NY NY 10002');


insert into Products
	(ProductId, 	Brand,		Model,		Style,		Price)
values
	(1,		'Burberry',	'BE2086',	'Hipster',	205),
	(2,		'Givenchy',	'VGV803',	'Nerdy',	360),
	(3,		'Gucci',	'GG1910',	'Retro',	312),
	(4,		'Persol',	'PO2965',	'Classic',	271),
	(5,		'Prada',	'PR22OV',	'Unique',	340);


insert into Orders
	(CustomerId,	ProductId,	Quantity,	OrderDate)
values
	(1,		1,		1,		'5/7/2013'),
	(1,		3,		1,		'5/17/2013'),
	(2,		2,		1,		'1/22/2013'),
	(2,		4,		1,		'3/12/2013'),
	(3,		5,		2,		'8/26/2013'),
	(4,		1,		1,		'1/12/2013'),
	(4,		2,		2,		'3/22/2013'),
	(4,		5,		1,		'6/19/2013'),
	(5,		1,		1,		'7/3/2013'),
	(5,		4,		1,		'9/13/2013');
