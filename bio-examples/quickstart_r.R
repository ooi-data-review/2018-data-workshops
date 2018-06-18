# R Quickstart for OOI Data
# Modified by Lori Garzio, from Sage's Matlab Quickstart
# 6/14/18

# The OOI Data Portal provides quick and easy access to most of the
# datasets collected by the OOI program.  In this tutorial, we will 
# demonstrate how to programmatically make a request for an OOI dataset and 
# then load and plot the results, all using R.

# ---------------------Step 1 - Requesting OOI Data---------------------
# While you can use the OOI Data Portal to request data, sometimes it is
# easier to use the OOI M2M Interface (aka the OOI API) to request data 
# from specific instruments, especially when you want to script your data 
# processing routine.  In addition, it's also useful when the number of 
# datasets is more than the few it would be okay to do by hand.

# In order to use the OOI API, you will first need to create an account on
# the OOI Data Portal.  Once you have done that, you will need to grab your
# API username and token, which can be found on your profile page.  We will
# add them as variables to make it easy to refer to later.

API_USERNAME <- 'your-username';
API_TOKEN <- 'your-token';

# Making asynchronous requests through the API is essentially the same as 
# requesting a download from the OOI Data Portal, but with the API you can 
# easily create one or more requests in an automated way.

# To make a data request, we basically construct a URL using the reference 
# designator, delivery method, stream name and other parameters. You can 
# find this information in catalog on the Data Portal.

# The URL is constructed using the following format:
# sensor/inv/{subsite}/{node}/{sensor}/{method}/{stream}

# In order to make the code clear, we're going to setup several variables 
# and concatenate all of the variables together with slashes.

site <- 'CP04OSSM'
node <- 'SBD11'
instrument <- '06-METBKA000'
method <- 'telemetered'
stream <- 'metbk_a_dcl_instrument'

api_base_url <- 'https://ooinet.oceanobservatories.org/api/m2m/12576/sensor/inv'

data_request_url <- sprintf('%s/%s/%s/%s/%s/%s', api_base_url, site, node, nstrument, method, stream)

# We can also add options to the data_request_url, such as start (beginDT) 
# and ending date/time (endDT). By default, asynchronous requests will return 
# NetCDF files, but you could also specify csv or json, using the format 
# option. Optionally, you can also specify include_provenance and 
# include_annotations, which will include separate text files in the 
# output directory with that information. Let's add some of these options to 
# the data_request_url.

beginDT <- '2016-01-01T00:00:00.000Z'
endDT <- '2017-01-01T00:00:00.000Z'
fmt <- 'application/netcdf'
incl_prov <- 'true'
incl_anno <- 'true'

data_request_url <- sprintf('%s?beginDT=%s&endDT=%s&format=%s&include_provenance=%s&include_annotations=%s',
                            data_request_url, beginDT, endDT, fmt, incl_prov, incl_anno)

# Now let's send the request. We do this here with the httr package,
# which is similar to Python's Requests library. (Note, you only need to 
# send the request once to generate the data files.  After which, we 
# recommend commenting out the request lines to prevent accidental 
# resubmission when running through the script again.

library(httr)
# response <- GET(data_request_url, authenticate(API_USERNAME, API_TOKEN))

# Now, let's read the JSON response to extract the URL where the data
# files can be found. The jsonlite package makes it easier to work
# with data in JSON format.

library(jsonlite)
info <- fromJSON((content(response, 'text')), flatten = TRUE)

# Which data URL should I use?
# The first URL in the allURLs key points to the THREDDS server, which 
# allows for programmatic data access without downloading the entire file.

# The second URL in the allURLs key provides a direct link to a web 
# server which you can use to quickly download files if you don't want 
# to go through THREDDS.

# info$allURLs[1] = "https://opendap.oceanobservatories.org/thredds/catalog/ooi/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument/catalog.html"
# info$allURLs[2] = "https://opendap.oceanobservatories.org/async_results/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument"


# -------------------Step 2 - Loading in NetCDF Files-------------------
# Once the dataset is ready on the server, we can start using it.
# For this example, it turns out that there are 3 different deployments
# spanning 2016, and each deployment has its own file.  In order to load 
# in all of the data, we will need to concatenate the data from all of the 
# files.  The easiest way to do this is to create a vector of all of the
# data files and then loop through it.  Using the THREDDS catalog link (the 
# first url above), click on each METBK .nc file, then click on the OPENDAP
# link, and then copy the "Data URL" and add that to your vector. 

urls <- c('https://opendap.oceanobservatories.org/thredds/dodsC/ooi/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument/deployment0003_CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument_20160101T000102.577000-20160513T150947.552000.nc',
          'https://opendap.oceanobservatories.org/thredds/dodsC/ooi/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument/deployment0004_CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument_20160527T155046.777000-20161012T150931.977000.nc',
          'https://opendap.oceanobservatories.org/thredds/dodsC/ooi/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument/deployment0005_CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument_20161012T142641.906000-20161231T235909.571000.nc')

# Now we can loop over each file and load the parameters we want. Here we 
# use the ncdf4 library to read the files. nc_open(filename) dumps the 
# contents of the file. Once a file is open, names(f$var) lists the
# variable names available in the file. You can also get more information
# about the variables in the file using Panoply.

library(ncdf4)

# Setup empty vectors
dtime <- c()
air_temperature <- c()
sea_surface_temperature <- c()

for (jj in 1:length(urls)){
  f <- nc_open(urls[jj])
  dtime <- c(dtime, ncvar_get(f, 'time'))
  air_temperature <- c(air_temperature, ncvar_get(f, 'air_temperature'))
  sea_surface_temperature <- c(sea_surface_temperature, ncvar_get(f, 'sea_surface_temperature'))
}

# Convert timestamp to date
dtime <- as.POSIXct(dtime, origin = '1900-01-01', tz = "UTC")

# Because this data set is so dense, we are going to calculate hourly
# averages to make plotting more manageable. Use the lubridate package
# to round the date/times to the nearest hour, and create a dataframe
# with the aggregated dataset.

library(lubridate)

rtime_hour <- round_date(dtime, unit = "hour")
havg <- setNames(aggregate(cbind(air_temperature, sea_surface_temperature), list(rtime_hour), mean, na.rm = TRUE), 
                 c("time_hh", "air_temp_mean", "sea_surf_temp_mean"))


# ---------------------Step 3 - Plotting the Results---------------------
# Note: plotly files can be saved as interactive web-based graphs. 
# See https://plot.ly/r/getting-started/
# However here we're saving the plots as local .png files using the export() 
# function with the webshot package: https://github.com/wch/webshot/

library(plotly)
library(webshot)

# Pull the source attribute to use as the plot title
source <- ncatt_get(f, 0, 'source')$value

xax <- list(showline = TRUE)
yax <- list(title = 'Hourly-Averaged Temperature (C)', showline = TRUE, zeroline = FALSE)
mk1 <- list(size = 3, color = 'red')
mk2 <- list(size = 3, color = 'blue')

p <- plot_ly(havg, x = havg$time_hh, y = havg$air_temp_mean, name = 'Air Temperature', 
             type = "scatter", mode = "markers", marker = mk1) %>%
  add_trace(y = havg$sea_surf_temp_mean, name = 'Sea Surface Temperature', 
            type = "scatter", mode = "markers", marker = mk2) %>%
  layout(title = source, xaxis = xax, yaxis = yax, legend = list(x = 0.7, y = 0.05))

p

sname <- sprintf('./%s_timeseries.png', source)
export(p, file = sname)