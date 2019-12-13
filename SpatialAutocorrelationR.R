#Spatial Autocorrelation Analysis in R 
#Dorian Hurricane Tweets
#Casey Lilley final OpenSource GIS lab

install.packages(c('spdep', "sf", "classInt", "tmap", "RColorBrewer"))
library(spdep)
library(sf)
library(RColorBrewer)
library(classInt)
library(tmap)

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
thresdist <- dnearneigh(coords, 0, 106021.2, row.names = NULL, longlat = NULL, bounds=c("GE", "LT"))
thresdist #view the outcome and number of neighbors 

#Include the counties themselves as neighbors 
selfdist <- include.self(thresdist)

#View the neighbor connections - we can see we have quite a lot!
plot(tweets.sp, border = 'lightgrey')
plot(selfdist, coords, add=TRUE, col = 'red')

#Create weight matrix from the neighbor objects
nbweights.lw <- nb2listw(thresdist, zero.policy = T)
lstws <- nb2listw(selfdist, style = "W")
foqweights.lw <- nb2listw(nb.foq, zero.policy = T)

###### Local Gi* Hotspot Analysis ####################################################################
locG <- localG(tweets.sf$ndti, listw = nbweights.lw, zero.policy = TRUE)#Get Ord Gi* statistic for hot and cold spots
head(locG)

#Add to the table
tweets.sp@data$locGi <- locG

#Map the Outputs
breaks<- c(0,1,.2)
GIColors <- c("blue", "white", "red")
plot(breaks, col=GIColors)
plot(tweets.sp, col=GIColors[findInterval(tweets.sp@data$locGi, breaks, all.inside = TRUE)], axes = F, asp=T)
box()
legend("bottomright", legend = c("low", "insignificant", "high"), fill = GIColors, bty = "n", cex = 0.7, y.intersp = 1, x.intersp = 1)
title("Gi* Cluster Map by Counties")

####Create another version of the map: should be the same, but different vis params
#Create a plot 
local_g <- localG(tweets.sp$tweetrate, lstws)
local_g <- cbind(tweets.sp, as.matrix(local_g))
names(local_g)[16] <- "gstat"
tm_shape(local_g) + tm_fill("gstat", palette = "RdBu", style = "pretty") +
  tm_borders(alpha=.5)

###### Local Moran ############################################################################

locm <- localmoran(tweets.sf$ndti,listw = nbweights.lw, zero.policy = TRUE)
#There are 5 columns of data. We want to copy some of the columns (the I score (column 1) and the z-score standard deviation (column 4)) back into the spatialPolygonsDataframe
tweets.sp@data$BLocI <- locm[,1]
tweets.sp@data$BLocIz <- locm[,4]
tweets.sp@data$BLocIR <- locm[,1]
tweets.sp@data$BLocIRz <- locm[,4]

#Now map the local Moran's I Outputs
MoranColors<- rev(brewer.pal(7, "RdGy"))
breaksMoran<-c(-1000,-2.58,-1.96,-1.65,1.65,1.96,2.58)
plot(tweets.sp, col = MoranColors[findInterval(tweets.sp@data$BLocIRz, breaksMoran, all.inside = T)], axes = T, asp = T)

# creates a local moran output
local <- localmoran(tweets.sp$tweetrate,
                    listw = nbweights.lw)
local[is.na(local)] <-0

# binds results to our polygon shapefile
moran.map <- cbind(tweets.sp, local)

# maps the results
tm_shape(moran.map) + tm_fill(col = "Pr.z...0.", style = "quantile",
                              title = "local moran statistic")
### to create LISA cluster map ###
quadrant <- vector(mode="numeric",length=nrow(local))
# centers the variable of interest around its mean
m.qualification <- tweets.sp$tweetrate - mean(tweets.sp$tweetrate)

# create local moran stat table
locstat <- local[,1]

# centers the local Moran's around the mean
m.local <- locstat - mean(locstat)

# significance threshold
signif <- 0.05

#p-value
pval <- local[,5]

# builds a data quadrant
quadrant[m.qualification > 0 & m.local > 0] <- 4
quadrant[m.qualification <0 & m.local<0] <- 1
quadrant[m.qualification <0 & m.local>0] <- 2
quadrant[m.qualification >0 & m.local<0] <- 3
quadrant[pval>signif] <- 0

# plot in r
brks <- c(0,1,2,3,4)
colors <- c("white","blue",rgb(0,0,1,alpha=0.4),rgb(1,0,0,alpha=0.4),"red")
plot(tweets.sp,border="lightgray",col=colors[findInterval(quadrant,brks,all.inside=FALSE)])
box()
legend("bottomleft",legend=c("insignificant","low-low","low-high","high-low","high-high"),
       fill=colors,bty="n", cex = 0.7, y.intersp = 1, x.intersp = 1)
title("Local Moran Significant Cluster Map")
quadrant
