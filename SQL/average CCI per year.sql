SELECT 
    SUBSTR(Date, 1, 4) AS Year,
    ROUND(AVG(CCI), 2) AS Avg_CCI
FROM ge_stock_data
GROUP BY Year
ORDER BY Year;
