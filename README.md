# exposureMPA
This is a working repository to read ocean climate porjections temperature data and compute the SST99 and MHW for specific MPAs. 
This is part of the project INterreg-MED MPA4Change. 
It uses Copernicus data: "Marine biogeochemistry data for the Northwest European Shelf and Mediterranean Sea from 2006 up to 2100 derived from climate projections"
Available here: https://cds.climate.copernicus.eu/datasets/sis-marine-properties?tab=overview

It contains: 
1. dofile for reading the .nc original data and computing a raster stack file
2. dofile for reading the raster stack file and compute the variables of interest (MHW and SST).

It works for a given example MPA. Future imròvemnets will include a code to obtain the MPA shape files and calculate the variabvles for any MPA in the Med and NW Atlantic.
