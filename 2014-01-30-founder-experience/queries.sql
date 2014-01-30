## Company Success By Founder Experience

SELECT CASE WHEN z.founded_order < 5 THEN z.founded_order ELSE 5 END AS founded,
       COUNT(z.person_permalink) AS people,
       AVG(z.funding_rounds) AS avg_funding_rounds,
       COUNT(CASE WHEN z.exit IN ('acquired','ipo') THEN z.person_permalink ELSE NULL END)/
          COUNT(z.person_permalink)::FLOAT AS exit_percent,
       COUNT(CASE WHEN z.big_exit = TRUE THEN z.person_permalink ELSE NULL END)/
          COUNT(z.person_permalink)::FLOAT AS big_exit_percent
  FROM (
        SELECT p.person_name,
               p.person_permalink,
               r.title,
               c.company_name,
               c.total_money_raised,
               CASE WHEN c.funding_rounds IS NULL THEN 0 ELSE c.funding_rounds END AS funding_rounds,
               c.founded_date,
               c.exit,
               CASE WHEN a.price IS NOT NULL OR c.exit = 'ipo' THEN TRUE ELSE FALSE END AS big_exit,
               RANK() OVER (PARTITION BY p.person_permalink ORDER BY c.founded_date) AS founded_order,
               COUNT(*) OVER (PARTITION BY p.person_permalink) AS companies_founded
          FROM crunchbase_dimension_people p
          JOIN crunchbase_dimension_relationships r
            ON r.person_permalink = p.person_permalink
           AND r.entity_type = 'company'
           AND r.title ILIKE '%founder%'
          JOIN crunchbase_dimension_companies c
            ON c.company_permalink = r.entity_permalink
           AND c.founded_date >= '1900-01-01'
          LEFT JOIN crunchbase_dimension_acquisitions a
            ON a.company_permalink = c.company_permalink
           AND c.exit = 'acquired'
           AND a.price_currency_code = 'USD'
           AND a.price >= 100000000
       ) z
 WHERE z.founded_date >= '2005-01-01'
   AND z.founded_date <= '2013-07-01'
 GROUP BY 1
 ORDER BY 1
LIMIT 100


## Company Success By Company Experience

SELECT CASE WHEN z.previous_companies > 3 THEN 4 ELSE z.previous_companies END AS previous_companies,
       COUNT(z.company_permalink) AS companies,
       AVG(z.funding_rounds) AS avg_funding_rounds,
       COUNT(CASE WHEN z.exit IN ('acquired','ipo') THEN z.company_permalink ELSE NULL END)/
        COUNT(z.company_permalink)::FLOAT AS exit_percent,
       COUNT(CASE WHEN z.big_exit = TRUE THEN z.company_permalink ELSE NULL END)/
        COUNT(z.company_permalink)::FLOAT AS big_exit_percent
  FROM (
SELECT a.company_permalink,
       a.total_money_raised,
       CASE WHEN a.funding_rounds IS NULL THEN 0 ELSE a.funding_rounds END AS funding_rounds,
       a.founded_date,
       a.exit,
       a.big_exit,
       COUNT(*) AS founders,
       MAX(a.previous_companies) AS previous_companies,
       MAX(a.age) AS age
  FROM (
SELECT c.company_permalink,
       c.total_money_raised,
       c.funding_rounds,
       c.founded_date,
       c.exit,
       c.big_exit,
       c.person_permalink,
       CASE WHEN c.born_year = 1900 THEN NULL ELSE c.founded_year - c.born_year END AS age,
       COUNT(DISTINCT prev.company_permalink) AS previous_companies
  FROM (SELECT r.person_permalink,
               p.born_year,
               c.company_permalink,
               c.total_money_raised,
               c.funding_rounds,
               c.founded_date,
               c.founded_year,
               c.exit,
               CASE WHEN a.price IS NOT NULL OR c.exit = 'ipo' THEN TRUE ELSE FALSE END AS big_exit
          FROM crunchbase_dimension_companies c
          JOIN crunchbase_dimension_relationships r
            ON r.entity_permalink = c.company_permalink
           AND r.entity_type = 'company'
           AND r.title ILIKE '%founder%'
          JOIN crunchbase_dimension_people p
            ON p.person_permalink = r.person_permalink
          LEFT JOIN crunchbase_dimension_acquisitions a
            ON a.company_permalink = c.company_permalink
           AND c.exit = 'acquired'
           AND a.price_currency_code = 'USD'
           AND a.price >= 100000000
       ) c
  LEFT JOIN (SELECT r.person_permalink,
                    c.company_permalink,
                    c.total_money_raised,
                    c.funding_rounds,
                    c.founded_date,
                    c.exit
               FROM crunchbase_dimension_companies c
               JOIN crunchbase_dimension_relationships r
                 ON r.entity_permalink = c.company_permalink
                AND r.entity_type = 'company'
                AND r.title ILIKE '%founder%'
       ) prev
    ON prev.person_permalink = c.person_permalink
   AND prev.company_permalink != c.company_permalink
   AND prev.founded_date < c.founded_date
   AND prev.founded_date >= '1900-01-01'
 GROUP BY 1,2,3,4,5,6,7,8
       ) a
 WHERE a.founded_date >= '2005-01-01'
   AND a.founded_date <= '2013-07-01'
 GROUP BY 1,2,3,4,5,6
       ) z
 GROUP BY 1
 ORDER BY 1
LIMIT 100

## Success of Previous Companies

SELECT CASE WHEN z.companies_founded < 5 THEN z.companies_founded ELSE 5 END AS companies_founded,
       CASE WHEN z.founded_order < 5 THEN z.founded_order ELSE 5 END AS founded_order,
       AVG(z.funding_rounds) AS rounds,
       COUNT(z.person_permalink) AS people,
       COUNT(CASE WHEN z.exit IN ('acquired','ipo') THEN z.person_permalink ELSE NULL END)/
          COUNT(z.person_permalink)::FLOAT AS exit_percent
  FROM (
SELECT p.person_name,
       p.person_permalink,
       r.title,
       c.company_name,
       c.total_money_raised,
       c.funding_rounds,
       c.founded_date,
       c.exit,
       RANK() OVER (PARTITION BY p.person_permalink ORDER BY c.founded_date) AS founded_order,
       COUNT(*) OVER (PARTITION BY p.person_permalink) AS companies_founded
  FROM crunchbase_dimension_people p
  JOIN crunchbase_dimension_relationships r
    ON r.person_permalink = p.person_permalink
   AND r.entity_type = 'company'
   AND r.title ILIKE '%founder%'
  JOIN crunchbase_dimension_companies c
    ON c.company_permalink = r.entity_permalink
   AND c.founded_date >= '1900-01-01'
       ) z
 WHERE z.founded_date >= '2005-01-01'
   AND z.founded_date <= '2013-07-01'
 GROUP BY 1,2
 ORDER BY 1,2
LIMIT 100

## Success of Successful Founders

SELECT preivous_acquired,
       COUNT(z.person_permalink) AS instances,
       AVG(z.funding_rounds) AS rounds,
       COUNT(CASE WHEN z.exit IN ('acquired','ipo') THEN z.person_permalink ELSE NULL END)/
          COUNT(z.person_permalink)::FLOAT AS exit_percent
  FROM (
SELECT c.person_permalink,
       c.company_permalink,
       c.funding_rounds,
       c.founded_date,
       c.exit,
       c.founded_order,
       c.companies_founded,
       COUNT(p.company_permalink) AS previous_companies,
       MAX(CASE WHEN p.exit IN ('acquired','ipo') THEN 1 
                WHEN p.exit IS NOT NULL THEN 0
                ELSE -1 END) AS preivous_acquired
  FROM (
        SELECT p.person_permalink,
               c.company_permalink,
               c.funding_rounds,
               c.founded_date,
               c.exit,
               RANK() OVER (PARTITION BY p.person_permalink ORDER BY c.founded_date) AS founded_order,
               COUNT(*) OVER (PARTITION BY p.person_permalink) AS companies_founded
          FROM crunchbase_dimension_people p
          JOIN crunchbase_dimension_relationships r
            ON r.person_permalink = p.person_permalink
           AND r.entity_type = 'company'
           AND r.title ILIKE '%founder%'
          JOIN crunchbase_dimension_companies c
            ON c.company_permalink = r.entity_permalink
           AND c.founded_date >= '1900-01-01'
       ) c
  LEFT JOIN (SELECT p.person_permalink,
                    c.company_permalink,
                    c.funding_rounds,
                    c.exit,
                    RANK() OVER (PARTITION BY p.person_permalink ORDER BY c.founded_date) AS founded_order,
                    COUNT(*) OVER (PARTITION BY p.person_permalink) AS companies_founded
               FROM crunchbase_dimension_people p
               JOIN crunchbase_dimension_relationships r
                 ON r.person_permalink = p.person_permalink
                AND r.entity_type = 'company'
                AND r.title ILIKE '%founder%'
               JOIN crunchbase_dimension_companies c
                 ON c.company_permalink = r.entity_permalink
                AND c.founded_date >= '1900-01-01'
       ) p
    ON p.person_permalink = c.person_permalink
   AND p.founded_order < c.founded_order
 GROUP BY 1,2,3,4,5,6,7
       ) z
 WHERE z.founded_date >= '2005-01-01'
   AND z.founded_date <= '2013-07-01'
 GROUP BY 1
 ORDER BY 1
LIMIT 100

## Age

SELECT CASE WHEN ROUND(age/10)*10 > 59 THEN 50 ELSE ROUND(age/10)*10 END AS age,
       COUNT(CASE WHEN z.founded_order > 1 THEN z.person_permalink ELSE NULL END) AS people_not_first,
       COUNT(CASE WHEN z.founded_order = 1 THEN z.person_permalink ELSE NULL END) AS people_first,
       AVG(CASE WHEN z.founded_order > 1 THEN z.funding_rounds ELSE NULL END) AS avg_funding_rounds_not_first,
       AVG(CASE WHEN z.founded_order = 1 THEN z.funding_rounds ELSE NULL END) AS avg_funding_rounds_first,
       COUNT(CASE WHEN z.founded_order > 1 AND z.exit IN ('acquired','ipo') THEN z.person_permalink ELSE NULL END)/
          COUNT(CASE WHEN z.founded_order > 1 THEN z.person_permalink ELSE NULL END)::FLOAT AS exit_percent_not_first,
       COUNT(CASE WHEN z.founded_order = 1 AND z.exit IN ('acquired','ipo') THEN z.person_permalink ELSE NULL END)/
          COUNT(CASE WHEN z.founded_order = 1 THEN z.person_permalink ELSE NULL END)::FLOAT AS exit_percent_first,
       COUNT(CASE WHEN z.founded_order > 1 AND z.big_exit = TRUE THEN z.person_permalink ELSE NULL END)/
          COUNT(CASE WHEN z.founded_order > 1 THEN z.person_permalink ELSE NULL END)::FLOAT AS big_exit_percent_not_first,
       COUNT(CASE WHEN z.founded_order = 1 AND z.big_exit = TRUE THEN z.person_permalink ELSE NULL END)/
          COUNT(CASE WHEN z.founded_order = 1 THEN z.person_permalink ELSE NULL END)::FLOAT AS big_exit_percent_first
  FROM (
        SELECT p.person_name,
               p.person_permalink,
               CASE WHEN p.born_year = 1900 THEN 0 ELSE c.founded_year - p.born_year END AS age,
               r.title,
               c.company_name,
               c.total_money_raised,
               CASE WHEN c.funding_rounds IS NULL THEN 0 ELSE c.funding_rounds END AS funding_rounds,
               c.founded_date,
               c.exit,
               CASE WHEN a.price IS NOT NULL OR c.exit = 'ipo' THEN TRUE ELSE FALSE END AS big_exit,
               RANK() OVER (PARTITION BY p.person_permalink ORDER BY c.founded_date) AS founded_order,
               COUNT(*) OVER (PARTITION BY p.person_permalink) AS companies_founded
          FROM crunchbase_dimension_people p
          JOIN crunchbase_dimension_relationships r
            ON r.person_permalink = p.person_permalink
           AND r.entity_type = 'company'
           AND r.title ILIKE '%founder%'
          JOIN crunchbase_dimension_companies c
            ON c.company_permalink = r.entity_permalink
           AND c.founded_date >= '1900-01-01'
          LEFT JOIN crunchbase_dimension_acquisitions a
            ON a.company_permalink = c.company_permalink
           AND c.exit = 'acquired'
           AND a.price_currency_code = 'USD'
           AND a.price >= 100000000
       ) z
 WHERE z.founded_date >= '2005-01-01'
   AND z.founded_date <= '2013-07-01'
   AND z.age >= 20
   AND z.age <= 100
 GROUP BY 1
 ORDER BY 1
LIMIT 100