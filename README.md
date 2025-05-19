# SQL Assessment Solutions  

### **Question 1: High-Value Customers with Multiple Products**  
**Approach**:  
- I have to divide my solution into subqueries and solve them one at a time
- I joined customer data with savings and investment accounts  
- I also Filtered for funded accounts (confirmed_amount>0)for savings_savingsaccount
and (amount>0) for Plans_plan 
- Counted distinct products per customer  
- Calculated total deposits in currency (kobo/100)  

**Challenges**:  
- I Initially miscounted transactions due to missing is_regular_savings flag  
- I Resolved this issue by using confirmed_amount > 0 as proxy for active accounts  
- data contains null rows I resolve this with colesce
---

### **Question 2: Transaction Frequency Analysis**  
**Approach**:  
- I use CTE (Common Table Expression)to break down complex logic into manageable steps
-  I Grouped transactions by customer and month  
- I Categorized frequency into:  
  - High (≥10/month)  
  - Medium (3-9/month)  
  - Low (≤2/month)  

**Challenges**:  
- Outliers skewed averages (fixed with 12-month window)  
  

---

### **Question 3: Account Inactivity Alert**  
**Approach**:  
- I Combined savings/investment last-activity dates  
- I Flagged accounts with: (a) No transactions in 1 year and   
  (b) But activity in past 2 years (to exclude new accounts)   

**Challenges**:  
- Investment plans does not have transaction dates (used last_charge_date)  

---

### **Question 4: Customer Lifetime Value**  
**Approach**:  
- I Calculated:  
  (a)Tenure (months since signup)  
  (b)Avg profit per transaction (0.1% of amount)  
  (c) CLV = (transactions/tenure) × 12 × avg_profit  

**Challenges**:  
- Kobo conversion required amount/100  
- Division by zero for new customers (I used NULLIF to avoid running into error)  

---

**Notes**:  
- All amounts converted from kobo  
- Tested with 2-year data window for consistency  
**Other Challenges**
- i had to download and install MySQL Workbench as SSMS couldnt import my data (adashi_assessment)
- I had to download Git Bash to create a Repository on GitHub 
