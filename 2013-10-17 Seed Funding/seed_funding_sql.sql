# Deal Count and Round Size

SELECT DATE_TRUNC('quarter',c.first_funding_at) AS quarter,
       COUNT(DISTINCT c.permalink) AS companies,
       COUNT(DISTINCT CASE WHEN i.vc_company = 1 THEN c.permalink ELSE NULL END) AS vc_companies,
       COUNT(DISTINCT CASE WHEN i.vc_company = 0 THEN c.permalink ELSE NULL END) AS non_vc_companies,
       SUM(i.round_size) AS total_round,
       SUM(CASE WHEN i.vc_company = 1 THEN i.round_size ELSE 0 END) AS vc_total_round,
       SUM(CASE WHEN i.vc_company = 0 THEN i.round_size ELSE 0 END) AS non_vc_total_round
  FROM crunchbase_companies_oct_2013 c
  JOIN (
        SELECT i.company_permalink,
               i.funded_at,
               i.funding_round_type,
               COUNT(DISTINCT i.investor_permalink) AS investors,
               SUM(i.raised_amount_usd) AS round_size,
               MAX(CASE WHEN i.investor_permalink LIKE '%financial-organization%' THEN 1 ELSE 0 END) AS vc_company
          FROM crunchbase_investments_oct_2013 i
         WHERE i.funded_at >= '2008-01-01'
         GROUP BY 1,2,3
       ) i
    ON i.company_permalink = c.permalink
   AND i.funded_at = c.first_funding_at
   AND i.round_size <= 4000000
 GROUP BY 1
 ORDER BY 1

# Follow-on Rounds

SELECT DATE_TRUNC('quarter',c.first_funding_at) AS quarter,
       COUNT(DISTINCT CASE WHEN i.round_size >  4000000 THEN c.permalink ELSE NULL END) AS no_seed,
       COUNT(DISTINCT CASE WHEN i.round_size <= 4000000 AND i.vc_company = 1 THEN c.permalink ELSE NULL END) AS raised_vc_seed,
       COUNT(DISTINCT CASE WHEN i.round_size <= 4000000 AND i.vc_company = 0 THEN c.permalink ELSE NULL END) AS raised_non_vc_seed,
       COUNT(DISTINCT CASE WHEN i.round_size >  4000000 AND c.funding_rounds > 1 THEN c.permalink ELSE NULL END) AS no_seed_f,
       COUNT(DISTINCT CASE WHEN i.round_size <= 4000000 AND i.vc_company = 1 AND c.funding_rounds > 1 THEN c.permalink ELSE NULL END) AS raised_vc_seed_f,
       COUNT(DISTINCT CASE WHEN i.round_size <= 4000000 AND i.vc_company = 0 AND c.funding_rounds > 1 THEN c.permalink ELSE NULL END) AS raised_non_vc_seed_f
  FROM crunchbase_companies_oct_2013 c
  JOIN (
        SELECT i.company_permalink,
               i.funded_at,
               i.funding_round_type,
               COUNT(DISTINCT i.investor_permalink) AS investors,
               SUM(i.raised_amount_usd) AS round_size,
               MAX(CASE WHEN i.investor_permalink LIKE '%financial-organization%' THEN 1 ELSE 0 END) AS vc_company
          FROM crunchbase_investments_oct_2013 i
         WHERE i.funded_at >= '2008-01-01'
         GROUP BY 1,2,3
       ) i
    ON i.company_permalink = c.permalink
   AND i.funded_at = c.first_funding_at
   AND i.round_size IS NOT NULL
 GROUP BY 1
 ORDER BY 1 

# Size of rounds by company

SELECT a.name,
       CASE WHEN a.raised_amount_usd >  4000000 AND a.round = 1 THEN 'no seed' 
            WHEN a.raised_amount_usd <= 4000000 AND a.round = 1 AND a.vc_company = 1 THEN 'vc seed'
            WHEN a.raised_amount_usd <= 4000000 AND a.round = 1 AND a.vc_company = 0 THEN 'no vc'
            ELSE 'WTF LOL' END AS type,
       MAX(CASE WHEN a.round = 1 THEN a.raised_amount_usd ELSE NULL END) AS round_1,
       MAX(CASE WHEN a.round = 2 THEN a.raised_amount_usd ELSE NULL END) AS round_2
  FROM ( 
        SELECT c.permalink,
               c.name,
               i.vc_company,
               c.funding_rounds,
               r.raised_amount_usd,
               r.funded_at,
               ROW_NUMBER() OVER (PARTITION BY c.permalink ORDER BY r.funded_at) AS round
          FROM crunchbase_companies_oct_2013 c
          JOIN (
                SELECT i.company_permalink,
                       i.funded_at,
                       SUM(i.raised_amount_usd) AS round_size,
                       MAX(CASE WHEN i.investor_permalink LIKE '%financial-organization%' THEN 1 ELSE 0 END) AS vc_company
                  FROM crunchbase_investments_oct_2013 i
                 WHERE i.funded_at >= '2008-01-01'
                 GROUP BY 1,2
               ) i
            ON i.company_permalink = c.permalink
           AND i.funded_at = c.first_funding_at
           AND i.round_size IS NOT NULL
          JOIN crunchbase_rounds_oct_2013 r
            ON r.company_permalink = c.permalink
         WHERE c.first_funding_at >= '2009-01-01'
           AND c.funding_rounds > 1
       ) a
 GROUP BY 1,2

# Round growth rate 

SELECT ROUND(z.round_1,-6) AS bucket,
       AVG(z.round_2/z.round_1) AS avg_growth
  FROM (

SELECT a.name,
       a.type,
       MAX(CASE WHEN a.round = 1 THEN a.raised_amount_usd ELSE NULL END) AS round_1,
       MAX(CASE WHEN a.round = 2 THEN a.raised_amount_usd ELSE NULL END) AS round_2
  FROM ( 
        SELECT c.permalink,
               c.name,
               CASE WHEN i.round_size >  4000000 THEN 'no seed' 
                    WHEN i.round_size <= 4000000 AND i.vc_company = 1 THEN 'vc seed'
                    WHEN i.round_size <= 4000000 AND i.vc_company = 0 THEN 'no vc'
                    ELSE 'WTF LOL' END AS type,
               c.funding_rounds,
               r.raised_amount_usd,
               r.funded_at,
               ROW_NUMBER() OVER (PARTITION BY c.permalink ORDER BY r.funded_at) AS round
          FROM crunchbase_companies_oct_2013 c
          JOIN (
                SELECT i.company_permalink,
                       i.funded_at,
                       SUM(i.raised_amount_usd) AS round_size,
                       MAX(CASE WHEN i.investor_permalink LIKE '%financial-organization%' THEN 1 ELSE 0 END) AS vc_company
                  FROM crunchbase_investments_oct_2013 i
                 WHERE i.funded_at >= '2008-01-01'
                 GROUP BY 1,2
               ) i
            ON i.company_permalink = c.permalink
           AND i.funded_at = c.first_funding_at
           AND i.round_size IS NOT NULL
          JOIN crunchbase_rounds_oct_2013 r
            ON r.company_permalink = c.permalink
         WHERE c.first_funding_at >= '2009-01-01'
           AND c.funding_rounds > 1
       ) a
 GROUP BY 1,2,3,4
       ) z
 GROUP BY 1