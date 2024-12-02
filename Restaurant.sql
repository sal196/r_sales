	 
create DataBase Restaurent;
use Restaurent;


Create table sale(
"customer_id" Varchar(1),
"order_date" Date,
"product_id" integer

);



insert into sale
("customer_id","order_date","product_id")

Values
('A','2021-01-01','1'),
('A','2021-01-01','2'),
('A','2021-01-07','2'),
('A','2021-01-10','3'),
('A','2021-01-11','3'),
('A','2021-01-11','3'),
('A','2021-01-01','2'),
('B','2021-01-02','2'),
('B','2021-01-04','1'),
('B','2021-01-11','1'),
('B','2021-01-16','3'),
('B','2021-02-01','3'),
('B','2021-01-01','3'),
('C','2021-01-01','3'),
('C','2021-01-07','3'),
('C','2021-01-01','3');




Create Table menu(
"product_id" INTEGER,
"product_name" VARCHAR(50),
"price" INTEGER
);

INSERT INTO menu("product_id","product_name","price")
VALUES
('1','Puri','60'),
('2','North Thali','100'),
('3','Naan','50'),
('4','fish curry','120'),
('5','South Thali','100');




Create Table member(

"customer_id" Varchar(1) ,
"join_date" Date
);

Insert into member
("customer_id" ,"join_date")
Values
('A','2021-01-07'),
('B','2021-01-09');


select * from sale;
select * from menu;
select * from member;



--1.what is the total amount each customer spent at the restaurant
select s.customer_id,sum(price) as Total_Amount_spent
from sale s
Inner join menu m
on s.product_id=m.product_id
group by s.customer_id;

--2.how many days has each customer visited the restaurent
select customer_id,COUNT (distinct[order_date]) as num_days
from sale
group by customer_id;

--3.What was the fist item from the menu purchased by each customer

select s.customer_id, m.product_name,
ROW_NUMBER()over(partition by s.customer_id order by s.order_date)
from sale s
join menu m
on s.product_id=m.product_id


--4.what isthe the most perchased item on the menu and how many times waas it purchsed by all custumers



select m.product_name,count(m.product_name) as product_Count
from sale s
join menu m
on s.product_id=m.product_id
group by m.product_name
order by count(m.product_name) DESC

--5.What item was popular for each customer
with item_count as(
select s.customer_id,m.product_name,
count(*)as order_count,
Dense_Rank()over (partition by s.customer_id order by count(*)DESC) as rn
from sale s
join menu m
on s.product_id=m.product_id
group by s.customer_id,m.product_name)


select customer_id,product_name
from item_count
where rn=1

--6.Which item was purchased first by the customer after they became member

with orders as(
select s.customer_id, m.product_name , s.order_date,mb.join_date,
DENSE_RANK() over(partition by s.customer_id order by order_date desc) as rn
from menu m
join sale s
on m.product_id=s.product_id
join member mb
on s.customer_id=mb.customer_id
where s.order_date<mb.join_date
)

select customer_id,product_name
from orders
where rn=1

--7.what is the total items and amount spent for each member before they become member?

select s.customer_id,


count(m.product_id) as total_items_ordered,
sum(price) as total_amount_spent
from menu m
join sale s
on m.product_id=s.product_id
join member mb
on S.customer_id=mb.customer_id 
where s.[order_date]<mb.join_date
group by s.customer_id


---8.if each $1spent equates to 10 points and puri has 2x points multiplier, how any points would each customer have?

select s.customer_id,m.product_name,m.price,
Case
      when m.product_name='Puri' then m.price*10*2
	  else m.price*10
	  end as points
from sale s
join menu m
on s.product_id=m.product_id

---9. Determine the name and price of Pruduct  rdered by each customer on all orders,dates & find out whether the customer wes a member

select s.customer_id,s.order_date,m.product_id,m.price,
Case
    when mb.join_date<=s.order_date then 'Y'
	else 'N'
	end as member
from menu m
join sale s
on s.product_id= m.product_id
left join member mb
on mb.customer_id=s.customer_id


--10.Rank from previous output from Quesion 9 based on order_date for each customer. Display null when customer not a member


with cte as
(
select s.customer_id,s.order_date,m.product_id,m.price,
Case
    when mb.join_date<=s.order_date then 'Y'
	else 'N'
	end as member_status
from menu m
join sale s
on s.product_id= m.product_id
left join member mb
on mb.customer_id=s.customer_id)

select*,
case
    when cte.member_status='Y' then RANK() over (partition by cte. customer_id , cte.member_status
	                                              order by order_date)
    else null
	end as ranking

	from cte




