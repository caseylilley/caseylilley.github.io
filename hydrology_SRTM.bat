::Casey Lilley, hydrology analysis automation 10/3/2019
::Open Source GIS at Middlebury College with Professor Holler
::SRTM DEM data

::set the path to your SAGA program
SET PATH=%PATH%;c:\saga6

::set the prefix to use for all names and outputs
SET pre=srtm_dem_hydro

::set the directory in which you want to save ouputs. In the example below, part of the directory name is the prefix you entered above
SET od=W:\Open_Source\Wk4_BatchProcessing\Wk4_SRTM\%pre%

:: the following creates the output directory if it doesn't exist already
if not exist %od% mkdir %od%

:: Run Mosaicking tool, with consideration for the input -GRIDS, the -
saga_cmd grid_tools 3 -GRIDS=S03E037.hgt;S04E037.hgt -NAME=%pre%Mosaic -TYPE=9 -RESAMPLING=1 -OVERLAP=1 -MATCH=0 -TARGET_OUT_GRID=%od%\%pre%mosaic.sgrd

:: Run UTM Projection tool
saga_cmd pj_proj4 24 -SOURCE=%od%\%pre%mosaic.sgrd -RESAMPLING=1 -KEEP_TYPE=1 -GRID=%od%\%pre%mosaicUTM.sgrd -UTM_ZONE=37 -UTM_SOUTH=1

:: Create hillshade visualization
saga_cmd ta_lighting 0 -ELEVATION=%od%\%pre%mosaicUTM.sgrd -SHADE=%od%\%pre%hillshade.sgrd -METHOD=0 -POSITION=0 -AZIMUTH=315.000000 -DECLINATION=45.000000 -EXAGGERATION=1.000000 -UNIT=0 -SHADOW=0 -NDIRS=8 -RADIUS=10.000000

:: Detect sinks and determine flow
saga_cmd ta_preprocessor 1 -ELEVATION=%od%\%pre%mosaicUTM.sgrd -SINKROUTE=%od%\%pre%sinkroute.sgrd -THRESHOLD=0 -THRSHEIGHT=100.000000

:: Remove sinks from DEM by filling them
saga_cmd ta_preprocessor 2 -DEM=%od%\%pre%mosaicUTM.sgrd -SINKROUTE=%od%\%pre%sinkroute.sgrd -DEM_PREPROC=%od%\%pre%sinkfilled.sgrd -METHOD=1 -THRESHOLD=0 -THRSHEIGHT=100.000000

:: Calculate flow accumulation
saga_cmd ta_hydrology 0 -ELEVATION=%od%\%pre%mosaicUTM.sgrd -SINKROUTE=%od%\%pre%sinkroute.sgrd -FLOW=%od%\%pre%flowaccum.sgrd -STEP=1 -FLOW_UNIT=0 -METHOD=4 -LINEAR_DO=1 -LINEAR_MIN=500 -CONVERGENCE=1.100000

:: Find the channel network
saga_cmd ta_channels 0 -ELEVATION=%od%\%pre%mosaicUTM.sgrd -SINKROUTE=%od%\%pre%sinkroute.sgrd -CHNLNTWRK=%od%\%pre%chnlNetwork.sgrd -CHNLROUTE=%od%\%pre%chnlRoute.sgrd -SHAPES=%od%\%pre%chnlShapes.sgrd -INIT_GRID=%od%\%pre%flowaccum.sgrd -INIT_METHOD=2 -INIT_VALUE=1000 -DIV_GRID=NULL -DIV_CELLS=5 -MINLEN=10

::print a completion message so that uneasy users feel confident that the batch script has finished!
ECHO Processing Complete!
PAUSE

