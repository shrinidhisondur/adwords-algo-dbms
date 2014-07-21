CREATE VIEW AdvertisersMatchPerQuery (AdvertiserId, qId, HitsCount, SumBid, CTC, budget) AS
SELECT X.AdvertiserId, X.qId, X.countTokens, Y.SumBid, X.CTC, X.budget
FROM (SELECT A.AdvertiserId, T.qId, count(*) AS countTokens, A.CTC, A.budget 
      FROM Advertisers A, Keywords K, QueryTokens T
      WHERE A.AdvertiserId = K.AdvertiserId AND K.keyword = T.token
      GROUP BY A.AdvertiserId, T.qId, A.CTC, A.budget) X,
     (SELECT sum(G.bid) AS SumBid, G.AdvertiserId, G.qId
      FROM (SELECT DISTINCT A.AdvertiserId, T.qId, K.Keyword, K.bid, A.CTC, A.budget 
	    FROM Advertisers A, Keywords K, QueryTokens T
	    WHERE A.AdvertiserId = K.AdvertiserId AND K.keyword = T.token) G
      GROUP BY G.AdvertiserId, G.qId) Y
WHERE X.AdvertiserId = Y.AdvertiserId AND X.qId = Y.qId;
	     
CREATE VIEW AdvertisersKeywordCount (AdvertiserId, KeywordCount) AS
SELECT A.AdvertiserId, count(*)
--FROM Advertisers_fake A, Keywords_fake K
FROM Advertisers A, Keywords K
WHERE A.AdvertiserId = K.AdvertiserId AND K.Bid > 0
GROUP BY A.AdvertiserId;

CREATE VIEW QueryTokenCount (qId, KeywordCount) AS
SELECT P.qId, sum(P.Powers)
FROM (SELECT T.qId, (power(count(*),2)) AS Powers
      FROM QueryTokens T
      GROUP BY qId, token) P
GROUP BY qId;

CREATE TABLE CompleteInfo
(AdvertiserId int,
 qId int,
 HitsCount int,
 KeywordCount int,
 QueryCount int,
 Similarity float,
 CTC float,
 QualityScore float,
 SumBid float,
 budget float,
 balance float,
 displayedCount int,
 Rank float
 );
 
CREATE TABLE GreedyFirstPriceResult
(qId int,
 Rank int,
 AdvertiserId int,
 balance float,
 budget float
 );

CREATE TABLE BalanceFirstPriceResult
(qId int,
 Rank int,
 AdvertiserId int,
 balance float,
 budget float
 );

CREATE TABLE PsiFirstPriceResult
(qId int,
 Rank int,
 AdvertiserId int,
 balance float,
 budget float
 );

CREATE TABLE GreedySecondPriceResult
(qId int,
 Rank int,
 AdvertiserId int,
 balance float,
 budget float
 );

CREATE TABLE BalanceSecondPriceResult
(qId int,
 Rank int,
 AdvertiserId int,
 balance float,
 budget float
 );

CREATE TABLE PsiSecondPriceResult
(qId int,
 Rank int,
 AdvertiserId int,
 balance float,
 budget float
 );
 

-- This is where the magic happens
 
INSERT INTO CompleteInfo
SELECT A.AdvertiserId, A.qId, A.HitsCount, K.KeywordCount, Q.KeywordCount, null, A.CTC, null, A.SumBid, A.budget, A.budget, 0, null 
FROM AdvertisersMatchPerQuery A, AdvertisersKeywordCount K, QueryTokenCount Q
WHERE A.AdvertiserId = K.AdvertiserId AND A.qId = Q.qid;

UPDATE CompleteInfo SET Similarity=HitsCount/(SQRT(QueryCount*KeywordCount));
UPDATE CompleteInfo SET QualityScore = CTC*Similarity;

exit;
