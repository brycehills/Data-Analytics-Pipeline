-- Problem 5: Data Transformation.  - raw -> pub 
--it is very inefficient to bulk insert into a 
-- table that contains a key and/or foreign keys (why?); to speed up, 
--you may drop the key/foreign key constraints

-- hint: create temporary tables (and indices) to speedup the data transformation
CREATE TABLE temp_Author (
		PubKey TEXT NOT NULL,
		Name TEXT
		);

CREATE TABLE temp_Title (
		PubKey TEXT NOT NULL UNIQUE,
		Title TEXT
		);
		
CREATE TABLE temp_Year (
		PubKey TEXT NOT NULL UNIQUE,
		Year TEXT
		);

CREATE TABLE temp_Journal (
		PubKey TEXT NOT NULL UNIQUE,
		Journal TEXT
		);

CREATE TABLE temp_Publisher (
		PubKey TEXT NOT NULL UNIQUE,
		Publisher TEXT
		);

CREATE TABLE temp_Month (
		PubKey TEXT NOT NULL UNIQUE,
		Month TEXT
		);
		
CREATE TABLE temp_Volume (
		PubKey TEXT NOT NULL UNIQUE,
		Volume TEXT
		);
	
CREATE TABLE temp_Number (
		PubKey TEXT NOT NULL UNIQUE,
		Number TEXT
		);

CREATE TABLE temp_ISBN (
		PubKey TEXT NOT NULL UNIQUE,
		ISBN TEXT
		);

CREATE TABLE temp_BookTitle (
		PubKey TEXT NOT NULL UNIQUE,
		BookTitle TEXT
		);
		
CREATE TABLE temp_Editor (
		PubKey TEXT NOT NULL UNIQUE,
		Editor TEXT
		);

INSERT INTO temp_Author (SELECT k, v FROM Field WHERE p = 'author');
	
WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'title')
INSERT INTO temp_Title (SELECT k, v FROM temp WHERE r = 1);

WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'year')
INSERT INTO temp_Year (SELECT k, v FROM temp WHERE r = 1);

WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'journal')
INSERT INTO temp_Journal (SELECT k, v FROM temp WHERE r = 1);

WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'publisher')
INSERT INTO temp_Publisher (SELECT k, v FROM temp WHERE r = 1);

WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'month')
INSERT INTO temp_Month (SELECT k, v FROM temp WHERE r = 1);

WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'volume')
INSERT INTO temp_Volume (SELECT k, v FROM temp WHERE r = 1);
	
WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'number')
INSERT INTO temp_Number (SELECT k, v FROM temp WHERE r = 1);

WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'isbn')
INSERT INTO temp_ISBN (SELECT k, v FROM temp WHERE r = 1);

WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'booktitle')
INSERT INTO temp_BookTitle (SELECT k, v FROM temp WHERE r = 1);

WITH temp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
				FROM Field WHERE p = 'editor')
INSERT INTO temp_Editor (SELECT k, v FROM temp WHERE r = 1);


-- PubSchema requires an integer key for each author and each publication. Use a sequence in postgres.				
CREATE SEQUENCE sequence_Author;
CREATE SEQUENCE sequence_Publication;


--Your challenge is to find out how to identify each author's correct Homepage. 
--(A small number of authors have two correct, but distinct homepages; you may choose any of them to insert in Author)
CREATE TABLE temp_Homepage (
	Name TEXT NOT NULL UNIQUE,
	Homepage TEXT
	);
	
WITH temp AS (SELECT row_number() over (partition BY ta.Name) AS r, ta.Name, f2.v AS hp
				FROM temp_Author ta INNER JOIN Field f1 ON ta.PubKey = f1.k
						INNER JOIN Field f2 ON ta.PubKey = f2.k
				WHERE f1.p = 'title' AND f1.v = 'Home Page' AND f2.p = 'url')
INSERT INTO temp_Homepage (SELECT Name, hp FROM temp WHERE temp.r = 1);
				
						
INSERT INTO Author (
	SELECT NEXTVAL('sequence_Author'), tn.Name, hp.Homepage
		FROM (SELECT DISTINCT Name FROM temp_Author) AS tn 
				LEFT OUTER JOIN temp_Homepage AS hp ON tn.Name = hp.Name
	);
	
INSERT INTO Publication (
	SELECT NEXTVAL('sequence_Publication'), p.k, tt.Title, ty.Year
		FROM Pub AS p 
			LEFT OUTER JOIN temp_Title AS tt ON p.k = tt.PubKey
			LEFT OUTER JOIN temp_Year AS ty ON p.k = ty.PubKey
		WHERE p.p in ('article', 'book', 'inproceedings', 'incollection')
	);
	
drop table temp_Homepage;
drop sequence sequence_Author;	
drop sequence sequence_Publication;


INSERT INTO Authored(
	SELECT DISTINCT a.AuthorID, p.PubID
		FROM temp_Author AS tn 
			INNER JOIN Author AS a on tn.Name = a.Name
			INNER JOIN Publication AS p ON tn.PubKey = p.PubKey
	);

INSERT INTO Article (
	SELECT p.PubID, tj.Journal, tm.Month, tv.Volume, tn.Number
		FROM Publication AS p
			LEFT OUTER JOIN temp_Journal AS tj ON p.PubKey = tj.PubKey
			LEFT OUTER JOIN temp_Month AS tm ON p.PubKey = tm.PubKey
			LEFT OUTER JOIN temp_Volume AS tv ON p.PubKey = tv.PubKey
			LEFT OUTER JOIN temp_Number AS tn ON p.PubKey = tn.PubKey
		WHERE EXISTS (
			SELECT * FROM Pub
			WHERE Pub.k = p.PubKey and Pub.p = 'article'
			)
	);	

INSERT INTO Book (
	SELECT p.PubID, tp.Publisher, ti.ISBN
		FROM Publication AS p
			LEFT OUTER JOIN temp_Publisher AS tp ON p.PubKey = tp.PubKey
			LEFT OUTER JOIN temp_ISBN AS ti ON p.PubKey = ti.PubKey
		WHERE EXISTS (
			SELECT * FROM Pub
			WHERE Pub.k = p.PubKey and Pub.p = 'book'
			)
	);

INSERT INTO Incollection (
	SELECT p.PubID, tb.BookTitle, tp.Publisher, ti.ISBN
		FROM Publication AS p
			LEFT OUTER JOIN temp_BookTitle AS tb ON p.PubKey = tb.PubKey
			LEFT OUTER JOIN temp_Publisher AS tp ON p.PubKey = tp.PubKey
			LEFT OUTER JOIN temp_ISBN AS ti ON p.PubKey = ti.PubKey
		WHERE EXISTS (
			SELECT * FROM Pub
			WHERE Pub.k = p.PubKey and Pub.p = 'incollection'
			)
	);
	
INSERT INTO Inproceedings (
	SELECT p.PubID, tb.BookTitle, te.Editor
		FROM Publication AS p
			LEFT OUTER JOIN temp_BookTitle AS tb ON p.PubKey = tb.PubKey
			LEFT OUTER JOIN temp_Editor AS te ON p.PubKey = te.PubKey
		WHERE EXISTS (
			SELECT * FROM Pub
			WHERE Pub.k = p.PubKey and Pub.p = 'inproceedings'
			)
	);
	

-- hint: Remember to drop all your temp tables when you are done
drop table temp_Author;
drop table temp_Title;
drop table temp_Year;
drop table temp_Journal;
drop table temp_Publisher;
drop table temp_Month;
drop table temp_Volume;
drop table temp_Number;
drop table temp_ISBN;
drop table temp_BookTitle;
drop table temp_Editor;
