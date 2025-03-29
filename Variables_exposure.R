##Jorge Garcia Molinos & Elena Ojea & Juan Bueno
##March 2025

install.packages("ncdf4")
library(terra)
library(lubridate)
library(ncdf4)
library(dplyr)
library(purrr)
library(raster)

##set working directory 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

###get the temperature data for 4.5


### load the raster stack (in this example the SSP45 daily temperature at 1 m depth) 
# and the polygon to extract the data (in this case the MPA Sudoeste Alentejano e Costa Vicentina from OSPAR)
#r <- rast("./ssp126/ssp126/ensemble/thetao/thetao_ensemble_sd+ba_surface_depth_5.0_stats_ssp126.nc",
#          subds="thetao_mean")
r <- rast("./Copernicus_4.8_4041_daily/Raster_stack.tif", subds="thetao")
time(r) <- seq(as.Date("2040-01-01"), as.Date("2041-12-31"), by="day") #change to days when needed


mpa <- vect("./SEA_CV_MPA.shp")

# subsample for period of interest (mid term: 2041-2050 y long-term: 2091-2100) 
# the original data goes from 1993-01-01 to 2099-12-01 at monthly intervals
#inicio <- interval(date("2006-01-01"), date("2040-01-01")) %/% days(1) 
#fin <- interval(date("2006-01-01"), date("2050-12-31")) %/% days(1) 
#rr <- r[[inicio:fin]] *NOT WORKING

# extract all cell values from the raster stack that fall within the MPA extent
# note that only those cells which centroid is contained within the polygon will be retained
mpa_proj <- project(mpa, r)   # this is to put the polygon on the same crs as the raster
r_mask <- mask(r, mpa_proj, touches = TRUE)
# then crop to reduce the extent and center on the MPA
r_crop <- crop(r_mask, mpa_proj)

# check everything looks fine
plot(r_crop[[1]])
plot(mpa_proj, add=TRUE) ##se ve un poco raro con lugares cortados


# now compute the metric of interest for all cells within the MPA
# first put a time stamp associated to the layers of the raster stack
time(r_crop) <- seq(as.Date("2040-01-01"), as.Date("2041-12-31"), by="day") #change to days when needed
# create an index for the years to compute the annual summaries with
yrs <- as.integer(format(time(r_crop), "%Y"))

##SST99:
# calculate the desired annual summaries, for example the 99th percentile
# the tapp function applies a function to each cell and across all layers of 
# a raster stack by a sequential index then return a raster stack with the results
myf <- function(x){quantile(x, probs = 0.99, na.rm = TRUE)}
P99 <- tapp(r_crop, yrs, myf)
names(P99)
P99$X2040


# if you want the numerical results instead you can extract the values as a table
# containing each cell within the MPA in a row and the P99 for each year by column followed
# by the cell id and the fraction of that cell that is covered by the MPA
# the na.omit is to drop the 
datos <- extract(P99, mpa_proj, fun=NULL, method="simple", cells=TRUE, xy=FALSE, ID=FALSE, exact=TRUE)

# calculate the desired annual summaries, for example the 99th percentile
# using the fraction and the values let's make an annual weighted mean of the P99 across the MPA
myf <-  function(x){weighted.mean(x, w = na.omit(datos)$fraction)}
P99_MPA <- apply(na.omit(datos[,1:10]), 2, myf) 

##MHW
# if you had daily instead of monthly data, you could calculate MHWs the same way 
# just by replacing the function (myf) and the temporal index (yrs) above as appropriate 

# the tapp function applies a function to each cell and across all layers of 
# a raster stack by a sequential index then return a raster stack with the results
