CREATE DATABASE RecommenDB;

USE Recommendb;

-- 3.1
CREATE TABLE Movies (
MovieID INTEGER PRIMARY KEY,
Title TEXT,
Release_date DATE,
Budget INTEGER,
Genres JSON,
Spoken_languages JSON );

-- 3.2
CREATE TABLE Ratings (
UserID INTEGER,
MovieID INTEGER,
Rating INTEGER,
Timestamp DATETIME,
PRIMARY KEY (MovieID, UserID),
CONSTRAINT MovieID_FK
FOREIGN KEY (MovieID) REFERENCES Movies(MovieID));

-- 3.4
CREATE TABLE Genres (
GenreID INTEGER PRIMARY KEY,
Name TEXT) ;

-- 3.5
CREATE TABLE Movie_has_Genre (
MovieID INTEGER,
GenreID INTEGER,
PRIMARY KEY (MovieID, GenreID),
FOREIGN KEY (MovieID) REFERENCES Movies (MovieID),
FOREIGN KEY (GenreID) REFERENCES genres (GenreID)) ;

-- 
INSERT INTO Movies 
(MovieID, Title, Budget) 
VALUES 
(1, 'Toy Story', 30000000);

-- 
SELECT * FROM Movies;

-- 
INSERT INTO Movies 
(MovieID, Title) 
VALUES
(2,'Jumanji'),
(3,'Grumpier Old Men'),
(4,'Waiting to Exhale'); 

SELECT * FROM Movies;

-- 
UPDATE Movies
SET Budget = 65000000
WHERE MovieID = 2;

SELECT * FROM Movies;

-- 4.5
DELETE FROM Movies
WHERE MovieID = 2;

SELECT * FROM Movies;

-- 4.6
DELETE FROM Movies; -- Adjust MySQL Workbench Preferences: Disable "Safe Updates" under "SQL Editor"

SELECT * FROM Movies;

-- 4.7
SET GLOBAL local_infile = true;

-- 4.8
LOAD DATA LOCAL INFILE '/Users/micha/RecommenDB/movies.csv' -- set to the correct path. Windows paths must use \\ or / as separator.
INTO TABLE Movies
FIELDS ENCLOSED BY '"' ESCAPED BY '\\'
IGNORE 1 LINES;

-- 4.9
ALTER TABLE Ratings DROP CONSTRAINT MovieID_FK;
ALTER TABLE Ratings DROP PRIMARY KEY ;

LOAD DATA LOCAL INFILE  '/Users/micha/RecommenDB/ratings.csv'
INTO TABLE Ratings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 LINES 
(UserID, MovieID, Rating, @Timestamp )
SET Timestamp = FROM_UNIXTIME(@Timestamp); -- 98 sec.

-- 
ALTER TABLE Ratings ADD CONSTRAINT
PRIMARY KEY (MovieID, UserID); -- 43 sec.

-- 
DELETE FROM Ratings WHERE MovieID NOT IN (
	SELECT MovieID from Movies ); -- 11 sec.

-- 
ALTER TABLE Ratings ADD CONSTRAINT MovieID_FK
FOREIGN KEY (MovieID) REFERENCES Movies(MovieID); -- 55 sec.

--
INSERT INTO Genres
SELECT DISTINCT
Genres->>"$[0].id",
Genres->>"$[0].name"
FROM Movies
WHERE Genres->>"$[0].id" IS NOT NULL;

SELECT * FROM Genres;

--
INSERT INTO Movie_has_Genre
SELECT DISTINCT 
MovieId, 
Genres->>"$[0].id"
FROM Movies
WHERE genres->>"$[0].id" IS NOT NULL;

SELECT * FROM Movie_has_Genre;

-- 5.1
SELECT UserID, MovieID
FROM Ratings 
WHERE rating = 5 ;

-- 5.3
SELECT UserID, m.MovieID, Title
FROM Ratings r, Movies m
WHERE rating = 5 
AND r.MovieID = m.MovieID;

SELECT UserID, m.MovieID, Title
FROM Ratings r
JOIN Movies m 
ON r.MovieID = m.MovieID
WHERE rating = 5 ;

-- 5.4
CREATE OR REPLACE VIEW Ratings5 AS 
SELECT UserID, m.MovieID, Title
FROM Ratings r, Movies m
WHERE rating = 5 
AND r.MovieID = m.MovieID;

-- 5.5
SELECT * FROM Ratings5;

-- 5.6
SELECT * 
FROM Movies 
WHERE Title LIKE '%Wall%';

-- 5.7
SELECT userId AS TargetGroup
FROM Ratings5 
WHERE MovieID = 1371;

-- 5.8
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5
WHERE MovieId = 1371;

-- 5.9
SELECT MovieID, Title, COUNT(*) AS N5R
FROM Ratings5
GROUP BY MovieID;

-- 5.10
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5
GROUP BY MovieID
ORDER BY COUNT(*) DESC;

-- 5.11
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5
GROUP BY MovieID
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 5.11

SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5
WHERE UserID IN (
SELECT UserId AS TargetGroup
FROM Ratings5 
WHERE MovieID = 60069 )
GROUP BY MovieID
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 6.1
EXPLAIN 
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5
WHERE UserID IN (
	SELECT UserId AS TargetGroup
	FROM Ratings5
	WHERE MovieID = 1371 )
GROUP BY MovieID
ORDER BY COUNT(*) DESC;

-- 6.2
CREATE TABLE Ratings5M AS 
SELECT UserID, m.MovieID, Title
FROM Ratings r, Movies m
WHERE rating = 5 
AND r.MovieID = m.MovieID;

-- 6.3 
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5m
WHERE UserID IN (
SELECT UserId AS TargetGroup
FROM Ratings5m 
WHERE MovieID = 1371 )
GROUP BY MovieID, Title
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 6.4
EXPLAIN
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5m
WHERE UserID IN (
SELECT UserId AS TargetGroup
FROM Ratings5m 
WHERE MovieID = 1371 )
GROUP BY MovieID, Title
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 6.5
CREATE TABLE Ratings5MI AS 
SELECT UserID, m.MovieID, Title
FROM Ratings r, Movies m
WHERE rating = 5 
AND r.MovieID = m.MovieID;

CREATE INDEX IX_MovieID ON Ratings5MI(MovieID);
CREATE INDEX IX_UserID ON Ratings5MI(USerID);

-- 6.6
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5MI
WHERE UserID IN (
	SELECT UserId AS TargetGroup
	FROM Ratings5MI
	WHERE MovieID = 1371 )
GROUP BY MovieID, Title
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 6.7
EXPLAIN
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5MI
WHERE UserID IN (
SELECT UserId AS TargetGroup
FROM Ratings5MI 
WHERE MovieID = 1371 )
GROUP BY MovieID, Title
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 6.8

-- 6.8
-- DROP TABLE Ratings5MIS;
CREATE TABLE Ratings5MIS AS 
SELECT UserID, m.MovieID, Title, Budget
FROM Ratings r, Movies m
WHERE rating = 5 
AND r.MovieID = m.MovieID
AND RAND() < 0.5;

CREATE INDEX IX_MovieID 
ON Ratings5MIS(MovieID);

CREATE INDEX IX_UserID 
ON Ratings5MIS(USerID);

-- 6.9
-- 0.052sec
SELECT MovieId, Title, COUNT(*) AS N5R
FROM Ratings5MIS
WHERE UserID IN (
	SELECT UserId AS TargetGroup
	FROM Ratings5MIS
	WHERE MovieID = 1371 )
GROUP BY MovieID, Title
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 6.10
SELECT MovieId, Title, COUNT(*) AS N_Ratings5_Target
FROM Ratings5MIS
WHERE UserID IN (
	SELECT UserId AS TargetGroup
	FROM Ratings5MIS
	WHERE MovieID = 1097 )
GROUP BY MovieID, Title
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 6.11
DROP TABLE rating_numbers ;

Use RecommenDB;

CREATE TABLE Rating_Numbers as
SELECT MovieID, COUNT(*) as NR,
-- COUNT(*) as N_Ratings_All,
SUM(CASE WHEN Rating = 5 THEN 1 ELSE 0 END) as N_Ratings5_All
FROM Ratings
GROUP BY movieId;

CREATE TABLE Rating_Numbers as
SELECT MovieID, 
COUNT(*) as N_Ratings5_All
FROM Ratings
WHERE Rating = 5
GROUP BY movieId;

CREATE INDEX IX_MovieID 
ON rating_numbers(MovieID);

select * from rating_numbers
order by nr desc;

-- 6.12
SELECT MovieId, r.Title, N_Ratings5_all, COUNT(*) AS N_Ratings5_target
FROM Ratings5MIS r
JOIN rating_numbers USING (MovieID)
WHERE UserID IN (
	SELECT UserId AS TargetGroup
	FROM Ratings5MIS
	WHERE MovieID = 1097 )
GROUP BY MovieID, Title, N_Ratings5_all
ORDER BY COUNT(*)*COUNT(*)/N_Ratings5_all DESC
LIMIT 10;


-- 7.1
-- 
DROP USER admin@localhost;
CREATE USER admin@localhost IDENTIFIED BY 'pass';

-- 7.2
UNINSTALL COMPONENT 'file://component_validate_password';
INSTALL COMPONENT 
'file://component_validate_password'; 

SET GLOBAL validate_password.policy = 1;
-- SET GLOBAL validate_password.length = 8;

SHOW VARIABLES LIKE 'validate_password.%';

-- 7.3
-- DROP USER gui@localhost;

CREATE USER gui@localhost IDENTIFIED BY 'pass';

-- 7.4
SELECT VALIDATE_PASSWORD_STRENGTH('pass');

-- 7.5
SELECT VALIDATE_PASSWORD_STRENGTH('HPgr_9$5');

-- 7.6

ALTER USER admin@localhost
IDENTIFIED BY 'HPgr_9$5';

DROP USER admin@'%';

CREATE USER admin@'%' 
IDENTIFIED BY 'HPgr_9$5';

-- 7.7
DROP USER gui@'%';
DROP USER gui@localhost;

CREATE USER gui@localhost
IDENTIFIED BY 'fl3SF1k_$';

CREATE USER gui@'%' 
IDENTIFIED BY 'fl3SF1k_$';

-- &allowPublicKeyRetrieval=true

-- 7.8

SELECT Host, User from  mysql.USER
WHERE User in ('admin', 'gui');


-- 7.7
GRANT ALL PRIVILEGES ON *.* TO admin@localhost;

SHOW GRANTS FOR admin@localhost;

FLUSH PRIVILEGES;
 -- damit wird das neue PW aktiv
-- > test login with new user

-- GRANT SELECT ON RecommenDB.* TO  gui@localhost;

-- DROP DATABASE Visualization;
CREATE DATABASE Visualization;

CREATE OR REPLACE VIEW Visualization.Movies AS SELECT * FROM RecommenDB.Movies;

CREATE OR REPLACE VIEW Visualization.rating_numbers AS SELECT * FROM RecommenDB.rating_numbers;

CREATE OR REPLACE VIEW Visualization.Ratings5MIS AS SELECT * FROM RecommenDB.Ratings5MIS;

GRANT SELECT ON Visualization.* TO  gui@localhost;

SHOW GRANTS FOR gui@localhost;

FLUSH PRIVILEGES;

show tables;


 -- 8
 use visualization; 
 
 -- 8.1
SELECT MovieId, r.Title, 
N_Ratings5_All, 
COUNT(*) AS N_Ratings5_Target
FROM Ratings5MIS r
JOIN rating_numbers USING (MovieID)
WHERE UserID IN (
	SELECT UserId AS TargetGroup
	FROM Ratings5MIS
	WHERE MovieID = 1097 )
GROUP BY MovieID, Title, N_Ratings5_All
ORDER BY COUNT(*)*COUNT(*)/N_Ratings5_All DESC
LIMIT 10;

-- 8.2

SELECT MovieId, r.Title, 
N_Ratings5_All, 
COUNT(*) AS N_Ratings5_Target
FROM Ratings5MIS r
JOIN rating_numbers USING (MovieID)
WHERE UserID IN (
	SELECT UserId AS TargetGroup
	FROM Ratings5MIS
	WHERE MovieID = ( 
 	    SELECT MovieID
 		FROM Movies
 		WHERE {{filter}} LIMIT 1 )
    )
GROUP BY MovieID, Title, N_Ratings5_All
ORDER BY COUNT(*)*COUNT(*)/N_Ratings5_All DESC
LIMIT 10;
