##Elena Ojea & Juan Bueno
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

# List files for scenario and time slice
nc_files <- list.files(path = "./Copernicus_4.8_4041_daily", pattern = "\\.nc$", full.names = TRUE)
nc_files 

#to check ow the data looks like and the dimensions (example file)
nc <- nc_open("./Copernicus_4.8_4041_daily/POLCOMS_ERSEM_biogeochemical-daily-all-rcp45-thetao-2040-08-v1.1.nc")

# Extract variables ( lat, lon, and thetao are in the file)
lat_bnd <- ncvar_get(nc, "lat_bnd")
lon_bnd <- ncvar_get(nc, "lon_bnd")
thetao <- ncvar_get(nc, "thetao")  # 3D or 4D array (lat, lon, depth, time)

thetao[1, 1, 1, ]
# Print dimensions of thetao
print(dim(thetao)) #shows 4 dim (lat, lon, depth, time)

##now we can move to build up a function that stacks the temperature daily data over a raster
# Function to extract the first depth layer and create a Raster Stack

create_raster_stack_from_nc <- function(nc_files) {
  # Initialize an empty list to store individual rasters
  raster_list <- list()
  
  # Loop through each file
  for (file in nc_files) {
    # Open the NetCDF file
    nc <- nc_open(file)
    
    # Extract the 'thetao' variable (temperature data)
    thetao <- ncvar_get(nc, "thetao")  # 4D array (lon, lat, depth, time)
    
    # Extract the first depth layer (depth = 1)
    first_layer <- thetao[, , 1, ]  # All lat, lon, and time for the first depth layer
    
    # Create a SpatRaster for each time step
    for (time_idx in 1:dim(first_layer)[3]) {
      # Extract the time slice (1 for each time step)
      time_slice <- first_layer[, , time_idx]
      
      # Create a SpatRaster for this time slice
      na_raster <- rast(time_slice)
      
      # Get the bounds for the longitude and latitude
      lon_bnd <- ncvar_get(nc, "lon_bnd")  # Longitude bounds
      lat_bnd <- ncvar_get(nc, "lat_bnd")  # Latitude bounds
      
      # Set the extent using the 'ext()' function
      ext(na_raster) <- c(min(lon_bnd), max(lon_bnd), min(lat_bnd), max(lat_bnd))
      
      # Append to the raster list
      raster_list[[length(raster_list) + 1]] <- na_raster
    }
    
    # Close the NetCDF file
    nc_close(nc)
  }
  
  # Combine all the rasters into a RasterStack (or SpatRasterStack in terra)
  raster_stack <- rast(raster_list)
  
  return(raster_stack)
}


# List of your NetCDF files
nc_files <- list.files(path = "./Copernicus_4.8_4041_daily", pattern = "\\.nc$", full.names = TRUE)

# Call the function to create a raster stack from the files
raster_stack <- create_raster_stack_from_nc(nc_files)

##raster stack is saved, maybe one file per scenario and timeslice could do.
writeRaster(raster_stack, filename = "./Copernicus_4.8_4041_daily/Raster_stack.tif", overwrite = TRUE)

# Plot the raster stack for the first time step **PROBLEM IS ROTATED CANNOT FIX
plot(raster_stack[[1]], main = "Shallowest Depth (Time Step 1)", axes = TRUE)
