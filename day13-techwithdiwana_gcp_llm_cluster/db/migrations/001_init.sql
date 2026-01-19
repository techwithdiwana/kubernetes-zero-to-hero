-- 001_init.sql
-- Tech With Diwana - Demo SQL schema

CREATE TABLE IF NOT EXISTS demo_messages (
  id SERIAL PRIMARY KEY,
  message TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
