# Modelling Flood Resiliency in Dar Es Salaam with OSM

By using data from the Resilience Academy and Ramani Huria, for Lab 6 I analyzed one aspect to flood resiliency in Dar Es Salaam subwards.
What subwards are particularly vulnerable to flooding based on building density within a floodplain? 
We used layers from Open Street Maps to get data on the buildings in Dar Es Salaam, and Resiliency Academy for the data layer for subwards. 

## Loading the Data into QGIS with osm2pgsql
1. With the data as shapefile, load the given .csv into QGIS by adding a deliminated text layer. This table has no geometry yet.
2. Connect to a Database: add a new connection for PostGIS, and open database manager. Next import the data into the database with import layer/file. Using a [batch script](convertOSMholler.bat) developed by Professor Holler, change the database name to your database, and the user name to your user name in Notepad ++.
3. Select which features and tags to load: edit this [dsm.style file](dsmholler.style) to select the tags and shape features important in your analysis. We added a tag for all natural and water features for the floodplain analysis.
4. Run the batch script, and then transform the data from WGS84 to UTM Zone 36S.
5. To load the Resiliency Academy Data into QGIS, add a connection to a WFS feature layer using the Resiliency Academy [URL]( https://geonode.resilienceacademy.ac.tz/geoserver/ows). We added the 'Dar es Salaam Administrative Sub-wards' layer from RA. Then you can load the layer into your database with DB Manager by importing a layer/file. Make sure to change the primary ley to the FID column as a unique ID, convert field names to lower case, and create a spatial index to avoid any issues later on in the analysis!

## Analysis
This analysis had 4 main steps, and then smaller steps within each element of the analysis:
1. Spatially defining an area for the floodplain: defined by land designated as "water" or "wetland" in Open Street Map. 

2. Find which buildings lie in a flooded water area
   - Add a column to the buildings layer for whether it is in the flooded area (y/n)
   - Convert each building to a point feature first to speed up this large calculation
   - Intersect with the floodplain layer to populate column
 
3. Find which subward each building is located in   
   - Select buildings from initial polygons layer
   - Add a column to the buildings layer for what subward it is in
   - Intersect bulidings with the subwards layer from Resiliency Academy to populate column

4. Calculate percentage of flooded buildings by subward
   - Add 3 columns to the subwards layer for the count of flooded buildings, total buildings, and percent flooded
   - Join the buildings layer to the subwards layer by subward, counting the total number of buildings in each subward and summing the total number of flooded buildings in each subward
   - Do a field calculator to find the percentage of buildings in a floodplain in each subward

View the [SQL code](caseylilley.github.io/lab6.sql) for this analysis.

Based on this analysis, we found that Majengo and Mjimpya subwards both have over 75% of buildings in a floodplain, indicating that they have high exposure risk to flooding. There are an additional five subwards that all have over 65% of buildings located in a floodplain - a very large amount. While this is a very simplistic analysis just calculating one aspect of flood vulnerability, I was suprised to find such high building density within floodplains. To further analyze the resilience and risk of each subward, we could also consider drain density, drain blockage frequency, historical flood extents, and informal settlements. 

This map visualizes our analysis. You can turn the water (floodplain) and building density by subward layers.
Check it out for yourself here! [Mapped Density of Flooded Buildings by Subward](caseylilley.github.io/dsmap/index.html)
