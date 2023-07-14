CREATE SCHEMA IF NOT EXISTS task_creation;
CREATE TABLE task_creation.task
(
    id          BIGINT                   NOT NULL,
    description VARCHAR(500)             NOT NULL,
    category    VARCHAR(16)              NOT NULL,
    CREATED_AT  TIMESTAMP WITH TIME ZONE NOT NULL,
    version     BIGINT                   NOT NULL, -- Required for optimistic locking, and for jdbc to determine if entity is new.
    CONSTRAINT pk_task_id PRIMARY KEY (id)
);