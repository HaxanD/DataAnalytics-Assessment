WITH customer_transactions AS (
    -- Combine savings and investment transactions with profit calculation
    SELECT 
        sa.owner_id AS customer_id,
        sa.transaction_date,
        sa.confirmed_amount AS amount,
        0.001 * sa.confirmed_amount AS profit  -- 0.1% profit rate
    FROM 
        adashi_staging.savings_savingsaccount sa
    WHERE 
        sa.transaction_status = 'success'
        AND sa.confirmed_amount > 0
    
    UNION ALL
    
    SELECT 
        pp.owner_id AS customer_id,
        pp.last_charge_date AS transaction_date,
        pp.amount,
        0.001 * pp.amount AS profit
    FROM 
        adashi_staging.plans_plan pp
    WHERE 
        pp.is_a_fund = 1
        AND pp.last_charge_date IS NOT NULL
        AND pp.amount > 0
),

customer_stats AS (
    -- Calculate customer metrics
    SELECT 
        uc.id AS customer_id,
        CONCAT(uc.first_name, ' ', uc.last_name) AS name,
        TIMESTAMPDIFF(MONTH, uc.date_joined, CURRENT_DATE()) AS tenure_months,
        COUNT(ct.amount) AS total_transactions,
        SUM(ct.profit) AS total_profit,
        AVG(ct.profit) AS avg_profit_per_transaction
    FROM 
        adashi_staging.users_customuser uc
    LEFT JOIN 
        customer_transactions ct ON uc.id = ct.customer_id
    WHERE 
        uc.is_active = 1
    GROUP BY 
        uc.id, uc.first_name, uc.last_name, uc.date_joined
    HAVING 
        COUNT(ct.amount) > 0
)

-- Final CLV estimation
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    -- CLV formula: (transactions/month) * 12 months * avg profit per transaction
    ROUND(
        (total_transactions / NULLIF(tenure_months, 0)) * 12 * avg_profit_per_transaction,
        2
    ) AS estimated_clv
FROM 
    customer_stats
ORDER BY 
    estimated_clv DESC;