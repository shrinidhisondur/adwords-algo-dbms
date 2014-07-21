LOAD DATA
INFILE 'Queries.dat'
INSERT
INTO TABLE Queries
fields terminated by "\t"
(
qId, 
query char(400)
)
