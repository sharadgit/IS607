library(plyr)

nyc = read.csv("NYC_Parking_Spots.csv", comment.char="", header=TRUE, sep=",",
               stringsAsFactors=FALSE);

names(nyc) = c("Type", "License", "LegalName", "Name", "FullAddress", "Zip", "Phone", "Spaces")
attach(nyc)

# Address is in one field, so I have to extract the latitude and longitude info
split.df = ldply(FullAddress, function(address) { 
                    split = unlist(strsplit(address, "\n", fixed = TRUE))
                    coord = split[3]
                    coord = sub("\\(", "", coord)
                    coord = sub("\\)", "", coord)
                    split = unlist(strsplit(coord, ","))
                    split.df = data.frame(lon=as.numeric(split[2]), lat=as.numeric(split[1]))
                    return (split.df)
                })

# add coordinates to nyc dataframe
nyc$lat = split.df$lat
nyc$lon = split.df$lon
rm(split.df)

# break locations by spaces
spaces = quantile(nyc$Spaces, c(.8,.6,.4,.2))

nyc$Quartile[nyc$Spaces >= spaces[1]] = "1"                                     
nyc$Quartile[nyc$Spaces < spaces[1] & nyc$Spaces >= spaces[2]] = "2"
nyc$Quartile[nyc$Spaces < spaces[2] & nyc$Spaces >= spaces[3]] = "3"
nyc$Quartile[nyc$Spaces < spaces[3] & nyc$Spaces >= spaces[4]] = "4"
nyc$Quartile[nyc$Spaces < spaces[4]] = "5"

# save data for future use
save(nyc, file="NYCParkingLatLon.dat")
