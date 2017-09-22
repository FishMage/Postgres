--q3a
SELECT COUNT(*),i.Area
FROM inproceedings i
GROUP BY i.Area; 

--q3b
SELECT a.author
FROM Authorship a, inproceedings i
WHERE a.pubkey = i.pubkey and i.Area = 'Database'
GROUP BY a.author
ORDER BY COUNT (a.pubkey) DESC
LIMIT 20;

--q3c
SELECT COUNT(author_count.author)
FROM (
      SELECT a.author, COUNT(DISTINCT i.area) AS a_count
      FROM Authorship a, inproceedings i
      WHERE a.pubkey = i.pubkey and i.Area != 'UNKNOWN'
      GROUP BY a.author
    ) as author_count
WHERE author_count.a_count = 2;

--q3d
--DROP VIEW IF EXISTS a_journal;
--DROP VIEW IF EXISTS a_conference;
with a_journal as(
    --CREATE VIEW a_journal as
    SELECT a.author as a_name, COUNT(article.pubkey) as art_count
    FROM Authorship a, article
    WHERE a.pubkey = article.pubkey
    GROUP BY a.author
    ),

    a_conference as (
    --CREATE VIEW a_conference as 
    SELECT a.author as a_name, COUNT(i.pubkey) as in_count
    FROM Authorship a, inproceedings i
    WHERE a.pubkey = i.pubkey
    GROUP BY a.author
    )

SELECT COUNT(a_journal.a_name)
FROM a_journal left join a_conference
on a_journal.a_name = a_conference.a_name
WHERE (a_journal.art_count > a_conference.in_count OR a_conference.in_count is NULL);

--q3e
--DROP VIEW IF EXISTS a_database;
--DROP VIEW IF EXISTS a_union_j_c;
--DROP VIEW IF EXISTS a_journal_2000;
--DROP VIEW IF EXISTS a_conference_2000;

--Author who publish at least one paper in Database
--CREATE VIEW a_database as
with a_database as(
    SELECT DISTINCT a.author as a_name
    FROM Authorship a, inproceedings i
    WHERE a.pubkey = i.pubkey and i.Area = 'Database'
  ),

a_journal_2000 as( 
    --CREATE VIEW a_journal_2000 as 
    SELECT DISTINCT a.author as a_name, article.pubkey as pubkey 
    FROM Authorship a, article
    WHERE a.pubkey = article.pubkey and article.year >= 2000
  ),

    --CREATE VIEW a_conference_2000 as
a_conference_2000 as (
    SELECT DISTINCT Author as a_name, i.pubkey as pubkey
    FROM Authorship a, inproceedings i
    WHERE a.pubkey = i.pubkey and i.year >= 2000
  ),

    --CREATE VIEW a_union_j_c as 
a_union_j_c as(
    SELECT *
    FROM a_journal_2000 
    UNION ALL 
    SELECT *
    FROM a_conference_2000
  )
--find top 5 authors
SELECT db.a_name, COUNT(u.pubkey) as a_count
FROM a_database as db, a_union_j_c as u
WHERE db.a_name = u.a_name
GROUP BY db.a_name
ORDER BY COUNT(u.pubkey) DESC
LIMIT 5;
