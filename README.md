# stock-price-dashboard
[Tableau Public Link](https://public.tableau.com/app/profile/krshirkoohi/viz/StockPriceDashboard_17187501544320/Dashboard)

![Dashboard](https://github.com/krshirkoohi/StockPriceDashboard/assets/72894688/ae9a033e-ec94-45a2-b3e6-14ff62200bdf)


## Outline

Find the data for company stocks. Let’s focus on Big Tech.

- We’re working with raw CSV data as our medium between programs.
- The technologies to be used are: SQLite and Tableau.
- We will select five stocks to observe.
- We will use SQL to extract the data to new CSV files ready for formatting.
- We’ll then import those files into Tableau and follow the template

## Data transformation

The dataset we will be using is the [Big Tech Stock Prices](https://www.kaggle.com/datasets/evangower/big-tech-stock-prices) set, available on Kaggle.

This provides stock price data for the years 2010 up to 2022.

We will be observing the following stocks: **AAPL**, **AMZN**, **GOOGL**, **META**, and **MSFT**.

### Initial data cleansing

We don’t need to check if the data needs to be cleansed, as it’s already correct. But, if we needed to, this is what we’d do:

Check for NULL values:

```sql
SELECT * FROM your_table WHERE your_column IS NULL;
```

Check data types:

```sql
SELECT * FROM your_table WHERE CAST(your_column AS NUMERIC) IS NULL;
```

Check patterns conform i.e. date formats:

```sql
-- General check
SELECT * FROM your_table WHERE your_column NOT LIKE '%[a-zA-Z0-9]%';

-- Check date formats
SELECT * FROM your_table 
WHERE Date NOT LIKE '____-__-__'
   OR Date NOT LIKE '%[^0-9-]%';
-- The last statement may be problematic as the '-' symbol in YYYY-MM-DD could cause interpretation problems
```

Alternatively, we could check for dates like this:

```sql
SELECT * FROM your_table WHERE DATE(Date) IS NULL;
```

It’s *always* best practise to have date columns in the format `YYYY-MM-DD` for numeric sorting.

### Creating new columns

Let’s create additional columns we will need for our dashboard.

#### Simple Moving Average

Let’s generate the [simple moving average (SMA)](https://www.investopedia.com/ask/answers/06/differencebetweenmas.asp) columns for each stock.

Motivation: 

> Simple moving averages (SMA) are viewed as a low-risk area to place transactions since they correspond to the [average price](https://www.investopedia.com/terms/a/averageprice.asp) that all traders have paid over a given time frame. Some of the most common include the 50-day. 100-day, and 200-day simple moving averages. The main difference between these three is the period used in the calculation.

The SMA formula:

```
SMA = (A_1 + A_2 + ... A_n) / n

A_n = Price at period n
n = total number of periods
```

In SQLite, we use subqueries and window functions to implement this:

```sql
-- Edit mode
ALTER TABLE Amazon ADD COLUMN MA50 REAL;
ALTER TABLE Amazon ADD COLUMN MA200 REAL;

-- Calculate MA50 and MA200
UPDATE Amazon SET
	MA50 = (
		SELECT AVG(Close)
		FROM (
			SELECT Close
			FROM Amazon AS sub
			WHERE sub.Date <= Amazon.Date
			ORDER BY sub.Date DESC
			LIMIT 50
		)	
	),
	MA200 = (
		SELECT AVG(Close)
		FROM (
			SELECT Close
			FROM Amazon AS sub
			WHERE sub.Date <= Amazon.Date
			ORDER BY sub.Date DESC
			LIMIT 200
		)
	)
);
```

Do for other stocks Apple, Meta, Google, Microsoft.

#### Previous day close price

We cannot run this query:

```sql
SELECT
    t1.Date,
    t1.Close,
    (SELECT t2.Close FROM Amazon t2 WHERE t2.Date < t1.Date ORDER BY t2.Date DESC LIMIT 1) AS "Previous day close price"
FROM Amazon t1;
```

This is due to days when no trading occurred not being recorded; this means there’s a gap in the `Date` sequence.

We can run this alternative query instead:

```sql
ALTER TABLE Amazon ADD COLUMN "Previous day close price" REAL;

UPDATE Amazon
SET "Previous day close price" = (
    SELECT t2.Close 
    FROM Amazon t2 
    WHERE t2.Date < Amazon.Date 
    ORDER BY t2.Date DESC 
    LIMIT 1
)
WHERE Amazon.Date >= (
    SELECT MIN(Date) FROM Amazon
);
```

#### Change in price

```sql
ALTER TABLE Amazon ADD COLUMN "Change in price" REAL;

UPDATE Amazon
SET "Change in price" = Close - (
    SELECT t2.Close 
    FROM Amazon t2 
    WHERE t2.Date < Amazon.Date 
    ORDER BY t2.Date DESC 
    LIMIT 1
)
WHERE Date >= (
    SELECT MIN(Date) FROM Amazon
);
```

#### Percent change in price

```sql
ALTER TABLE Amazon ADD COLUMN "Percent change in price" REAL;

UPDATE Amazon
SET "Percent change in price" = (
    CASE
        WHEN "Change in price" IS NOT NULL AND (
            SELECT t2.Close 
            FROM Amazon t2 
            WHERE t2.Date < Amazon.Date 
            ORDER BY t2.Date DESC 
            LIMIT 1
        ) IS NOT NULL
        THEN "Change in price" / (
            SELECT t2.Close 
            FROM Amazon t2 
            WHERE t2.Date < Amazon.Date 
            ORDER BY t2.Date DESC 
            LIMIT 1
        ) 
        ELSE NULL
    END
)
WHERE Date >= (
    SELECT MIN(Date) FROM Amazon
);
```

#### Previous day volume

```sql
ALTER TABLE Amazon ADD COLUMN "Previous day volume" REAL;

UPDATE Amazon
SET "Previous day volume" = (
    SELECT t2.Volume 
    FROM Amazon t2 
    WHERE t2.Date < Amazon.Date 
    ORDER BY t2.Date DESC 
    LIMIT 1
)
WHERE Date >= (
    SELECT MIN(Date) FROM Amazon
);
```

#### Change in volume

```sql
ALTER TABLE Amazon ADD COLUMN "Change in volume" REAL;

UPDATE Amazon
SET "Change in volume" = Volume - (
    SELECT t2.Volume 
    FROM Amazon t2 
    WHERE t2.Date < Amazon.Date 
    ORDER BY t2.Date DESC 
    LIMIT 1
)
WHERE Date >= (
    SELECT MIN(Date) FROM Amazon
);
```

### Final data cleansing

We drop the row representing first day of trading, `2010-01-04` as it contains NULL values for previous day values. 

Justification: one day doesn’t have much impact on a dataset spanning over 10 years.

```sql
DELETE FROM Amazon
WHERE Date = (SELECT MIN(Date) FROM Amazon);
```

Our new dataset spans from the trading days `2010-01-05` to `2022-12-29` i.e. 5th Jan 2010 to 29th Dec 2022.

### Saving the views

Finally, we will save our updated tables to corresponding CSV files. We use DB Browser for this.

To clarify, the transformed data is saved to a folder ‘Transformed Data’ (apt).

Our data is now ready for Tableau to connect.

## Building the Dashboard

Filtering the five year range 2018 - 2022 inclusive.

The following views were created:

- Moving Average SMA50, SMA200, and Close Prices
- Volumes for all Companies
- Histogram of Volume Changes
- Detailed Volume and Price Tables

Please see the Tableau Workbook for more information.
