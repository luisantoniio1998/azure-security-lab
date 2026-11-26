CREATE TABLE IF NOT EXISTS notes (
    id UUID PRIMARY KEY,
    text TEXT NOT NULL CHECK (
        length(trim(text)) BETWEEN 1 AND 2000
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
