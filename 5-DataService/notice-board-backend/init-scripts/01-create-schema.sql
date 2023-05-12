CREATE SCHEMA IF NOT EXISTS noticeboard;
CREATE TABLE noticeboard.notice
(
    id         BIGSERIAL       NOT NULL,
    notice     VARCHAR(255) NOT NULL,
    created_by VARCHAR(100)
);