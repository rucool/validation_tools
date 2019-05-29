%% WRF 3.6 comparison to NAM and GFS Data
% no plots, just metrics
close all; clear; clc; 
%% Set up
start_date = datenum(2016,01,01);
end_date = datenum(2017,01,01)-1;
buoy = 'DOEFL';

%% DoE Load
tic
%111m
[doe_time_i,doe_90_ws_i,~] = doeflb_loader(start_date,end_date);
n = 600; % average every n values (600 = 10 minutes)
doe_90_ws_i2 = arrayfun(@(i) nanmean(doe_90_ws_i(i:i+n-1)),1:n:length(doe_90_ws_i)-n+1); % the averaged vector
%doe_130_ws_i2 = arrayfun(@(i) nanmean(doe_130_ws_i(i:i+n-1)),1:n:length(doe_130_ws_i)-n+1); % the averaged vector

doe_time_i2 = start_date:minutes(10):end_date+1;

% hourly winds
doe_time_i3 = start_date:hours(1):end_date+1;
[hind,~] = ismember(datenum(doe_time_i2),datenum(doe_time_i3(1:end-1)));
hind = find(hind==1);
% 3 hourly winds
doe_time_i4 = start_date:hours(3):end_date+1;
[hind2,~] = ismember(datenum(doe_time_i2),datenum(doe_time_i4(1:end-1)));
hind2 = find(hind2==1);

disp('DoE Buoy Load Time:')
toc

%% Metrics
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel
clearvars -except doe_90_ws_i2 hind wrf_ws buoy start_date end_date nam_ws hind2 gfs_ws
lvl = 2; %100m
[wrf_ws,~,~] = wrf_rerun_loader(start_date,end_date,lvl);
metricsWRF = wrf_metrics(doe_90_ws_i2(hind)',wrf_ws);
disp('WRF 3.6');
% disp(datestr(doe_time_i2(hind(1))));
% disp(datestr(wrf_time(1)));
% disp(datestr(doe_time_i2(hind(end))));
% disp(datestr(wrf_time(end)));
disp(metricsWRF);
%/Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201904_validation/output/WRF36_DoE/new_pt_6ho_comp/Yearly
%metrics_buoy%s_NAM_GFS_WRF36_%s_%s_6ho.csv
outfile = sprintf('output/WRF36_DoE/new_pt_1ho_comp/Yearly/metrics_buoy%s_NAM_GFS_WRF36_%s_%s_1ho.csv',buoy,datestr(start_date,29),datestr(end_date,29));
[fid, m] = fopen(outfile,'w');
disp(m)

fprintf(fid,'%s\n','Model,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
fprintf(fid,'%s,','WRF 3.6 100m');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);
clearvars wrf_ws metricsWRF

lvl = 2; %80m
[~, nam_ws, ~] = nam_dataload_historical(start_date,end_date,lvl,buoy);
metricsNAMS = wrf_metrics(doe_90_ws_i2(hind),nam_ws);
disp('NAM')
% disp(datestr(doe_time_i2(hind(1))));
% disp(datestr(nam_time(1)));
% disp(datestr(doe_time_i2(hind(end))));
% disp(datestr(nam_time(end)));
disp(metricsNAMS);

fprintf(fid,'%s,','NAM 80m');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsNAMS.mo,metricsNAMS.mf,metricsNAMS.so,metricsNAMS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsNAMS.rms,metricsNAMS.crms,metricsNAMS.mb,metricsNAMS.cc,metricsNAMS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsNAMS.c1,metricsNAMS.c2,metricsNAMS.c3,metricsNAMS.count);
clearvars nam_ws metricsNAMS

lvl = 3; %100m
[~, gfs_ws, gfs_wd] = gfs_dataload_historical(start_date,end_date,lvl,buoy);
metricsGFS = wrf_metrics(doe_90_ws_i2(hind2),gfs_ws);
disp('GFS')
% disp(datestr(doe_time_i2(hind2(1))));
% disp(datestr(gfs_time(1)));
% disp(datestr(doe_time_i2(hind2(end))));
% disp(datestr(gfs_time(end)));
disp(metricsGFS);

fprintf(fid,'%s,','GFS 100m');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsGFS.mo,metricsGFS.mf,metricsGFS.so,metricsGFS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsGFS.rms,metricsGFS.crms,metricsGFS.mb,metricsGFS.cc,metricsGFS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsGFS.c1,metricsGFS.c2,metricsGFS.c3,metricsGFS.count);

fclose(fid);