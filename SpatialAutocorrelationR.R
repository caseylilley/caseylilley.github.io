#Spatial Autocorrelation Analysis in R 
#Dorian Hurricane Tweets
#Casey Lilley final OpenSource GIS lab

install.packages(c('spdep', "sf"))
install.packages("sf")
library(spdep)
library(sf)
library(RColorBrewer)

#Set working directory to GIS W Drive
setwd("W:/Open_Source/FinalProj")

#Import the spatial data to R, using the counties with the comined twitter count and rate from lab10

tweets.sf <- st_read("countiesTweets.shp") #reading a shapefile
head(tweets.sf, n=4) #list spatial object and the first 4 attribute records to see data

#Converting and sf object to a spatial object
tweets.sp <- as(tweets.sf, "Spatial")
class(tweets.sp)
plot(tweets.sp) #see basic view of data and county outlines 

###Creating neighbor objects

#Create a first order queen continuity
nb.foq <- poly2nb(tweets.sp, queen = TRUE, row.names = tweets.sp$countyns)
nb.foq

#Create a second order queen continuity 
nb.soq <- nblag(nb.foq, 2)
nb.soq

#Create threshold distance weight matrix
#First, we need to get the centroids of the polygons
coords <- coordinates(tweets.sp)
thresdist <- dnearneigh(coords, 0, 106021.2, row.names = tweets.sp$geoid)
thresdist #view the outcome and number of neighbors 

#Create weight matrix from the neighbor objects
nbweights.lw <- nb2listw(thresdist, zero.policy = T)
foqweights.lw <- nb2listw(nb.foq, zero.policy = T)


###### Local Gi* Hotspot Analysis ####################################################################
locG <- localG(tweets.sp@data$tweetrate, listw = nbweights.lw, zero.policy = TRUE)#Get Ord Gi* statistic for hot and cold spots
head(locG)

#Add to the table
tweets.sp@data$locGi <- locG

#Map the Outputs
breaks<- c(-100, -1.65, 1.65)
GIColors <- c("blue", "white", "red")
plot(breaks, col=GIColors)
plot(tweets.sp, col=GIColors[findInterval(tweets.sp@data$locGi, breaks, all.inside = TRUE)], axes = F, asp=T)
box()
legend("bottomright", legend = c("low", "insignificant", "high"), fill = GIColors, bty = "n", cex = 0.7, y.intersp = 1, x.intersp = 1)
title("Gi* Cluster Map by Counties")

###### Local Moran ############################################################################

locm <- localmoran(tweets.sf$tweetrate,listw = nbweights.lw, zero.policy = TRUE)
#There are 5 columns of data. We want to copy some of the columns (the I score (column 1) and the z-score standard deviation (column 4)) back into the spatialPolygonsDataframe
tweets.sp@data$BLocI <- locm[,1]
tweets.sp@data$BLocIz <- locm[,4]
tweets.sp@data$BLocIR <- locm[,1]
tweets.sp@data$BLocIRz <- locm[,4]

#Now map the local Moran's I Outputs
MoranColors<- rev(brewer.pal(7, "RdGy"))
breaksMoran<-c(-1000,-2.58,-1.96,-1.65,1.65,1.96,2.58)
plot(tweets.sp, col = MoranColors[findInterval(tweets.sp@data$BLocIRz, breaksMoran, all.inside = T)], axes = T, asp = T)


#Creating a map of significant clusters of local I
library(classInt)
library(dplyr)

tweetrate <- tweets.sp@data$tweetrate

# Define significance for the maps
significance <- 0.05

# Create the lagged variable
lagvar <- lag.listw(foqweights.lw, tweetrate, zero.policy = T)

#Center the variable around the mean, compariing the lagged variable and the number of tweets
meantweet <- tweetrate - mean(tweetrate)
meanlag <- lagvar - mean(lagvar)

# Derive quadrants 
q <- vector(mode = "numeric", length = nrow(LSOAloci))
q[meantweet < 0 & meanlag < 0] <- 1
q[meantweet < 0 & meanlag > 0] <- 2
q[meantweet > 0 & meanlag < 0] <- 3
q[meantweet > 0 & meanlag > 0] <- 4
q[locm[,5] > significance] <- 0 # assigns places that are not significant a category of 0

# set coloring scheme
brks <- c(0, 1, 2, 3, 4)
colors <- c("white", "blue", rgb(0, 0, 1, alpha = 0.4), rgb(1, 0, 0, alpha = 0.4), 
            "red")
plot(tweets.sp, border = NA, col = colors[findInterval(q, brks, all.inside = FALSE)])
plot(tweets.sp, add = TRUE)
box()
legend("bottomright", legend = c("insignificant", "low-low", "low-high", "high-low", 
                                 "high-high"), fill = colors, bty = "n", cex = 0.7, y.intersp = 1, x.intersp = 1)
title("Local I Cluster Map")
