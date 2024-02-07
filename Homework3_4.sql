	--the first question
SELECT count(*),billing_country 
FROM invoice i 
GROUP BY billing_country 
ORDER BY 1;
	--the second question 
SELECT sum(total),billing_city
FROM invoice i 
GROUP BY billing_city 
ORDER BY 1
OFFSET 0 LIMIT 5;
    --the third question 
WITH worst_customer AS (SELECT sum(total) AS least_money, customer_id
                        FROM invoice i
                        GROUP BY customer_id
                        ORDER BY sum(total)
                        LIMIT 1)
SELECT customer_id,first_name,last_name,(SELECT least_money
                                         FROM worst_customer)
FROM customer 
WHERE customer_id = (SELECT customer_id
                   FROM worst_customer)
                   
      --the fourth question 
WITH rock_music AS (SELECT DISTINCT customer_id,genre.name
                    FROM track 
                        JOIN genre 
                           ON track.genre_id = genre.genre_id
                        JOIN invoice_line
                           ON track.track_id = invoice_line.track_id
                        JOIN invoice 
                           ON invoice_line.invoice_id = invoice.invoice_id
                     WHERE upper(genre.name) = 'ROCK')
                     
SELECT email,first_name,last_name,(SELECT name
                                   FROM rock_music
                                   LIMIT 1) AS genre_name
FROM customer 
WHERE customer_id IN (SELECT customer_id
                      FROM rock_music) AND email ILIKE 's%'
ORDER BY 1;
       --the fifth question
WITH most_spent AS (SELECT SUM(total) AS total, invoice.customer_id, billing_country
                        FROM invoice
                                 JOIN customer
                                      ON invoice.customer_id = customer.customer_id
                        GROUP BY billing_country, invoice.customer_id),
     max_spent AS (SELECT MAX(most_spent.total) AS max_spend, billing_country
                           FROM most_spent
                           GROUP BY billing_country)
SELECT customer.customer_id, last_name, most_spent.billing_country, total
FROM most_spent
         JOIN max_spent
              ON max_spent.max_spend = most_spent.total AND
                 most_spent.billing_country = max_spent.billing_country
         JOIN customer
              ON most_spent.customer_id = customer.customer_id;
     -- Part 2 
     -- the first question 
SELECT count(*),name
FROM track 
GROUP BY name
ORDER BY 1 DESC;
     -- the second question 
WITH most_album AS (SELECT SUM(total) as total_sum, album.album_id
                         FROM album
                                  JOIN track
                                       ON album.album_id = track.album_id
                                  JOIN invoice_line
                                       ON track.track_id = invoice_line.track_id
                                  JOIN invoice
                                       ON invoice_line.invoice_id = invoice.invoice_id
                         GROUP BY album.album_id
                         ORDER BY 1 DESC
                             OFFSET 0 LIMIT 1)
SELECT title, (SELECT total_sum FROM most_album)
FROM album
WHERE album_id IN (SELECT album_id FROM most_album)
;
     -- the third question
WITH total_country AS (SELECT SUM(total) AS total, billing_country
                          FROM invoice
                          GROUP BY billing_country),
     total_all AS (SELECT SUM(total) AS total_sum
                   FROM total_country)
SELECT total, ROUND(total / (SELECT total_sum FROM total_all) * 100, 3) AS percentage, billing_country
FROM total_country
ORDER BY total DESC
;
     -- the fourth question 
WITH customers_amount AS (SELECT COUNT(customer_id) AS number_of_customers
                               , employee_id
                          FROM employee
                                   JOIN customer
                                        ON employee.employee_id = customer.support_rep_id
                          GROUP BY employee_id)
   , sales_per_employee AS (SELECT SUM(total)       AS total
                                 , COUNT(invoice_id) AS sales_number
                                 , employee_id
                            FROM invoice
                                     JOIN customer
                                          ON invoice.customer_id = customer.customer_id
                                     JOIN employee
                                          ON customer.support_rep_id = employee.employee_id
                            GROUP BY employee_id)
SELECT customers_amount.employee_id, first_name, last_name, number_of_customers, ROUND(total / sales_number, 3) AS average_sale
     , total
FROM customers_amount
         JOIN sales_per_employee
              ON customers_amount.employee_id = sales_per_employee.employee_id
         JOIN employee
              ON customers_amount.employee_id = employee.employee_id
;
      --fifth question
SELECT SUM(milliseconds) AS duration, SUM(total) AS total, album.album_id
FROM album
         JOIN track
              ON album.album_id = track.album_id
         JOIN invoice_line
              ON track.track_id = invoice_line.track_id
         JOIN invoice
              ON invoice_line.invoice_id = invoice.invoice_id
GROUP BY album.album_id
ORDER BY total DESC, duration;
      --sixth question 
WITH appere_times AS (SELECT COUNT(track.track_id) AS num_times
                               , track.track_id
                          FROM playlist
                                   JOIN playlist_track
                                        ON playlist.playlist_id = playlist_track.playlist_id
                                   JOIN track
                                        ON playlist_track.track_id = track.track_id
                          GROUP BY track.track_id
                          ORDER BY 1 DESC)
   , revenue_per_track AS (SELECT SUM(unit_price * quantity) AS total_revenue
                                , invoice_line.track_id
                           FROM invoice_line
                                    JOIN invoice
                                         ON invoice_line.invoice_id = invoice.invoice_id
                           GROUP BY invoice_line.track_id, invoice_line.track_id)
SELECT track.track_id, name, num_times, total_revenue
FROM appere_times
         JOIN revenue_per_track
              ON appere_times.track_id = revenue_per_track.track_id
         JOIN track
              ON appere_times.track_id = track.track_id
ORDER BY total_revenue DESC
;
    --seventh question
SELECT SUM(total)AS total_sales_per_year, DATE_PART('year', invoice_date), 100 - (100 * LAG(SUM(total), 1)
                    OVER (
                        ORDER BY DATE_PART('year',invoice_date))) / SUM(total) AS change_percentage
FROM invoice
GROUP BY DATE_PART('year', invoice_date)
ORDER BY date_part
;