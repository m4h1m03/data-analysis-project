-- Exploring the british_airways_reviews table (Supabase / Postgres)
-- Findings:
--   * 2,500 rows.
--   * stars only takes the odd values 1, 3, 5, 7 and 9, so it is a 1-9 scale, not 1-5.
--     The 4.27 average is therefore not comparable to a normal 5-star average.
--   * Several counts are suspiciously round (227 reviews each for ratings 1, 7 and 9;
--     1000/500/500/500 by traveller type), which suggests the data was sampled to fixed quotas.
--   * type_of_traveller, recommended and seat_type have no NULLs or inconsistent spellings.

-- Total number of reviews (expected: 2500)
SELECT COUNT(*)
FROM british_airways_reviews;

-- Star rating summary (expected: 1 / 9 / 4.27)
SELECT
  MIN(stars) AS lowest_star_rating,
  MAX(stars) AS highest_star_rating,
  ROUND(AVG(stars), 2) AS average_star_rating
FROM british_airways_reviews;

-- Rating distribution: which star values exist and how often
SELECT
  stars,
  COUNT(*)
FROM british_airways_reviews
GROUP BY stars
ORDER BY COUNT(*) DESC;

-- Reviews per traveller type
SELECT
  type_of_traveller,
  COUNT(*)
FROM british_airways_reviews
GROUP BY 1
ORDER BY 2 DESC;

-- Reviews per recommended value (yes / no)
SELECT
  recommended,
  COUNT(*)
FROM british_airways_reviews
GROUP BY 1
ORDER BY 2 DESC;

-- Reviews per seat type
SELECT
  seat_type,
  COUNT(*)
FROM british_airways_reviews
GROUP BY 1
ORDER BY 2 DESC;
