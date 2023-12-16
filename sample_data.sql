# 1. Return the employees who work in the offices located in the USA
select lastName, firstName from employees where officeCode in (select officeCode from  offices where country = 'USA'); 

# 2. Return the employees who has the highest payment
select customerNumber, checkNumber, amount from payments where amount = (select max(amount) from payments);
select payments.amount,customers.customerName from customers join payments on (payments.customerNumber=customers.customerNumber) order by payments.amount desc limit 1;

# 3. Find customers whose payments are greater than the average payment using sub query
select customerNumber, checkNumber, amount from payments where amount>(select avg(amount) from payments);
select payments.amount,customers.*from customers join payments on (payments.customerNumber=customers.customerNumber) where payments.amount>(select avg(amount) from payments);

# 4. Find the customers who have not placed any orders
select customerNumber from customers where customerNumber not in (select distinct customerNumber from orders);

# 5. Select products whose buy prices are greater than the average buy price of all products
select productName , buyPrice from products where buyPrice> (select avg(buyPrice) from products);

# 6. Find the total value of all products in the order and then filter only the products that has order amount greater than 60000
select orderNumber, sum(priceEach*quantityOrdered) as total from orderdetails group by orderNumber having sum(priceEach*quantityordered)>60000;

# 7. Find the customers who placed at least one sales order with the total value greater than 60000
SELECT sum(od.quantityOrdered * od.priceEach) as total_value,c.customerName,c.customerNumber
FROM customers c
 left JOIN orders o ON (o.customerNumber = c.customerNumber)
left join  orderdetails od ON (od.orderNumber = o.orderNumber)
GROUP BY c.customerNumber
HAVING SUM(od.quantityOrdered * od.priceEach) > 60000;

# 8. Find out the name of the sales rep who has handled the customers along with the customer and check details where at least one check is available for a customer
select firstName, lastName, salesRepEmployeeNumber, checkNumber, customerName from customers c left join employees e on c.salesRepEmployeeNumber=e.employeeNumber  left join payments p
on p.customerNumber=c.customerNumber where checkNumber is not null order by customerName, checkNumber;

# 9.Find out the list of product codes available under the order number 10123
select orderNumber, productCode from orders left join orderdetails using (orderNumber) where orderNumber=10123;
select distinct products.productCode from products  join orderdetails  on (orderdetails.productCode=products.productCode) join orders on 
(orders.orderNumber=orderdetails.orderNumber) where orders.orderNumber=10123;

# 10.Get the text description of all the products
select distinct productName, textDescription,  productCode from products  pd join productlines  pdl on pd.productLine=pdl.productLine;

# 11.Get the order, order details and product name of all the orders
select orderNumber,orderDate,orderLineNumber,productCode,quantityOrdered,priceEach,customerNumber, customerName from orders o left join orderdetails od
 using (orderNumber) left join products p using(productCode) left join customers using (customerNumber) order by orderNumber,orderLineNumber;


# 12.Get the order, order details, customer name and product name of all the orders
select orders.orderNumber,orderDate, products.productCode,orderLineNumber, priceEach, quantityOrdered, productName from orders join orderdetails using (orderNumber)
 left join products using (productCode) left 
join customers  using (customerNumber) order by orderNumber, orderLineNumber;

# 13. Find the sales price of the product whose code is S10_1678 that is less than the manufacturer’s suggested retail price (MSRP) for that product.
select orderNumber,p.productCode, productName, priceEach,quantityOrdered from products p left join orderdetails  od on p.productCode=od.productCode and  MSRP>priceEach
where p.productCode='S10_1678';
SELECT products.productCode, orderdetails.priceEach, products.MSRP
FROM orderdetails
 left JOIN products ON orderdetails.productCode = products.productCode
WHERE orderdetails.productCode = 'S10_1678' AND orderdetails.priceEach < products.MSRP;

# 14.Find the top three highest valued-orders in each year
select * from ( select orderNumber,year(orderDate) as order_year,priceEach*quantityOrdered as order_value, rank() over (partition by year(orderDate) order by
    priceEach*quantityOrdered desc) as order_value_rank from orders o left join orderdetails using(orderNumber)) as order_values where order_value_rank<=3;

  WITH RankedOrders AS (
    SELECT orders.orderDate, orders.orderNumber, orderdetails.quantityOrdered, orderdetails.priceEach,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM orders.orderDate) ORDER BY orderdetails.quantityOrdered * orderdetails.priceEach DESC) AS row_num
    FROM orderdetails JOIN
        orders ON orderdetails.orderNumber = orders.orderNumber
)
SELECT
    orderDate, orderNumber, quantityOrdered, priceEach FROM RankedOrders WHERE row_num <= 3;
    


# 15.Return the type of customers based on the number of orders that customers ordered
 #Order_Count  	Type_of Customer
#1	            One-Time customer
#2	            Repeated Customer
#3	            Frequent Customer
#More than 3    Loyal Customer
select customerName, ordercount,
CASE
WHEN ordercount=1 THEN 'One-Time Customer'
WHEN ordercount=2 THEN 'Repeated Customer'
WHEN ordercount= 3 THEN 'Frequent Customer'
ELSE 'Loyal Customer'
END  customerType
  from (select customerName, count(*) as ordercount from orders 
  left  join customers using (customerNumber) group by customerName) as co order by customerName;

