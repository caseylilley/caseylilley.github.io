## Twitter Use Case - Spatio-Temporal Analysis of Users' Sentiments Across Space
To learn more about the different uses and analyses of twitter data, I reviewed an [article](twittercase.md) investigating public sentiment across space using tweets.

## Vulnerability Analysis and Issues of Reproducability in GIS
For this [lab](vul.md), we attempted to reproduce an analysis conducted by Malcomb et al. on Malawi household climactic vulnerability. Our process revealed several issues in reproducibility and the importance of considering error and uncertainty, especially in the creation of social vulnerability indices. 

## Modeling Flood Resiliency in Dar Es Salaam Using OSM
By using data from the Resilience Academy and Ramani Huria, for Lab 6 I analyzed the density of buildings in each subward in Dar Es Salaam, Tanzania located in a floodplain. Read more about the analysis and view the map online: [Resiliency in Dar Es Salaam](resiliencyDar.md)


## Using SAGA to Model Global Digital Elevation 
Using ASTER data, I visualized a hydrological landscape around Mount Kilimanjaro. Then I created a batch processing algorithm to automate the hydrological analysis and look for sources of error in SRTM and ASTER data: [Terrain Analysis](Global_DEM_Models.md)


## Modeling Distance and Direction in QGIS
Read more about how I built a model to show distance and direction of polygons from a point in QGIS for the first lab assignment:
[My First QGIS Model](qgisModelDirDis.md)


## FOSS4G Conference Article Blog Post
### Utilizing Open Data for Energy Access Planning in Tanzania

Researchers Cader, Pelz, Radu, and Blechinger utilized open source data to bridge gaps in data availability challenges in energy planning in Tanzania. Data is crucial for decision making and infrastructure development: it is essential to understand the extent of current electricity transmission and distribution infrastructure, as well as the locations of underserved areas with a demand for energy. The team at Reiner Lemoine Institut gGmbH in Berlin, Germany utilized High Resolution Settlement Layer (HRSL) – a raster dataset that derives human settlements from satellite imagery – paired with Open Street Maps and existing datasets for Tanzania to create a base data set for energy planning. By performing distance calculations in GIS to the nearest major population center with grid infrastructure, they created shapefiles for on-grid and off-grid settlements in Tanzania. 


These estimations are still rudimentary, as not all settlements located in a grid area are guaranteed to have energy access, and access to decentralized energy infrastructure is becoming increasingly accessible. Yet, with the high accuracy of the HRSL, this team created an interactive web-mapping tool they added to OSM. The layers, showing administrative – population and electricity access level information – along with grid infrastructure and distance to the grid information were processed using two online software packages, and are now openly available to a variety of stakeholders. This information, made possible through open datasets, is helpful for both private sector developers, governmental organizations and rural energy access planners in identification of priority settlements for electrification efforts and grid expansion. 

[View the article](https://www.int-arch-photogramm-remote-sens-spatial-inf-sci.net/XLII-4-W8/23/2018/isprs-archives-XLII-4-W8-23-2018.pdf)

