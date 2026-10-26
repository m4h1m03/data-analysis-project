-- Cleaning the review dates in british_airways_reviews
-- The raw date column is text such as '1st August 2023'.
-- Steps: check the format, strip the ordinal suffix, convert to a real date,
-- then store it in a new review_date column. The raw date column is left untouched.

-- 1. Look at a random sample of the raw dates
SELECT date
FROM british_airways_reviews
ORDER BY random()
LIMIT 50;

-- 2. Check every date has the same shape: day + suffix, month name, year
-- Rows that match the pattern (expected: 2500)
SELECT COUNT(date)
FROM british_airways_reviews
WHERE date ~'^[0-9]+[A-Za-z]{2} [A-Za-z]+ \d{4}$';

-- Rows that do NOT match the pattern (expected: 0)
SELECT COUNT(date)
FROM british_airways_reviews
WHERE date !~'^[0-9]+[A-Za-z]{2} [A-Za-z]+ \d{4}$';

-- 3. Preview stripping the ordinal suffix (st/nd/rd/th) from the day
SELECT
  date AS raw_date,
  regexp_replace(date, '([0-9]+)[A-Za-z]{2} ', '\1 ') AS suffix_removed_date
FROM british_airways_reviews
LIMIT 20;

-- 4. Test the full conversion to a real date and find the true date range
-- (expected: 2015-11-10 to 2023-08-01)
WITH cleaned AS (
  SELECT
    date AS raw_date,
    regexp_replace(date, '([0-9]+)[A-Za-z]{2} ', '\1 ') AS suffix_removed_date
  FROM british_airways_reviews
)
SELECT
  MIN(to_date(cleaned.suffix_removed_date, 'FMDD Month YYYY')) AS earliest_converted_date,
  MAX(to_date(cleaned.suffix_removed_date, 'FMDD Month YYYY')) AS latest_converted_date
FROM cleaned;

-- 5. Store the converted dates in a new review_date column (the raw date column is left as it is)
-- WARNING: the ALTER TABLE and UPDATE below have already been run.
-- Do not run ALTER TABLE again: it will error because review_date already exists.
ALTER TABLE british_airways_reviews
ADD COLUMN review_date DATE;

UPDATE british_airways_reviews
SET review_date = to_date(
      regexp_replace(date, '([0-9]+)[A-Za-z]{2} ', '\1 '),
      'FMDD Month YYYY'
    );

-- 6. Check every row was converted (expected: 0 NULLs)
SELECT COUNT(*)
FROM british_airways_reviews
WHERE review_date IS NULL;
