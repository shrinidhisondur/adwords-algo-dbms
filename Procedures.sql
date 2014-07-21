CREATE OR REPLACE PROCEDURE displayBalancedFirstPriceAd (queryId IN int, k IN int)
IS

--DECLARE
	--maxDisplay  number (3);
	CURSOR topK IS
	SELECT * FROM CompleteInfo G1 WHERE G1.qId = queryId AND G1.AdvertiserId IN   
		(SELECT G.AdvertiserId --G.qid, ROWNUM as Rank, G.AdvertiserId, G.balance, G.budget
		FROM (SELECT *
			  FROM CompleteInfo B
			  WHERE B.SumBid <= B.Balance AND B.qId = queryId
		      ORDER BY B.Rank DESC, B.AdvertiserId ASC) G
		WHERE ROWNUM <= k)
		FOR UPDATE;
		
	SingleRecord topK%ROWTYPE;
	iterator 	 int;
BEGIN
	
--	dbms_output.put_line('Start');
	IF NOT topK%ISOPEN THEN
--	dbms_output.put_line('Opening');
		OPEN topK;
	END IF; 
	
	iterator := 1;
	FETCH topK INTO SingleRecord;  
	
	--dbms_output.put_line('AdvertiserId    Budget    Balance     DisplayCount');
	WHILE topK%FOUND 
		
	LOOP
		
		--dbms_output.put_line(SingleRecord.AdvertiserId || '             ' || SingleRecord.Budget || '       ' || 
		--					 SingleRecord.Balance || '           ' || SingleRecord.displayedCount);
		IF (SingleRecord.CTC*100 > SingleRecord.displayedCount) THEN
			
			INSERT INTO BalanceFirstPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance - SingleRecord.SumBid, SingleRecord.Budget);
		
			UPDATE CompleteInfo
			SET Balance = Balance - SingleRecord.Sumbid
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
			
			UPDATE CompleteInfo
			SET Rank = QualityScore*Balance
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
			
		ELSE
			
			INSERT INTO BalanceFirstPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance, SingleRecord.Budget);
		
		END IF;
		
		IF (SingleRecord.displayedCount < 99) THEN
			UPDATE CompleteInfo
			SET displayedCount = displayedCount + 1
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		ELSE
			UPDATE CompleteInfo
			SET displayedCount = 0
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		END IF;
		
			
		FETCH topK INTO SingleRecord;  
		iterator := iterator + 1;
		
	END LOOP; 
END;
/

CREATE OR REPLACE PROCEDURE displayGreedyFirstPriceAd (queryId IN int, k IN int)
IS

--DECLARE
	--maxDisplay  number (3);
	CURSOR topK IS
	SELECT * FROM CompleteInfo G1 WHERE G1.qId = queryId AND G1.AdvertiserId IN   
		(SELECT G.AdvertiserId --G.qid, ROWNUM as Rank, G.AdvertiserId, G.balance, G.budget
		FROM (SELECT *
			  FROM CompleteInfo
			  WHERE CompleteInfo.SumBid <= CompleteInfo.Balance AND CompleteInfo.qId = queryId
		      ORDER BY CompleteInfo.Rank DESC, CompleteInfo.AdvertiserId ASC) G
		WHERE ROWNUM <= k)
		FOR UPDATE;
		
	SingleRecord topK%ROWTYPE;
	iterator	 int;
BEGIN
	
--	dbms_output.put_line('Start');
	IF NOT topK%ISOPEN THEN
--	dbms_output.put_line('Opening');
		OPEN topK;
	END IF; 
	iterator := 1;
		
	--dbms_output.put_line('AdvertiserId    Budget    Balance     DisplayCount     SumBid');
	FETCH topK INTO SingleRecord;  
		 
	WHILE topK%FOUND 
		
	LOOP
		
		
		IF (SingleRecord.CTC*100 > SingleRecord.displayedCount) THEN
			
			UPDATE CompleteInfo
			SET Balance = Balance - SingleRecord.Sumbid
			WHERE CompleteInfo.AdvertiserId = SingleRecord.Advertiserid; 
			INSERT INTO GreedyFirstPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance - SingleRecord.SumBid, SingleRecord.Budget);
		
		ELSE 
			INSERT INTO GreedyFirstPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance, SingleRecord.Budget);
		
		END IF;
		
		IF (SingleRecord.displayedCount < 99) THEN
			UPDATE CompleteInfo
			SET displayedCount = displayedCount + 1
			WHERE CompleteInfo.AdvertiserId = SingleRecord.Advertiserid;
		ELSE
			UPDATE CompleteInfo
			SET displayedCount = 0
			WHERE CompleteInfo.AdvertiserId = SingleRecord.Advertiserid;
		END IF;
		
		
		--dbms_output.put_line(SingleRecord.AdvertiserId || '             ' || SingleRecord.Budget || '       ' || 
		--					 SingleRecord.Balance || '           ' || SingleRecord.displayedCount || '       ' || SingleRecord.SumBid);
		
		FETCH topK INTO SingleRecord;  
		iterator := iterator + 1;		
		 
	END LOOP; 
	IF topK%ISOPEN THEN
--	dbms_output.put_line('Opening');
		
		CLOSE topK;
	END IF;
END;
/

CREATE OR REPLACE PROCEDURE displayPsiFirstPriceAd (queryId IN int, k IN int)
IS

--DECLARE
	--maxDisplay  number (3);
	CURSOR topK IS
	SELECT * FROM CompleteInfo G1 WHERE G1.qId = queryId AND G1.AdvertiserId IN   
		(SELECT G.AdvertiserId --G.qid, ROWNUM as Rank, G.AdvertiserId, G.balance, G.budget
		FROM (SELECT *
			  FROM CompleteInfo B
			  WHERE B.SumBid <= B.Balance AND B.qId = queryId
		      ORDER BY B.Rank DESC, B.AdvertiserId ASC ) G
		WHERE ROWNUM <= k)
		FOR UPDATE;
		
	SingleRecord topK%ROWTYPE;
	iterator 	 int;
BEGIN
	
--	dbms_output.put_line('Start');
	IF NOT topK%ISOPEN THEN
--	dbms_output.put_line('Opening');
		OPEN topK;
	END IF; 
	
	iterator := 1;
	FETCH topK INTO SingleRecord;  
	
	--dbms_output.put_line('AdvertiserId    Budget    Balance     DisplayCount');
		 
	WHILE topK%FOUND 
		
	LOOP
		--dbms_output.put_line(SingleRecord.AdvertiserId || '             ' || SingleRecord.Budget || '       ' || 
		--					 SingleRecord.Balance || '           ' || SingleRecord.displayedCount);
							 
		IF (SingleRecord.CTC*100 > SingleRecord.displayedCount) THEN
			
			UPDATE CompleteInfo
			SET Balance = Balance - SingleRecord.Sumbid
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
			
			UPDATE CompleteInfo
			SET Rank = QualityScore*SumBid*(1-EXP(-Balance/Budget))--QualityScore*Balance
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
			
			INSERT INTO PsiFirstPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance - SingleRecord.SumBid, SingleRecord.Budget);
			
		ELSE
			INSERT INTO PsiFirstPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance, SingleRecord.Budget);
		
		
		END IF;
		
		IF (SingleRecord.displayedCount < 99) THEN
			UPDATE CompleteInfo
			SET displayedCount = displayedCount + 1
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		ELSE
			UPDATE CompleteInfo
			SET displayedCount = 0
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		END IF;
		
			
		FETCH topK INTO SingleRecord;  
		iterator := iterator + 1;
		
	END LOOP; 
END;
/

CREATE OR REPLACE PROCEDURE displayBalancedSecondPriceAd (queryId IN int, k IN int)
IS

	CURSOR topK IS
	SELECT * FROM CompleteInfo G1 WHERE G1.qId = queryId AND G1.AdvertiserId IN   
		(SELECT G.AdvertiserId --G.qid, ROWNUM as Rank, G.AdvertiserId, G.balance, G.budget
		FROM (SELECT *
			  FROM CompleteInfo B
			  WHERE B.SumBid <= B.Balance AND B.qId = queryId
		      ORDER BY B.Rank DESC, B.AdvertiserId ASC) G
		WHERE ROWNUM <= k)
	FOR UPDATE;
		
	SingleRecord topK%ROWTYPE;
	NextRecord	 float;
	iterator	 int;
	
	type array_int is varray(100) of int;
	type array_float is varray(100) of float;
	adids array_int;
	bids  array_float;
	
	
BEGIN
	
	adids := array_int();
	bids  := array_float();
	
	FOR i IN 1..100 LOOP
		bids.extend;
		adids.extend;
		bids(i) := 0;
		adids(i) := 0;
	END LOOP;
	
	IF NOT topK%ISOPEN THEN
		OPEN topK;
	END IF;
	
	iterator := 0;
	FETCH topK INTO SingleRecord;  
	--dbms_output.put_line('AdvertiserId    Budget    Balance     DisplayCount');

	WHILE topK%FOUND 
		
	LOOP
		
			iterator := iterator + 1;
			adids(iterator) := SingleRecord.AdvertiserId;
			IF (SingleRecord.CTC*100 > SingleRecord.displayedCount) THEN
			
			SELECT CASE
			WHEN EXISTS (SELECT *
 						 FROM CompleteInfo
						 WHERE CompleteInfo.SumBid < SingleRecord.Sumbid AND
						 CompleteInfo.AdvertiserId != SingleRecord.AdvertiserId AND
						 CompleteInfo.SumBid <= CompleteInfo.Balance AND
						 CompleteInfo.qId = SingleRecord.qId)
						 
  		 	THEN
  		 		1
			ELSE
				0	
 			END INTO NextRecord
 			FROM DUAL;
 			
 			IF NextRecord = 1 THEN
	 			SELECT max(SumBid)
	 			INTO NextRecord
				FROM CompleteInfo
				WHERE CompleteInfo.Sumbid < SingleRecord.Sumbid AND
				CompleteInfo.AdvertiserId != SingleRecord.AdvertiserId AND
				CompleteInfo.SumBid <= CompleteInfo.Balance AND
				CompleteInfo.qId = SingleRecord.qId;
			ELSE
				NextRecord := SingleRecord.SumBid;
			END IF;
				
			bids(iterator) := NextRecord;
			
			INSERT INTO BalanceSecondPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance - NextRecord, SingleRecord.Budget);
			
		ELSE
			bids(iterator) := 0;
			INSERT INTO BalanceSecondPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance, SingleRecord.Budget);
		END IF;
		
		IF (SingleRecord.displayedCount < 99) THEN
			UPDATE CompleteInfo
			SET displayedCount = displayedCount + 1
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		ELSE
			UPDATE CompleteInfo
			SET displayedCount = 0
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		END IF;
					
		FETCH topK INTO SingleRecord;
				
	END LOOP;
	
	IF (iterator > 0) THEN
	
		FOR i IN 1..iterator LOOP
		
			UPDATE CompleteInfo
			SET Balance = Balance - bids(i)
			WHERE CompleteInfo.AdvertiserId = adids(i);
			
			UPDATE CompleteInfo
			SET Rank = QualityScore*Balance
			WHERE CompleteInfo.AdvertiserId = adids(i);

		END LOOP;
	END IF;
	
END;
/

CREATE OR REPLACE PROCEDURE displayGreedySecondPriceAd (queryId IN int, k IN int)
IS

	CURSOR topK IS
	SELECT * FROM CompleteInfo G1 WHERE G1.qId = queryId AND G1.AdvertiserId IN   
		(SELECT G.AdvertiserId --G.qid, ROWNUM as Rank, G.AdvertiserId, G.balance, G.budget
		FROM (SELECT *
			  FROM CompleteInfo 
			  WHERE CompleteInfo.SumBid <= CompleteInfo.Balance AND CompleteInfo.qId = queryId
		      ORDER BY CompleteInfo.Rank DESC, CompleteInfo.AdvertiserId ASC ) G
		WHERE ROWNUM <= k)
	FOR UPDATE;
	
	SingleRecord topK%ROWTYPE;
	NextRecord	 float;
	iterator 	 int;
	
	type array_int is varray(100) of int;
	type array_float is varray(100) of float;
	adids array_int;
	bids  array_float;
		
BEGIN
	
	adids := array_int();
	bids  := array_float();
	
	FOR i IN 1..100 LOOP
		bids.extend;
		adids.extend;
		bids(i) := 0;
		adids(i) := 0;
	END LOOP;
	
	IF NOT topK%ISOPEN THEN
		OPEN topK;
	END IF; 
	
	iterator := 0;
	FETCH topK INTO SingleRecord;  
	--dbms_output.put_line('AdvertiserId    Budget    Balance     DisplayCount');
	
	WHILE topK%FOUND 
		
	LOOP
	
		--dbms_output.put_line(SingleRecord.AdvertiserId || '             ' || SingleRecord.Budget || '       ' || 
		--					 SingleRecord.Balance || '           ' || SingleRecord.displayedCount);
		iterator := iterator + 1;
		
		SELECT CASE
			WHEN EXISTS (SELECT *
 						 FROM CompleteInfo
						 WHERE CompleteInfo.Sumbid < SingleRecord.Sumbid AND
						 CompleteInfo.AdvertiserId != SingleRecord.AdvertiserId AND
						 CompleteInfo.SumBid <= CompleteInfo.Balance AND
						 CompleteInfo.qId = SingleRecord.qId)
						 
  		 	THEN
  		 		1
			ELSE
				0	
 			END INTO NextRecord
 			FROM DUAL;
 			
 			IF NextRecord = 1 THEN
	 			SELECT max(SumBid)
	 			INTO NextRecord
				FROM CompleteInfo
				WHERE CompleteInfo.Sumbid < SingleRecord.Sumbid AND
				CompleteInfo.AdvertiserId != SingleRecord.AdvertiserId AND
				CompleteInfo.SumBid <= CompleteInfo.Balance AND
				CompleteInfo.qId = SingleRecord.qId;
			ELSE
				NextRecord := SingleRecord.SumBid;
			END IF;
			
		adids(iterator) := SingleRecord.AdvertiserId;
		
		IF (SingleRecord.CTC*100 > SingleRecord.displayedCount) THEN
			
			bids(iterator) := NextRecord;
			INSERT INTO GreedySecondPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance - NextRecord, SingleRecord.Budget);
		
			
		ELSE
			INSERT INTO GreedySecondPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance, SingleRecord.Budget);
			bids(iterator) := 0;
			
		END IF;
		
		IF (SingleRecord.displayedCount < 99) THEN
			UPDATE CompleteInfo
			SET displayedCount = displayedCount + 1
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		ELSE
			UPDATE CompleteInfo
			SET displayedCount = 0
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
			
		
		END IF;
		
			
		FETCH topK INTO SingleRecord;  
		
	END LOOP; 
	
	IF (iterator > 0) THEN
	
		FOR i IN 1..iterator LOOP
			UPDATE CompleteInfo
			SET Balance = Balance - bids(i)
			WHERE CompleteInfo.AdvertiserId = adids(i);
		END LOOP;
	END IF;
			
END;
/

CREATE OR REPLACE PROCEDURE displayPsiSecondPriceAd (queryId IN int, k IN int)
IS

--DECLARE
	CURSOR topK IS
	SELECT * FROM CompleteInfo G1 WHERE G1.qId = queryId AND G1.AdvertiserId IN   
		(SELECT G.AdvertiserId
		FROM (SELECT *
			  FROM CompleteInfo B
			  WHERE B.SumBid <= B.Balance AND B.qId = queryId
		      ORDER BY B.Rank DESC, B.AdvertiserId ASC) G
		WHERE ROWNUM <= k)
		FOR UPDATE;
		
	SingleRecord topK%ROWTYPE;
	NextRecord	 float;
	iterator 	 int;
	
	type array_int is varray(100) of int;
	type array_float is varray(100) of float;
	adids array_int;
	bids  array_float;
		
BEGIN
	
	adids := array_int();
	bids  := array_float();
	
	FOR i IN 1..100 LOOP
		bids.extend;
		adids.extend;
		bids(i) := 0;
		adids(i) := 0;
	END LOOP;
	
	IF NOT topK%ISOPEN THEN
		OPEN topK;
	END IF;
	
	iterator := 0;
	FETCH topK INTO SingleRecord;  
	--dbms_output.put_line('AdvertiserId    Budget    Balance     DisplayCount');
	
	WHILE topK%FOUND 
		
	LOOP
	
		iterator := iterator + 1;
		
		SELECT CASE
			WHEN EXISTS (SELECT *
 						 FROM CompleteInfo
						 WHERE CompleteInfo.Sumbid < SingleRecord.Sumbid AND
						 CompleteInfo.AdvertiserId != SingleRecord.AdvertiserId AND
						 CompleteInfo.Balance >= CompleteInfo.Sumbid AND
						 CompleteInfo.qId = SingleRecord.qId)
						 
  		 	THEN
  		 		1
			ELSE
				0	
 			END INTO NextRecord
 			FROM DUAL;
 			
 			IF NextRecord = 1 THEN
	 			SELECT max(SumBid)
	 			INTO NextRecord
				FROM CompleteInfo
				WHERE CompleteInfo.Sumbid < SingleRecord.Sumbid AND
				CompleteInfo.AdvertiserId != SingleRecord.AdvertiserId AND
				CompleteInfo.Balance >= CompleteInfo.Sumbid AND 
				CompleteInfo.qId = SingleRecord.qId;
			ELSE
				NextRecord := SingleRecord.SumBid;
			END IF;
			
		adids(iterator) := SingleRecord.AdvertiserId;			
		IF (SingleRecord.CTC*100 > SingleRecord.displayedCount) THEN

			INSERT INTO PsiSecondPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance - NextRecord, SingleRecord.Budget);
			bids(iterator) := NextRecord;
					
		ELSE
		
			INSERT INTO PsiSecondPriceResult
			VALUES (SingleRecord.qId, iterator, SingleRecord.AdvertiserId, SingleRecord.Balance, SingleRecord.Budget);
			bids(iterator) := 0;		
		END IF;
		
		IF (SingleRecord.displayedCount < 99) THEN
			UPDATE CompleteInfo
			SET displayedCount = displayedCount + 1
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		ELSE
			UPDATE CompleteInfo
			SET displayedCount = 0
			WHERE CompleteInfo.AdvertiserId = SingleRecord.AdvertiserId;
		END IF;
					
		FETCH topK INTO SingleRecord;
		
	END LOOP; 
	
	IF (iterator > 0) THEN
	
		FOR i IN 1..iterator LOOP
		
			UPDATE CompleteInfo
			SET Balance = Balance - bids(i)
			WHERE CompleteInfo.AdvertiserId = adids(i);
		
			UPDATE CompleteInfo
			SET Rank = QualityScore*SumBid*(1-EXP(-Balance/Budget))--QualityScore*Balance
			WHERE CompleteInfo.AdvertiserId = adids(i);
		
		END LOOP;
	END IF;

END;
/

CREATE OR REPLACE PROCEDURE displayGreedyFirstPriceAll (k IN int)
IS

	iterator 	 int;
	queryCount		 int;
BEGIN
	
	UPDATE CompleteInfo SET displayedCount = 0;
	UPDATE CompleteInfo SET Balance = Budget;
	UPDATE CompleteInfo SET Rank = QualityScore*SumBid;
	
	SELECT count(*)
	INTO queryCount
	FROM Queries;
		
	iterator := 1;
	
	WHILE iterator <= queryCount 
		
	LOOP
		
		displayGreedyFirstPriceAd(iterator, k);
		iterator := iterator + 1;
		
	END LOOP; 
END;
/

CREATE OR REPLACE PROCEDURE displayBalancedFirstPriceAll (k IN int)
IS

	iterator 	 int;
	queryCount		 int;
BEGIN
	
	UPDATE CompleteInfo SET displayedCount = 0;
	UPDATE CompleteInfo SET Balance = Budget;
	UPDATE CompleteInfo SET Rank = QualityScore*Balance;
	
	SELECT count(*)
	INTO queryCount
	FROM Queries;
		
	iterator := 1;
	
	WHILE iterator <= queryCount 
		
	LOOP
		
		displayBalancedFirstPriceAd(iterator, k);
		iterator := iterator + 1;
		
	END LOOP; 
END;
/

CREATE OR REPLACE PROCEDURE displayPsiFirstPriceAll (k IN int)
IS

	iterator 	 int;
	queryCount		 int;
BEGIN
	
	UPDATE CompleteInfo SET displayedCount = 0;
	UPDATE CompleteInfo SET Balance = Budget;
	UPDATE CompleteInfo SET Rank = QualityScore*SumBid*(1-EXP(-Balance/Budget));
	
	SELECT count(*)
	INTO queryCount
	FROM Queries;
		
	iterator := 1;
	
	WHILE iterator <= queryCount 
		
	LOOP
		
		displayPsiFirstPriceAd(iterator, k);
		iterator := iterator + 1;
		
	END LOOP; 
END;
/

CREATE OR REPLACE PROCEDURE displayBalancedSecondPriceAll (k IN int)
IS

	iterator 	 int;
	queryCount		 int;
BEGIN
	
	UPDATE CompleteInfo SET displayedCount = 0;
	UPDATE CompleteInfo SET Balance = Budget;
	UPDATE CompleteInfo SET Rank = QualityScore*Balance;
	
	SELECT count(*)
	INTO queryCount
	FROM Queries;
		
	iterator := 1;
	
	WHILE iterator <= querycount 
		
	LOOP
		
		displayBalancedSecondPriceAd(iterator, k);
		iterator := iterator + 1;
		
	END LOOP; 
END;
/

CREATE OR REPLACE PROCEDURE displayGreedySecondPriceAll (k IN int)
IS

	iterator 	 int;
	queryCount		 int;
BEGIN
	
	UPDATE CompleteInfo SET displayedCount = 0;
	UPDATE CompleteInfo SET Balance = Budget;
	UPDATE CompleteInfo SET Rank = QualityScore*SumBid;
	
	SELECT count(*)
	INTO queryCount
	FROM Queries;
		
	iterator := 1;
	
	WHILE iterator <= querycount 
		
	LOOP
		
		displayGreedySecondPriceAd(iterator, k);
		iterator := iterator + 1;
		
	END LOOP; 
END;
/

CREATE OR REPLACE PROCEDURE displayPsiSecondPriceAll (k IN int)
IS

	iterator 	 int;
	queryCount		 int;
BEGIN

	UPDATE CompleteInfo SET displayedCount = 0;
	UPDATE CompleteInfo SET Balance = Budget;
	UPDATE CompleteInfo SET Rank = QualityScore*SumBid*(1-EXP(-Balance/Budget));
	
	SELECT count(*)
	INTO queryCount
	FROM Queries;
		
	iterator := 1;
	
	WHILE iterator <= querycount 
		
	LOOP
		
		displayPsiSecondPriceAd(iterator, k);
		iterator := iterator + 1;
		
	END LOOP; 
END;
/

exit;

