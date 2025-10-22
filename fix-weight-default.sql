-- Zmień domyślną wartość wagi z 70.5 na NULL
ALTER TABLE daily_stats ALTER COLUMN weight SET DEFAULT NULL;

-- Opcjonalnie: usuń wszystkie rekordy z wagą 70.5 (jeśli chcesz wyczyścić istniejące dane)
-- UPDATE daily_stats SET weight = NULL WHERE weight = 70.5;

-- Sprawdź aktualną strukturę tabeli
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'daily_stats' 
AND table_schema = 'public'
AND column_name = 'weight';
