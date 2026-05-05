-- Database Schema for Campus Vote App
-- Target: SQLite (Standard for Flutter apps)

CREATE TABLE users (
    student_id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    has_voted INTEGER DEFAULT 0, -- 0 for false, 1 for true
    voted_at DATETIME
);

CREATE TABLE positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL -- e.g., 'President', 'Secretary'
);

CREATE TABLE candidates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    position_id INTEGER,
    vote_count INTEGER DEFAULT 0,
    FOREIGN KEY (position_id) REFERENCES positions(id)
);

CREATE TABLE vote_audit (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id TEXT,
    candidate_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(student_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(id)
);
