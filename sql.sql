-- Create the player_playtime table if it doesn't exist
CREATE TABLE IF NOT EXISTS player_playtime (
    identifier VARCHAR(255) PRIMARY KEY,
    last_played_minute INT
);

-- Add the salary_perjam column to the job_grades table
ALTER TABLE job_grades
ADD COLUMN salary_perjam INT;

-- Add the paycheck column to the users table
ALTER TABLE users
ADD COLUMN paycheck INT;