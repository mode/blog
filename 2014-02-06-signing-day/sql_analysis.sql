# Geographic Diversity

SELECT z.recruited_year,
       z.conference_2014,
       SUM(z.power) AS concentration_score
  FROM (
SELECT a.recruited_year,
       a.conference_2014,
       (a.state_players/a.all_players::FLOAT) *
       (a.state_players/a.all_players::FLOAT)::FLOAT AS power
  FROM (
SELECT p.recruited_year,
       p.conference_2014,
       p.state,
       c.players AS all_players,
       COUNT(*) AS state_players
  FROM nfl_players_hometowns p
  JOIN (SELECT recruited_year,
               conference_2014,
               COUNT(*) AS players
          FROM nfl_players_hometowns
         WHERE state IS NOT NULL
           AND conference_2014 IN ('acc','big-ten','big-12','sec','pac-12')
         GROUP BY 1,2
       ) c
    ON c.conference_2014 = p.conference_2014
   AND c.recruited_year = p.recruited_year
 WHERE p.state IS NOT NULL
 GROUP BY 1,2,3,4
       ) a
       ) z 
 GROUP BY 1,2

## Conference centers relative to one another

SELECT z.year,
       z.start_conf,
       z.end_conf,
       ACOS( COS(RADIANS(90-z.start_lat)) * COS(RADIANS(90-z.end_lat)) + SIN(RADIANS(90-z.start_lat)) * 
         SIN(RADIANS(90-z.end_lat)) * COS(RADIANS(z.start_long-z.end_long)))*6371 AS distance
  FROM (
SELECT start.year,
       start.conference AS start_conf,
       ends.conference AS end_conf,
       start.lat_sum/start.total_sum AS start_lat,
       start.long_sum/start.total_sum AS start_long,
       ends.lat_sum/ends.total_sum AS end_lat,
       ends.long_sum/ends.total_sum AS end_long
  FROM (
        SELECT a.conference,
               a.year,
               SUM(a.players * a.lat) AS lat_sum,
               SUM(a.players * a.long) AS long_sum,
               SUM(a.players) AS total_sum
          FROM (
        SELECT c.conference_2014 AS conference,
               c.year,
               c.county,
               c.players,
               l.lat,
               l.long
          FROM (SELECT conference_2014,
                       recruited_year AS year,
                       county,
                       COUNT(*) AS players
                  FROM nfl_players_hometowns
                 WHERE conference_2014 IN ('acc','big-ten','big-12','sec','pac-12')
                   AND recruited_year >= 1950
                GROUP BY 1,2,3
               ) c
          JOIN county_locations l
            ON l.county_code = c.county
           AND l.lat >= 24
           AND l.long >= -150
           AND l.long < 0
               ) a
         GROUP BY 1,2
       ) start
  JOIN (
        SELECT a.conference,
               a.year,
               SUM(a.players * a.lat) AS lat_sum,
               SUM(a.players * a.long) AS long_sum,
               SUM(a.players) AS total_sum
          FROM (
        SELECT c.conference_2014 AS conference,
               c.year,
               c.county,
               c.players,
               l.lat,
               l.long
          FROM (SELECT conference_2014,
                       recruited_year AS year,
                       county,
                       COUNT(*) AS players
                  FROM nfl_players_hometowns
                 WHERE conference_2014 IN ('acc','big-ten','big-12','sec','pac-12')
                   AND recruited_year >= 1950
                GROUP BY 1,2,3
               ) c
          JOIN county_locations l
            ON l.county_code = c.county
           AND l.lat >= 24
           AND l.long >= -150
           AND l.long < 0
               ) a
         GROUP BY 1,2
       ) ends
    ON start.year = ends.year
       ) z
 ORDER BY 1

## Distances pivoted

SELECT z.year,
      -- ACC 
       ACOS( COS(RADIANS(90-z.lat_acc)) * COS(RADIANS(90-z.lat_sec)) + SIN(RADIANS(90-z.lat_acc)) * 
         SIN(RADIANS(90-z.lat_sec)) * COS(RADIANS(z.long_acc-z.long_sec)))*6371 AS acc_to_sec,
       ACOS( COS(RADIANS(90-z.lat_acc)) * COS(RADIANS(90-z.lat_pac12)) + SIN(RADIANS(90-z.lat_acc)) * 
         SIN(RADIANS(90-z.lat_pac12)) * COS(RADIANS(z.long_acc-z.long_pac12)))*6371 AS acc_to_pac12,
       ACOS( COS(RADIANS(90-z.lat_acc)) * COS(RADIANS(90-z.lat_big10)) + SIN(RADIANS(90-z.lat_acc)) * 
         SIN(RADIANS(90-z.lat_big10)) * COS(RADIANS(z.long_acc-z.long_big10)))*6371 AS acc_to_big10,
       ACOS( COS(RADIANS(90-z.lat_acc)) * COS(RADIANS(90-z.lat_big12)) + SIN(RADIANS(90-z.lat_acc)) * 
         SIN(RADIANS(90-z.lat_big12)) * COS(RADIANS(z.long_acc-z.long_big12)))*6371 AS acc_to_big12,
       ACOS( COS(RADIANS(90-z.lat_acc)) * COS(RADIANS(90-z.lat_all)) + SIN(RADIANS(90-z.lat_acc)) * 
         SIN(RADIANS(90-z.lat_all)) * COS(RADIANS(z.long_acc-z.long_all)))*6371 AS acc_to_all,
      -- SEC
       ACOS( COS(RADIANS(90-z.lat_sec)) * COS(RADIANS(90-z.lat_pac12)) + SIN(RADIANS(90-z.lat_sec)) * 
         SIN(RADIANS(90-z.lat_pac12)) * COS(RADIANS(z.long_sec-z.long_pac12)))*6371 AS sec_to_pac12,
       ACOS( COS(RADIANS(90-z.lat_sec)) * COS(RADIANS(90-z.lat_big10)) + SIN(RADIANS(90-z.lat_sec)) * 
         SIN(RADIANS(90-z.lat_big10)) * COS(RADIANS(z.long_sec-z.long_big10)))*6371 AS sec_to_big10,
       ACOS( COS(RADIANS(90-z.lat_sec)) * COS(RADIANS(90-z.lat_big12)) + SIN(RADIANS(90-z.lat_sec)) * 
         SIN(RADIANS(90-z.lat_big12)) * COS(RADIANS(z.long_sec-z.long_big12)))*6371 AS sec_to_big12,
       ACOS( COS(RADIANS(90-z.lat_sec)) * COS(RADIANS(90-z.lat_all)) + SIN(RADIANS(90-z.lat_sec)) * 
         SIN(RADIANS(90-z.lat_all)) * COS(RADIANS(z.long_sec-z.long_all)))*6371 AS sec_to_all,
      -- PAC 12
       ACOS( COS(RADIANS(90-z.lat_pac12)) * COS(RADIANS(90-z.lat_big10)) + SIN(RADIANS(90-z.lat_pac12)) * 
         SIN(RADIANS(90-z.lat_big10)) * COS(RADIANS(z.long_pac12-z.long_big10)))*6371 AS pac12_to_big10,
       ACOS( COS(RADIANS(90-z.lat_pac12)) * COS(RADIANS(90-z.lat_big12)) + SIN(RADIANS(90-z.lat_pac12)) * 
         SIN(RADIANS(90-z.lat_big12)) * COS(RADIANS(z.long_pac12-z.long_big12)))*6371 AS pac12_to_big12,
       ACOS( COS(RADIANS(90-z.lat_pac12)) * COS(RADIANS(90-z.lat_all)) + SIN(RADIANS(90-z.lat_pac12)) * 
         SIN(RADIANS(90-z.lat_all)) * COS(RADIANS(z.long_pac12-z.long_all)))*6371 AS pac12_to_all,
      -- BIG 10
       ACOS( COS(RADIANS(90-z.lat_big10)) * COS(RADIANS(90-z.lat_big12)) + SIN(RADIANS(90-z.lat_big10)) * 
         SIN(RADIANS(90-z.lat_big12)) * COS(RADIANS(z.long_big10-z.long_big12)))*6371 AS big10_to_big12,
       ACOS( COS(RADIANS(90-z.lat_big10)) * COS(RADIANS(90-z.lat_all)) + SIN(RADIANS(90-z.lat_big10)) * 
         SIN(RADIANS(90-z.lat_all)) * COS(RADIANS(z.long_big10-z.long_all)))*6371 AS big10_to_all,
      -- BIG 12
       ACOS( COS(RADIANS(90-z.lat_big12)) * COS(RADIANS(90-z.lat_all)) + SIN(RADIANS(90-z.lat_big12)) * 
         SIN(RADIANS(90-z.lat_all)) * COS(RADIANS(z.long_big12-z.long_all)))*6371 AS big12_to_all
  FROM (
SELECT z.year,

       MAX(CASE WHEN z.conference = 'acc' THEN z.conf_lat ELSE NULL END) AS lat_acc,
       MAX(CASE WHEN z.conference = 'acc' THEN z.conf_long ELSE NULL END) AS long_acc,
       MAX(CASE WHEN z.conference = 'sec' THEN z.conf_lat ELSE NULL END) AS lat_sec,
       MAX(CASE WHEN z.conference = 'sec' THEN z.conf_long ELSE NULL END) AS long_sec,
       MAX(CASE WHEN z.conference = 'pac-12' THEN z.conf_lat ELSE NULL END) AS lat_pac12,
       MAX(CASE WHEN z.conference = 'pac-12' THEN z.conf_long ELSE NULL END) AS long_pac12,
       MAX(CASE WHEN z.conference = 'big-ten' THEN z.conf_lat ELSE NULL END) AS lat_big10,
       MAX(CASE WHEN z.conference = 'big-ten' THEN z.conf_long ELSE NULL END) AS long_big10,
       MAX(CASE WHEN z.conference = 'big-12' THEN z.conf_lat ELSE NULL END) AS lat_big12,
       MAX(CASE WHEN z.conference = 'big-12' THEN z.conf_long ELSE NULL END) AS long_big12,
       MAX(CASE WHEN z.conference = 'acc' THEN z.total_lat ELSE NULL END) AS lat_all,
       MAX(CASE WHEN z.conference = 'acc' THEN z.total_long ELSE NULL END) AS long_all
  FROM (
SELECT by_conf.conference,
       by_conf.year,
       by_conf.lat_sum/by_conf.total_sum AS conf_lat,
       by_conf.long_sum/by_conf.total_sum AS conf_long,
       total.lat_sum/total.total_sum AS total_lat,
       total.long_sum/total.total_sum AS total_long
  FROM (
        SELECT a.conference,
               a.year,
               SUM(a.players * a.lat) AS lat_sum,
               SUM(a.players * a.long) AS long_sum,
               SUM(a.players) AS total_sum
          FROM (
        SELECT c.conference_2014 AS conference,
               c.year,
               c.county,
               c.players,
               l.lat,
               l.long
          FROM (SELECT conference_2014,
                       recruited_year AS year,
                       county,
                       COUNT(*) AS players
                  FROM nfl_players_hometowns
                 WHERE conference_2014 IN ('acc','big-ten','big-12','sec','pac-12')
                   AND recruited_year >= 1950
                GROUP BY 1,2,3
               ) c
          JOIN county_locations l
            ON l.county_code = c.county
           AND l.lat >= 24
           AND l.long >= -150
           AND l.long < 0
               ) a
         GROUP BY 1,2
       ) by_conf
  JOIN (SELECT a.year,
               SUM(a.players * a.lat) AS lat_sum,
               SUM(a.players * a.long) AS long_sum,
               SUM(a.players) AS total_sum
          FROM (
        SELECT c.year,
               c.county,
               c.players,
               l.lat,
               l.long
          FROM (SELECT recruited_year AS year,
                       county,
                       COUNT(*) AS players
                  FROM nfl_players_hometowns
                 WHERE conference_2014 IN ('acc','big-ten','big-12','sec','pac-12')
                   AND recruited_year >= 1950
                GROUP BY 1,2
               ) c
          JOIN county_locations l
            ON l.county_code = c.county
           AND l.lat >= 24
           AND l.long >= -150
           AND l.long < 0
               ) a
         GROUP BY 1
       ) total
    ON total.year = by_conf.year
       ) z
 GROUP BY 1
       ) z
 ORDER BY 1 