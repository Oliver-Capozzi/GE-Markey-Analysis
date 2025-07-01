WITH cleaned AS (
  SELECT Date, Close, SMA,
         ROW_NUMBER() OVER (PARTITION BY Date) AS rn
  FROM ge_stock_data
  WHERE Volume > 0
    AND strftime('%w', Date) NOT IN ('0', '6')  -- remove weekends
)
SELECT
  strftime('%Y', Date) AS Year,
  COUNT(*) AS Trading_Days,
  SUM(CASE WHEN Close > SMA THEN 1 ELSE 0 END) AS Bullish_Days,
  SUM(CASE WHEN Close < SMA THEN 1 ELSE 0 END) AS Bearish_Days
FROM cleaned
WHERE rn = 1
GROUP BY Year
ORDER BY Year;
