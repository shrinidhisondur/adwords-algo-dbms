DBMS PROJECT
					  Web Advertisements
					--------------------------

Name : Shrinidhi Sondur	

Project Summary:
----------------
It is a simulation of the real world implementation of displaying dynamic advertisements based on relevance
of the query and an auction of keywords to advertisers. Relevance is calculated using different algorithms.


Development of Code:
--------------------
1. To populate the Input into the database, we call the 3 ctl SQL Loader files for each table from Java, namely 
Queries, Advertisers and Keywords tables using SQL loader.

2. We split the queries into tokens using a Stored Procedure called Tokenise, using cursor and regexp functions 
and store them into a table called QueryTokens. 

3. Build our core database information:
	Joining the tables intelligently, we build a big database which contains the following information per
	AdvertiserId and QueryId
	a. Similarity
	b. Quality Score
	c. Rank
	The above parameters are different for different algorithms. We are ready to start the tasks now.
	
4. Task 1: Greedy algorithm and First price auction.
	1. We select topK advertisements with greatest AdRank each time sequentially. Here AdRank = bid*QualityScore. 
	2. The Ad is simulated as clicked only for the first ctc*100 times per 100. We charge the Advertiser 
       an amount equal to the sum of his bids for all keywords that matched.
	3. Balance is Updated.

5. Task 2: Greedy algorithm and Second price auction.
	1. We select topK advertisements with greatest AdRank each time sequentially. Here AdRank = bid*QualityScore. 
	2. The Ad is simulated as clicked only for the first ctc*100 times per 100. We charge the Advertiser 
       an amount equal to the sum of the next highest valid bid for all keywords that matched. If there is
	   no one less than him, his own bid is charged.
	3. Balance is Updated.

6. Task 3: Balance algorithm and First price auction.
	1. We select topK advertisements with greatest AdRank each time sequentially. Here AdRank = balance*QualityScore. 
	2. The Ad is simulated as clicked only for the first ctc*100 times per 100. We charge the Advertiser 
       an amount equal to the sum of his bids for all keywords that matched.
	3. Balance is Updated.

7. Task 4: Balance algorithm and Second price auction.
	1. We select topK advertisements with greatest AdRank each time sequentially. Here AdRank = balance*QualityScore. 
	2. The Ad is simulated as clicked only for the first ctc*100 times per 100. We charge the Advertiser 
       an amount equal to the sum of the next highest valid bid for all keywords that matched. If there is
	   no one less than him, his own bid is charged.
	3. Balance is Updated.

8. Task 5: Generalized balance algorithm and First price auction.
	1. We select topK advertisements with greatest AdRank each time sequentially. Here AdRank = psi*QualityScore, where psi = Sum of Bids for a query*(1-EXP(-Balance/Budget)). 
	2. The Ad is simulated as clicked only for the first ctc*100 times per 100. We charge the Advertiser 
       an amount equal to the sum of his bids for all keywords that matched.
	3. Balance is Updated.

9. Task 6: Generalized balance algorithm and Second price auction.
	1. We select topK advertisements with greatest AdRank each time sequentially. Here AdRank = psi*QualityScore, where psi = Sum of Bids for a query*(1-EXP(-Balance/Budget)). 
	2. The Ad is simulated as clicked only for the first ctc*100 times per 100. We charge the Advertiser 
       an amount equal to the sum of the next highest valid bid for all keywords that matched. If there is
	   no one less than him, his own bid is charged.
	3. Balance is Updated.


Main Difficulties:
-------------------
1. Tokenization using cursors. 
2. Scalability of algorithms to run in reasonable time.
3. Minimizing calls from Java, and strengthening SQL code.
4. Handling corner cases in Second Price Algorithms where there is now lower bid etc. 



Skills Acquired:
---------------
1. Writing Optimised Queries
2. Using basic JDBC API.
3. Intuitive understanding of separation of front end and back end database work
4. Writing PL/SQL procedures.
5. Importance and Shortcoming of Cursors.
