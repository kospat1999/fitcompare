-- FitCompare Database Setup
-- Zaktualizowana struktura bazy danych dla nowych funkcjonalności

-- 1. Tabela użytkowników (zachowujemy integer ID dla kompatybilności)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabela treningów
CREATE TABLE IF NOT EXISTS trainings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- Siłownia, Bieganie, Schody, Custom
  duration INTEGER NOT NULL, -- w minutach
  details JSONB, -- szczegóły treningu (gymType, floors, etc.)
  date DATE NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabela danych dziennych
CREATE TABLE IF NOT EXISTS daily_stats (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  calories INTEGER DEFAULT 0,
  steps INTEGER DEFAULT 0,
  protein DECIMAL(5,1) DEFAULT 0,
  weight DECIMAL(5,1) DEFAULT NULL,
  supplements BOOLEAN DEFAULT FALSE,
  rest_day BOOLEAN DEFAULT FALSE,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date) -- jeden rekord na użytkownika na dzień
);

-- 4. Tabela metryk użytkowników (agregowane dane)
CREATE TABLE IF NOT EXISTS user_metrics (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  training_time INTEGER DEFAULT 0, -- suma wszystkich treningów w minutach
  distance DECIMAL(8,2) DEFAULT 0, -- dystans w km
  calories INTEGER DEFAULT 0, -- suma kalorii
  steps INTEGER DEFAULT 0, -- suma kroków
  protein DECIMAL(8,1) DEFAULT 0, -- suma białka
  supplements BOOLEAN DEFAULT FALSE, -- ostatni stan suplementów
  rest_day BOOLEAN DEFAULT FALSE, -- ostatni stan rest day
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Tabela celów użytkowników
CREATE TABLE IF NOT EXISTS user_goals (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  training_time_goal INTEGER DEFAULT 60, -- cel czasu treningu w minutach
  calories_goal INTEGER DEFAULT 2000, -- cel kalorii
  steps_goal INTEGER DEFAULT 10000, -- cel kroków
  protein_goal DECIMAL(5,1) DEFAULT 100.0, -- cel białka w gramach
  target_weight DECIMAL(5,1) DEFAULT NULL, -- waga docelowa w kg
  supplements_goal BOOLEAN DEFAULT TRUE, -- zawsze true
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5.1. Dodaj kolumnę target_weight jeśli nie istnieje (dla istniejących tabel)
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS target_weight DECIMAL(5,1) DEFAULT NULL;

-- 5.2. Dodaj kolumnę rest_day jeśli nie istnieje (dla istniejących tabel)
ALTER TABLE user_metrics ADD COLUMN IF NOT EXISTS rest_day BOOLEAN DEFAULT FALSE;
ALTER TABLE daily_stats ADD COLUMN IF NOT EXISTS rest_day BOOLEAN DEFAULT FALSE;

-- 6. Wstawienie użytkowników
INSERT INTO users (username, password, name) VALUES
('fiko', 'Test1234!', 'Fiko'),
('patka', 'Test1234!', 'Patka')
ON CONFLICT (username) DO NOTHING;

-- 7. Wstawienie domyślnych celów dla użytkowników
INSERT INTO user_goals (user_id, training_time_goal, calories_goal, steps_goal, protein_goal, supplements_goal) 
SELECT 
  u.id,
  60, -- 60 minut treningu
  2000, -- 2000 kalorii
  10000, -- 10000 kroków
  100.0, -- 100g białka
  TRUE -- suplementy zawsze na Tak
FROM users u
WHERE u.username IN ('fiko', 'patka')
ON CONFLICT (user_id) DO NOTHING;

-- 6. Wstawienie początkowych metryk dla użytkowników
INSERT INTO user_metrics (user_id, training_time, distance, calories, steps, protein, supplements, rest_day)
SELECT 
  u.id,
  0, 0, 0, 0, 0, FALSE, FALSE
FROM users u
WHERE u.username IN ('fiko', 'patka')
ON CONFLICT (user_id) DO NOTHING;

-- 7. Funkcje do automatycznego aktualizowania updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 8. Triggery dla automatycznego updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_trainings_updated_at ON trainings;
CREATE TRIGGER update_trainings_updated_at BEFORE UPDATE ON trainings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_daily_stats_updated_at ON daily_stats;
CREATE TRIGGER update_daily_stats_updated_at BEFORE UPDATE ON daily_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_metrics_updated_at ON user_metrics;
CREATE TRIGGER update_user_metrics_updated_at BEFORE UPDATE ON user_metrics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_goals_updated_at ON user_goals;
CREATE TRIGGER update_user_goals_updated_at BEFORE UPDATE ON user_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 9. Indeksy dla lepszej wydajności
CREATE INDEX IF NOT EXISTS idx_trainings_user_date ON trainings(user_id, date);
CREATE INDEX IF NOT EXISTS idx_trainings_date ON trainings(date);
CREATE INDEX IF NOT EXISTS idx_daily_stats_user_date ON daily_stats(user_id, date);
CREATE INDEX IF NOT EXISTS idx_daily_stats_date ON daily_stats(date);

-- 10. Funkcja do aktualizacji metryk użytkownika po dodaniu treningu
CREATE OR REPLACE FUNCTION update_user_metrics_after_training()
RETURNS TRIGGER AS $$
BEGIN
    -- Aktualizuj czas treningu
    UPDATE user_metrics 
    SET training_time = (
        SELECT COALESCE(SUM(duration), 0)
        FROM trainings 
        WHERE user_id = NEW.user_id
    ),
    updated_at = NOW()
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 11. Trigger dla aktualizacji metryk po dodaniu treningu
DROP TRIGGER IF EXISTS update_metrics_after_training_insert ON trainings;
CREATE TRIGGER update_metrics_after_training_insert
    AFTER INSERT ON trainings
    FOR EACH ROW EXECUTE FUNCTION update_user_metrics_after_training();

DROP TRIGGER IF EXISTS update_metrics_after_training_update ON trainings;
CREATE TRIGGER update_metrics_after_training_update
    AFTER UPDATE ON trainings
    FOR EACH ROW EXECUTE FUNCTION update_user_metrics_after_training();

DROP TRIGGER IF EXISTS update_metrics_after_training_delete ON trainings;
CREATE TRIGGER update_metrics_after_training_delete
    AFTER DELETE ON trainings
    FOR EACH ROW EXECUTE FUNCTION update_user_metrics_after_training();

-- 12. Funkcja do aktualizacji metryk użytkownika po dodaniu danych dziennych
CREATE OR REPLACE FUNCTION update_user_metrics_after_daily_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Aktualizuj metryki na podstawie wszystkich danych dziennych
    UPDATE user_metrics 
    SET 
        calories = (
            SELECT COALESCE(SUM(calories), 0)
            FROM daily_stats 
            WHERE user_id = NEW.user_id
        ),
        steps = (
            SELECT COALESCE(SUM(steps), 0)
            FROM daily_stats 
            WHERE user_id = NEW.user_id
        ),
        protein = (
            SELECT COALESCE(SUM(protein), 0)
            FROM daily_stats 
            WHERE user_id = NEW.user_id
        ),
        supplements = NEW.supplements,
        rest_day = NEW.rest_day,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 13. Trigger dla aktualizacji metryk po dodaniu danych dziennych
DROP TRIGGER IF EXISTS update_metrics_after_daily_stats_insert ON daily_stats;
CREATE TRIGGER update_metrics_after_daily_stats_insert
    AFTER INSERT ON daily_stats
    FOR EACH ROW EXECUTE FUNCTION update_user_metrics_after_daily_stats();

DROP TRIGGER IF EXISTS update_metrics_after_daily_stats_update ON daily_stats;
CREATE TRIGGER update_metrics_after_daily_stats_update
    AFTER UPDATE ON daily_stats
    FOR EACH ROW EXECUTE FUNCTION update_user_metrics_after_daily_stats();

DROP TRIGGER IF EXISTS update_metrics_after_daily_stats_delete ON daily_stats;
CREATE TRIGGER update_metrics_after_daily_stats_delete
    AFTER DELETE ON daily_stats
    FOR EACH ROW EXECUTE FUNCTION update_user_metrics_after_daily_stats();

-- 14. RLS (Row Level Security) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE trainings ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;

-- 15. Polityki bezpieczeństwa - pozwól wszystkim na odczyt i zapis (dla prostoty)
DROP POLICY IF EXISTS "Allow all operations on users" ON users;
CREATE POLICY "Allow all operations on users" ON users FOR ALL USING (true);

DROP POLICY IF EXISTS "Allow all operations on trainings" ON trainings;
CREATE POLICY "Allow all operations on trainings" ON trainings FOR ALL USING (true);

DROP POLICY IF EXISTS "Allow all operations on daily_stats" ON daily_stats;
CREATE POLICY "Allow all operations on daily_stats" ON daily_stats FOR ALL USING (true);

DROP POLICY IF EXISTS "Allow all operations on user_metrics" ON user_metrics;
CREATE POLICY "Allow all operations on user_metrics" ON user_metrics FOR ALL USING (true);

DROP POLICY IF EXISTS "Allow all operations on user_goals" ON user_goals;
CREATE POLICY "Allow all operations on user_goals" ON user_goals FOR ALL USING (true);

-- 16. Sprawdzenie czy wszystko działa
SELECT 'Setup completed successfully!' as status;

-- 17. Przykładowe zapytania do testowania
-- Sprawdź użytkowników
-- SELECT * FROM users;

-- Sprawdź strukturę tabel
-- SELECT table_name, column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_schema = 'public' 
-- ORDER BY table_name, ordinal_position;
