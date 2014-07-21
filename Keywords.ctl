LOAD DATA
INFILE 'Keywords.dat'
INSERT
INTO TABLE Keywords
fields terminated by "\t"
(
AdvertiserId,
keyword,  
bid
)
