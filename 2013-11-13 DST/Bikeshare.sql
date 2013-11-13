--Excluded days

'2010-11-04' TR --Unknown
'2011-03-10' TR --Unknown
'2012-10-29' M  --Sandy
'2012-10-30' T  --Sandy
'2013-03-06' W  --Snowstorm

-- Overall ridership
SELECT DATE_TRUNC('month',t.start_time) AS month,
       COUNT(*) AS all_rides,
       COUNT(CASE WHEN t.type != 'Casual' THEN t.id ELSE NULL END) AS subscriber_rides,
       COUNT(CASE WHEN t.type != 'Casual' 
                   AND EXTRACT(dow FROM t.start_time) IN (1,2,3,4,5)
                   AND (EXTRACT(hour FROM t.start_time) IN (6,7,8,9,10)
                    OR EXTRACT(hour FROM t.start_time) IN (15,16,17,18,19))
                  THEN t.id ELSE NULL END) AS commuters
  FROM capital_bikeshare_trip_types t
 GROUP BY 1
 ORDER BY 1

-- Differences before and after for all days

SELECT EXTRACT(hour FROM t.start_time) AS hour,
       FLOOR(EXTRACT(minute FROM t.start_time)/15)*15 AS minute,
       EXTRACT(hour FROM t.start_time)::VARCHAR || ':'||
       (FLOOR(EXTRACT(minute FROM t.start_time)/15)*15)::VARCHAR AS time,
       COUNT(CASE WHEN (t.start_time >= '2011-03-06' AND t.start_time <= '2011-03-14') 
                    OR (t.start_time >= '2012-03-04' AND t.start_time <= '2012-03-11') 
                    OR (t.start_time >= '2013-03-03' AND t.start_time <= '2013-03-10') THEN t.id ELSE NULL END) AS start_before, --13 days
       COUNT(CASE WHEN (t.start_time >= '2011-03-14' AND t.start_time <= '2011-03-21') 
                    OR (t.start_time >= '2012-03-11' AND t.start_time <= '2012-03-18') 
                    OR (t.start_time >= '2013-03-10' AND t.start_time <= '2013-03-17') THEN t.id ELSE NULL END) AS start_after, --15 days
       COUNT(CASE WHEN (t.start_time >= '2010-10-31' AND t.start_time <= '2010-11-07') 
                    OR (t.start_time >= '2011-10-30' AND t.start_time <= '2011-11-06') 
                    OR (t.start_time >= '2012-10-28' AND t.start_time <= '2012-11-04') THEN t.id ELSE NULL END) AS end_before, --12 days
       COUNT(CASE WHEN (t.start_time >= '2010-11-07' AND t.start_time <= '2010-11-14') 
                    OR (t.start_time >= '2011-11-06' AND t.start_time <= '2011-11-13') 
                    OR (t.start_time >= '2012-11-04' AND t.start_time <= '2012-11-11') THEN t.id ELSE NULL END) AS end_after --15 days
  FROM capital_bikeshare_trip_types t
 WHERE EXTRACT(dow FROM t.start_time) IN (1,2,3,4,5)
   AND EXTRACT(hour FROM t.start_time) IN (6,7,8,9,10,15,16,17,18,19,20)
   AND t.type != 'Casual'
   AND DATE_TRUNC('day',t.start_time) NOT IN ('2010-11-04','2011-03-10','2012-10-29','2012-10-30','2013-03-06') --Bad weather days
   AND ((t.start_time >= '2010-10-31' AND t.start_time <= '2010-11-14')  --2010 DST end
    OR  (t.start_time >= '2011-03-06' AND t.start_time <= '2011-03-20')  --2011 DST start
    OR  (t.start_time >= '2011-10-30' AND t.start_time <= '2011-11-13')  --2011 DST end
    OR  (t.start_time >= '2012-03-04' AND t.start_time <= '2012-03-18')  --2012 DST start
    OR  (t.start_time >= '2012-10-28' AND t.start_time <= '2012-11-11')  --2012 DST end
    OR  (t.start_time >= '2013-03-03' AND t.start_time <= '2013-03-17')) --2013 DST start
 GROUP BY 1,2,3
 ORDER BY 1,2,3

-- Differences before and after for only Mondays and Fridays

SELECT EXTRACT(dow FROM t.start_time),
       EXTRACT(hour FROM t.start_time) AS hour,
       FLOOR(EXTRACT(minute FROM t.start_time)/15)*15 AS minute,
       EXTRACT(hour FROM t.start_time)::VARCHAR || ':'||
       (FLOOR(EXTRACT(minute FROM t.start_time)/15)*15)::VARCHAR AS time,
       COUNT(CASE WHEN (t.start_time >= '2011-02-20' AND t.start_time <= '2011-03-14') 
                    OR (t.start_time >= '2012-02-18' AND t.start_time <= '2012-03-11') 
                    OR (t.start_time >= '2013-02-17' AND t.start_time <= '2013-03-10') THEN t.id ELSE NULL END) AS start_before,
       COUNT(CASE WHEN (t.start_time >= '2011-03-14' AND t.start_time <= '2011-04-03') 
                    OR (t.start_time >= '2012-03-11' AND t.start_time <= '2012-04-02') 
                    OR (t.start_time >= '2013-03-10' AND t.start_time <= '2013-04-01') THEN t.id ELSE NULL END) AS start_after,
       COUNT(CASE WHEN (t.start_time >= '2010-10-17' AND t.start_time <= '2010-11-07') 
                    OR (t.start_time >= '2011-10-16' AND t.start_time <= '2011-11-06') 
                    OR (t.start_time >= '2012-10-14' AND t.start_time <= '2012-11-04') THEN t.id ELSE NULL END) AS end_before,
       COUNT(CASE WHEN (t.start_time >= '2010-11-07' AND t.start_time <= '2010-11-28') 
                    OR (t.start_time >= '2011-11-06' AND t.start_time <= '2011-11-27') 
                    OR (t.start_time >= '2012-11-04' AND t.start_time <= '2012-11-25') THEN t.id ELSE NULL END) AS end_after
  FROM capital_bikeshare_trip_types t
 WHERE EXTRACT(dow FROM t.start_time) IN (1,5)
   AND EXTRACT(hour FROM t.start_time) IN (6,7,8,9,10,15,16,17,18,19)
   AND t.type != 'Casual'
   AND DATE_TRUNC('day',t.start_time) NOT IN ('2010-11-04','2011-03-10','2012-10-29','2012-10-30','2013-03-06') --Bad weather days
   AND ((t.start_time >= '2010-10-17' AND t.start_time <= '2010-11-28')  --2010 DST end
    OR  (t.start_time >= '2011-02-20' AND t.start_time <= '2011-04-03')  --2011 DST start
    OR  (t.start_time >= '2011-10-16' AND t.start_time <= '2011-11-27')  --2011 DST end
    OR  (t.start_time >= '2012-02-18' AND t.start_time <= '2012-04-02')  --2012 DST start
    OR  (t.start_time >= '2012-10-14' AND t.start_time <= '2012-11-25')  --2012 DST end
    OR  (t.start_time >= '2013-02-17' AND t.start_time <= '2013-04-01')) --2013 DST start
 GROUP BY 1,2,3,4
 ORDER BY 1,2,3,4
 
 
-- Table showing summary for all DST change events

SELECT EXTRACT(hour FROM t.start_time)::VARCHAR || ':'||
       (FLOOR(EXTRACT(minute FROM t.start_time)/15)*15)::VARCHAR AS hour,
       COUNT(CASE WHEN (t.start_time >= '2010-10-31' AND t.start_time <= '2010-11-07') THEN t.id ELSE NULL END) AS end_2010_before,
       COUNT(CASE WHEN (t.start_time >= '2010-11-07' AND t.start_time <= '2010-11-14') THEN t.id ELSE NULL END) AS end_2010_after,
       COUNT(CASE WHEN (t.start_time >= '2011-03-06' AND t.start_time <= '2011-03-14') THEN t.id ELSE NULL END) AS start_2011_before,
       COUNT(CASE WHEN (t.start_time >= '2011-03-14' AND t.start_time <= '2011-03-21') THEN t.id ELSE NULL END) AS start_2011_after,
       COUNT(CASE WHEN (t.start_time >= '2011-10-30' AND t.start_time <= '2011-11-06') THEN t.id ELSE NULL END) AS end_2011_before,
       COUNT(CASE WHEN (t.start_time >= '2011-11-06' AND t.start_time <= '2011-11-13') THEN t.id ELSE NULL END) AS end_2011_after,
       COUNT(CASE WHEN (t.start_time >= '2012-03-04' AND t.start_time <= '2012-03-11') THEN t.id ELSE NULL END) AS start_2012_before,
       COUNT(CASE WHEN (t.start_time >= '2012-03-11' AND t.start_time <= '2012-03-18') THEN t.id ELSE NULL END) AS start_2012_after,
       COUNT(CASE WHEN (t.start_time >= '2012-10-28' AND t.start_time <= '2012-11-04') THEN t.id ELSE NULL END) AS end_2012_before,
       COUNT(CASE WHEN (t.start_time >= '2012-11-04' AND t.start_time <= '2012-11-11') THEN t.id ELSE NULL END) AS end_2012_after,
       COUNT(CASE WHEN (t.start_time >= '2013-03-03' AND t.start_time <= '2013-03-10') THEN t.id ELSE NULL END) AS start_2013_before,
       COUNT(CASE WHEN (t.start_time >= '2013-03-10' AND t.start_time <= '2013-03-17') THEN t.id ELSE NULL END) AS start_2013_after
  FROM capital_bikeshare_trip_types t
 WHERE EXTRACT(dow FROM t.start_time) IN (1,2,3,4,5)
   AND EXTRACT(hour FROM t.start_time) IN (6,7,8,9,10,15,16,17,18,19)
   AND t.type != 'Casual'
   AND DATE_TRUNC('day',t.start_time) NOT IN ('2010-11-04','2011-03-10','2012-10-29','2012-10-30','2013-03-06') --Bad weather days
   AND ((t.start_time >= '2010-10-31' AND t.start_time <= '2010-11-14')  --2010 DST end
    OR  (t.start_time >= '2011-03-06' AND t.start_time <= '2011-03-20')  --2011 DST start
    OR  (t.start_time >= '2011-10-30' AND t.start_time <= '2011-11-13')  --2011 DST end
    OR  (t.start_time >= '2012-03-04' AND t.start_time <= '2012-03-18')  --2012 DST start
    OR  (t.start_time >= '2012-10-28' AND t.start_time <= '2012-11-11')  --2012 DST end
    OR  (t.start_time >= '2013-03-03' AND t.start_time <= '2013-03-17')) --2013 DST start
 GROUP BY 1
 ORDER BY 1

-- Differences before and after broken apart by all days of the week

SELECT EXTRACT(dow FROM t.start_time) IN (1,2,3,4,5),
       EXTRACT(hour FROM t.start_time) AS hour,
       FLOOR(EXTRACT(minute FROM t.start_time)/15)*15 AS minute,
       EXTRACT(hour FROM t.start_time)::VARCHAR || ':'||
       (FLOOR(EXTRACT(minute FROM t.start_time)/15)*15)::VARCHAR AS time,
       COUNT(CASE WHEN (t.start_time >= '2011-03-06' AND t.start_time <= '2011-03-14') 
                    OR (t.start_time >= '2012-03-04' AND t.start_time <= '2012-03-11') 
                    OR (t.start_time >= '2013-03-03' AND t.start_time <= '2013-03-10') THEN t.id ELSE NULL END)/13 AS start_before,
       COUNT(CASE WHEN (t.start_time >= '2011-03-14' AND t.start_time <= '2011-03-21') 
                    OR (t.start_time >= '2012-03-11' AND t.start_time <= '2012-03-18') 
                    OR (t.start_time >= '2013-03-10' AND t.start_time <= '2013-03-17') THEN t.id ELSE NULL END)/15 AS start_after,
       COUNT(CASE WHEN (t.start_time >= '2010-10-31' AND t.start_time <= '2010-11-07') 
                    OR (t.start_time >= '2011-10-30' AND t.start_time <= '2011-11-06') 
                    OR (t.start_time >= '2012-10-28' AND t.start_time <= '2012-11-04') THEN t.id ELSE NULL END)/12 AS end_before,
       COUNT(CASE WHEN (t.start_time >= '2010-11-07' AND t.start_time <= '2010-11-14') 
                    OR (t.start_time >= '2011-11-06' AND t.start_time <= '2011-11-13') 
                    OR (t.start_time >= '2012-11-04' AND t.start_time <= '2012-11-11') THEN t.id ELSE NULL END)/15 AS end_after
  FROM capital_bikeshare_trip_types t
 WHERE EXTRACT(dow FROM t.start_time) IN (1,2,3,4,5)
   AND EXTRACT(hour FROM t.start_time) IN (6,7,8,9,10,15,16,17,18,19)
   AND t.type != 'Casual'
   AND DATE_TRUNC('day',t.start_time) NOT IN ('2010-11-04','2011-03-10','2012-10-29','2012-10-30','2013-03-06') --Bad weather days
   AND ((t.start_time >= '2010-10-31' AND t.start_time <= '2010-11-14')  --2010 DST end
    OR  (t.start_time >= '2011-03-06' AND t.start_time <= '2011-03-20')  --2011 DST start
    OR  (t.start_time >= '2011-10-30' AND t.start_time <= '2011-11-13')  --2011 DST end
    OR  (t.start_time >= '2012-03-04' AND t.start_time <= '2012-03-18')  --2012 DST start
    OR  (t.start_time >= '2012-10-28' AND t.start_time <= '2012-11-11')  --2012 DST end
    OR  (t.start_time >= '2013-03-03' AND t.start_time <= '2013-03-17')) --2013 DST start
 GROUP BY 1,2,3,4
 ORDER BY 1,2,3,4

-- Rides by day

SELECT DATE_TRUNC('day',t.start_time) AS day,
       COUNT(*) AS ride,
  FROM capital_bikeshare_trip_types t
 WHERE EXTRACT(dow FROM t.start_time) IN (1,2,3,4,5)
   AND ((t.start_time >= '2010-10-31' AND t.start_time <= '2010-11-14')  --2010 DST end
    OR  (t.start_time >= '2011-03-06' AND t.start_time <= '2011-03-20')  --2011 DST start
    OR  (t.start_time >= '2011-10-30' AND t.start_time <= '2011-11-13')  --2011 DST end
    OR  (t.start_time >= '2012-03-04' AND t.start_time <= '2012-03-18')  --2012 DST start
    OR  (t.start_time >= '2012-10-28' AND t.start_time <= '2012-11-11')  --2012 DST end
    OR  (t.start_time >= '2013-03-03' AND t.start_time <= '2013-03-17')) --2013 DST start
 GROUP BY 1
 ORDER BY 1
