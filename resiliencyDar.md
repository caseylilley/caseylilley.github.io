# Modeling Flood Resiliency in Dar Es Salaam with Open Street Map

By using data from the Resilience Academy and Ramani Huria, for Lab 6 I analyzed one aspect to flood resiliency in Dar Es Salaam subwards. Bottom-up methods of acquiring data with an open source platform, like Open Street Map, create new possibilities for detailed analysis in areas of the world that were previously difficult to get rich data on. Ramani Huria and the Resilience Academy are using community based mapping techniques to develop maps of the most flood-prone areas of the city and how flooding affects different groups of people. In Dar Es Salaam - a rapidly growing city with many informal settlements, there is a combination of planned flood and waster infrastructure, as well as less planned systems as the population exceeds the city's capacity. Therefore, there is a lot to analyze about the city, and we can learn tools in QGIS and a PostGIS database to handle such a large dataset. 

My analysis focuses on buildings located within floodplains. What subwards are particularly vulnerable to flooding based on building density within a floodplain? For the purpose of this analysis, a floodplain is categorized as a "wetland", "water", "floodplain", or "river" in either the "water features" or "natural" tags in OSM. Protection of natural river cooridors is a globally contested topic, as rivers naturally meander and during storm events need to have room to naturally flood and handle the excess water. Development in wetlands happens globally, but in a rapidly urbanizing city with many informal developments, settlements are more vulnerable. In Dar Es Salaam, floodplains are located throughout the city, and some subwards with higher proportion of informal settlements have buildings located within a waterway designation. These settlements will be more vulnerable to flooding during a large rain or storm, as the natural waterways expand to their floodplains. By conducting a spatial analysis on the number and percentage of buildings in each subward located in a floodplain, planners can be better equipped to develop solutions for the most vulnerable subwards. 

I worked with Paige Dickson for this analysis. We used layers from Open Street Maps to get data on the buildings in Dar Es Salaam, and Resiliency Academy for the data layer for subwards. 

## Loading the Data into QGIS with osm2pgsql
1. Retrieve the data: we used layers from [Open Street Map](https://www.openstreetmap.org/) and downloaded all buildings, as well as floodplains with the tags mentioned above, and [Resiliency Academy](https://geonode.resilienceacademy.ac.tz/geoserver/ows) for the data layer for Subwards. With the data as shapefile, load the given .csv into QGIS by adding a deliminated text layer. This table has no geometry yet.
2. Connect to a Database: add a new connection for PostGIS, and open database manager. Next import the data into the database with import layer/file. Using a [batch script](convertOSMholler.bat) developed by Professor Holler, change the database name to your database, and the user name to your user name in Notepad ++.
3. Select which features and tags to load: edit this [dsm.style file](dsmholler.style) to select the tags and shape features important in your analysis. We added a tag for all natural and water features for the floodplain analysis.
4. Run the batch script, and then transform the data from WGS84 to UTM Zone 36S.
5. To load the Resiliency Academy Data into QGIS, add a connection to a WFS feature layer using the Resiliency Academy [URL]( https://geonode.resilienceacademy.ac.tz/geoserver/ows). We added the 'Dar es Salaam Administrative Sub-wards' layer from RA. Then you can load the layer into your database with DB Manager by importing a layer/file. Make sure to change the primary key to the FID column as a unique ID, convert field names to lower case, and create a spatial index to avoid any issues later on in the analysis!

## Analysis
This analysis had 4 main steps, and then smaller steps within each element of the analysis:
1. Spatially defining an area for the floodplain: defined by land designated as "wetland", "water", "floodplain", or "river" in either the "water features" or "natural" tags in OSM 

2. Find which buildings lie in a flooded water area
   - Add a column to the buildings layer for whether it is in the flooded area (y/n)
   - Convert each building to a point feature first to speed up this large calculation
   - Intersect with the floodplain layer to populate column
 
3. Find which subward each building is located in   
   - Select buildings from initial polygons layer
   - Add a column to the buildings layer for what subward it is in
   - Intersect bulidings with the subwards layer from Resiliency Academy to populate column

4. Calculate percentage of flooded buildings (buildings located within a floodplain) by subward
   - Add 3 columns to the subwards layer for the count of flooded buildings, total buildings, and percent flooded
   - Join the buildings layer to the subwards layer by subward, counting the total number of buildings in each subward and summing the total number of flooded buildings in each subward
   - Use a field calculator to find the percentage of buildings in a floodplain in each subward

View and use the [SQL code](caseylilley.github.io/lab6.sql) for this analysis.

## Visualize the Analysis
This map visualizes our analysis using a web map with Leaflet. You can toggle between the water (floodplain) and building density by subward layers.
Check it out for yourself here! [Mapped Density of Flooded Buildings by Subward](caseylilley.github.io/dsmap/index.html)

## Discussion
Based on this analysis, we found that Majengo and Mjimpya subwards both have over 75% of buildings in a floodplain, indicating that they have high exposure risk to flooding. There are an additional five subwards that all have over 65% of buildings located in a floodplain - a very large amount. While this is a very simplistic analysis just calculating one aspect of flood vulnerability, I was suprised to find such high building density within floodplains. To further analyze the resilience and risk of each subward, we could also consider drain density, drain blockage frequency, historical flood extents, and informal settlements. 

It is also important to note that not all subwards have land in a floodplain: the floodplain is mostly concentrated in the center of the city. A good next step for this analysis would be to differentiate between subwards that did not have any floodplain land, and subwards that did contain floodplain but have no buildings located within it. As you can see currently, the map is misleading in this regard, as it suggests that the periphery subwards that had either had no building data or no floodplain are all less flood-prone. While this might be true, the analysis doesn't cover this so it would be important to make this distinction. 

Large datasets that are crowdsourced provide new and exciting avenues for knowledge and analysis in areas where data was previously inaccessible or not collected regularly. Yet also, it is important to consider some of the limitations of using Open Street Map and how uncertainty can propagate through the analysis to affect the results. Because multiple tags are used in OSM, by thousands of users contributing to the data, the initial dataset has more error and uncertainty than data that is highly regulated and controlled from a top-down source. Different people have different intepretations and associations of words, or boundary objects, and by coding data into a descrete category a lot of that nuance from the original data provider is lost (Schuurman 2008). Though the OSM user guide provides guidelines, there is still some uncertainty in the standardization of the data; it is unclear exactly what makes a location a wetland or floodplain, for example. Using just this data and creating an output on a map holds a certain authority to viewers, so it is important to acknowledge limitations. 

## References

OpenStreetMap. (n.d.). Retrieved from https://www.openstreetmap.org/.

Ramani Huria. (2016). Retrieved from https://ramanihuria.org/.

Schuurman, N. (2008). Database ethnographies using social science methodologies to enhance data analysis and interpretation. Geography Compass, 2(5), 1529-1548. https://doi.org/10.1111/j.1749-8198.2008.00150.x

[back to Main page](README.md)
