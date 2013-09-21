###################
# File: youtube_results.sql
# Description: Finds average scores for top artists, and average views
#     per day for each year.
# Author: Benn Stancil (@bennstancil, benn@modeanalytics.com)
###################


## Average views and scores by artist
## id is ordered by artist, then views

SELECT a.term,
       AVG(CASE WHEN a.id - 4 <= l.low THEN a.score ELSE NULL END) AS top_5,
       AVG(a.score) AS top_30,
       AVG(CASE WHEN a.id - 4 <= l.low THEN a.views ELSE NULL END) AS top_5_views,
       AVG(a.views) AS top_30_views
       COUNT(*)
  FROM top_youtube_artists a
  JOIN (
        SELECT term,
               MIN(id) AS low
          FROM top_youtube_artists
         GROUP BY 1
       ) l
    ON l.term = a.term
 WHERE a.id - 29 <= l.low
 GROUP BY 1

## Views per day, unadjusted and adjusted

SELECT c.year,
       AVG(c.views/DATEDIFF(SYSDATE(),c.upload)) AS views_per_day,
       AVG(CASE WHEN c.row_number - 19 <= l.low
                THEN c.views/(((4000-DATEDIFF(SYSDATE(),upload))/4000)*DATEDIFF(SYSDATE(),upload))
                ELSE NULL END) AS top_20_views_per_day_trim,
       COUNT(*)
  FROM (SELECT *,
               EXTRACT(YEAR FROM upload) AS year,
               @curRow := @curRow + 1 AS row_number
          FROM top_youtube_artists
          JOIN (SELECT @curRow := 0) r
         ORDER BY EXTRACT(YEAR FROM upload),views DESC
       ) c
  JOIN (SELECT year,
               MIN(row_number) AS low
          FROM (SELECT EXTRACT(YEAR FROM upload) AS year,
                       @curRow := @curRow + 1 AS row_number
                  FROM top_youtube_artists
                  JOIN (SELECT @curRow := 0) r
                 ORDER BY EXTRACT(YEAR FROM upload),views DESC
               ) a
         GROUP BY 1
       ) l
    ON l.year = c.year
  JOIN (SELECT term,
               MIN(id) AS low_artist
          FROM top_youtube_artists
         GROUP BY 1
       ) t
    ON t.term = c.term
   AND c.id - 29 <= t.low_artist
 GROUP BY 1
 ORDER BY 1
