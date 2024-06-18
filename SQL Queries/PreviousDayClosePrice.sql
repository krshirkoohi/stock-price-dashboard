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