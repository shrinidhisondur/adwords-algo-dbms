CREATE TABLE Advertisers
(
AdvertiserId int,
Budget float,
CTC float
);

CREATE TABLE Queries
(
qId int,
query VARCHAR(400)
);

CREATE TABLE QueryTokens
(
qId int,
token VARCHAR(400)
);

CREATE TABLE Keywords
(AdvertiserId int, 
 keyword VARCHAR(100), 
 bid FLOAT);

CREATE OR REPLACE PROCEDURE tokenize
AS
BEGIN
DECLARE
q_id integer;

CURSOR cursor1 is
	SELECT qid FROM Queries;
BEGIN
 
	OPEN cursor1;

 LOOP 
 
	FETCH cursor1 INTO q_id;
    EXIT WHEN cursor1%NOTFOUND;
    INSERT INTO QueryTokens (qid, token)
	WITH test AS
    (SELECT q.qid qid, q.query str FROM Queries q WHERE q.qid = q_id)
	 SELECT qid, regexp_substr(str, '[^ ]+', 1, level) TOKEN
	 FROM test
	 CONNECT by level <= length(regexp_replace (str, '[^ ]+')) + 1;
  
END LOOP;
CLOSE cursor1;
END;
END tokenize;
/

exit;
