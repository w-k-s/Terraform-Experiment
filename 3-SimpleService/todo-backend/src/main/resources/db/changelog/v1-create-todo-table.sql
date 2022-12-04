CREATE TABLE IF NOT EXISTS todo
(
    id           BIGINT auto_increment PRIMARY KEY       NOT NULL,
    description  VARCHAR(255)             NOT NULL,
    created_at   TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE
);
