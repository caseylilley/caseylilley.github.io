# Spatial Autocorrelation in R
## Final GIS Project

For my final project, I am replicating the spatial autocorrelation and cluster analysis in labs 9 & 10 with twitter data in R. 
This process has several steps:

## Data
I will be using the same dataset used for the [Twitter labs 9 & 10](dorian2.md). By using a previously analyzed dataset, we can compare results for maximum reproducibility across software tools. 
Download the analyzed twitter data:[countiesTweets.shp]()
Use the R file with code and documentation: [Spatial Autocorrelation in R]()

## Setting Up Workspace
For this analysis, I am using RStudio Version 3.6.1, and packages `spdep` for spatial autocorrelation tools, `sf` for reading and interpreting data, and `RColorBrewer` for plotting and mapping outcomes. To set up the workspace, we will start by installing and calling these packages, as well as pointing the working directory to the same folder with the data saved as a shapefile. 
```
install.packages(c('spdep', "sf", "RColorBrewer"))
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
plot(tweets.sp) #see basic view of data and county outlines 
```

## Creating Spatial Neighbors
One of the first steps in this analysis is to create a neighborhood matrix, which creates a relationship between each polygon. Because spatial autocorrelation is testing clustering by objects that are near each other, it is important to define what "near" means for the dataset. I test several different measures of nearness for this analysis. 
#### Threshold Distance 
I will start with a threshold distance analysis, because this is the wiehgts matrix we used for the spatial hotspot analysis in GeoDa in [lab 10](dorian2.md). Distance based neighbors defines a set of connections between polygons based on a defined Euclidean distance between centroids. Therefore, the first step is to get the centroids of the polygons, and then we can use the function `dnearneigh` from the `spdep` package installed earlier:
```
coords <- coordinates(tweets.sp)
thresdist <- dnearneigh(coords, 0, 106021.2, row.names = tweets.sp$geoid)
```
To continue with the threshold distance part of the analysis, jump to the next section. But read on to first create several other measures of neighbors that we can use for comparison later.

#### Queen Contiguity
Whereas distance based neighbors depend on relative evenness of distribution of object, contiguity based relations are better to use for irregular polygons that vary a lot in their shape and size. Contiguity ignores distance, and instead focuses on the location of an area. A First order queen contiguity neighborhood matrix defines a neighbor when at least one point on the boundary of a polygon is shared with at least one point of its neighbor. We can use the `poly2nb` function to create this matrix:
```
nb.foq <- poly2nb(tweets.sp, queen = TRUE, row.names = tweets.sp$countyns)
```
We can also create higher order neighbors that are helpful when looking at the effect of lags on spatial autocorrelation. While this is not the main focus of this analysis, it could be helpful when applied to other datasets.
```
nb.soq <- nblag(nb.foq, 2)
```
We can call `nb.foq` and `nb.soq` to see the total number of regions, the number of nonzero links, percentage nonzero links and weights, the average number of links, and the number of regions with no links. This dataset has 2 regions with no links, which is important to note to handle later in the analysis. 
As an alternative to queen contiguity, you could also create a first order rook contiguity neighborhood matrix. It is smilar to queen contiguity, however it does not include corners for the polygons- only polygons that share more than one boundary point. You would still use the `poly2nb` function, but make the parameter `queen = FALSE`.

## Creating a weight matrix 
We can then create a weight matrix based on the assigned neighbor objects. I will continue this part of the analysis with the threshold distance neighborhood matrix, but you can use the same syntax with your desired neighbor object definitions. Because there are regions with no neighbor links, we have to use `zero.policy = TRUE`.
```
nbweights.lw <- nb2listw(thresdist, zero.policy = T)
```

## Local Measures of Spatial Autocorrelation
Local measures, consider spatial variation in each place as opposed to finding one statistic for the whole dataset - as global measures do.
#### Hotspot Analysis: Getis-Ord Gi*
MORE on the tool and what it does. 
First, use the `localG` function to get the Gi* statistic for the hot and cold spots in the data, then view the numbers to ensure the values are in the ballpark of what you would expect (2.58 standard deviations away from the mean). Then, add these values to the spatial dataframe, and map the outputs. I am using a significance level of 0.05, which is 1.96 standard devaiations from the mean.
```
locG <- localG(tweets.sf$tweetrate, listw = nbweights.lw, zero.policy = TRUE)
head(locG)
#Add to the spatial dataframe
tweets.sp@data$locGi <- locG

#Map the Outputs
breaks<- c(-100, -1.96, 1.96) #manually assign breaks for the significance level you want
GIColors <- c("blue", "white", "red")
plot(tweets.sp, col=GIColors[findInterval(tweets.sp@data$locGi, breaks, all.inside = TRUE)], axes = F, asp=T)
box()
legend("bottomright", legend = c("low", "insignificant", "high"), fill = GIColors, bty = "n", cex = 0.7, y.intersp = 1, x.intersp = 1)
title("Gi* Cluster Map by Counties")
```
#### Local Moran's Spatial Autocorrelation
To calculate a cluster analysis based on Moran's statistic, we can use the `localmoran` function, which will create an output of 5 columns of data. We want to copy some of the columns (notably the I score in column 1 and the z-score in column 4) into the spatial dataframe, and then we can plot the output.
```
locm <- localmoran(tweets.sf$tweetrate,listw = nbweights.lw, zero.policy = TRUE)
#Copy some of the columns into the spatialPolygonsDataframe
tweets.sp@data$BLocI <- locm[,1]
tweets.sp@data$BLocIz <- locm[,4]
tweets.sp@data$BLocIR <- locm[,1]
tweets.sp@data$BLocIRz <- locm[,4]

#Now map the local Moran's I Outputs
MoranColors<- rev(brewer.pal(7, "RdGy"))
breaksMoran<-c(-1000,-2.58,-1.96,-1.65,1.65,1.96,2.58) #based on standard deviations of significance
plot(tweets.sp, col = MoranColors[findInterval(tweets.sp@data$BLocIRz, breaksMoran, all.inside = T)], axes = T, asp = T)
```
We can also create a plot of the significant clusters of local Moran scores. To do this, we have to derive the quadrants of significance (high-high, high-low, low-high, and low-low), and then set a coloring scheme. 
```

tweetrate <- tweets.sf$tweetrate

# Define significance for the maps
significance <- 0.05

# Create the lagged variable
lagvar <- lag.listw(nbweights.lw, tweetrate, zero.policy = T)

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
legend("bottomright", legend = c("insignificant", "low-low", "low-high", "high-low","high-high"), fill = colors, bty = "n", cex = 0.7, y.intersp = 1, x.intersp = 1)
title("Local I Cluster Map")
```

## Results
The map produced from using the same threshold distance for the Getis-Ord Gi* hotspot analysis looks similar to the map created with the same methodology in GeoDa, yet with some notable differences. The hotspots, or areas of significantly higher twitter activity per 100,000 people, appear almost identical. Only the county in Northern Maine that is significant in the GeoDa analysis does not appear in this analysis. Yet, there are very few counties that are significantly negative with lower normalized activity. 
![Gi*](gi_threshdist.png)
Similarly, the map of the significant clusters of Moran's I have accurate hotspots but are missing the areas of low activity.
![moran](morandist.png)
Running these two analyses with different neighborhood matrices produced similar results for this data, though this is not always the case. 
