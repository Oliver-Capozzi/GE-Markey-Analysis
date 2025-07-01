SELECT 
    SUBSTR(Date, 1, 4) AS Year,
    ROUND(AVG([Aroon Up]), 2) AS Avg_Aroon_Up,
    ROUND(AVG([Aroon Down]), 2) AS Avg_Aroon_Down
FROM ge_stock_data
GROUP BY Year
ORDER BY Year;
