\set ON_ERROR_STOP on

CREATE SCHEMA IF NOT EXISTS gold;

-- dim_user
CREATE TABLE gold.dim_user (
user_id INT NOT NULL UNIQUE,
gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
zip_code VARCHAR(10),
age_group VARCHAR(20) NOT NULL,
occupation VARCHAR(20) NOT NULL
);

-- dim_movie
CREATE TABLE gold.dim_movie (
movie_id INT NOT NULL UNIQUE,
title VARCHAR(200) NOT NULL,
release_year INT,
genre_name VARCHAR(200) NOT NULL -- ACTION, DRAMA, FICTION
);

-- dim_date
CREATE TABLE gold.dim_date (
date_id INT PRIMARY KEY,
rated_at DATE NOT NULL UNIQUE,
day INT NOT NULL,
month INT NOT NULL,
year INT NOT NULL,
day_of_week INT NOT NULL,
day_name VARCHAR(10) NOT NULL,
week INT NOT NULL,
month_name VARCHAR(10) NOT NULL,
quarter INT NOT NULL
);

-- dim_time
CREATE TABLE gold.dim_time (
time_id INT PRIMARY KEY,
rated_time TIME NOT NULL UNIQUE,
hour INT NOT NULL,
minute INT NOT NULL,
second INT NOT NULL,
time_of_day VARCHAR(10) NOT NULL -- am/pm
);

-- fact_rating
CREATE TABLE gold.fact_rating (
rating_id INT PRIMARY KEY,
user_id INT NOT NULL REFERENCES gold.dim_user(user_id),
movie_id INT NOT NULL REFERENCES gold.dim_movie (movie_id),
date_id INT NOT NULL REFERENCES gold.dim_date (date_id),
time_id INT NOT NULL REFERENCES gold.dim_time (time_id),
rating NUMERIC(2,1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
rating_count INT NOT NULL, -- počet všetkých hodnotení filmu COUNT(*)
rating_percentage INT NOT NULL -- hodnotenie v percentách
);


-- indexy na cudzie kľúče
CREATE INDEX ON gold.fact_rating(user_id);
CREATE INDEX ON gold.fact_rating (movie_id);
CREATE INDEX ON gold.fact_rating (date_id);
CREATE INDEX ON gold.fact_rating (time_id);

BEGIN;

TRUNCATE gold.fact_rating,
gold.dim_user,
gold.dim_movie,
gold.dim_date,
gold.dim_time; -- RESTART INDENTITY in case of AUTO INCREMENT

INSERT INTO
gold.dim_user (
user_id,
gender,
zip_code,
age_group,
occupation
)
SELECT u.user_id, u.gender, u.zip_code, a.age_group, o.occupation
FROM silver.stg_users u
LEFT JOIN silver.stg_age_group a ON a.age_group_id = u.age
LEFT JOIN silver.stg_occupations o ON o.occupation_id = u.occupation_id
ORDER BY u.user_id;

COMMIT;