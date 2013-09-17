--Conflict by type

SELECT YEAR,	  
	   COUNT(CASE WHEN Type = 2 THEN ID ELSE NULL END) AS "Interstate conflict",
	   COUNT(CASE WHEN Type = 3 THEN ID ELSE NULL END) AS "Civil war",
	   COUNT(CASE WHEN Type = 4 THEN ID ELSE NULL END) AS "Civil war with intervening parties"
  FROM armed_conflict_history
 WHERE YEAR >= 1950
 GROUP BY 1
 ORDER BY 1
 

--Conflict by intensity

SELECT YEAR,	  
	   COUNT(CASE WHEN h.Int = 1 THEN ID ELSE NULL END) AS "Minor conflict",
	   COUNT(CASE WHEN h.Int = 2 THEN ID ELSE NULL END) AS "Major conflict"	
  FROM armed_conflict_history h
 WHERE YEAR >= 1950
 GROUP BY 1
 ORDER BY 1

 
--Percent of Conflicts that are major

SELECT Type,
	   COUNT(CASE WHEN h.Int = 2 THEN ID ELSE NULL END)
		/COUNT(ID) AS "Percent major",
	   COUNT(CASE WHEN h.Int = 1 THEN ID ELSE NULL END)/
		COUNT(ID)AS "Percent minor"	
  FROM armed_conflict_history h
 WHERE YEAR >= 2008
 GROUP BY 1
 ORDER BY 1


--Intensity after intervention

SELECT COUNT(ID) AS cases,
	   COUNT(DISTINCT ID) AS conflicts,
	   COUNT(CASE WHEN int__1 = int_0 THEN ID ELSE NULL END) AS y0_same,
	   COUNT(CASE WHEN int__1 > int_0 THEN ID ELSE NULL END) AS y0_decreased,
	   COUNT(CASE WHEN int__1 < int_0 THEN ID ELSE NULL END) AS y0_increased,
       COUNT(CASE WHEN int__1 = two_after THEN ID ELSE NULL END) AS y1_same,
       COUNT(CASE WHEN int__1 > two_after THEN ID ELSE NULL END) AS y1_decreased,
       COUNT(CASE WHEN int__1 < two_after THEN ID ELSE NULL END) AS y1_increased
  FROM (

SELECT y0.ID,
	   y_2.Int AS int__2,
	   y_1.Int AS int__1,
  	   y0.Int AS int_0,
	   (COALESCE(y2.Int,0) 
	     + COALESCE(y1.Int,0))/2 AS two_after
    FROM armed_conflict_history y0
    JOIN armed_conflict_history y_1
      ON y_1.ID = y0.ID
     AND y_1.Type = 3
     AND y_1.YEAR = y0.YEAR - 1
    LEFT JOIN armed_conflict_history y_2
      ON y_2.ID = y0.ID
     AND y_2.YEAR = y0.YEAR - 2
    LEFT JOIN armed_conflict_history y1
      ON y1.ID = y0.ID
     AND y1.YEAR = y0.YEAR + 1
    LEFT JOIN armed_conflict_history y2
      ON y2.ID = y0.ID
     AND y2.YEAR = y0.YEAR + 2
   WHERE y0.Type = 4
		) a


--Conflict Length

SELECT result,
	   COUNT(ID),
       COUNT(CASE WHEN five_plus_years = 1 THEN ID ELSE NULL END) AS lasting_at_least_five_years
  FROM (
	  SELECT ID,
	  	     CASE WHEN i2 + i3 + i4 + i5 + i6 <= 2 
            	   AND GREATEST(y2,y3,y4,y5,y6) != 2012
			      THEN 'ended'
	  	     	  WHEN CASE WHEN t2 = 4 THEN 1 ELSE 0 END + 
	  	     	 	   CASE WHEN t3 = 4 THEN 1 ELSE 0 END + 
	  	     	 	   CASE WHEN t4 = 4 THEN 1 ELSE 0 END + 
	  	     	 	   CASE WHEN t5 = 4 THEN 1 ELSE 0 END + 
	  	     	 	   CASE WHEN t6 = 4 THEN 1 ELSE 0 END >= 3
	  	     	 	OR LEAST(t2,t3,t4,t5,t6) = 4
	  	     	  THEN 'endured together'
	  	     	  ELSE 'endured alone' 
			 END AS result,
			 CASE WHEN y6 != 1950 THEN 1 ELSE 0 END AS five_plus_years
	    FROM (
	  SELECT y0.ID,
		  	 COALESCE(y2.YEAR,1950) as y2,
			 COALESCE(y3.YEAR,1950) as y3,
			 COALESCE(y4.YEAR,1950) as y4,
			 COALESCE(y5.YEAR,1950) as y5,
			 COALESCE(y6.YEAR,1950) as y6,
	  	     COALESCE(y2.Type,5) AS t2,
	  	     COALESCE(y3.Type,5) AS t3,
	  	     COALESCE(y4.Type,5) AS t4,
	  	     COALESCE(y5.Type,5) AS t5,
	  	     COALESCE(y6.Type,5) AS t6,
	  	     COALESCE(y2.Int,0) AS i2,
	  	     COALESCE(y3.Int,0) AS i3,
	  	     COALESCE(y4.Int,0) AS i4,
	  	     COALESCE(y5.Int,0) AS i5,
	  	     COALESCE(y6.Int,0) AS i6
	      FROM armed_conflict_history y0
	      JOIN armed_conflict_history y_1
	        ON y_1.ID = y0.ID
	       AND y_1.Type = 3
	       AND y_1.YEAR = y0.YEAR - 1
	      LEFT JOIN armed_conflict_history y1
	        ON y1.ID = y0.ID
	       AND y1.YEAR = y0.YEAR + 1
	      LEFT JOIN armed_conflict_history y2
	        ON y2.ID = y0.ID
	       AND y2.YEAR = y0.YEAR + 2
	      LEFT JOIN armed_conflict_history y3
	        ON y3.ID = y0.ID
	       AND y3.YEAR = y0.YEAR + 3
	      LEFT JOIN armed_conflict_history y4
	        ON y4.ID = y0.ID
	       AND y4.YEAR = y0.YEAR + 4
	      LEFT JOIN armed_conflict_history y5
	        ON y5.ID = y0.ID
	       AND y5.YEAR = y0.YEAR + 5
	      LEFT JOIN armed_conflict_history y6
	        ON y6.ID = y0.ID
	       AND y6.YEAR = y0.YEAR + 6
	     WHERE y0.Type = 4
	  		) a
    	) b
  GROUP BY 1