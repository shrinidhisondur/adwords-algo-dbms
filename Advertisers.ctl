LOAD DATA
INFILE 'Advertisers.dat'
INSERT
INTO TABLE Advertisers
fields terminated by "\t"
(
AdvertiserId,
budget,  
CTC
)
