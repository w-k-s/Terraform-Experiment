CREATE SCHEMA IF NOT EXISTS task_feed;
CREATE TABLE task_feed.tasker
(
    id      BIGINT       NOT NULL,
    name    VARCHAR(100) NOT NULL,
    version BIGINT       NOT NULL, -- Required for optimistic locking, and for jdbc to determine if entity is new.
    CONSTRAINT pk_tasker_id PRIMARY KEY (id)
);


CREATE TABLE task_feed.tasker_category
(
    tasker_id BIGINT       NOT NULL,
    category  VARCHAR(100) NOT NULL,
    CONSTRAINT fk_tasker_category_id FOREIGN KEY (tasker_id) REFERENCES task_feed.tasker (id),
    CONSTRAINT uk_tasker_category_id_category UNIQUE (id, category)
);

CREATE TABLE task_feed.task_feed
(
    tasker_id        BIGINt                   NOT NULL,
    task_id          BIGINT                   NOT NULL,
    task_description VARCHAR(200)             NOT NULL,
    created          TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT fk_task_feed_tasker_id FOREIGN KEY (tasker_id) REFERENCES task_feed.tasker (id)
);