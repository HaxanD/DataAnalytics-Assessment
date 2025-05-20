-- let create CTE for monthly transaction counts
WITH monthly_transactions AS (
    SELECT 
        -- Customer identification columns
        uc.id AS customer_id,                       
        CONCAT(uc.first_name, ' ', uc.last_name) AS customer_name,  -- Combined full name
        
        -- Transaction aggregation
        DATE_FORMAT(sa.transaction_date, '%Y-%m-01') AS month,  -- Group transactions by month (YYYY-MM-01 format)
        COUNT(DISTINCT sa.id) AS transaction_count    
        
    FROM 
        adashi_staging.users_customuser uc              
    JOIN 
        adashi_staging.savings_savingsaccount sa        -- Join with savings accounts
        ON uc.id = sa.owner_id                          -- Link via user ID
    WHERE 
        sa.transaction_status = 'success'               -- Only count successful transactions
        AND sa.transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)  -- Last 12 months only
        AND uc.is_active = 1                            -- Filter for active users only
    GROUP BY 
        uc.id,                                          -- Group by customer
        uc.first_name, uc.last_name,                   
        DATE_FORMAT(sa.transaction_date, '%Y-%m-01')    -- Group by month
),

-- Categorize customers by transaction frequency
customer_stats AS (
    SELECT 
        -- Customer identification
        customer_id,                               
        customer_name,                                
        
        -- Frequency calculations
        AVG(transaction_count) AS avg_transactions_per_month,  -- Calculate monthly average transactions
        
        -- Customer segmentation logic 
        CASE 
            WHEN AVG(transaction_count) >= 10 THEN 'High Frequency'     -- 10+ transactions per month
            WHEN AVG(transaction_count) >= 3 THEN 'Medium Frequency'    -- 3-9 transactions per month
            ELSE 'Low Frequency'                                        -- 0-2 transactions per month
        END AS frequency_category                       -- New column name with segmentation
        /* is a conditional expression which is similar to if-then-else in other programming 
          that allows you to return different values based on specified conditions.*/
   FROM 
        monthly_transactions                            -- Data from first CTE
    GROUP BY 
        customer_id, customer_name                     -- Group by customer
)

-- Final aggregated results
SELECT 
    -- Output columns
    frequency_category,                                 -- High/Medium/Low frequency
    COUNT(customer_id) AS customer_count,               -- Number of customers in each category
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month  -- Rounded average
    
FROM 
    customer_stats                                     -- Data from second CTE
GROUP BY 
    frequency_category                                
ORDER BY 
    -- Custom sorting to force High > Medium > Low
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;