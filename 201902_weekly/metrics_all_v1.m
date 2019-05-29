%% Metrics for RU-WRF/NAMS/GFS compared to buoy
clear; clc; close all;

%% Data load

% Select a Station
buoy = '44025';

% Specify Model File
% dfile = 'wrf_data_20190121_20190203.nc';
dfile = 'wrf_data_20190223_20190317.nc';
end_date = datenum(2019,3,17);
[gfs_time, gfs_ws, wd_gfs, nams_time, nams_ws, wd_nams] = nams_gfs_dataload_v2(end_date,buoy);
%load('nams_data.mat')
%------------------------------------------------
% Load model data
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_stations = ncread(dfile,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
wrf_ws = squeeze(wrf_ws(1,ind,:)); 

% Load Realtime Buoy Data
ndbc_url = sprintf('https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/%s/%sh9999.nc',buoy,buoy);
ndbc_dtime = double(ncread(ndbc_url,'time'))/(24*60*60)+datenum(1970,1,1);
ind = find(ndbc_dtime>=min(wrf_dtime) & ndbc_dtime<max(wrf_dtime));
ndbc_dtime = ndbc_dtime(ind);
ndbc_ws = squeeze(ncread(ndbc_url,'wind_spd',[1 1 min(ind)],[1 1 length(ind)],[1 1 1]));

% Interpolate buoy data to nearest hour
for jj=1:length(wrf_dtime)
  dtime = wrf_dtime(jj);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12)); %Limit to 4h window
  if length(ind)>1
    buoy_ws(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
  else
    buoy_ws(jj,1) = NaN;
  end
end

% Scale Buoy Data
zo = .5/1000;
us = log(10/zo)/log(5/zo);
buoy_ws = buoy_ws*us;

%% ALL
% RU-WRF to Buoy

metricsWRF = wrf_metrics(buoy_ws,wrf_ws);
disp(metricsWRF);

outfile = sprintf('output/metrics_%s_%s_%s.csv',buoy,datestr(wrf_dtime(1),29),datestr(wrf_dtime(end),29));
fid = fopen(outfile,'w');

fprintf(fid,'%s\n','Model,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
fprintf(fid,'%s,','RU-WRF');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);

% NAMS to Buoy

metricsNAMS = wrf_metrics(buoy_ws,nams_ws);
disp(metricsNAMS);
fprintf(fid,'%s,','NAMS');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsNAMS.mo,metricsNAMS.mf,metricsNAMS.so,metricsNAMS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsNAMS.rms,metricsNAMS.crms,metricsNAMS.mb,metricsNAMS.cc,metricsNAMS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsNAMS.c1,metricsNAMS.c2,metricsNAMS.c3,metricsNAMS.count);

% GFS to Buoy

metricsGFS = wrf_metrics(buoy_ws,gfs_ws);
disp(metricsGFS);
fprintf(fid,'%s,','GFS');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsGFS.mo,metricsGFS.mf,metricsGFS.so,metricsGFS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsGFS.rms,metricsGFS.crms,metricsGFS.mb,metricsGFS.cc,metricsGFS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsGFS.c1,metricsGFS.c2,metricsGFS.c3,metricsGFS.count);

%% Below 12.5m/s
% RU-WRF to Buoy

% ind_WSPD= DATA(:,3)==99;
% DATA(ind_WSPD,3)=NaN;

buoy_ws_ind = buoy_ws>12.5;
buoy_ws(buoy_ws_ind)=NaN;

wrf_ws_ind = wrf_ws>12.5;
wrf_ws(wrf_ws_ind)=NaN;


metricsWRF = wrf_metrics(buoy_ws,wrf_ws);
disp(metricsWRF);

fprintf(fid,'%s\n','Below 12.5 m/s');
fprintf(fid,'%s,','RU-WRF');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);

%% NAMS to Buoy

nams_ws_ind = nams_ws>12.5;
nams_ws(nams_ws_ind)=NaN;

metricsNAMS = wrf_metrics(buoy_ws,nams_ws);
disp(metricsNAMS);
fprintf(fid,'%s,','NAMS');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsNAMS.mo,metricsNAMS.mf,metricsNAMS.so,metricsNAMS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsNAMS.rms,metricsNAMS.crms,metricsNAMS.mb,metricsNAMS.cc,metricsNAMS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsNAMS.c1,metricsNAMS.c2,metricsNAMS.c3,metricsNAMS.count);

%% GFS to Buoy

gfs_ws_ind = gfs_ws>12.5;
buoy_ws(buoy_ws_ind)=NaN;

metricsGFS = wrf_metrics(buoy_ws,gfs_ws);
disp(metricsGFS);
fprintf(fid,'%s,','GFS');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsGFS.mo,metricsGFS.mf,metricsGFS.so,metricsGFS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsGFS.rms,metricsGFS.crms,metricsGFS.mb,metricsGFS.cc,metricsGFS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsGFS.c1,metricsGFS.c2,metricsGFS.c3,metricsGFS.count);


fclose(fid);