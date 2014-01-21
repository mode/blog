# School diversity

SELECT z.school,
       SUM(z.power) AS concentration_score
  FROM (
SELECT a.school,
       (a.state_players*1.0/a.all_players) *
       (a.state_players*1.0/a.all_players) AS power
  FROM (
SELECT p.school,
       p.state_code,
       c.players AS all_players,
       COUNT(*) AS state_players
  FROM states p
  JOIN (SELECT c.school,
               COUNT(*) AS players
          FROM states c
         GROUP BY 1
       ) c
    ON c.school = p.school
 GROUP BY 1,2,3
       ) a
       ) z 
 GROUP BY 1