--Casey Lilley & Paige Dickson
--Open Source GIS at Middlebury College
-- Dar Es Salaam Ramani Huria analysis of building in floodplains

--Select buildings from initial polygons
CREATE TABLE builds as
SELECT way, building, osm_id
FROM planet_osm_polygon
WHERE building IS NOT null

--Intersect the buildings with the floodplain
--Start by creating a new table column to indicate if the building lies within the floodplain
ALTER TABLE builds ADD COLUMN flooded Boolean

--Update the buildings to indicate if they are located within a floodplain based on intersection with water
UPDATE builds
SET flooded = TRUE
FROM water
WHERE st_intersects(way, (select geom FROM water))

--Update the buildings to be points to increase efficiency of processing time
UPDATE builds 
set way = st_centroid(way)

--Intersect the buildings layer with the subwards to figure out the total number of buildings in each subward
ALTER TABLE builds ADD COLUMN subward integer

UPDATE builds
SET subward = fid 
FROM subwards
WHERE st_intersects(builds.way, (subwards.geom))

--Calculate percentage of flooded buildings (buildings located in a floodplain) by subward
UPDATE subwards
SET floodedbuilds = COUNT(flood.builds)
FROM builds
WHERE builds.flood = 1

--Create a new table to join the subwards layer and the number of total buildings and of buildings in a floodplain
Create table  joinsw as
SELECT 
builds.subward as sw,
sum(builds.flood) as floods,
count(builds.osm_id) as buildcnt
FROM builds as builds
Join subwards as subward_id
ON st_intersects(builds.way, subward_id.geom)
GROUP BY builds.subward

--Calculate the percentage of buildings located in a floodplain 
ALTER TABLE joinsw ADD COLUMN pctflood float

UPDATE joinsw	
SET pctflood = floods * 1.0 /buildcnt * 100

--Set the percent to 0 where there were no buildings in floodplains
UPDATE joinsw
SET pctflood = 0
WHERE pctflood is null

--Display the finalized results on a map, rather than in a table
CREATE VIEW floodedsubwards as
SELECT a.geom, a.fid, a.subward, b.floods,  b.buildcnt, b.pctflood
FROM subwards AS a FULL JOIN joinsw AS b
ON a.fid = b.sw





