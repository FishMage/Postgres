--q4a
--DROP VIEW IF EXISTS journal;
--DROP VIEW IF EXISTS conference;

--CREATE VIEW journal as
--CREATE VIEW conference as

with conference as(
    SELECT COUNT(i.pubkey) as c_count, FLOOR(i.year/10)*10 as decades
    FROM inproceedings i
    WHERE i.year >= 1950
    GROUP BY decades
  ),

journal as(
    SELECT COUNT(a.pubkey) j_count, FLOOR(a.year/10)*10 as decades
    FROM article a
    WHERE a.year >= 1950
    GROUP BY decades
  )

--select both
SELECT j.decades, j.j_count, c.c_count
FROM journal j full outer join conference c
on j.decades = c.decades
ORDER BY j.decades asc;

--q4b
--table storing each each author's publish activities in diff decades and area
--
--4 individual view storing data of Authorship, area and decades
--
--table storing one author and his/her collaborator's info
-- Collaboration for article
-- Author| collaborator| decades
with collaborate_article as(
    SELECT a1.author as author, a2.author as collaborator, FLOOR(article.year/10)*10 as decades
    FROM Authorship a1, Authorship a2, article
    WHERE a1.pubkey = article.pubkey and (a1.pubkey = a2.pubkey and a1.author != a2.author)
    GROUP BY a1.author, a2.author, FLOOR(article.year/10)*10
    HAVING COUNT(*) = 1
  ),
-- Collaboration for inproceedings
-- Author| collaborator| decades
collaborate_inproceedings as(
    --CREATE VIEW collaborate_inproceedings as
    SELECT a1.author as author, a2.author as collaborator, FLOOR(i.year/10)*10 as decades
    FROM Authorship a1, Authorship a2, inproceedings i
    WHERE a1.pubkey = i.pubkey and (a1.pubkey = a2.pubkey and a1.author != a2.author)
    GROUP BY a1.author, a2.author, FLOOR(i.year/10)*10
    HAVING COUNT(*) = 1
  ),

--author_decaces_area
--CREATE VIEW database_dacades as
database_dacades as(
    SELECT a.author as author, FLOOR(i.year/10)*10 as decades, i.Area as area
    FROM Authorship a, inproceedings i
    WHERE a.pubkey = i.pubkey and i.area = 'Database'
    GROUP BY a.author, FLOOR(i.year/10)*10, i.Area
    HAVING COUNT(*) = 1
  ),

--CREATE VIEW theory_decades as
theory_decades as(
    SELECT a.author as author, FLOOR(i.year/10)*10 as decades, i.Area as area
    FROM Authorship a, inproceedings i
    WHERE a.pubkey = i.pubkey and i.area = 'Theory'
    GROUP BY a.author, FLOOR(i.year/10)*10, i.Area
    HAVING COUNT(*) = 1
  ),

systems_decades as(
    SELECT a.author as author, FLOOR(i.year/10)*10 as decades, i.Area as area
    FROM Authorship a, inproceedings i
    WHERE a.pubkey = i.pubkey and i.area = 'Systems'
    GROUP BY a.author, FLOOR(i.year/10)*10, i.Area
    HAVING COUNT(*) = 1
  ),

mlai_decades as(
    SELECT a.author as author, FLOOR(i.year/10)*10 as decades, i.Area as area
    FROM Authorship a, inproceedings i
    WHERE a.pubkey = i.pubkey and i.area = 'ML-AI'
    GROUP BY a.author, FLOOR(i.year/10)*10, i.Area
    HAVING COUNT(*) = 1
  ),

author_decades_area as(
    SELECT * FROM database_dacades
    UNION 
    SELECT * FROM theory_decades
    UNION 
    SELECT * FROM systems_decades
    UNION
    SELECT * from mlai_decades
  ),
-- Collaboration for both inproceedings& articles
-- Union of two views
--CREATE VIEW collaboration as
collaboration as(
    SELECT * 
    FROM collaborate_article
    UNION 
    SELECT *
    FROM collaborate_inproceedings
  )

--Final Result
SELECT ada_col.decades,AVG(ada_col.col), ada_col.area
FROM
(
  SELECT c.author as author, COUNT(c.collaborator) as col, c.decades as decades, ada.area as area
  FROM author_decades_area ada, collaboration c
  WHERE ada.author = c.author and ada.decades = c.decades
  GROUP BY ada.area, c.decades, c.author
) as ada_col
GROUP BY ada_col.decades, ada_col.area;

--q4c
with AuthorCount_paper_area_decade as(
  SELECT i.pubkey as pubkey, FLOOR(i.year/10)*10 as decades, i.Area as area, COUNT(a.author) as numAuthor

  FROM inproceedings i, authorship a 
  WHERE FLOOR(i.year/10)*10 >= 1950 and i.Area != 'UNKNOWN' and i.pubkey = a.pubkey
  GROUP BY i.pubkey, decades, i.area
  ORDER BY decades ASC
)
SELECT apad.decades, apad.area, AVG(apad.numAuthor)
FROM AuthorCount_paper_area_decade apad
GROUP BY apad.decades, apad.area
ORDER BY apad.decades ASC;

--q4d
-- datapoints
with AuthorCount_paper_area_decade as(
  SELECT i.pubkey as pubkey, FLOOR(i.year/10)*10 as decades, i.Area as area, COUNT(a.author) as numAuthor

  FROM inproceedings i, authorship a 
  WHERE FLOOR(i.year/10)*10 >= 1950 and i.Area != 'UNKNOWN' and i.pubkey = a.pubkey
  GROUP BY i.pubkey, decades, i.area
  ORDER BY decades ASC
),
area_decade_avgAuthor as (
  SELECT apad.decades as x, apad.area as area, AVG(apad.numAuthor) as y
  FROM AuthorCount_paper_area_decade apad
  GROUP BY apad.decades, apad.area
  ORDER BY apad.decades ASC
)
SELECT s.area, s.slope 
FROM (
  SELECT a.area ,(COUNT(a.x) *sum(a.x*a.y) - SUM(a.x)*SUM(a.y))/(COUNT(a.x)*SUM(a.x*a.x) - SUM(a.x)* SUM(a.x)) as slope
  FROM area_decade_avgAuthor a
  GROUP BY a.area
) as s
GROUP BY s.AREA, s.slope;

