SELECT 
    SUBSTR(Date, 1, 4) AS Year,
    COUNT(*) AS Days_Oversold
FROM ge_stock_data
WHERE RSI < 30
GROUP BY Year
ORDER BY Year;
