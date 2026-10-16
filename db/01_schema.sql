-- 01_schema.sql

CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    address TEXT
);

CREATE TABLE detectives (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    rank TEXT NOT NULL CHECK (rank IN ('junior', 'senior', 'lead', 'consultant')),
    hire_date DATE NOT NULL
);

CREATE TABLE cases (
    id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'suspended')),
    opened_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    closed_at TIMESTAMPTZ,
    fee NUMERIC(10,2) NOT NULL CHECK (fee >= 0),
    CHECK (closed_at IS NULL OR closed_at > opened_at)
);

CREATE TABLE case_detectives (
    case_id INTEGER NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    detective_id INTEGER NOT NULL REFERENCES detectives(id) ON DELETE RESTRICT,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('lead', 'member', 'consultant')),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (case_id, detective_id)
);

CREATE TABLE evidence (
    id SERIAL PRIMARY KEY,
    case_id INTEGER NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    found_at TIMESTAMPTZ NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('physical', 'digital', 'testimony', 'document'))
);

CREATE TABLE suspects (
    id SERIAL PRIMARY KEY,
    case_id INTEGER NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    alias TEXT,
    status TEXT NOT NULL DEFAULT 'person_of_interest'
        CHECK (status IN ('person_of_interest', 'suspect', 'cleared', 'arrested'))
);

CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    case_id INTEGER NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    detective_id INTEGER NOT NULL REFERENCES detectives(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    content TEXT NOT NULL,
    hours_spent NUMERIC(5,2) NOT NULL CHECK (hours_spent > 0)
);