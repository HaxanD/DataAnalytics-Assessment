WITH all_accounts AS (
    -- Combine savings and investment accounts with last activity dates
    SELECT 
        sa.id AS account_id,
        sa.owner_id,
        'Savings' AS account_type,
        MAX(sa.transaction_date) AS last_transaction_date
    FROM 
        savings_savingsaccount sa
    WHERE 
        sa.transaction_status = 'success'
    GROUP BY 
        sa.id, sa.owner_id
    
    UNION ALL
    
    SELECT 
        pp.id AS account_id,
        pp.owner_id,
        'Investment' AS account_type,
        pp.last_charge_date AS last_transaction_date
    FROM 
        plans_plan pp
    WHERE 
        pp.is_a_fund = 1
        AND pp.last_charge_date IS NOT NULL
),

inactive_accounts AS (
    -- Flag accounts with no activity for 1+ years but were previously active
    SELECT 
        a.account_id,
        a.owner_id,
        a.account_type,
        a.last_transaction_date,
        DATEDIFF(CURRENT_DATE(), a.last_transaction_date) AS inactivity_days
    FROM 
        all_accounts a
    WHERE 
        a.last_transaction_date < DATE_SUB(CURRENT_DATE(), INTERVAL 365 DAY)
        AND EXISTS (
            SELECT 1 FROM all_accounts a2 
            WHERE a2.owner_id = a.owner_id 
            AND a2.last_transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 730 DAY)
        )
)

-- Final output for ops team
SELECT 
    ia.account_id AS plan_id,
    ia.owner_id,
    ia.account_type AS type,
    ia.last_transaction_date,
    ia.inactivity_days
FROM 
    inactive_accounts ia
JOIN 
    users_customuser uc ON ia.owner_id = uc.id
WHERE 
    uc.is_active = 1
ORDER BY 
    ia.inactivity_days DESC;