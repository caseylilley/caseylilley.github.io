## QGIS Model for Direction and Distance
In the first lab, we created a model to calculate direction and distance from a point. A model like this can be useful to visualize geographic theories such as the Bid Rent Model. 
For our purposes, we calculated direction and distance of city tracts from a central business district to look at the distribution of median gross rent around a city center. We started by examining Chicago as a case study to develop and test [the model](https://caseylilley.github.io/Dist_and_dir_updated.model3), pictured below.  

![model_image](https://caseylilley.github.io/DistanceDirectionModel.PNG)

The model requires the city center input to be a point, so if you have several polygons or tracts as the city center, use [this model]() to find the mean coordinates of the centroids, which will output a single point as the central business district. The input for tracts has to be polygons in this model. The model will transform the coordinate systems to a World Mercator projection before calculating both the distance of each tract from the CBD and the direction. Cardinal directions (North, South, East, West) are also calculated and added as an attribute. It is also important to note that for this model, no features can be selected. 

I then used this model to look at the distribution of median gross rent around the Seattle central business district. I found the CBD by finding the centroid of 3 census blocks located in downtown Seattle, and analyzed distance and direction from the CBD for all tracts in King County, WA. You can view the [scatter plot](https://caseylilley.github.io/scatter_plot_distance.html) of distance and median gross rent, and the [polar plot](https://caseylilley.github.io/polarplot_direction.html) of direction and median gross rent. These are the associated maps showing distance, direction, and median gross rent across census tracts in King County, WA. If you want to manipulate and run this case yourself, you can use this [geopackage of data](https://caseylilley.github.io/King_County_Tracts.gpkg).

![model_image](https://caseylilley.github.io/DistanceSeattle.png)
![model_image](https://caseylilley.github.io/DirectionSeattle.png)
![model_image](https://caseylilley.github.io/MedGrossRent.png)

It is important to place this model in the larger context of GIS and the Open Source community. Currently, there are several larger debates happening within geography about what exactly GIS is and what it should be used for. GIS as tool...

Another discussion within the community follows what the broader purpose of GIS is, especially within the field of geography.

[back to Main page](README.md)
