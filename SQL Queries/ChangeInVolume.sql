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