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