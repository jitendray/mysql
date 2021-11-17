### Problem

I have a table in mysql database this data.
    
    id  date         number   qty
    ----------------------------------
    1   07-10-2018   200      5   
    2   01-12-2018   300      10
    3   03-02-2019   700      12
    4   07-03-2019   1000     15

I want to calculate difference between two consecutive rows and i need output format be like:
    
    id  date         number  diff    qty    avg
    -----------------------------------------------
    1   07-10-2018   200     0       5      0
    2   01-12-2018   300     100     10     10
    3   03-02-2019   700     400     12     33.33
    4   07-03-2019   1000    300     15     20

Note: I want first value of diff and avg column to be 0 and rest is the difference.

**SqlDump**: [Diff between consecutive rows in MySQL.sql](https://github.com/jitendray/mysql/blob/1f15ac7bff25c5a6e006ba73801b5149fac0f43f/sqldumps/Diff%20between%20consecutive%20rows%20in%20MySQL.sql)

### Solution

For **MySQL 8** then use [Lag](https://dev.mysql.com/doc/refman/8.0/en/window-function-descriptions.html#function_lag) window function.
```sql
SELECT 
    purchases.id, 
    purchases.date, 
    purchases.number, 
    purchases.qty,
    IFNULL(purchases.number - LAG(purchases.number) OVER w, 0) AS diff,
    ROUND(IFNULL(purchases.number - LAG(purchases.number) OVER w, 0)/ purchases.qty, 2) AS 'Avg'
FROM purchases
WINDOW w AS (ORDER BY purchases.`date` ASC);
```
For **MySQL 5.7 or lesser version**, use the [MySQL variable](https://dev.mysql.com/doc/refman/8.0/en/user-variables.html) to do this job. Consider your table name is `purchases`.

```sql
SELECT 
    purchases.id, 
    purchases.date, 
    purchases.number, 
    purchases.qty, 
    @diff:= IF(@prev_number = 0, 0, purchases.number - @prev_number) AS diff,
    ROUND(@diff / qty, 2) 'avg',
    @prev_number:= purchases.number as dummy
FROM 
    purchases, 
    (SELECT @prev_number:= 0 AS num) AS b
ORDER BY purchases.`date` ASC;

-------------------------------------------------------------------------------
Output:

| id| date 		| number| qty 	| diff 	| avg 	| dummy | 
-----------------------------------------------------------------
| 1 | 2018-10-07 	| 200 	| 5 	| 0 	| 0.00 	| 200 	|   
| 2 | 2018-12-01 	| 300 	| 10 	| 100 	| 10.00 | 300 	|   
| 3 | 2019-02-03 	| 700 	| 12 	| 400 	| 33.33 | 700 	|  
| 4 | 2019-03-07 	| 1000 	| 15 	| 300 	| 20.00 | 1000 	|
````
***Explaination***
 - `(SELECT @prev_number:= 0 AS num) AS b`
we initialized variable `@prev_number` to 0(zero) in FROM clause and joined with each row of the `purchases` table. 
 - `@diff:= IF(@prev_number = 0, 0, purchases.number - @prev_number) AS diff` First we are generating difference and then created another variable **diff** to reuse it for average calculation. Also we included one condition to make the diff for first row as zero.
 - `@prev_number:= purchases.number as dummy` we are setting current **number** to this variable, so it can be used by next row.

**Note**: We have to use this variable first, in both **difference** as well as **average** and then set to the new value, so next row can access value from the previous row.

You can skip/modify `order by` clause as per your requirements.
