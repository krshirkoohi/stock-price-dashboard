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