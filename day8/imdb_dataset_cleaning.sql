create database if not exists messy_IMDB_db;
use messy_IMDB_db;

select *
from imdb_raw;

-- standardized all column names
ALTER TABLE imdb_raw
	RENAME COLUMN `IMBD title ID` TO imdb_title_id,
	RENAME COLUMN `Original titlÊ` TO original_title,
	RENAME COLUMN `Release year` TO release_year,
	RENAME COLUMN `Genrë¨` TO genre,
	RENAME COLUMN `Duration` TO duration,
	RENAME COLUMN `Country` TO country,
	RENAME COLUMN `Content Rating` TO content_rating,
	RENAME COLUMN `Director` TO director,
	RENAME COLUMN `Income` TO income,
	RENAME COLUMN `Votes` TO votes,
	RENAME COLUMN `Score` TO score;

-- dropped complete blank column
ALTER TABLE imdb_raw
DROP COLUMN MyUnknownColumn;

-- dropped blank row
delete
from imdb_raw
where imdb_title_id = '';

select *
from imdb_raw;

-- normalizing original_title column
alter table imdb_raw
add column title varchar(200);

select imdb_title_id,original_title,title
from imdb_raw;

update imdb_raw
set title = trim(original_title);

SELECT title
FROM imdb_raw
WHERE title REGEXP '[^A-Za-z0-9 .:,''\-()!?\+]';

UPDATE imdb_raw 
SET title = 'Star Wars: Episode V – The Empire Strikes Back'
WHERE title LIKE 'Star Wars: Episode V%';

UPDATE imdb_raw 
SET title = 'Léon'
WHERE title LIKE 'LÃ©on%';

UPDATE imdb_raw 
SET title = 'WALL·E'
WHERE title LIKE 'WALLÂ·E%';

UPDATE imdb_raw 
SET title = 'Spider-Man: Into the Spider-Verse'
WHERE title LIKE 'Spider-Man: Into the Spider-Verse%';

UPDATE imdb_raw 
SET title = 'Mononoke-hime'
WHERE title LIKE 'Mononoke-hime%';

UPDATE imdb_raw 
SET title = 'Star Wars: Episode VI – Return of the Jedi'
WHERE title LIKE 'Star Wars: Episode VI%';

UPDATE imdb_raw 
SET title = 'Le fabuleux destin d''Amélie Poulain'
WHERE title LIKE 'Le fabuleux destin d''AmÃ©lie%';

UPDATE imdb_raw 
SET title = 'Per qualche dollaro in più'
WHERE title LIKE 'Per qualche dollaro in piÃ¹%';


-- fixing release_year column
select 
	release_year,
	release_date
from imdb_raw
where release_date is null;

alter table imdb_raw
add column release_date date;

update ignore imdb_raw
set release_date = date(release_year);

select 
	release_year,
	release_date
from imdb_raw
where release_date is null;

select 
	release_year,
	release_date
from imdb_raw;

update imdb_raw
set release_date = '1972-09-21'
where release_year = '09 21 1972';

UPDATE imdb_raw
SET release_date = '2008-07-23'
WHERE release_year = ' 23 -07-2008';

UPDATE imdb_raw
SET release_date = '2004-02-22'
WHERE release_year = '22 Feb 04';

UPDATE imdb_raw
SET release_date = '1999-10-29'
WHERE release_year = '10-29-99';

UPDATE imdb_raw
SET release_date = '1966-12-23'
WHERE release_year = '23rd December of 1966 ';

UPDATE imdb_raw
SET release_date = '2003-01-16'
WHERE release_year = '01/16-03';

UPDATE imdb_raw
SET release_date = '1976-11-18'
WHERE release_year = '18/11/1976';

UPDATE imdb_raw
SET release_date = '1946-11-21'
WHERE release_year = '21-11-46';

-- standardized genre column
select * from imdb_raw;

UPDATE imdb_raw
SET genre = REPLACE(genre, ', ', ',');

-- correct duration values
alter table imdb_raw
add column duration_in_minutes int;

select *
from imdb_raw
where duration regexp '[^0-9]';

update imdb_raw
set duration = '178'
where duration = '178c';

update imdb_raw
set duration = null
where duration regexp '[^0-9]';

select duration,duration_in_minutes
from imdb_raw;

update imdb_raw
set duration_in_minutes = cast(duration as unsigned);

-- fixing country
select distinct country
from imdb_raw;

select country
from imdb_raw
where country regexp '[0-9]+';

update imdb_raw
set country = 'Italy'
where country = 'Italy1';

select country
from imdb_raw
where country like 'U%';

update imdb_raw
set country = 'USA'
where country = 'US.';

update imdb_raw
set country = 'USA'
where country = 'US';

select country
from imdb_raw
where country like 'N%';

update imdb_raw
set country = 'New Zealand'
where country like 'New Z%';

select distinct country
from imdb_raw;

-- generalizing content rating
select distinct content_rating
from imdb_raw;

update imdb_raw
set content_rating = trim(content_rating);

update imdb_raw
set content_rating = null
where content_rating not in ('R','PG-13','Not Rated','PG','Unrated','G');

update imdb_raw
set content_rating = 'Unrated'
where content_rating = 'Not Rated';

-- fixing income
alter table imdb_raw
add column movie_income int;

select income,movie_income
from imdb_raw;

select income
from imdb_raw
where income regexp '[A-Za-z]';

update imdb_raw
set income = trim(income);

update imdb_raw
set income = '$ 408,035,783'
where income = '$ 4o8,035,783';

UPDATE imdb_raw
SET income = REPLACE(income, '$ ', '');
UPDATE imdb_raw
SET income = REPLACE(income, '.', '');
UPDATE imdb_raw
SET income = REPLACE(income, ',', '');

update imdb_raw
set movie_income = cast(income as unsigned);

ALTER TABLE imdb_raw MODIFY COLUMN movie_income BIGINT;

-- modifying votes column
select votes,no_of_votes
from imdb_raw;

UPDATE imdb_raw
SET votes = REPLACE(votes, '.', '');

alter table imdb_raw
add column no_of_votes bigint;

update imdb_raw
set no_of_votes = cast(votes as unsigned);

-- cleaning score column
alter table imdb_raw
add column imdb_score decimal(3,1);

select distinct score
from imdb_raw;

select score
from imdb_raw
where score regexp '[a-zA-Z,-]';

update imdb_raw
set score = '9'
where score  = '9.' or score = '9,.0';

update imdb_raw
set score = '8.9'
where score  = '8,9f' or score = '08.9';

update imdb_raw
set score = '8.8'
where score  = '88..8' or score = '8:8';

update imdb_raw
set score = '8.7'
where score  = '++8.7' or score = '8.7.' or score = '8,7e-0';

update imdb_raw
set score = '8.6'
where score  = '8,6';

update imdb_raw
set imdb_score = cast(score as float);

-- all done

select * from imdb_raw;



CREATE TABLE imdb_cleaned (
    imdb_title_id        VARCHAR(32)     PRIMARY KEY,
    title                VARCHAR(255),
    release_date         DATE,
    genre                VARCHAR(255),
    duration_in_minutes  INT,
    country              VARCHAR(100),
    content_rating       VARCHAR(50),
    director             VARCHAR(255),
    movie_income         BIGINT,
    no_of_votes          BIGINT,
    imdb_score           DECIMAL(3,1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO imdb_cleaned (
    imdb_title_id,
    title,
    release_date,
    genre,
    duration_in_minutes,
    country,
    content_rating,
    director,
    movie_income,
    no_of_votes,
    imdb_score
)
SELECT
    imdb_title_id,
    title,
    release_date,
    genre,
    duration_in_minutes,
    country,
    content_rating,
    director,
    movie_income,
    no_of_votes,
    imdb_score
FROM imdb_raw
WHERE imdb_title_id <> '';

SELECT 
    'imdb_title_id','title','release_date','genre','duration_in_minutes',
    'country','content_rating','director','movie_income','no_of_votes','imdb_score'
UNION ALL
SELECT 
    imdb_title_id,
    title,
    DATE_FORMAT(release_date, '%Y-%m-%d'),
    genre,
    duration_in_minutes,
    country,
    content_rating,
    director,
    movie_income,
    no_of_votes,
    imdb_score
FROM imdb_cleaned
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/imdb_cleaned.csv'
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

