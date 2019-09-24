## QGIS Model for Direction and Distance
In the first lab, we created a model to calculate direction and distance from a point. 
For our purposes, we calculated direction and distance of city tracts from a central business district to look at the distribution of median gross rent around a city center. We started by examining Chicago as a case study to develop and test our model, pictured below.  

![model_image](https://caseylilley.github.io/DistanceDirectionModel.PNG)

The model requires the city center input to be a point, so if you have several polygons or tracts as the city center, use [this model]() to find the mean coordinates of the centroids, which will output a single point as the central business district. The input for tracts has to be polygons in this model. The model will transform the coordinate systems to a World Mercator projection before calculating both the distance of each tract from the CBD and the direction. Cardinal directions (North, South, East, West) are also calculated and added as an attribute. 

I then used this model to look at the distribution of median gross rent and race around the Seattle central business district. I found the CBD by finding the centroid of 3 census blocks located in downtown Seattle, and analyzed distance and direction from the CBD for all tracts in King County. You can view the [scatter plot](https://caseylilley.github.io/scatter_plot_distance.html) of distance and median gross rent, and the [polar plot](https://caseylilley.github.io/polarplot_direction.html) of direction and median gross rent. There are also very interesting patterns in the racial distribution for distance and direction around the Seattle cbd. You can view a map here. 

[Use the model](https://github.com/caseylilley/caseylilley.github.io/blob/master/distance_from_point.model3)

[back to Main page](README.md)
