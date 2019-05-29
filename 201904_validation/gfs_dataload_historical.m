function [gfs_time, gfs_ws, gfs_wd] = gfs_dataload_historical(start_date,end_date,lvl,buoy)
%clear; clc; close all;
%start_date = datenum(2015,08,5);
%end_date = datenum(2015,08,07);
%buoy = 'DOEFL';
%lvl = 1; % Level 1,2,3 corresponds to 10m, 80m, 100m
forecast_offset = 0;

if strcmp(buoy,'44065') == 1
    %gfs lon       lat
    c1 = 1146; c2 = 200;
elseif strcmp(buoy,'44025') == 1
    %gfs
    c1 = 1148; c2 = 200;
elseif strcmp(buoy,'44009') == 1
    %gfs
    c1 = 1142; c2 = 207;
elseif strcmp(buoy,'DOEFL') == 1
    %gfs
    c1 = 1143; c2 = 204;
end
    
%start_date = addtodate(end_date,-9,'day');
%start_date = start_date-1;
timespans = string(datestr(start_date:end_date,'yyyymmdd'));
timespan = addtodate(start_date,forecast_offset,'hour'):hours(3):addtodate(end_date,23,'hour');
%% Local
%addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_weekly/gfsdata
%addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_weekly/namsdata
%% Server Present
%addpath /Volumes/Home/jad438/validation_data/gfsdata
%addpath /Volumes/Home/jad438/validation_data/namdata
%% Server Historical
addpath /Volumes/home/jad438/validation_data/historicalgfsdata
%addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel/namhist

for ii = 1:length(timespans)
fidgfs{ii} = ['gfs_data_hist_' char(timespans(ii)) '.nc']';
gfs_raw(ii).ws = ncread(fidgfs{ii}','wind_speed');
gfs_new(ii).ws = squeeze(gfs_raw(ii).ws(c1,c2,lvl,:))';
gfs_raw(ii).wd = ncread(fidgfs{ii}','wind_from_direction');
gfs_new(ii).wd = squeeze(gfs_raw(ii).wd(c1,c2,lvl,:))';
gfs_new(ii).time = [ncread(fidgfs{ii}','time')+datenum(2010,1,1)]';
end

lat = ncread(fidgfs{ii}','lat_0');
lati = squeeze(lat(c2))';
lon = ncread(fidgfs{ii}','lon_0');
loni = squeeze(lon(c1))';
disp('------------')
disp('GFS Coords Used')
disp(lati)
disp(loni-360)



%% gfs

ws_gfst = reshape([gfs_new(:).ws],1,[]);
wd_gfst = reshape([gfs_new(:).wd],1,[]);
time_gfst = reshape([gfs_new(:).time],1,[]);

[~,j] = ismember(time_gfst,timespan);
gfs_time = nan(size(timespan));
gfs_time(j) = time_gfst;

gfs_ws = nan(size(timespan));
gfs_ws(j) = ws_gfst;

gfs_wd = nan(size(timespan));
gfs_wd(j) = wd_gfst;

end