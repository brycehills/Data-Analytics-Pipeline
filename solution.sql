-- 1. For each type of publication, count the total number of publications of that type. 
-- Your query should return a set of (publication-type, count) pairs.
SELECT p AS Publication_Type, COUNT(*) FROM pub GROUP BY p;

/* 1. Solution:
 publication_type |  count
------------------+---------
 article          | 5715860
 book             |   38814
 incollection     |  136070
 inproceedings    | 6067310
 mastersthesis    |      26
 phdthesis        |  174384
 proceedings      |  101808
 www              | 6004882
*/

-- 2.
/*We say that a field occurs in a publication type, if there exists at least one publication of that type having that field. For example, publisher occurs in incollection, but publisher does not occur in inproceedings. Find the fields that occur in all publications types. Your query should return a set of field names: for example it may return title, if title occurs in all publication types (article, inproceedings, etc. notice that title does not have to occur in every publication instance, only in some instance of every type), but it should not return publisher (since the latter does not occur in any publication of type inproceedings).*/
SELECT f.p AS field_name
FROM Pub p, Field f
WHERE p.k = f.k
GROUP BY f.p
HAVING COUNT (DISTINCT p.p) >= (SELECT COUNT(DISTINCT p) FROM pub);

/* 2. Solution:
 field_name
------------
 author
 ee
 note
 title
 year
*/

-- Part 3:
/*Your two queries above may be slow. Speed them up by creating appropriate indexes, 
using the CREATE INDEX statement. You also need indexes on 
Pub and Field for the next question;*/
CREATE INDEX PubKey ON Pub(k);
CREATE INDEX PubP ON Pub(p);
CREATE INDEX FieldKey ON Field(k);
CREATE INDEX FieldP ON Field(p);
CREATE INDEX FieldV ON Field(v);


--Find the top 20 authors with the largest number of publications. (Runtime: under 10s)
WITH tmpAuth AS (SELECT AuthorID, COUNT(PubID) AS Number_Publications
                                FROM Authored
                                GROUP BY AuthorID
                                ORDER BY Number_Publications DESC
                                LIMIT 20)
SELECT a.AuthorID, Name, Number_Publications
        FROM Author AS a INNER JOIN tmpAuth ON a.AuthorID = tmpAuth.AuthorID;
		
--result:
/*
 authorid |         name         | number_publications
----------+----------------------+---------------------
  1567064 | H. Vincent Poor      |                2462
  2344069 | Mohamed-Slim Alouini |                1828
    21968 | Philip S. Yu         |                1725
    11915 | Yang Liu             |                1646
    23708 | Wei Wang             |                1628
    20910 | Lajos Hanzo          |                1562
     2787 | Wei Zhang            |                1480
  2347963 | Yu Zhang             |                1475
   830935 | Zhu Han 0001         |                1426
   833532 | Lei Zhang            |                1409
    34818 | Dacheng Tao          |                1383
  1561462 | Lei Wang             |                1379
    37206 | Victor C. M. Leung   |                1365
    38142 | Wen Gao 0001         |                1346
    32589 | Witold Pedrycz       |                1345
    32800 | Hai Jin 0001         |                1331
  2349079 | Wei Li               |                1310
    29504 | Xin Wang             |                1309
    26704 | Luca Benini          |                1262
    25092 | Li Zhang             |                1247
*/
		

--Find the top 20 authors with the largest number of publications in STOC. 
--Suggestions: top 20 authors in SOSP, or CHI, or SIGMOD, or SIGGRAPH; note that you need to do some digging to find out how DBLP spells the name of your conference. (Runtime: under 10s.)
CREATE MATERIALIZED VIEW STOC AS
	SELECT DISTINCT f.k AS PubKey
		FROM Field f
		WHERE (f.p = 'booktitle' AND f.v LIKE '%STOC%') OR
			  (f.p = 'crossref' AND f.v LIKE '%STOC%') OR
			  (f.p = 'title' AND f.v LIKE '%Symposium on Theory of Computing%');

WITH tmp AS (SELECT ad.AuthorID, COUNT(ad.PubID) AS Number_Publications
				FROM Authored AS ad
					INNER JOIN Publication AS p ON ad.PubID = p.PubID
					INNER JOIN STOC AS s ON p.PubKey = s.PubKey
				GROUP BY ad.AuthorID
				ORDER BY Number_Publications DESC
				LIMIT 20)
SELECT a.AuthorID, Name, Number_Publications
	FROM Author AS a INNER JOIN tmp ON a.AuthorID = tmp.AuthorID;
	
/*
output:

 authorid |           name            | number_publications
----------+---------------------------+---------------------
  2295732 | Avi Wigderson             |                  58
     3606 | Robert Endre Tarjan       |                  33
  2028693 | Ran Raz                   |                  30
   428494 | Moni Naor                 |                  29
    21807 | Noam Nisan                |                  29
    51839 | Uriel Feige               |                  28
   878533 | Santosh S. Vempala        |                  27
  2394894 | Rafail Ostrovsky          |                  27
    71546 | Mihalis Yannakakis        |                  26
     3565 | Venkatesan Guruswami      |                  26
     9024 | Oded Goldreich 0001       |                  25
  2322336 | Frank Thomson Leighton    |                  25
     9063 | Prabhakar Raghavan        |                  24
  2344692 | Mikkel Thorup             |                  24
    11739 | Christos H. Papadimitriou |                  24
    34940 | Rocco A. Servedio         |                  23
  2358513 | Yin Tat Lee               |                  23
  2566708 | Moses Charikar            |                  23
    16078 | Noga Alon                 |                  22
    11905 | Sanjeev Khanna            |                  22
(20 rows)
*/

--Repeat this for two more conferences, of your choice. 
--sigmod
CREATE MATERIALIZED VIEW SIGMOD AS
	SELECT DISTINCT f.k AS PubKey
		FROM Field f
		WHERE (f.p = 'booktitle' AND f.v LIKE '%SIGMOD%') OR
			  (f.p = 'cdrom' AND f.v LIKE '%SIGMOD%') OR
			  (f.p = 'journal' AND f.v LIKE '%SIGMOD%') OR
			  (f.p = 'note' AND f.v LIKE '%SIGMOD%') OR
			  (f.p = 'url' AND f.v LIKE '%SIGMOD%') OR
			  (f.p = 'title' AND f.v LIKE '%SIGMOD%') OR
			  (f.p = 'title' AND f.v LIKE '%Special Interest Group on Management of Data%');

WITH temp AS (SELECT ad.AuthorID, COUNT(ad.PubID) AS NumPublications
				FROM Authored AS ad
					INNER JOIN Publication AS p ON ad.PubID = p.PubID
					INNER JOIN SIGMOD AS si ON p.PubKey = si.PubKey
				GROUP BY ad.AuthorID
				ORDER BY NumPublications DESC
				LIMIT 20)
SELECT a.AuthorID, Name, NumPublications
	FROM Author AS a INNER JOIN temp ON a.AuthorID = temp.AuthorID;
	
/* result:
 authorid |         name          | numpublications
----------+-----------------------+-----------------
    29737 | Marianne Winslett     |             104
    37128 | Michael Stonebraker   |              82
    28852 | H. V. Jagadish        |              74
    32487 | Surajit Chaudhuri     |              71
    15313 | Richard T. Snodgrass  |              70
    14870 | Michael J. Franklin   |              67
    22558 | Divesh Srivastava     |              66
  2832829 | Michael J. Carey 0001 |              62
   713744 | Jeffrey F. Naughton   |              62
  1155927 | David J. DeWitt       |              59
    34618 | Beng Chin Ooi         |              58
     7934 | Dan Suciu             |              57
  2680514 | Hector Garcia-Molina  |              51
    18567 | Samuel Madden         |              51
    12087 | Joseph M. Hellerstein |              50
     1517 | Johannes Gehrke       |              49
    44000 | Donald Kossmann       |              48
    15284 | Jiawei Han 0001       |              48
  1710849 | Jennifer Widom        |              48
    36493 | Tim Kraska            |              47
(20 rows)
*/
	
--pods
CREATE MATERIALIZED VIEW PODS AS
	SELECT DISTINCT f.k AS PubKey
		FROM Field f
		WHERE (f.p = 'booktitle' AND f.v LIKE '%PODS%') OR
			  (f.p = 'title' AND f.v LIKE '%Principles of Database Systems%');

WITH tmp AS (SELECT ad.AuthorID, COUNT(ad.PubID) AS NumPublications
				FROM Authored AS ad
					INNER JOIN Publication AS p ON ad.PubID = p.PubID
					INNER JOIN PODS AS si ON p.PubKey = si.PubKey
				GROUP BY ad.AuthorID
				ORDER BY NumPublications DESC
				LIMIT 20)
SELECT a.AuthorID, Name, NumPublications
	FROM Author AS a INNER JOIN tmp ON a.AuthorID = tmp.AuthorID;
	
/*result:
 authorid |           name            | numpublications
----------+---------------------------+-----------------
    33806 | Leonid Libkin             |              38
    11235 | Victor Vianu              |              32
    12883 | Georg Gottlob             |              32
     7934 | Dan Suciu                 |              31
  2689596 | Phokion G. Kolaitis       |              31
  2344233 | Yehoshua Sagiv            |              31
   808424 | Moshe Y. Vardi            |              30
    11540 | Serge Abiteboul           |              29
  2572634 | Benny Kimelfeld           |              29
    23776 | Tova Milo                 |              23
    24202 | Ronald Fagin              |              22
    29409 | Dirk Van Gucht            |              21
  1567083 | Jan Van den Bussche       |              20
    11739 | Christos H. Papadimitriou |              20
    34786 | Frank Neven               |              19
  1594748 | Michael Benedikt          |              18
  2613688 | Jeffrey D. Ullman         |              18
    22340 | Yufei Tao                 |              17
      113 | Wenfei Fan                |              17
     4979 | David P. Woodruff         |              16
(20 rows)
*/

--The two major database conferences are 'PODS' (theory) and 'SIGMOD Conference' (systems). Find
--(a). all authors who published at least 10 SIGMOD papers but never published a PODS paper, and
CREATE VIEW t_PODS AS (SELECT ad.AuthorID, COUNT(ad.PubID) AS NumPublications
							FROM Authored AS ad
								INNER JOIN Publication AS p ON ad.PubID = p.PubID
								INNER JOIN PODS AS po ON p.PubKey = po.PubKey
							GROUP BY ad.AuthorID
							ORDER BY NumPublications DESC);

CREATE VIEW t_SIGMOD AS (SELECT ad.AuthorID, COUNT(ad.PubID) AS NumPublications
				      		  FROM Authored AS ad
						    		INNER JOIN Publication AS p ON ad.PubID = p.PubID
						   		    INNER JOIN SIGMOD AS si ON p.PubKey = si.PubKey
					   		  GROUP BY ad.AuthorID
					  		  ORDER BY NumPublications DESC);
					   
SELECT ts.AuthorID, a.Name, ts.NumPublications
	FROM t_PODS AS tp 
		FULL OUTER JOIN t_SIGMOD AS ts ON tp.AuthorID = ts.AuthorID
		LEFT OUTER JOIN Author AS a ON ts.AuthorID = a.AuthorID
	WHERE tp.NumPublications IS NULL AND ts.NumPublications >= 10
	ORDER BY ts.NumPublications DESC;

/* result part A:
 authorid |            name             | numpublications
----------+-----------------------------+-----------------
    15284 | Jiawei Han 0001             |              48
    44000 | Donald Kossmann             |              48
    36493 | Tim Kraska                  |              47
  2340534 | Vanessa Braganholo          |              44
    63870 | Guoliang Li 0001            |              36
     8732 | Volker Markl                |              35
    34581 | Carsten Binnig              |              35
    23119 | Christian S. Jensen         |              33
  1578012 | Elke A. Rundensteiner       |              33
  2391107 | Alfons Kemper               |              33
    18625 | Feifei Li 0001              |              32
   391491 | Stratos Idreos              |              32
    38821 | Xiaokui Xiao                |              31
    17211 | Jeffrey Xu Yu               |              31
    30677 | Jim Gray 0001               |              30
    18400 | David B. Lomet              |              29
    21648 | Jignesh M. Patel            |              28
   678746 | AnHai Doan                  |              28
    35812 | Juliana Freire              |              27
     3949 | Krithi Ramamritham          |              27
    24693 | Sihem Amer-Yahia            |              27
    31629 | Bin Cui 0001                |              26
    38364 | Ihab F. Ilyas               |              26
  1591819 | Arie Segev                  |              25
    11324 | Anthony K. H. Tung          |              25
    24071 | Ahmed K. Elmagarmid         |              23
   804520 | Nan Tang 0001               |              22
  1259448 | Andrew Pavlo                |              22
     7809 | Nick Roussopoulos           |              22
     5938 | Ling Liu 0001               |              22
  2841723 | Arun Kumar 0001             |              22
    11248 | Jim Melton                  |              21
  1907755 | Eugene Wu 0002              |              21
  2325699 | Louiqa Raschid              |              21
  1073184 | Guy M. Lohman               |              21
     1470 | Mourad Ouzzani              |              21
    31728 | Kevin Chen-Chuan Chang      |              21
   208340 | Laura M. Haas               |              21
    28340 | Jun Yang 0001               |              20
     9495 | Gao Cong                    |              20
   178735 | Aditya G. Parameswaran      |              20
    22205 | Karl Aberer                 |              20
    35815 | Ioana Manolescu             |              19
    15237 | Goetz Graefe                |              19
    14677 | Jian Pei                    |              19
     7395 | E. F. Codd                  |              19
      203 | Stanley B. Zdonik           |              18
     4081 | Daniel J. Abadi             |              18
    29704 | Bingsheng He                |              18
    30119 | Arnon Rosenthal             |              18
  1513318 | Andrew Eisenberg            |              18
  2062327 | Badrish Chandramouli        |              18
    21829 | Barzan Mozafari             |              17
    18242 | Amit P. Sheth               |              17
    34211 | Themis Palpanas             |              17
      776 | Bruce G. Lindsay 0001       |              17
    18166 | Hans-Arno Jacobsen          |              17
   641226 | Wook-Shin Han               |              17
  2569873 | Asuman Dogac                |              17
  1583528 | Gang Chen 0001              |              16
    38208 | Ugur ├çetintemel             |              16
  2236159 | James Cheng                 |              15
    56968 | Dirk Habich                 |              15
   147355 | Jiannan Wang                |              15
    11491 | Tilmann Rabl                |              15
    35350 | Patrick Valduriez           |              15
    23997 | Jingren Zhou                |              15
  1566317 | Luis Gravano                |              15
    29112 | C. J. Date 0001             |              15
  2297953 | Immanuel Trummer            |              14
   560754 | Betty Salzberg              |              14
    19474 | Raymond Chi-Wing Wong       |              14
    30156 | Nicolas Bruno               |              14
  2965948 | Kaushik Chakrabarti         |              14
  1716460 | Wei Wang 0011               |              14
  1901558 | Jorge-Arnulfo Quian├⌐-Ruiz   |              14
   769698 | Lu Qin 0001                 |              14
  3079909 | Michael J. Cafarella        |              14
   266001 | Suman Nath                  |              14
    22895 | Aaron J. Elmore             |              14
    25289 | Jayavel Shanmugasundaram    |              14
    24369 | Cong Yu 0001                |              13
  2322627 | Hongjun Lu                  |              13
    10737 | Torsten Grust               |              13
  1176208 | Carlo Curino                |              13
  1571581 | Clement T. Yu               |              13
  1578922 | Alvin Cheung                |              13
     4393 | Yinghui Wu                  |              13
     3768 | Xiaofang Zhou 0001          |              13
  2542656 | Viktor Leis                 |              13
   476854 | Kevin S. Beyer              |              13
    31078 | Xifeng Yan                  |              13
   889097 | Qiong Luo 0001              |              13
   360440 | Jens Teubner                |              12
  1037967 | Nan Zhang 0004              |              12
   449056 | Jos├⌐ A. Blakeley            |              12
  1100135 | Jayant Madhavan             |              12
   923026 | Ce Zhang 0001               |              12
  1470102 | Jianhua Feng                |              12
    23907 | Sudipto Das                 |              12
    26472 | Vasilis Vassalos            |              12
  1412207 | Ashraf Aboulnaga            |              12
    32563 | Meihui Zhang 0001           |              12
  2569398 | Eric N. Hanson              |              12
  2249007 | Zhen Hua Liu                |              12
    25997 | Rajasekar Krishnamurthy     |              12
    37311 | Peter Bailis                |              12
  1152978 | Sanjay Krishnan             |              12
     6164 | Philippe Bonnet             |              12
   817656 | Gio Wiederhold              |              11
  2268570 | Arash Termehchy             |              11
  2313421 | Amihai Motro                |              11
  2319211 | Lijun Chang                 |              11
  2326742 | Carlos Ordonez 0001         |              11
    35674 | Nesime Tatbul               |              11
  2339519 | Abolfazl Asudeh             |              11
  2749555 | Xiaolei Qian                |              11
  2843204 | Sailesh Krishnamurthy       |              11
    21461 | Chee Yong Chan              |              11
    19731 | Eric Lo 0001                |              11
    38662 | Bolin Ding                  |              11
    18949 | Matthias Jarke              |              11
    44360 | Zhifeng Bao                 |              11
   296301 | Zhenjie Zhang               |              11
    13970 | Mohamed F. Mokbel           |              11
    29033 | Stefan Manegold             |              11
    22983 | Joachim Hammer              |              11
    22434 | Xu Chu                      |              11
    10034 | Saravanan Thirumuruganathan |              11
    32833 | Sunita Sarawagi             |              11
  1362879 | Sebastian Schelter          |              11
  1463908 | Yinan Li                    |              11
  2986723 | Lawrence A. Rowe            |              11
     6810 | Chengkai Li                 |              11
    33354 | Fatma ├ûzcan                 |              11
    24403 | Jianliang Xu                |              10
    23651 | Calton Pu                   |              10
  2928744 | Kyuseok Shim                |              10
    30330 | Yannis Velegrakis           |              10
    31302 | Ben Kao                     |              10
    21836 | Il-Yeol Song                |              10
    20977 | Antonios Deligiannakis      |              10
    18033 | Senjuti Basu Roy            |              10
   352807 | Anastassia Ailamaki         |              10
    13077 | Shuigeng Zhou               |              10
   707794 | Martin L. Kersten           |              10
   820237 | Sang-Won Lee 0001           |              10
   827540 | Florin Rusu                 |              10
   862931 | Anisoara Nica               |              10
   882578 | Berthold Reinwald           |              10
  1001092 | Theodoros Rekatsinas        |              10
  1268262 | Thomas J. Cook              |              10
  1274446 | Boris Glavic                |              10
  1583239 | Mal├║ Castellanos            |              10
     5169 | Torben Bach Pedersen        |              10
  2205717 | Shamkant B. Navathe         |              10
     5078 | K. Sel├ºuk Candan            |              10
  2332613 | Margaret H. Eich            |              10
  2389781 | Chris Jermaine              |              10
    23835 | Byron Choi                  |              10
*/


--(b). all authors who published at least 5 PODS papers but never published a SIGMOD paper. (Runtime: under 10s)
SELECT tp.AuthorID, a.Name, tp.NumPublications
	FROM t_PODS AS tp 
		FULL OUTER JOIN t_SIGMOD AS ts ON tp.AuthorID = ts.AuthorID
		LEFT OUTER JOIN Author AS a ON tp.AuthorID = a.AuthorID
	WHERE tp.NumPublications >= 5 AND ts.NumPublications IS NULL
	ORDER BY tp.NumPublications DESC;
/* result
 authorid |          name           | numpublications
----------+-------------------------+-----------------
  2967860 | Stavros S. Cosmadakis   |               8
  2449609 | Eljas Soisalon-Soininen |               7
     5591 | Kobbi Nissim            |               6
    34487 | Srikanta Tirthapura     |               5
   337710 | Nofar Carmeli           |               5
  1569688 | Nancy A. Lynch          |               5
     5522 | Alan Nash               |               5
    31944 | Michael Mitzenmacher    |               5
  2769066 | Marco Console           |               5
  2774441 | Kari-Jouko R├ñih├ñ        |               5
  2840310 | Vassos Hadzilacos       |               5
  2696287 | Hubie Chen              |               5
(12 rows)
*/

--drop mv
drop view t_PODS;
drop view t_SIGMOD;

--A decade is a sequence of ten consecutive years, e.g. 1982, 1983, ..., 1991. For each decade, compute the total number of publications in DBLP in that decade. Hint: for this and the next query you may want to compute a temporary table with all distinct years. (Runtime: under 1minute.)
CREATE TABLE t_Year (
		Year INT,
		NumPublications INT
		);
INSERT INTO t_Year (
		SELECT CAST(Year AS INT), COUNT(PubKey)
			FROM Publication
			WHERE Year IS NOT NULL
			GROUP BY Year);
	
SELECT y1.Year AS s_year, SUM(y2.NumPublications)
	FROM t_Year AS y1, t_Year AS y2
	WHERE y1.Year <= y2.Year AND 
		  y2.Year < y1.Year + 10
	GROUP BY y1.Year
	ORDER BY y1.Year;
	
/* output:
 s_year |   sum
-----------+---------
      1936 |     113
      1937 |     132
      1938 |     127
      1939 |     157
      1940 |     191
      1941 |     207
      1942 |     234
      1943 |     330
      1944 |     489
      1945 |     694
      1946 |     888
      1947 |    1199
      1948 |    1525
      1949 |    1935
      1950 |    2583
      1951 |    3152
      1952 |    3990
      1953 |    5034
      1954 |    5868
      1955 |    6722
      1956 |    7756
      1957 |    8852
      1958 |   10223
      1959 |   11887
      1960 |   13227
      1961 |   14726
      1962 |   16810
      1963 |   19240
      1964 |   22447
      1965 |   26107
      1966 |   29790
      1967 |   33778
      1968 |   37788
      1969 |   42166
      1970 |   46605
      1971 |   51888
      1972 |   56888
      1973 |   62454
      1974 |   68291
      1975 |   74914
      1976 |   82671
      1977 |   92595
      1978 |  103020
      1979 |  116579
      1980 |  132320
      1981 |  151301
      1982 |  172456
      1983 |  196309
      1984 |  224862
      1985 |  256451
      1986 |  288934
      1987 |  323793
      1988 |  361557
      1989 |  403126
      1990 |  448527
      1991 |  499366
      1992 |  553340
      1993 |  614258
      1994 |  687642
      1995 |  774891
      1996 |  882572
      1997 | 1002836
      1998 | 1133378
      1999 | 1269195
      2000 | 1418113
      2001 | 1562326
      2002 | 1721486
      2003 | 1882438
      2004 | 2041567
      2005 | 2193574
      2006 | 2332759
      2007 | 2465630
      2008 | 2608703
*/

drop table t_Year;


--Find the top 20 most collaborative authors. That is, for each author determine its number of collaborators, then find the top 20. Hint: for this and some question below you may want to compute a temporary table of coauthors. (Runtime: a couple of minutes.)
CREATE TABLE Col_Authors(
		a_id INT,
		y INT
		);
INSERT INTO Col_Authors (SELECT a1.AuthorID AS a_id, a2.AuthorID AS y
						  FROM Authored AS a1 INNER JOIN Authored AS a2 ON a1.PubID = a2.PubID
						  WHERE a1.AuthorID <> a2.AuthorID);
							
SELECT a_id, COUNT(DISTINCT y) AS count_collabs
	FROM Col_Authors
	GROUP BY a_id
	ORDER BY count_collabs DESC
	LIMIT 20;
	
/* output:
  a_id   | count_collabs
---------+---------------
   11915 |          4575
   23708 |          4420
    2787 |          4245
  833532 |          3940
 2347963 |          3884
 2349079 |          3755
 1561462 |          3718
    9857 |          3455
   27860 |          3310
   29504 |          3186
   25092 |          3168
   21365 |          3149
   22369 |          3113
   21928 |          3053
   12539 |          3030
   29584 |          2979
   49826 |          2976
    1749 |          2957
 1561453 |          2929
    8386 |          2928
(20 rows)
*/
--For each decade, find the most prolific author in that decade. Hint: you may want to first compute a temporary table, storing for each decade and each author the number of publications of that author in that decade. Runtime: a few minutes.
CREATE TABLE YA (
		Year INT,
		AuthorID INT,
		NumPublications INT
		);

INSERT INTO YA (
		SELECT CAST(p.Year AS INT), ad.AuthorID, COUNT(PubKey)
			FROM Publication AS p INNER JOIN Authored AS ad ON p.PubID = ad.PubID
			WHERE p.Year IS NOT NULL
			GROUP BY p.Year, ad.AuthorID);

WITH temp AS (SELECT t1.Year AS s_Year, t1.AuthorID, SUM(t2.NumPublications) AS t_count
				FROM YA AS t1 
					INNER JOIN YA AS t2 ON t1.AuthorID = t2.AuthorID
				WHERE t1.Year <= t2.Year AND 
					  t2.Year < t1.Year + 10 AND
					  t1.Year <= 2022
				GROUP BY t1.Year, t1.AuthorID)
SELECT s_Year, AuthorID
	FROM temp
	WHERE (s_Year, t_count) IN (SELECT s_Year, MAX(t_count)
										   	   FROM temp
										   	   GROUP BY s_Year);

drop table YA;

/*output:
 s_year | authorid
--------+----------
   1936 |  1047196
   1937 |  1047196
   1938 |  1047196
   1939 |  1934818
   1940 |  1047196
   1941 |  1047196
   1941 |  1874737
   1942 |  1874737
   1943 |   248979
   1943 |  1229748
   1944 |  1874737
   1945 |  1047196
   1946 |  1047196
   1947 |  1047196
   1948 |  3078384
   1949 |  2241535
   1949 |  2339067
   1950 |  3078384
   1951 |  2241535
   1952 |  2698186
   1952 |  3078384
   1953 |  3078384
   1954 |   485593
   1955 |  1681087
   1956 |   219371
   1956 |  1371454
   1957 |  1161806
   1958 |  1219596
   1959 |  1219596
   1960 |   219747
   1961 |   219747
   1961 |   398153
   1962 |   398153
   1962 |  1219596
   1963 |  1219596
   1964 |    35308
   1964 |    42827
   1964 |  1219596
   1965 |  2613688
   1966 |  2613688
   1967 |  2613688
   1968 |  2613688
   1969 |  2613688
   1970 |   800448
   1970 |  2613688
   1971 |    13586
   1972 |    13586
   1973 |    13586
   1974 |    13586
   1974 |   800448
   1975 |   800448
   1976 |   800448
   1977 |   800448
   1978 |   800448
   1979 |   800448
   1980 |   800448
   1981 |   800448
   1982 |   800448
   1983 |   800448
   1984 |    26979
   1985 |    26979
   1986 |    26979
   1987 |    26979
   1988 |    63523
   1988 |  1526507
   1989 |    63523
   1990 |    63523
   1991 |    63523
   1992 |    63523
   1993 |    63523
   1994 |    63523
   1995 |   734311
   1996 |   734311
   1997 |   734311
   1998 |    38142
   1999 |    38142
   2000 |  1567064
   2001 |  1567064
   2002 |  1567064
   2003 |  1567064
   2004 |  1567064
   2005 |  1567064
   2006 |  1567064
   2007 |  1567064
   2008 |  1567064
   2009 |  1567064
   2010 |  1567064
   2011 |  1567064
   2012 |  1567064
   2013 |  1567064
   2014 |  1567064
   2015 |  1567064
   2016 |    11915
   2017 |    11915
   2018 |    11915
   2019 |    11915
   2020 |    11915
   2021 |    11915
   2022 |    11915
(99 rows)
*/


--Find the institutions that have published most papers in STOC; return the top 20 institutions. Then repeat this query with your favorite conference (SOSP or CHI, or ...), and see which are the best places and you didn't know about. Hint: where do you get information about institutions? Use the Homepage information: convert a Homepage like http://www.cs.ucr.edu/msalloum to http://www.cs.ucr.edu; now you have grouped all authors from our department, and we use this URL as surrogate for the institution. Read about substring manipulation in postres, by looking up substring, position, and trim.--
CREATE VIEW institution_view AS (
		SELECT AuthorID, SPLIT_PART(Homepage, '/', 3) AS Institution
			FROM Author
			WHERE Homepage IS NOT NULL);
			
SELECT i.Institution, COUNT(DISTINCT ad.PubID) AS Number_Publications
	FROM STOC AS s
		INNER JOIN Publication AS p ON s.PubKey = p.PubKey
		INNER JOIN Authored AS ad ON p.PubID = ad.PubID
		INNER JOIN institution_view AS i ON ad.AuthorID = i.AuthorID
	GROUP BY i.Institution
	ORDER BY Number_Publications DESC
	LIMIT 20;
/*	output:
        institution        | number_publications
---------------------------+---------------------
 orcid.org                 |                 603
 www.wikidata.org          |                 494
 dl.acm.org                |                 491
 scholar.google.com        |                 444
 en.wikipedia.org          |                 424
 mathgenealogy.org         |                 395
 zbmath.org                |                 358
 d-nb.info                 |                 213
 id.loc.gov                |                 174
 isni.org                  |                 112
 www.cs.huji.ac.il         |                  69
 viaf.org                  |                  63
 www.cs.princeton.edu      |                  52
 www1.cs.columbia.edu      |                  51
 www.wisdom.weizmann.ac.il |                  50
 www.cs.toronto.edu        |                  40
 sites.google.com          |                  35
 www.cs.washington.edu     |                  33
 www.cs.jhu.edu            |                  31
 www.cs.berkeley.edu       |                  28
(20 rows)
	*/

SELECT i.Institution, COUNT(DISTINCT ad.PubID) AS Number_Publications
	FROM PODS AS po
		INNER JOIN Publication AS p ON po.PubKey = p.PubKey
		INNER JOIN Authored AS ad ON p.PubID = ad.PubID
		INNER JOIN institution_view AS i ON ad.AuthorID = i.AuthorID
	GROUP BY i.Institution
	ORDER BY Number_Publications DESC
	LIMIT 20;
/* otuput:
        institution        | number_publications
---------------------------+---------------------
 scholar.google.com        |                 278
 dl.acm.org                |                 273
 orcid.org                 |                 216
 www.wikidata.org          |                 152
 mathgenealogy.org         |                 133
 id.loc.gov                |                 117
 zbmath.org                |                 108
 en.wikipedia.org          |                 106
 www-rocq.inria.fr         |                  43
 twitter.com               |                  36
 openlibrary.org           |                  33
 isni.org                  |                  30
 d-nb.info                 |                  28
 researcher.watson.ibm.com |                  27
 www.scopus.com            |                  24
 www.uantwerpen.be         |                  23
 www.cs.indiana.edu        |                  22
 www.cis.upenn.edu         |                  17
 viaf.org                  |                  17
 www.cse.cuhk.edu.hk       |                  17
*/
	
	
SELECT i.Institution, COUNT(DISTINCT ad.PubID) AS Number_Publications
	FROM SIGMOD AS s
		INNER JOIN Publication AS p ON s.PubKey = p.PubKey
		INNER JOIN Authored AS ad ON p.PubID = ad.PubID
		INNER JOIN institution_view AS i ON ad.AuthorID = i.AuthorID
	GROUP BY i.Institution
	ORDER BY Number_Publications DESC
	LIMIT 20;
	
/* OUTPUT:
      institution       | number_publications
------------------------+---------------------
 scholar.google.com     |                1264
 orcid.org              |                1143
 dl.acm.org             |                1123
 www.wikidata.org       |                 872
 en.wikipedia.org       |                 669
 id.loc.gov             |                 258
 mathgenealogy.org      |                 240
 d-nb.info              |                 211
 twitter.com            |                 177
 www.linkedin.com       |                 159
 research.microsoft.com |                 158
 zbmath.org             |                 158
 isni.org               |                 151
 viaf.org               |                 150
 www.scopus.com         |                 104
 www.ics.uci.edu        |                  95
 ieeexplore.ieee.org    |                  92
 www.cs.wisc.edu        |                  73
 people.csail.mit.edu   |                  59
 www-db.in.tum.de       |                  52
(20 rows)
*/
	
drop view institution_view;
drop materialized view STOC;
drop materialized view SIGMOD;
drop materialized view PODS;


