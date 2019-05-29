close all; clear; clc;

% Select a Station
buoy = '44065';

% Specify Model File
% dfile = 'wrf_data_20190121_20190203.nc';
dfile = '2weeks2_20190212_20190225.nc';
nfile = 'nams_data_points_20190225_20190226.nc';
%------------------------------------------------
% Load model data
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_stations = ncread(dfile,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
%wrf_ws = squeeze(wrf_ws(1,ind,:)); 

% Load NAMS data
nam_dtime = ncread(nfile,'time')+datenum(2010,1,1); %Convert to Matlab time
nam_ws = ncread(nfile,'wind_speed');
nam_stations = ncread(nfile,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,nam_stations);
nam_ws = squeeze(nam_ws(1,:,:)); 
%plot([0:1:15],nam_ws)


