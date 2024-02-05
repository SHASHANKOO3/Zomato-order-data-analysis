--The Datasets

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- What is the total amount each customer spent on Zomato

Select S.userid User_ID, SUM(P.price) Amount_Spent from sales S, product P
where S.product_id = P.product_id
GROUP BY userid

-- How many days each customer visited Zomato

SELECT userid USER_ID, count(DISTINCT(created_date)) Number_of_Visited_Days from sales GROUP BY userid

--What was the first product purchased by the each customer

Select * from (Select *, Rank() OVER (PARTITION BY userid order by created_date) rnk from sales) a where rnk = 1

--What is the most purchased item by the customer and how many time it is purchased by all customer

Select userid, Count(product_id) count_product from Sales where product_id = 
(Select TOP 1 product_id from sales group by product_id order by count(product_id) Desc) 
group by userid

--What item was first purchased by the customer after becoming member

Select * from
(Select userid, product_id, created_date, gold_signup_date, Rank() over (Partition BY userid order by created_date) rnk from
(Select s.userid, s.created_date, s.product_id, g.gold_signup_date 
from goldusers_signup g, sales s where s.userid = g.userid
and s.created_date >= g.gold_signup_date) C)D where rnk = 1

--What item was purchased by the customer just before becoming member

Select * from
(Select userid, product_id, created_date, gold_signup_date, Rank() over (Partition BY userid order by created_date) rnk from
(Select s.userid, s.created_date, s.product_id, g.gold_signup_date 
from goldusers_signup g, sales s where s.userid = g.userid
and s.created_date < g.gold_signup_date) C)D where rnk = 1

-- if buying each product contains points for eg P1 for rs 5 gives 2 pts
-- and for P2 5 rs gives 10rs = 5 zomato points and for P3 5 rs  = 1 zomato pts
-- calculate pts collected by each customes and for which product most pts has been given till now

Select userid, sum(reward) user_reward from
(Select E.*, total/points as reward FROM
(Select D.*, 
CASE 
WHEN product_id = 1 THEN 5
WHEN product_id = 2 THEN 2
WHEN product_id = 3 THEN 5
ELSE 0
END AS points from
(Select C.userid, C.product_id, sum(C.price) as total from
(Select s.*, p.price from sales s, product p where 
s.product_id = p.product_id) C
Group BY userid, product_id)D)E) F GROUP BY userid

--rnk all the transaction of the customers

select *, rank() over(partition by userid order by created_date) rankk from sales

--all the transaction for each member whenever they are gold member,
--for every non gold member transaction marks as NA


Select s.userid, s.created_date, s.product_id, g.gold_signup_date 
from sales s left join goldusers_signup g on s.userid = g.userid
and s.created_date >= g.gold_signup_date
