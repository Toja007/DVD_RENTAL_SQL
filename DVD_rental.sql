/* Query number 1 - HOW MUCH DID EACH CATEGORY GENERATE? */


SELECT cat.name AS category, 
	SUM(p.amount) AS sum_total_amt,
	COUNT(*) AS count
FROM category AS cat 
JOIN film_category AS fc
ON cat.category_id = fc.category_id
JOIN film AS f
ON f.film_id = fc.film_id
JOIN inventory AS i
ON i.film_id = f.film_id
JOIN rental AS r
ON r.inventory_id = i.film_id
JOIN payment AS p
ON p.rental_id = r.rental_id
GROUP BY 1
ORDER BY 2 DESC;





/* Query 2 - WHAT IS AVERAGE NUMBER OF FILMS RENTED ON THE EARLIEST DATE ON RECORD SORTED BY CATEGORY? */


WITH t1 AS (SELECT cat.name AS name,
	           DATE_TRUNC('MONTH',r.rental_date) AS month
	    FROM category AS cat
	    JOIN film_category AS fc
	    ON cat.category_id = fc.category_id
	    JOIN film AS f
	    ON f.film_id = fc.film_id
	    JOIN inventory AS i
	    ON i.film_id = f.film_id
	    JOIN rental AS r
	    ON r.inventory_id = i.inventory_id
	    GROUP BY 1,r.rental_date),
      
 t2 AS (SELECT MIN(month) AS min
	    FROM t1),

t3 AS (SELECT t1.name,
       		  t1.month AS date,
       		  COUNT(*) AS counts
	   FROM t1
       JOIN t2 
       ON t1.month = t2.min
	   WHERE month = t2.min
	   GROUP BY 1,2)

SELECT name, date, AVG(counts)::INT AS avg_count
FROM t3
GROUP BY 1,2;






/* Query 3 - WHAT WAS THE RENTAL ORDER FOR EACH STORE IN 2005? */


SELECT store,
	month,
	year,
	COUNT(*) AS count
FROM (SELECT s.store_id store,
		DATE_PART('MONTH', r.rental_date) AS month,
		DATE_PART('YEAR', r.rental_date) AS year
	FROM store AS s
	JOIN staff AS st
	ON s.store_id = st.store_id
	JOIN rental AS r
	ON st.staff_id = r.staff_id)t1
WHERE year = 2005
GROUP BY 1,2,3
ORDER BY 3,2,4 DESC;




/* Query 4 - WHO ARE TO TOP TEN MOST FREQUENT CUSTOMERS? */


WITH t1 AS (SELECT customer_id,
            		title
			FROM film AS f
			JOIN inventory AS i
			ON f.film_id = i.film_id
			JOIN rental AS r
			ON r.inventory_id = i.inventory_id),

t2 AS (SELECT DISTINCT customer_id,
       			COUNT(*) counts 
		FROM t1
		GROUP BY t1.customer_id)

SELECT customer_id,
		counts,
        DENSE_RANK() 
        OVER (ORDER BY counts DESC) AS ranking
FROM t2
GROUP BY 1,2
