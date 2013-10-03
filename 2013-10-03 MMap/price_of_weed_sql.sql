-- Data By State --

SELECT w.state,
       AVG(CASE WHEN ppo >= 1000 THEN 1000 ELSE ppo END) AS avg_ppo,
       SUM(price)/AVG(p.population) AS price_per_person,
       SUM(amount)/AVG(p.population) AS amount_per_person,
       COUNT(*)/AVG(p.population) AS transactions_per_capita,
       SUM(price) AS price,
       SUM(amount) AS amount,
       COUNT(*) AS transactions
 FROM price_of_weed_data w
 JOIN state_populations_2010 p
   ON p.state = w.state
GROUP BY 1


-- Results By City --

SELECT w.location,
       AVG(amount) AS avg_amount,
       AVG(CASE WHEN ppo >= 1000 THEN 1000 ELSE ppo END) AS avg_ppo,
       COUNT(*) AS transactions
  FROM price_of_weed_data w
 GROUP BY 1 
 HAVING COUNT(*) >= 20
 ORDER BY 4 DESC