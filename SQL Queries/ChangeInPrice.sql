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