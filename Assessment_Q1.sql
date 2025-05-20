SELECT 
    uc.id AS owner_id,
    CONCAT(uc.first_name, ' ', uc.last_name) AS name,
    COUNT(DISTINCT sa.id) AS savings_count,
    COUNT(DISTINCT CASE WHEN pp.is_a_fund = 1 THEN pp.id END) AS investment_count,
    (
        SUM(COALESCE(sa.confirmed_amount, 0)) + 
        SUM(COALESCE(CASE WHEN pp.is_a_fund = 1 THEN pp.amount ELSE 0 END, 0))
    ) / 100 AS total_deposits
FROM 
    adashi_staging.users_customuser uc
LEFT JOIN 
    adashi_staging.savings_savingsaccount sa 
    ON uc.id = sa.owner_id 
    AND sa.confirmed_amount > 0
    /* we use 2-year filter to ensures we only consider recent active accounts
       - Excludes inactive accounts*/
    AND sa.transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 2 YEAR)  -- Last 2 years
LEFT JOIN 
    adashi_staging.plans_plan pp 
    ON uc.id = pp.owner_id
    AND pp.is_a_fund = 1
    /* Consistent 2-year window for investments
       - Aligns with savings account timeframe
       - Avoids mixing old and new products */
    AND pp.start_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 2 YEAR)  -- Last 2 years
GROUP BY 
    uc.id, uc.first_name, uc.last_name
HAVING 
    COUNT(DISTINCT sa.id) > 0
    AND COUNT(DISTINCT CASE WHEN pp.is_a_fund = 1 THEN pp.id END) > 0
ORDER BY 
    total_deposits DESC;