-- Playoff Appearances in the last ten years --

SELECT team,
       COUNT(*),
       SUM(games_played)
  FROM playoff_results
 WHERE league = 'mlb'
   AND year >= 2003
   AND year < 2013
 GROUP BY 1
 ORDER BY 2 DESC
 
-- Playoff participation of all championship participants  



SELECT a.year,
       mlb.sp AS mlb_series_played,
       nfl.sp AS nfl_series_played,
       nba.sp AS nba_series_played,
       mlb.gp AS mlb_games_played,
       nfl.gp AS nfl_games_played,
       nba.gp AS nba_games_played,
       mlb.poss_sp AS mlb_possible_series,
       nfl.poss_sp AS nfl_possible_series,
       nba.poss_sp AS nba_possible_series
  FROM (SELECT a.id AS year
          FROM playoff_results a
         WHERE a.id >= 1900
           AND a.id <= 2013
       ) a
  LEFT JOIN (
  -- MLB results --  
        SELECT f.year,
               COUNT(h.id) AS sp,
               SUM(h.games_played) AS gp,
               COUNT(h.id)/MAX(p.possible_series)::FLOAT AS poss_sp,
               COUNT(h.id)/MAX(p.all_series)::FLOAT AS all_sp,
               SUM(h.games_played)/MAX(p.games_played)::FLOAT AS poss_gp
          FROM playoff_results f
          JOIN (SELECT y.year,
                       COUNT(DISTINCT py.year || py.series) + COUNT(DISTINCT py.year) AS possible_series
                  FROM playoff_results y
                  JOIN playoff_results py
                    ON py.league = y.league
                   AND py.year < y.year
                   AND py.year >= y.year - 10
                 WHERE y.series = 'ws'
                   AND y.won_series = 1
                   AND y.league = 'mlb'
                 GROUP BY 1
               ) p
            ON p.year = f.year
          LEFT JOIN playoff_results h
            ON h.league = f.league 
           AND h.team = f.team
           AND h.year < f.year
           AND h.year >= f.year - 10
         WHERE f.series = 'ws'
           AND f.league = 'mlb'
         GROUP BY 1
       ) mlb
    ON mlb.year = a.year
  LEFT JOIN (
  -- NFL Results -- 
       SELECT f.year,
              COUNT(h.id) AS sp,
              SUM(h.games_played) AS gp,
              COUNT(h.id)/MAX(p.possible_series)::FLOAT AS poss_sp
         FROM playoff_results f
         JOIN (SELECT y.year,
                      COUNT(DISTINCT py.year || py.series) - COUNT(DISTINCT py.year) AS possible_series
                 FROM playoff_results y
                 JOIN playoff_results py
                   ON py.league = y.league
                  AND py.year < y.year
                  AND py.year >= y.year - 10
                WHERE y.series = 'sb'
                  AND y.won_series = 1
                  AND y.league = 'nfl'
                GROUP BY 1
              ) p
           ON p.year = f.year
         LEFT JOIN playoff_results h
           ON h.league = f.league 
          AND h.team = f.team
          AND h.year < f.year
          AND h.year >= f.year - 10
        WHERE f.series = 'sb'
          AND f.league = 'nfl'
        GROUP BY 1
       ) nfl
    ON nfl.year = a.year
  LEFT JOIN (
  -- NBA results --
       SELECT f.year,
              COUNT(h.id) AS sp,
              SUM(h.games_played) AS gp,
              COUNT(h.id)/MAX(p.possible_series)::FLOAT AS poss_sp
         FROM playoff_results f
         JOIN (SELECT y.year,
                      COUNT(DISTINCT py.year || py.series) + COUNT(DISTINCT py.year) AS possible_series
                 FROM playoff_results y
                 JOIN playoff_results py
                   ON py.league = y.league
                  AND py.year < y.year
                  AND py.year >= y.year - 10
                WHERE y.series = 'finals'
                  AND y.won_series = 1
                  AND y.league = 'nba'
                GROUP BY 1
              ) p
           ON p.year = f.year
         LEFT JOIN playoff_results h
           ON h.league = f.league 
          AND h.team = f.team
          AND h.year < f.year
          AND h.year >= f.year - 10
        WHERE f.series = 'finals'
          AND f.league = 'nba'
        GROUP BY 1
       ) nba
    ON nba.year = a.year 
 ORDER BY a.year
