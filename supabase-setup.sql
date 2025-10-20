-- Tworzenie tabeli użytkowników
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tworzenie tabeli danych fitness
CREATE TABLE fitness_data (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Wstawienie przykładowych użytkowników
INSERT INTO users (username, password, name) VALUES 
('fiko', 'Test1234!', 'Fiko'),
('patka', 'Test1234!', 'Patka');

-- Utworzenie indeksów dla lepszej wydajności
CREATE INDEX idx_fitness_data_user_id ON fitness_data(user_id);
CREATE INDEX idx_fitness_data_updated_at ON fitness_data(updated_at);

-- Funkcja do automatycznego aktualizowania updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger dla automatycznego aktualizowania updated_at
CREATE TRIGGER update_fitness_data_updated_at 
    BEFORE UPDATE ON fitness_data 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
