--Casey Lilley
--Open Source GIS with Professor Holler Lab 9 & 10

--Getting coordinate system to the postGIS database
INSERT into spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) 
values ( 102004, 'esri', 102004, '+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs ', 'PROJCS["USA_Contiguous_Lambert_Conformal_Conic", 
GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",33],PARAMETER["Standard_Parallel_2",45],PARAMETER["Latitude_Of_Origin",39],UNIT["Meter",1],AUTHORITY["EPSG","102004"]]');

--Creating geometry for each table, while transforming in into the Lambert Conformal Conic projection estabilshed above
select addgeometrycolumn ('public', 'november', 'geom', 102004, 'POINT', 2)
select addgeometrycolumn ('public', 'dorain', 'geom', 102004, 'POINT', 2)

update dorain
set geom = st_transform (st_setsrid(st_makepoint (lng, lat) , 4326) , 102004);

update november
set geom = st_transform (st_setsrid(st_makepoint (lng, lat) , 4326) , 102004);

--Update geometry for counties, also setting it to the lambert conformal conic projection
update counties
set geometry = st_transform (geometry, 102004);

select Populate_Geometry_Columns ();

--Delete states we are not interested in (keep the eastern part of the US)
delete from counties
where  statefp NOT IN ('54', '51', '50', '47', '45', '44', '42', '39', '37',
 '36', '34', '33', '29', '28', '25', '24', '23', '22', '21', '18', '17',
 '13', '12', '11', '10', '09', '05', '01');
 
 --Count the number of each type of tweet by county, starting with November tweets to establish our baseline 
alter table november add column geoid varchar(5);

update november
set geoid = counties.geoid
from counties 
where st_intersects (november.geom, counties.geometry);

create table novcounts as
select COUNT(user_id), geoid
from november
group by geoid;

alter table counties add column novembercount integer;

--there are many Null values so default to 0 before merging
update counties 
set novembercount = 0;

update counties 
set novembercount = novcounts.count
from novcounts
where counties.geoid = novcounts.geoid;

--repeat this process with dorian (dorain due to typo early in creating the data in PostGIS)
alter table dorain add column geoid varchar(5);
update dorain
set geoid = counties.geoid
from counties 
where st_intersects (dorain.geom, counties.geometry);

create table dorcounts as
select COUNT(user_id), geoid
from dorain
group by geoid;

alter table counties add column dorcount integer;

update counties 
set dorcount = 0;

update counties 
set dorcount = dorcounts.count
from dorcounts
where counties.geoid = dorcounts.geoid;

--Normalize the Twitter data, first by population, then by normalized twitter activity
alter table counties add column tweetrate real;

update counties
set tweetrate = (dorcount/pop) * 10000

--Normalized tweeet difference index
alter table counties add column ndti real;

--Have to account for where it will divide by zero
update counties
set ndti = coalesce((1.0000*dorcount - novembercount)/ NULLIF((1.0000*dorcount + novembercount), 0), 0)

--Making centroids out of counties for heat map
create table countypoints as 
select *, st_centroid(geometry)
from counties



