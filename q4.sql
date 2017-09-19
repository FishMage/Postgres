/*
--q4a
DROP VIEW IF EXISTS journal;
DROP VIEW IF EXISTS conference;

CREATE VIEW journal as
SELECT COUNT(a.pubkey) j_count, FLOOR(a.year/10)*10 as decades
FROM article a
WHERE a.year >= 1950
GROUP BY decades;

CREATE VIEW conference as
SELECT COUNT(i.pubkey) as c_count, FLOOR(i.year/10)*10 as decades
FROM inproceedings i
WHERE i.year >= 1950
GROUP BY decades;

--select both
SELECT j.decades, j.j_count, c.c_count
FROM journal j full outer join conference c
on j.decades = c.decades
ORDER BY j.decades asc;
*/
--q4b

--table storing each each author's publish activities in diff decades and area
DROP VIEW IF EXISTS author_decades_area;

--4 individual view storing data of Authorship, area and decades
DROP VIEW IF EXISTS database_dacades;
DROP VIEW IF EXISTS theory_decades;
DROP VIEW IF EXISTS systems_decades;
DROP VIEW IF EXISTS mlai_decades;

--table storing one author and his/her collaborator's info
DROP VIEW IF EXISTS collaboration;
DROP VIEW IF EXISTS collaborate_article;
DROP VIEW IF EXISTS collaborate_inproceedings;

-- Collaboration for article
-- Author| collaborator| decades
CREATE VIEW collaborate_article as
SELECT a1.author as author, a2.author as collaborator, FLOOR(article.year/10)*10 as decades
FROM Authorship a1, Authorship a2, article
WHERE a1.pubkey = article.pubkey and (a1.pubkey = a2.pubkey and a1.author != a2.author)
GROUP BY a1.author, a2.author, FLOOR(article.year/10)*10
HAVING COUNT(*) = 1;

-- Collaboration for inproceedings
-- Author| collaborator| decades
CREATE VIEW collaborate_inproceedings as
SELECT a1.author as author, a2.author as collaborator, FLOOR(i.year/10)*10 as decades
FROM Authorship a1, Authorship a2, inproceedings i
WHERE a1.pubkey = i.pubkey and (a1.pubkey = a2.pubkey and a1.author != a2.author)
GROUP BY a1.author, a2.author, FLOOR(i.year/10)*10
HAVING COUNT(*) = 1;

-- Collaboration for both inproceedings& articles
-- Union of two views
CREATE VIEW collaboration as
SELECT * 
FROM collaborate_article
UNION 
SELECT *
FROM collaborate_inproceedings;



CREATE VIEW database_dacades as
SELECT a.author as author, FLOOR(i.year/10)*10 as decades, i.Area as area
FROM Authorship a, inproceedings i
WHERE a.pubkey = i.pubkey and i.area = 'Database'
GROUP BY a.author, FLOOR(i.year/10)*10, i.Area
HAVING COUNT(*) = 1;

CREATE VIEW theory_decades as
SELECT a.author as author, FLOOR(i.year/10)*10 as decades, i.Area as area
FROM Authorship a, inproceedings i
WHERE a.pubkey = i.pubkey and i.area = 'Theory'
GROUP BY a.author, FLOOR(i.year/10)*10, i.Area
HAVING COUNT(*) = 1;

CREATE VIEW systems_decades as
SELECT a.author as author, FLOOR(i.year/10)*10 as decades, i.Area as area
FROM Authorship a, inproceedings i
WHERE a.pubkey = i.pubkey and i.area = 'Systems'
GROUP BY a.author, FLOOR(i.year/10)*10, i.Area
HAVING COUNT(*) = 1;

CREATE VIEW mlai_decades as
SELECT a.author as author, FLOOR(i.year/10)*10 as decades, i.Area as area
FROM Authorship a, inproceedings i
WHERE a.pubkey = i.pubkey and i.area = 'ML-AI'
GROUP BY a.author, FLOOR(i.year/10)*10, i.Area
HAVING COUNT(*) = 1;

CREATE VIEW author_decades_area as
SELECT * FROM database_dacades
UNION 
SELECT * FROM theory_decades
UNION 
SELECT * FROM systems_decades
UNION
SELECT * from mlai_decades;

--Final Result
SELECT ada_col.decades, AVG(ada_col.col), ada_col.area
FROM
(
  SELECT c.author as author, COUNT(c.collaborator) as col, c.decades as decades, ada.area as area
  FROM author_decades_area ada, collaboration c
  WHERE ada.author = c.author and ada.decades = c.decades
  GROUP BY ada.area, c.decades, c.author
) as ada_col
GROUP BY ada_col.decades, ada_col.area;
