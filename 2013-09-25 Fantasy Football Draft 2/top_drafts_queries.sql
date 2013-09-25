-- Number of drafts that selected each position, by draft round

SELECT p.position,
			 SUM(CASE WHEN p.position = o.r1_pos THEN 1 ELSE 0 END) AS r1,
			 SUM(CASE WHEN p.position = o.r2_pos THEN 1 ELSE 0 END) AS r2,
			 SUM(CASE WHEN p.position = o.r3_pos THEN 1 ELSE 0 END) AS r3,
			 SUM(CASE WHEN p.position = o.r4_pos THEN 1 ELSE 0 END) AS r4,
			 SUM(CASE WHEN p.position = o.r5_pos THEN 1 ELSE 0 END) AS r5,
			 SUM(CASE WHEN p.position = o.r6_pos THEN 1 ELSE 0 END) AS r6,
			 SUM(CASE WHEN p.position = o.r7_pos THEN 1 ELSE 0 END) AS r7,
			 SUM(CASE WHEN p.position = o.r8_pos THEN 1 ELSE 0 END) AS r8,
			 SUM(CASE WHEN p.position = o.r9_pos THEN 1 ELSE 0 END) AS r9,
			 SUM(CASE WHEN p.position = o.r10_pos THEN 1 ELSE 0 END) AS r10
  FROM top_ff_drafting_orders o
	JOIN (SELECT DISTINCT r5_pos AS position
				  FROM top_ff_drafting_orders
			 ) p
 WHERE source = "espn"
 GROUP BY 1

-- Percent of drafts that have filled each position by the time draft gets to round n

SELECT p.position,
			 SUM(CASE WHEN p.position IN (o.r1_pos) THEN 1 ELSE 0 END)/1000 AS r1,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos) THEN 1 ELSE 0 END)/1000 r2,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos,o.r3_pos) THEN 1 ELSE 0 END)/1000 AS r3,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos,o.r3_pos,o.r4_pos) THEN 1 ELSE 0 END)/1000 AS r4,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos,o.r3_pos,o.r4_pos,o.r5_pos) THEN 1 ELSE 0 END)/1000 AS r5,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos,o.r3_pos,o.r4_pos,o.r5_pos,o.r6_pos) THEN 1 ELSE 0 END)/1000 AS r6,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos,o.r3_pos,o.r4_pos,o.r5_pos,o.r6_pos,o.r7_pos) THEN 1 ELSE 0 END)/1000 AS r7,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos,o.r3_pos,o.r4_pos,o.r5_pos,o.r6_pos,o.r7_pos,o.r8_pos) THEN 1 ELSE 0 END)/1000 AS r8,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos,o.r3_pos,o.r4_pos,o.r5_pos,o.r6_pos,o.r7_pos,o.r8_pos,o.r9_pos) THEN 1 ELSE 0 END)/1000 AS r9,
			 SUM(CASE WHEN p.position IN (o.r1_pos,o.r2_pos,o.r3_pos,o.r4_pos,o.r5_pos,o.r6_pos,o.r7_pos,o.r8_pos,o.r9_pos,o.r10_pos) THEN 1 ELSE 0 END)/1000 AS r10
  FROM top_ff_drafting_orders o
	JOIN (SELECT DISTINCT r5_pos AS position
				  FROM top_ff_drafting_orders
			 ) p
 WHERE source = 'espn'
 GROUP BY 1
 ORDER BY 1

-- Draft position of QBs

SELECT source,
  		 draft_position,
			 COUNT(CASE WHEN r1_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r1,
			 COUNT(CASE WHEN r2_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r2,
			 COUNT(CASE WHEN r3_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r3,
			 COUNT(CASE WHEN r4_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r4,
			 COUNT(CASE WHEN r5_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r5,
			 COUNT(CASE WHEN r6_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r6,
			 COUNT(CASE WHEN r7_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r7,
			 COUNT(CASE WHEN r8_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r8,
			 COUNT(CASE WHEN r9_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r9,
			 COUNT(CASE WHEN r10_pos = 'qb' THEN 1 ELSE NULL END)/100 AS r10
  FROM top_ff_drafting_orders 
 GROUP BY 1,2
 ORDER BY 1,2

-- Average performance of top drafts by starting draft postion

SELECT source,
       draft_position,
       AVG(total_pts) AS average,
       MAX(total_pts)
  FROM top_ff_drafting_orders
 WHERE source = 'espn'
 GROUP BY 1,2