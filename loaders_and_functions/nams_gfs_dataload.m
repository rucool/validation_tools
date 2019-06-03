%function [gfs_time, gfs_ws, gfs_wd, nam_time , nam_ws, nam_wd, start_date] = nams_gfs_dataload(end_date,total_days,buoy,glvl,nlvl)
clear; clc; close all;
end_date = datenum(2019,5,25);
total_days = 2;
buoy = '44065';
glvl = 2; %height level for gfs, 10,80,100
nlvl = 2; %height level for nam, 10,80

if strcmp(buoy,'44065') == 1
    %gfs
    c1 = 426;%lon
    c2 = 162;%lat
    %nam
    c3 = 500+1;%lon 
    c4 = 222+1;%lat
elseif strcmp(buoy,'44025') == 1
    %gfs
    c1 = 428;%lon
    c2 = 162;%lat
    %nam
    c3 = 504+1;%lon
    c4 = 222+1;%lat
elseif strcmp(buoy,'44009') == 1
    %gfs
    c1 = 422;%lon
    c2 = 155;%lat
    %nam
    c3 = 495+1;%lon 
    c4 = 203+1;%lat
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
gfs_new(ii).ws = squeeze(gfs_raw(ii).ws(c1,c2,glvl,:));
gfs_raw(ii).wd = ncread(fidgfs{ii}','wind_from_direction');
gfs_new(ii).wd = squeeze(gfs_raw(ii).wd(c1,c2,glvl,:));
gfs_new(ii).time = ncread(fidgfs{ii}','time')+datenum(2010,1,1);

fidnam{ii} = ['nams_data_' char(timespan(ii)) '.nc']';
nam_raw(ii).ws = ncread(fidnam{ii}','wind_speed');
nam_new(ii).ws = squeeze(nam_raw(ii).ws(c3,c4,nlvl,:));
nam_raw(ii).wd = ncread(fidnam{ii}','wind_from_direction');
nam_new(ii).wd = squeeze(nam_raw(ii).wd(c3,c4,nlvl,:));
nam_new(ii).time = ncread(fidnam{ii}','time')+datenum(2010,1,1);
end

%% nams

nam_ws = reshape([nam_new(:).ws],[],1);
nam_wd = reshape([nam_new(:).wd],[],1);
nam_time = reshape([nam_new(:).time],[],1);

%% gfs

gfs_ws = reshape([gfs_new(:).ws],[],1);
gfs_wd = reshape([gfs_new(:).wd],[],1);
gfs_time = reshape([gfs_new(:).time],[],1);

%end