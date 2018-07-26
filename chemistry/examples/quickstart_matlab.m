% Matlab Quickstart for OOI Data
% Written by Sage, 6/11/18
close all; clear all;

% The OOI Data Portal provides quick and easy access to most of the
% datasets collected by the OOI program.  In this tutorial, we will 
% demonstrate how to programmatically make a request for an OOI dataset and 
% then load and plot the results, all using Matlab.

% Step 1 - Requesting OOI Data
% While you can use the OOI Data Portal to request data, sometimes it is
% easier to use the OOI M2M Interface (aka the OOI API) to request data 
% from specific instruments, especially when you want to script your data 
% processing routine.  In addition, it's also useful when the number of 
% datasets is more than the few it would be okay to do by hand.

% In order to use the OOI API, you will first need to create an account on
% the OOI Data Portal.  Once you have done that, you will need to grab your
% API username and token, which can be found on your profile page.  We will
% add them as variables to make it easy to refer to later.

API_USERNAME = 'YOUR USERNAME';
API_TOKEN = 'YOUR TOKEN';

% Making asynchronous requests through the API is essentially the same as 
% requesting a download from the OOI Data Portal, but with the API you can 
% easily create one or more requests in an automated way.

% To make a data request, we basically construct a URL using the reference 
% designator, delivery method, stream name and other parameters. You can 
% find this information in catalog on the Data Portal.

% The URL is constructed using the following format:
% /sensor/inv/{subsite}/{node}/{sensor}/{method}/{stream}

% In order to make the code clear, we're going to setup several variables 
% and concatenate all of the variables together with slashes.

site = 'CP04OSSM';
node = 'SBD11';
instrument = '06-METBKA000';
method = 'telemetered';
stream = 'metbk_a_dcl_instrument';

api_base_url = 'https://ooinet.oceanobservatories.org/api/m2m/12576/sensor/inv';

data_request_url = sprintf('%s/%s/%s/%s/%s/%s',api_base_url,site,node,instrument,method,stream);

% In matlab, we need to use weboptions() to specify our username and
% password for the request.

options = weboptions('Username',API_USERNAME,'Password',API_TOKEN);

% We also need to up Matlab's default timeout from 5 seconds to something
% higher, like 60 seconds.

options.Timeout = 60;

% Finally, we also need to specify a start (beginDT) and ending date/time 
% (endDT) for our request. By default, asynchronous requests will return 
% NetCDF files, but you could also specify csv or json, using the format 
% option. Optionally, you can also specify include_provenance and 
% include_annotations, which will include separate text files in the 
% output directory with that information.

% Now let's send the request. (Note, you only need to send the request
% once to generate the data files.  After which, we recommend commenting 
% out the request lines to prevent accidental resubmission when running 
% through the script again.

% response = webread(data_request_url,...
%     'beginDT','2016-01-01T00:00:00.000Z',...
%     'endDT','2017-01-01T00:00:00.000Z',...
%     'format','application/netcdf',...
%     'include_provenance','true',...
%     'include_annotations','true',...
%     options);

% Now let's decode the JSON response to extract the URL where the data
% files can be found.
% data = jsondecode(response);

% Which data URL should I use?
% The first URL in the allURLs key points to the THREDDS server, which 
% allows for programmatic data access without downloading the entire file.
% data.allURLs(1)

% The second URL in the allURLs key provides a direct link to a web 
% server which you can use to quickly download files if you don't want 
% to go through THREDDS.
% data.allURLs(2)

% url1 = 'https://opendap.oceanobservatories.org/thredds/catalog/ooi/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument/catalog.html';
% url2 = 'https://opendap.oceanobservatories.org/async_results/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument';

% Step 2 - Loading in NetCDF Files
% Once the dataset is ready on the server, we can start using it.
% For this example, it turns out that there are 3 different deployments
% spanning 2016, and each deployment has its own file.  In order to load 
% in all of the data, we will need to concatenate the data from all of the 
% files.  The easiest way to do this is to create an array of all of the
% data files and then loop through it.  Using the THREDDS catalog link (the 
% first url above), click on each METBK .nc file, then click on the OPENDAP
% link, and then copy the "Data URL" and add that to your array.

urls = {
    'https://opendap.oceanobservatories.org/thredds/dodsC/ooi/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument/deployment0003_CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument_20160101T000102.577000-20160513T150947.552000.nc'
    'https://opendap.oceanobservatories.org/thredds/dodsC/ooi/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument/deployment0004_CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument_20160527T155046.777000-20161012T150931.977000.nc',
    'https://opendap.oceanobservatories.org/thredds/dodsC/ooi/sage@marine.rutgers.edu/20180611T191824-CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument/deployment0005_CP04OSSM-SBD11-06-METBKA000-telemetered-metbk_a_dcl_instrument_20161012T142641.906000-20161231T235909.571000.nc',
    };

% Now we can loop over each file and load the parameters we want.  

% Note, to find out which parameters are available in the file you can use
% ncinfo() or Panoply.

% Setup empty arrays
dtime = [];
air_temperature  = [];
sea_surface_temperature = [];

for jj=1:length(urls)
    filename = char(urls(jj));
    dtime = [dtime; ncread(filename,'time')];
    air_temperature = [air_temperature; ncread(filename,'air_temperature')];
    sea_surface_temperature = [sea_surface_temperature; ncread(filename,'sea_surface_temperature')];
end
 
% Convert to Matlab time
dtime = dtime/(60*60*24)+datenum(1900,1,1);

% Step 3 - Plotting the Results
% And now we can plot the results.

% Pull the source attribute to use as a plot title
source = ncreadatt(filename,'/','source'); %Get the data stream's name

p = plot(dtime,air_temperature,'r.','markersize',3);
hold on;
plot(dtime,sea_surface_temperature,'b.','markersize',3);
set(gca,'xlim',[dtime(1) dtime(end)]);
datetick('keeplimits');
ylabel('Temperature (C)')
title(source,'interpreter','none')
xlabel([datestr(dtime(1),'mmm dd, yyyy') ' to ' datestr(dtime(end),'mmm dd, yyyy')]);
legend('Air Temperature','Sea Surface Temperature','Location','SouthEast');

set(gcf,'PaperPosition',[0.25 0.5 8 5]); % Add 'renderer','opengl' if necessary
print(gcf,'-dpng','-r300', 'quickstart_2018.png');
