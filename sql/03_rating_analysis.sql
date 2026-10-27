-- Rating analysis for british_airways_reviews
-- Uses the review_date column created in 02_clean_dates.sql.
-- Findings (star ratings are on a 1-9 scale):
--   * Reviews per year are uneven: the peak is 2016-2017 (about 570 each) and the
--     lowest full years are 2020-2021 (104 and 87). 2015 (from 10 Nov) and 2023
--     (to 1 Aug) are partial years, so their counts are not comparable.
--   * The average rating is flat across the years: 4.25 to 4.31.
--   * Recommended 'yes' averages 4.32 against 4.25 for 'no'. That is almost no
--     difference, which is unusual for real reviews.
--   * By seat type the averages range from 4.14 to 4.32, and First Class (4.32)
--     equals Economy (4.32).
--   * Conclusion: the star rating looks unrelated to year, recommendation and seat
--     type. Together with the round counts noted in 01_explore_columns.sql, the data
--     looks randomised or sampled, so stars probably cannot show what drives
--     satisfaction.

-- Reviews per year (expected: 9 rows, 2015 to 2023, adding up to 2500)
SELECT
  EXTRACT(YEAR FROM review_date) AS year,
  COUNT(*) AS count
FROM british_airways_reviews
GROUP BY EXTRACT(YEAR FROM review_date)
ORDER BY EXTRACT(YEAR FROM review_date) ASC;

-- Average star rating per year, with the number of reviews behind each average
SELECT
  EXTRACT(YEAR FROM review_date) AS year,
  ROUND(AVG(stars), 2) AS average_star_rating,
  COUNT(*) AS count
FROM british_airways_reviews
GROUP BY 1
ORDER BY 1 ASC;

-- Average star rating by recommended status (expected: no 4.25, yes 4.32)
SELECT
  recommended,
  ROUND(AVG(stars), 2) AS average_star_rating,
  COUNT(*) AS count
FROM british_airways_reviews
GROUP BY recommended
ORDER BY 2;

-- Average star rating and review count per seat type
SELECT
  seat_type,
  ROUND(AVG(stars), 2) AS average_star_rating,
  COUNT(*) AS review_count
FROM british_airways_reviews
GROUP BY seat_type
ORDER BY 2;
