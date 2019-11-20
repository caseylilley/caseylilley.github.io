# An Investigation into Reproducibility in GIS: Vulnerability Analysis in Malawi based on methods from Malcomb et al. 

Reproducibility, or obtaining the same results with the same input data, methods, and code, in GIS is a common problem; much of the discipline is not suited for reproducible analyses. This is important for the advancement of geographic research, making it become more rigorous and methods more clear. Further, issues of reproducability and replicability in vulnerability modelling is compounded. MORE on vulnerability challenges and definitions. Thus, it becomes critically important for the field to be able to clearly define methods and data, to encourage challenging results. The authors highlight that they use "locally derived indicators and granular data in a transparent and easily replicable methodology" to avoid many of the dangers and pitfalls in vulnerability mapping analyses. We investigated the extent to which this is true, while simultaneously learning tools for multi-criteria analyses in GIS.

## Malcomb et al.'s Methodology
Malcomb et al. analyzed the drivers of vulnerability at the household level in Malawi with the intention of creating a policy relevant climatic vulnerability model that can address what areas are most vulnerable and where development solutions should be applied. They utilized elements of exposure, sensitivity, and adaptive capacity to calculate an overall vulnerability assessment across Malawi. After conducting interviews with households to better understand perceptions of climate change, adaptation, governance, vulnerability, and foreign aid, Malcomb et al. quantified the relative importance of different factors contributing to assets of land, livestock, and income, and access to markets, food, water, health care, and labor, livlihood sensitivity based on crop productivity and natural resource use in recovering from disasters, and finally physical exposure to recurring floods and droughts. The authors then used data from the Demographic and Health Survey, Famine Early Warning Network, and UNEP/ GRID-Europe to populate the fields they found to be important in each element of vulnerability. This table shows the primary framework of indicators they used, and the weights they assigned them based on their local knowledge through interviews and previous literature on vulnerability. 
![Weights](MalcombWeights.PNG)

They then normalized each indicator variable from zero to five to represent the varying conditions for a household, with zero being the worst and five benig the best. The authors also disaggregated the DHS indicators to the village level, and then combined them to conduct the analysis at the administrative scale of Traditional Authorities. The overall score is then represented by the equation: household reselience = adaptive capacity + livelihood sensitivity - physical exposure, creating a composite map.
![Fig5](MalcombMap.PNG)

## Methodology to Reproduce Analysis
Data Sources:
- DHS Survey Data
- Traditional Authorities Shapefile for Malawi
- Cluster points
- Estimated flood risk for flood hazards and exposition to drought events from the UNEP Global Risk Platform 

## Adaptive Capacity - Summarizing DHS Surveys by Traditional Authority
By examining the metadata for the DHS survey data, we collaboratively extracted the variables in Malcolm et al.'s assets and access analysis. As a class, we each got assigned a variable and wrote the SQL code to reclassify the data into quantiles. We dropped no data and null values within each of the 12 indicator variables, and then reclassified them in quintile ranks. We used best judgement to decide whether high or low values for each variable should be 1 or 5, based on what is more favorable for each variable. Then, to preserve the anonynmity of the DHS data, Professor Holler put together and polished the SQL code and gave us the aggregated data on the TA level. 

## Sensitivity 
Malcomb et al. used data from FewsNET 2005, which was not available, so we had to cut this part out of the analysis. Therefore, the final product at best is 80% the orginial analysis because the livelihood sensativity accounted for 20% of the final result. 

# Exposure
We quickly realized several potential issues for this part of the analysis. We had to download the global data for the flood risk layer because the data for Malawi was incomplete. Further, we have to clip areas out that are not included in Malcomb et al.'s work - including major lakes and national parks. We then resampled the layers to match each other, using a warp cell size with bilinear resmapling and a clip to restrict the analysis to the extent of Malawi. We first had to do a buffer to eliminate sliver polygons. The we recoded both layers to be on a quantile scale. For flood risk, this was simple because values were listed from 0-4, so by performing a raster calculation and adding 1 to each cell I normalized the values 1-5. For drought exposure, I used GRASS tools r.Quantile and r.Recode to reclassify the values into quantiles. 

## Making the Model: Putting it all together
Finally, we put these data sources together to try to reproduce Malcomb et al.'s Figure 4. Professor Holler gave us an initial [model](vulnerability.model3) to clip and correctly rasterize each layer so they match. This analysis used a geographic reference system of WGS 84 - EPSG:4326. Then I did the reclass steps described above for flood and drought risk layers, and combined all layers with a raster calculator based on Malcomb et al.'s equation. We needed to invert the adaptive capacity score so that a high score for capacity correlates with a high vulnerability. Thus, the equation was ((2-Adaptive Capacity)(0.40)) + ((Drought Exposure)(0.20)) + (Flood Risk(0.20)). But this [initial map]() was at a coarser resolution than Malcolm et al.'s model, so I altered the [model](vulnerability.Finer.model3) to include a parameter to define resolution. [image of model2](ModelResolution.JPG) This parameter defaults to 0.041667 decimal degrees - the final resolution I used - but a user can input their own number. This produced a final map pictured below.
!(MalcolmReproduce.pdf)

## Analysis and Discussion
Clearly this map has notable differences from the Figure presented by Malcomb et al., despite our efforts as a class to closely follow the methods to reproduce the results. Notable, you can see different pockets of high vulnerability in the Northern region of the country, and overall there appears to be higher vulnerability in our version of the analysis than Malcolm et al.'s.

This research is not reproducible, despite the authors' claims to transparent and replicable methodology, for several reasons. When viewing the paper through the lens of Tate's analysis of different vulnerability models, several key parts of the analysis stick out as unreproducible. Malcolm et al. uses a hierarchical model, meaning .... 

First, the data accessibility proved a challenge. We were unable to access the FEWSNet data for livlihood sensativity - 20% of the final analysis. And even with the DHS Survey Data and UNEP exposure data we were able to get, it was unclear which exact layers and variables the authors used so we used best judgement. For example, the UNEP flood layer for Malawai was clipped incorrectly, and labeled as population exposure to risk, so we used global data. Secondly, there were many issues with the methods that prevent this study from being reproducible.

- Many of the indicator variables for assets and access are binary variables: a household either owns a cell phone or they don't. Yet Malcomb et al. conducted a quintile ranking for each variable, before combining them into an aggregate score. We had to make decisions about the best way to assign values 1 to 5 to each binary variable because it is unclear in their methodology. Do they give the households without a cell phone a 1 and with a 5? Or values of 2 and 4 to be less polarizing? 

Further, the very premise of quintile ranking for this type of variable is problematic because it gives the idea that the authors have more precision than they actually have in their analysis. 

- While the Traditional Authorities unit of analysis may be the most directly useful to policy implications because "many projects and assessments are organized at the TA level," it is incorrect and produces a high degree of uncertainty in this analysis. The DHS household surveys have an uncertainty level at the district level, so trying to break it down to a finer unit of analysis could potentially place household information in the wrong TA. The authors do not acknowledge this source of error and uncertainty. 






