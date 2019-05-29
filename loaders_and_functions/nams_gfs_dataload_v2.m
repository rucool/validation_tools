function [time_gfs, ws_gfs, wd_gfs, time_nams, ws_nams, wd_nams, start_date] = nams_gfs_dataload_v2(end_date,total_days,buoy)
%clear; clc; close all;
%end_date = datenum(2019,3,8);

if strcmp(buoy,'44065') == 1
    %gfs
    c1 = 426; c2 = 162;
    %nam
    c3 = 500; c4 = 222;
elseif strcmp(buoy,'44025') == 1
    %gfs
    c1 = 428; c2 = 162;
    %nam
    c3 = 504; c4 = 222;
elseif strcmp(buoy,'44009') == 1
    %gfs
    c1 = 422; c2 = 155;
    %nam
    c3 = 495; c4 = 203;
end

start_date = addtodate(end_date,-total_days,'day');
timespan = string(datestr(start_date:end_date,'yyyymmdd'));

%% Local
%addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_weekly/gfsdata
%addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_weekly/namsdata
%% Server Present
addpath /Volumes/home/jad438/validation_data/gfsdata
addpath /Volumes/home/jad438/validation_data/namdata
%% Server Historical
%addpath /Volumes/Home/jad438/validation_data/historicalnamdata

for ii = 1:length(timespan)
fidgfs{ii} = ['gfs_data_' char(timespan(ii)) '.nc']';

gfs_raw(ii).ws = ncread(fidgfs{ii}','wind_speed');
gfs_new(ii).ws = squeeze(gfs_raw(ii).ws(c1,c2,:));
gfs_raw(ii).wd = ncread(fidgfs{ii}','wind_from_direction');
gfs_new(ii).wd = squeeze(gfs_raw(ii).wd(c1,c2,:));
gfs_new(ii).time = ncread(fidgfs{ii}','time')+datenum(2010,1,1);

fidnams{ii} = ['nams_data_' char(timespan(ii)) '.nc']';
nams_raw(ii).ws = ncread(fidnams{ii}','wind_speed');
nams_new(ii).ws = squeeze(nams_raw(ii).ws(c3,c4,:));
nams_raw(ii).wd = ncread(fidnams{ii}','wind_from_direction');
nams_new(ii).wd = squeeze(nams_raw(ii).wd(c3,c4,:));
nams_new(ii).time = ncread(fidnams{ii}','time')+datenum(2010,1,1);
end

%% nams

ws_nams = reshape([nams_new(:).ws],[],1);
wd_nams = reshape([nams_new(:).wd],[],1);
time_nams = reshape([nams_new(:).time],[],1);

%% gfs

ws_gfs = reshape([gfs_new(:).ws],[],1);
wd_gfs = reshape([gfs_new(:).wd],[],1);
time_gfs = reshape([gfs_new(:).time],[],1);

end