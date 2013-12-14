## Average number of funding rounds

SELECT a.founded_year,
       COUNT(CASE WHEN a.stanford = TRUE THEN a.company_permalink ELSE NULL END) AS stanford_companies,
       COUNT(CASE WHEN a.stanford = FALSE THEN a.company_permalink ELSE NULL END) AS non_stanford_companies,
       AVG(CASE WHEN a.stanford = TRUE THEN a.funding_rounds ELSE NULL END) AS stanford_rounds,
       AVG(CASE WHEN a.stanford = FALSE THEN a.funding_rounds ELSE NULL END) AS non_stanford_rounds
  FROM (SELECT c.permalink AS company_permalink,
               c.funding_rounds,
               c.founded_year,
               c.funding_total_usd,
               c.status,
               CASE WHEN d.permalink IS NOT NULL THEN TRUE ELSE FALSE END AS stanford,
               d.permalink,
               MAX(d.degree_code) AS degree
          FROM derek.crunchbase_companies c
          LEFT JOIN benn.dimension_relationships r
            ON '/company/' || r.company_permalink = c.permalink
           AND r.title ILIKE '%founder%'
          LEFT JOIN (
                     SELECT d.permalink,
                            d.year,
                            CASE WHEN d.degree LIKE '%P%' THEN 5
                                 WHEN d.degree LIKE '%M%' AND degree LIKE '%B%' THEN 4
                                 WHEN d.degree LIKE '%J%' THEN 3
                                 WHEN (d.degree LIKE '%M%' AND d.degree NOT LIKE '%B%')
                                   OR  d.degree LIKE '%G%' THEN 2
                                 WHEN d.degree LIKE '%B%' AND d.degree NOT LIKE '%M%' THEN 1
                                 ELSE 0 END AS degree_code
                        FROM benn.crunchbase_stanford_degrees d
                       WHERE d.institution ILIKE '%stanford%'
               ) d
            ON d.permalink = r.permalink
         WHERE c.funding_rounds > 0
           AND c.founded_year >= 2009
           AND c.founded_year <= 2012
         GROUP BY 1,2,3,4,5,6,7
       ) a
 GROUP BY 1
 ORDER BY 1

## Current status of companies by founder

SELECT a.stanford,
       COUNT(*) AS all_companies,
       COUNT(CASE WHEN a.status = 'operating' THEN a.company_permalink ELSE NULL END) AS operating,
       COUNT(CASE WHEN a.status = 'closed' THEN a.company_permalink ELSE NULL END) AS closed,
       COUNT(CASE WHEN a.status = 'acquired' THEN a.company_permalink ELSE NULL END) AS acquired,
       COUNT(CASE WHEN a.status = 'ipo' THEN a.company_permalink ELSE NULL END) AS ipo
  FROM (SELECT c.permalink AS company_permalink,
               c.funding_rounds,
               c.founded_year,
               c.funding_total_usd,
               c.status,
               CASE WHEN d.permalink IS NOT NULL THEN 1 ELSE 0 END AS stanford,
               d.permalink,
               MAX(d.degree_code) AS degree
          FROM derek.crunchbase_companies c
          LEFT JOIN benn.dimension_relationships r
            ON '/company/' || r.company_permalink = c.permalink
           AND title ILIKE '%founder%'
          LEFT JOIN (
                     SELECT d.permalink,
                            d.year,
                            CASE WHEN d.degree LIKE '%P%' THEN 5
                                 WHEN d.degree LIKE '%M%' AND degree LIKE '%B%' THEN 4
                                 WHEN d.degree LIKE '%J%' THEN 3
                                 WHEN (d.degree LIKE '%M%' AND d.degree NOT LIKE '%B%')
                                   OR  d.degree LIKE '%G%' THEN 2
                                 WHEN d.degree LIKE '%B%' AND d.degree NOT LIKE '%M%' THEN 1
                                 ELSE 0 END AS degree_code
                        FROM benn.crunchbase_stanford_degrees d
                       WHERE d.institution ILIKE '%stanford%'
               ) d
            ON d.permalink = r.permalink
         WHERE c.funding_rounds > 0
           AND founded_year >= 2003
         GROUP BY 1,2,3,4,5,6,7
       ) a
 GROUP BY 1

## Acquisition price for companies

SELECT a.stanford,
       COUNT(*) AS all_companies,
       AVG(a.price) AS all_price_avg,
       AVG(CASE WHEN a.med > .45 AND a.med < .55 THEN a.price ELSE NULL END) AS median_ish,
       COUNT(CASE WHEN a.med > .45 AND a.med < .55 THEN a.price ELSE NULL END) AS median_ish_count
  FROM (SELECT *,
               PERCENT_RANK() OVER (PARTITION BY z.stanford ORDER BY z.price) AS med
          FROM (  
        SELECT c.permalink AS company_permalink,
               c.funding_rounds,
               c.founded_year,
               c.funding_total_usd,
               c.status,
               a.price,
               CASE WHEN d.permalink IS NOT NULL THEN TRUE ELSE FALSE END AS stanford,
               d.permalink,
               MAX(d.degree_code) AS degree
          FROM derek.crunchbase_companies c
          JOIN (SELECT a.company_permalink,
                       MAX(a.price_amount) AS price
                  FROM derek.crunchbase_acquisitions a
                 GROUP BY 1
               ) a
            ON a.company_permalink = c.permalink
           AND a.price IS NOT NULL
          LEFT JOIN benn.dimension_relationships r
            ON '/company/' || r.company_permalink = c.permalink
           AND r.title ILIKE '%founder%'
          LEFT JOIN (
                     SELECT d.permalink,
                            d.year,
                            CASE WHEN d.degree LIKE '%P%' THEN 5
                                 WHEN d.degree LIKE '%M%' AND degree LIKE '%B%' THEN 4
                                 WHEN d.degree LIKE '%J%' THEN 3
                                 WHEN (d.degree LIKE '%M%' AND d.degree NOT LIKE '%B%')
                                   OR  d.degree LIKE '%G%' THEN 2
                                 WHEN d.degree LIKE '%B%' AND d.degree NOT LIKE '%M%' THEN 1
                                 ELSE 0 END AS degree_code
                        FROM benn.crunchbase_stanford_degrees d
                       WHERE d.institution ILIKE '%stanford%'
               ) d
            ON d.permalink = r.permalink
         WHERE c.funding_rounds > 0
           AND founded_year >= 2003
         GROUP BY 1,2,3,4,5,6,7,8
       ) z
       ) a
 GROUP BY 1

 d
 
## ff

SELECT a.stanford,
       a.funding_round_type,       
       COUNT(DISTINCT a.company_permalink) AS companies,
       AVG(CASE WHEN a.pr > .4 AND a.pr < .6 THEN a.raised_amount_usd ELSE NULL END) AS median_ish,
       AVG(a.raised_amount_usd) AS average,
       AVG(a.round_number) AS round_number
  FROM (SELECT *,
               PERCENT_RANK() OVER (PARTITION BY a.stanford, a.funding_round_type ORDER BY a.raised_amount_usd) AS pr
  FROM (SELECT c.permalink AS company_permalink,
               c.funding_rounds,
               c.founded_year,
               c.status,
               round.round_number,
               round.funding_round_type,
               round.raised_amount_usd,
               CASE WHEN d.permalink IS NOT NULL THEN TRUE ELSE FALSE END AS stanford,
               d.permalink,
               MAX(d.degree_code) AS degree
          FROM derek.crunchbase_companies c
          JOIN (SELECT round.company_permalink,
                       round.funding_round_type,
                       round.raised_amount_usd,
                       ROW_NUMBER() OVER (PARTITION BY round.company_permalink ORDER BY round.funded_at) AS round_number
                  FROM derek.crunchbase_rounds round
               ) round
            ON round.company_permalink = c.permalink
          LEFT JOIN benn.dimension_relationships r
            ON '/company/' || r.company_permalink = c.permalink
           AND r.title ILIKE '%founder%'
          LEFT JOIN (
                     SELECT d.permalink,
                            d.year,
                            CASE WHEN d.degree LIKE '%P%' THEN 5
                                 WHEN d.degree LIKE '%M%' AND degree LIKE '%B%' THEN 4
                                 WHEN d.degree LIKE '%J%' THEN 3
                                 WHEN (d.degree LIKE '%M%' AND d.degree NOT LIKE '%B%')
                                   OR  d.degree LIKE '%G%' THEN 2
                                 WHEN d.degree LIKE '%B%' AND d.degree NOT LIKE '%M%' THEN 1
                                 ELSE 0 END AS degree_code
                        FROM benn.crunchbase_stanford_degrees d
                       WHERE d.institution ILIKE '%stanford%'
               ) d
            ON d.permalink = r.permalink
         WHERE c.funding_rounds > 0
           AND c.founded_year >= 2003
         GROUP BY 1,2,3,4,5,6,7,8,9
       ) a
       ) a
 GROUP BY 1,2