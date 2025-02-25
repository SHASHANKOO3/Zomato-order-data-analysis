-- The Datasets

SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;

-- What is the total amount each customer spent on Zomato

SELECT S.userid AS User_ID, SUM(P.price) AS Amount_Spent 
FROM sales S
JOIN product P ON S.product_id = P.product_id
GROUP BY S.userid;

-- How many days each customer visited Zomato

SELECT userid AS User_ID, COUNT(DISTINCT created_date) AS Number_of_Visited_Days 
FROM sales 
GROUP BY userid;

-- What was the first product purchased by each customer

SELECT * FROM (
    SELECT S.*, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk 
    FROM sales S
) WHERE rnk = 1;

-- What is the most purchased item by the customer and how many times it was purchased by all customers

SELECT userid, COUNT(product_id) AS count_product 
FROM Sales 
WHERE product_id = (
    SELECT product_id FROM (
        SELECT product_id, COUNT(product_id) AS cnt 
        FROM sales 
        GROUP BY product_id 
        ORDER BY cnt DESC
    ) WHERE ROWNUM = 1
) 
GROUP BY userid;

-- What item was first purchased by the customer after becoming a member

SELECT * FROM (
    SELECT S.userid, S.product_id, S.created_date, G.gold_signup_date, 
           RANK() OVER (PARTITION BY S.userid ORDER BY S.created_date) AS rnk 
    FROM sales S
    JOIN goldusers_signup G ON S.userid = G.userid 
    WHERE S.created_date >= G.gold_signup_date
) WHERE rnk = 1;

-- What item was purchased by the customer just before becoming a member

SELECT * FROM (
    SELECT S.userid, S.product_id, S.created_date, G.gold_signup_date, 
           RANK() OVER (PARTITION BY S.userid ORDER BY S.created_date DESC) AS rnk 
    FROM sales S
    JOIN goldusers_signup G ON S.userid = G.userid 
    WHERE S.created_date < G.gold_signup_date
) WHERE rnk = 1;

-- Calculate points collected by each customer and find which product gave the most points

SELECT userid, SUM(reward) AS user_reward FROM (
    SELECT E.*, total / points AS reward FROM (
        SELECT D.*, 
               CASE 
                   WHEN product_id = 1 THEN 5
                   WHEN product_id = 2 THEN 2
                   WHEN product_id = 3 THEN 5
                   ELSE 0
               END AS points 
        FROM (
            SELECT C.userid, C.product_id, SUM(C.price) AS total 
            FROM (
                SELECT S.*, P.price 
                FROM sales S
                JOIN product P ON S.product_id = P.product_id
            ) C
            GROUP BY userid, product_id
        ) D
    ) E
) GROUP BY userid;

-- Rank all transactions of the customers

SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rankk 
FROM sales;

-- All transactions for each member whenever they are a gold member,
-- For every non-gold member transaction, mark it as NA

SELECT S.userid, S.created_date, S.product_id, 
       CASE 
           WHEN G.gold_signup_date IS NOT NULL AND S.created_date >= G.gold_signup_date 
           THEN G.gold_signup_date 
           ELSE 'NA' 
       END AS membership_status 
FROM sales S
LEFT JOIN goldusers_signup G ON S.userid = G.userid;
