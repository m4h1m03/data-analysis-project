-- Further analysis of british_airways_reviews: conditional aggregation, CTEs and window functions.
-- Findings (star ratings are on a 1-9 scale):
--   * The recommendation rate by traveller type is 34.0% to 36.4% (overall 35.2%). With about
--     500 reviews per group, a spread of that size is within random variation.
--   * Ranking seat types by average rating within each year, with no minimum group size,
--     produces noisy winners: averages up to 6.00 based on as few as 2 reviews.
--   * With a minimum of 31 reviews per group, Economy wins 5 years, Premium Economy 2 and
--     Business 2. First Class never qualifies (135 reviews across nine years), so the filter
--     removes it from every ranking. The winning averages (4.25 to 4.66) sit close to the
--     overall 4.27, which fits seat type not predicting the rating. The threshold of 31 is
--     arbitrary, and a different one would change some winners.

-- Percentage of reviewers who recommend British Airways, by traveller type
-- (expected: Couple Leisure 34.00, Solo Leisure 35.20, Business 36.40, Family Leisure 36.40)
SELECT
  type_of_traveller,
  ROUND(AVG(
    CASE
      WHEN recommended = 'yes' THEN 1
      ELSE 0
    END
  ) * 100, 2) AS percent_recommended,
  COUNT(*) AS review_count
FROM british_airways_reviews
GROUP BY type_of_traveller
ORDER BY percent_recommended;

-- Average star rating and review count for each combination of year and seat type
-- (expected: 36 rows)
SELECT
  EXTRACT(YEAR FROM review_date) AS year,
  seat_type,
  ROUND(AVG(stars), 2) AS average_star_rating,
  COUNT(*) AS review_count
FROM british_airways_reviews
GROUP BY year, seat_type
ORDER BY year;

-- Top-ranked seat type per year by average rating, with no minimum group size
-- (expected: 9 rows; some winners rest on very few reviews)
WITH yearly AS (
  SELECT
    EXTRACT(YEAR FROM review_date) AS year,
    seat_type,
    ROUND(AVG(stars), 2) AS average_star_rating,
    COUNT(*) AS review_count
  FROM british_airways_reviews
  GROUP BY year, seat_type
),
ranked AS (
  SELECT
    year,
    seat_type,
    average_star_rating,
    review_count,
    RANK() OVER (
      PARTITION BY year
      ORDER BY average_star_rating DESC
    ) AS rank_in_year
  FROM yearly
)
SELECT
  year,
  seat_type,
  average_star_rating,
  review_count
FROM ranked
WHERE rank_in_year = 1
ORDER BY year;

-- The same ranking, but only for groups with more than 30 reviews
-- HAVING filters before the ranking, so small groups cannot take rank 1
-- (expected: 9 rows, none with fewer than 31 reviews)
WITH
  yearly AS (
    SELECT
      EXTRACT(YEAR FROM review_date) AS year,
      seat_type,
      ROUND(AVG(stars), 2) AS average_star_rating,
      COUNT(*) AS review_count
    FROM british_airways_reviews
    GROUP BY year, seat_type
    HAVING COUNT(*) > 30
  ),
  ranked AS (
    SELECT
      year,
      seat_type,
      average_star_rating,
      review_count,
      RANK() OVER (
        PARTITION BY year
        ORDER BY average_star_rating DESC
      ) AS rank_in_year
    FROM yearly
  )
SELECT
  year,
  seat_type,
  average_star_rating,
  review_count,
  rank_in_year
FROM ranked
WHERE rank_in_year = 1
ORDER BY year;
