CREATE SCHEMA IF NOT EXISTS silver;

CREATE OR REPLACE VIEW silver.stg_users AS 
SELECT
    TRIM(id)::INT AS user_id,
    TRIM(age)::INT AS age,
    UPPER(TRIM(gender)) AS gender,
    TRIM(occupation_id)::INT AS occupation_id,
    TRIM(zip_code) AS zip_code
FROM bronze.users;

CREATE OR REPLACE VIEW silver.stg_movies AS 
SELECT
    TRIM(id)::INT AS movie_id,
    TRIM(title) AS title,
    TRIM(release_year)::INT AS release_year
FROM bronze.movies;

CREATE OR REPLACE VIEW silver.ratings AS 
SELECT
    TRIM(id)::INT AS rating_id,
    TRIM(user_id)::INT AS user_id,
    TRIM(movie_id)::INT AS movie_id,
    TRIM(rating)::NUMERIC(2,1) AS rating,
    TRIM(rated_at)::TIMESTAMP AS rated_at
FROM bronze.ratings;

CREATE OR REPLACE VIEW silver.occupations AS 
SELECT
    TRIM(id)::INT AS occupation_id,
    TRIM(name) AS occupation_name
FROM bronze.occupations;

CREATE OR REPLACE VIEW silver.age_group AS 
SELECT
    TRIM(id)::INT AS age_group_id,
    TRIM(name) AS age_group_name
FROM bronze.age_group;

CREATE OR REPLACE VIEW silver.genres AS 
SELECT
    TRIM(id)::INT AS genre_id,
    TRIM(name) AS genre_name
FROM bronze.genres;

CREATE OR REPLACE VIEW silver.genres_movies AS 
SELECT
    TRIM(id)::INT AS genre_movie_id,
    TRIM(movie_id)::INT AS movie_id,
    TRIM(genre_id)::INT AS genre_id
FROM bronze.genres_movies;

-- kontrola
SELECT * FROM silver.stg_movies ORDER BY movie_id LIMIT 10;