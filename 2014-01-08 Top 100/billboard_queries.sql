## Artists by the number of years they appear
SELECT y.years,
       COUNT(y.artist) AS artists
  FROM (
        SELECT a.artist,
               COUNT(DISTINCT a.year) AS years
          FROM billboard_top_100_year_end a
         GROUP BY 1
       ) y
 GROUP BY 1
 ORDER BY 1

## Number of songs by most frequently appearing artists
SELECT COUNT(z.song_name) AS all_songs,
       COUNT(CASE WHEN z.most_years >= 5 THEN z.song_name ELSE NULL END) AS songs_by_5_plus_artists
  FROM (
SELECT s.song_name,
       s.year,
       s.group_name,
       MAX(y.years) AS most_years
  FROM billboard_top_100_year_end s
  JOIN (SELECT a.artist,
               COUNT(DISTINCT a.year) AS years
          FROM benn.billboard_top_100_year_end a
         GROUP BY 1
       ) y
    ON y.artist = s.artist
 GROUP BY 1,2,3
       ) z

## Chance of return by debut position
SELECT (z.first_rank - ((z.first_rank::INT - 1) % 10))/10 AS first_rank_bucket,
       COUNT(*) AS artists,
       COUNT(CASE WHEN z.following_songs > 0 THEN z.artist ELSE NULL END) AS reappearing_artists,
       COUNT(CASE WHEN z.following_songs > 0 THEN z.artist ELSE NULL END)/COUNT(*)::FLOAT AS reappear_percent
  FROM (
SELECT a.artist,
       a.year,
       a.year_rank AS first_rank,
       COUNT(n.*) AS following_songs,
       AVG(n.year_rank) AS avg_rank,
       MIN(n.year_rank) AS low_rank
  FROM (
        SELECT b.artist,
               b.song_name,
               b.year,
               b.year_rank,
               ROW_NUMBER() OVER (PARTITION BY b.artist ORDER BY b.year, b.year_rank) AS appearance
          FROM billboard_top_100_year_end b
       ) a
  LEFT JOIN billboard_top_100_year_end n
    ON n.artist = a.artist
   ANd n.song_name != a.song_name
   AND n.year <= a.year + 5
   AND n.year > a.year
 WHERE a.appearance = 1
   AND a.year <= 2008
 GROUP BY 1,2,3
       ) z
 GROUP BY 1
 ORDER BY 1

## Chance of return by start position or on number of songs in debut year
SELECT (z.start_position - ((z.start_position::INT - 1) % 10))/10 AS first_rank_bucket,
       --z.debut_year_songs,
       COUNT(*) AS artists,
       COUNT(CASE WHEN z.next_year_song = 1 THEN z.artist ELSE NULL END) AS reappear_next_year,
       COUNT(CASE WHEN z.returned = 1 THEN z.artist ELSE NULL END) AS reappear_five_year
  FROM (
SELECT a.artist,
       MIN(CASE WHEN s.year = a.debut_year THEN s.year_rank ELSE NULL END) AS start_position,
       COUNT(CASE WHEN s.year = a.debut_year THEN s.song_name ELSE NULL END) AS debut_year_songs,
       MAX(CASE WHEN s.year = a.debut_year + 1 THEN 1 ELSE NULL END) AS next_year_song,
       MAX(CASE WHEN s.year > a.debut_year THEN 1 ELSE NULL END) AS returned
  FROM (
        SELECT b.artist,
               MIN(b.year) AS debut_year
          FROM billboard_top_100_year_end b
         GROUP BY 1
       ) a
  JOIN billboard_top_100_year_end s
    ON s.artist = a.artist
   AND s.year >= a.debut_year
   AND s.year < a.debut_year + 5
 WHERE a.debut_year <= 2008
 GROUP BY 1
       ) z
 GROUP BY 1
 ORDER BY 1

## Relationship between time since last hit and number of hits
SELECT CASE WHEN x.previous_songs > 10 THEN 11 ELSE x.previous_songs END AS previous_songs,
       CASE WHEN x.year - x.last_year > 10 THEN 11 ELSE x.year - x.last_year END AS time_since_last,
       COUNT(x.artist) AS occurances,
       COUNT(CASE WHEN x.next_five_year_songs > 0 THEN x.artist ELSE NULL END) AS returing,
       COUNT(CASE WHEN x.next_five_year_songs > 0 THEN x.artist ELSE NULL END)/COUNT(x.artist)::FLOAT AS percent_returning
  FROM (
SELECT z.artist,
       z.year,
       z.year_songs,
       z.previous_songs,
       z.next_five_year_songs,
       MAX(p.year) AS last_year
  FROM (
        SELECT y.artist,
               y.debut_year + y.counter AS year,
               COUNT(CASE WHEN s.year = y.debut_year + y.counter THEN s.song_name ELSE NULL END) AS year_songs,
               COUNT(CASE WHEN s.year <= y.debut_year + y.counter THEN s.song_name ELSE NULL END) AS previous_songs,
               COUNT(CASE WHEN s.year > y.debut_year + y.counter AND s.year <= y.debut_year + y.counter + 5 
                          THEN s.song_name ELSE NULL END) AS next_five_year_songs
          FROM (
                SELECT a.artist,
                       i.id - 1 AS counter,
                       MIN(a.year) AS debut_year
                  FROM billboard_top_100_year_end a
                  JOIN billboard_top_100_year_end i
                    ON i.id >= 0
                   AND i.id <= 59
                 GROUP BY 1,2
               ) y
          JOIN billboard_top_100_year_end s
            ON s.artist = y.artist
         WHERE y.debut_year + y.counter <= 2013
 GROUP BY 1,2
       ) z
  JOIN billboard_top_100_year_end p
    ON p.artist = z.artist
   AND p.year <= z.year
 WHERE z.year <= 2008
 GROUP BY 1,2,3,4,5
       ) x 
 GROUP BY 1,2
 ORDER BY 1,2

## Data for probability model
SELECT x.*,
       x.year - x.last_year AS years_since_last
  FROM (
SELECT z.*,
       MAX(p.year) AS last_year
  FROM (
        SELECT y.artist,
               y.debut_year,
               y.debut_year + y.counter AS year,
               y.counter AS years_since_debut,
               MIN(CASE WHEN s.year = y.debut_year THEN s.year_rank ELSE NULL END) AS debut_position,
               COUNT(CASE WHEN s.year = y.debut_year THEN s.song_name ELSE NULL END) AS debut_songs,
               COUNT(CASE WHEN s.year <= y.debut_year + y.counter THEN s.song_name ELSE NULL END) AS total_hits,
               MIN(CASE WHEN s.year <= y.debut_year + y.counter THEN s.year_rank ELSE NULL END) AS best_position,
               COUNT(CASE WHEN s.year > y.debut_year + y.counter AND s.year <= y.debut_year + y.counter + 5 
                          THEN s.song_name ELSE NULL END) AS return_songs,
               MIN(CASE WHEN s.year > y.debut_year + y.counter AND s.year <= y.debut_year + y.counter + 5 
                        THEN s.year_rank ELSE NULL END) AS best_return_position
          FROM (
                SELECT a.artist,
                       i.id - 1 AS counter,
                       MIN(a.year) AS debut_year
                  FROM billboard_top_100_year_end a
                  JOIN billboard_top_100_year_end i
                    ON i.id >= 0
                   AND i.id <= 59
                 GROUP BY 1,2
               ) y
          JOIN billboard_top_100_year_end s
            ON s.artist = y.artist
         WHERE y.debut_year + y.counter <= 2013
         GROUP BY 1,2,3,4
       ) z
  JOIN billboard_top_100_year_end p
    ON p.artist = z.artist
   AND p.year <= z.year
 WHERE z.year <= 2008 # Use for training data
# WHERE z.year = 2013 # Use for 2013 data for predictions
 GROUP BY 1,2,3,4,5,6,7,8,9,10
       ) x 
 ORDER BY 1,2,3