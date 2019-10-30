## Modelling Flood Resiliency in Dar Es Salaam with OSM

By using data from the Resilience Academy and Ramani Huria, for Lab 6 I analyzed one aspect to flood resiliency in Dar Es Salaam subwards.
What subwards are particularly vulnerable to flooding based on their location within a floodplain? Working with Paige, we analyzed the 
density of buildings in each subward that are located in a floodplain - defined by land designated as "water" or "wetland" in Resiliency 
Academy. We used PostGIS SQL statements to convert each building in Dar Es Salaam (a layer from Open Street Maps) to a point feature, and 
then calculate the total number of buildings in each subward and the total number of buildings in each subward that are located in a 
floodplain. We found that Majengo and Mjimpya subwards both have over 75% of buildings in a floodplain, indicating that they have high 
exposure risk to flooding. There are an additional five subwards that all have over 65% of buildings located in a floodplain - a very 
large amount. While this is a very simplistic analysis just calculating one aspect of flood vulnerability, I was suprised to find such 
high building density within floodplains. To further analyze the resilience and risk of each subward, we could also consider drain density, 
drain blockage frequency, historical flood extents, and informal settlements. 

This map visualizes our analysis. You can turn the water (floodplain) and building density by subward layers. 
Check it out for yourself here! [Mapped Density of Flooded Buildings by Subward](caseylilley.github.io/dsmap/index.html)
