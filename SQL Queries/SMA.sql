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