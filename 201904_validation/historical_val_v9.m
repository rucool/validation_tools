%% Historical Validation of RU-WRF in the NREL Period w/ GFS and NAM data
% the one where it plots WRF4.0 to WRF3.9 and the DoE Buoy
%% setup
clear; clc; close all;
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel/wrf_nrel
addpath /Volumes/home/jad438/wrf_converters/
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201904_validation
%% Setup Variables
point = 'DOEFL';
start_date = datenum(2016,07,24);
end_date = datenum(2016,07,27);

%% Load in NREL period RU-WRF Dataset
tic
dfile4 = 'rtgv40_20160723_20160725.nc';
wrf_dtime4 = ncread(dfile4,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws4 = ncread(dfile4,'wind_speed');
wrf_stations = ncread(dfile4,'station')';
% Extract 10m, 100m, 120m, 140m level (bin 1 of 4) for the selected buoy
ind = strmatch(point,wrf_stations);
wrf_ws4 = squeeze(wrf_ws4(3,ind,:)); 

dfilec4 = 'coldv40_20160723_20160725.nc';
wrf_dtimec4 = ncread(dfilec4,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_wsc4 = ncread(dfilec4,'wind_speed');
wrf_stationsc = ncread(dfilec4,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(point,wrf_stationsc);
wrf_wsc4 = squeeze(wrf_wsc4(3,ind,:)); 

dfile = 'rtgv39_20160723_20160725.nc';
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_stations = ncread(dfile,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(point,wrf_stations);
wrf_ws = squeeze(wrf_ws(3,ind,:)); 

dfilec = 'coldv39_20160723_20160725.nc';
wrf_dtimec = ncread(dfilec,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_wsc = ncread(dfilec,'wind_speed');
wrf_stationsc = ncread(dfilec,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(point,wrf_stationsc);
wrf_wsc = squeeze(wrf_wsc(3,ind,:)); 

disp('RU-WRF Load Time:')
toc

%% Load in DoE Buoy data
tic
[doe_time_i,doe_111_ws_i,doe_111_wd_i,doe_130_ws_i,doe_130_wd_i] = doeflb_loader(start_date,end_date);

n = 600; % average every n values (600 = 10 minutes)
doe_111_ws_i2 = arrayfun(@(i) nanmean(doe_111_ws_i(i:i+n-1)),1:n:length(doe_111_ws_i)-n+1); % the averaged vector
doe_130_ws_i2 = arrayfun(@(i) nanmean(doe_130_ws_i(i:i+n-1)),1:n:length(doe_130_ws_i)-n+1); % the averaged vector

doe_time_i2 = start_date:minutes(10):end_date+1;

disp('DoE Buoy Load Time:')
toc

%% Load in WRF 3.6
level = 3;
[ws_wrf,wd_wrf,time_wrf] = wrf_rerun_loader(start_date,end_date,level);

%% Load in NAM and GFS
buoy = 'DOEFL';
lvl = 3; %100m
[gfs_time, gfs_ws, gfs_wd] = gfs_dataload_historical(start_date,end_date,lvl,buoy);
lvl = 2; %80m
[nam_time, nam_ws, nam_wd] = nam_dataload_historical(start_date,end_date,lvl,buoy);

%% indexing
tic
disp('Indexing, Plotting, and Metrics Load time:')
% indexing for plotting and metrics
ind = find(wrf_dtime>=start_date & wrf_dtime < end_date);
ind2 = find(wrf_dtime4>=start_date & wrf_dtime4 < end_date);
%% Plotting
hold on;
plot(wrf_dtimec(ind),wrf_wsc(ind),'color',[0.3010, 0.7450, 0.9330],'linestyle','--','linewidth',2,'displayname','WRF 3.9 Coldpix'); 
plot(wrf_dtime(ind),wrf_ws(ind),'color',[0.8500, 0.3250, 0.0980],'linestyle','--','linewidth',2,'displayname','WRF 3.9 RTG');
plot(wrf_dtimec4(ind2),wrf_wsc4(ind2),'color',[0, 0.4470, 0.7410],'linewidth',2,'displayname','WRF 4.0 Coldpix'); 
plot(wrf_dtime4(ind2),wrf_ws4(ind2),'color',[0.6350, 0.0780, 0.1840],'linewidth',2,'displayname','WRF 4.0 RTG');

plot(time_wrf,ws_wrf,'color',[1 0 1],'linewidth',2,'displayname','WRF 3.6')

plot(gfs_time,gfs_ws,'color',[.1 1 .1],'linewidth',2,'displayname','GFS 100m')
plot(nam_time,nam_ws,'color',[0 .7 0],'linewidth',2,'displayname','NAM 80m')

plot(datenum(doe_time_i2(2:end)),doe_111_ws_i2,'k-','linewidth',2,'displayname','DoE Buoy 111m');
%plot(datenum(doe_time_i2(2:end)),doe_130_ws_i2,'color',[.75 .75 .75],'linewidth',2,'displayname','DoE Buoy 130m');

title(sprintf('Wind Speeds at %s',point));
legend('location','best','autoupdate','off'); %{'Coldestpix','RTG','Buoy'}, 'Location','best');
datetick('x','mm/dd HH:MM','keepticks');

plot_date_start = datenum(2016,07,24,6,0,0);
plot_date_end = datenum(2016,07,25,6,0,0);
xlim([plot_date_start plot_date_end]);

%set(gca,'xlim',[wrf_dtime(1) wrf_dtime(end)]);
xlabel(sprintf('Start date: %s',datestr(start_date,1)));
ylabel('m/s');
grid on
% figure save
set(gcf,'PaperPosition',[0.25 0.5 10 5]);
fname = sprintf('output/buoy%s_ALL_comparison_%s_%s',point,datestr(wrf_dtime(ind(1)),29),datestr(wrf_dtime(ind(end)),29));
print(gcf,'-dpng','-r300', fname);

%% Metrics
% metricsWRF = wrf_metrics(ndbc_ws2(ind),wrf_ws(ind));
% disp(metricsWRF);
% 
% outfile = sprintf('output/WRF4_RTG_COLD/metrics_WRF4_WRF3_all_%s_%s_%s.csv',point,datestr(wrf_dtime(ind(1)),29),datestr(wrf_dtime(ind(end)),29));
% fid = fopen(outfile,'w');
% 
% % RTG
% fprintf(fid,'%s\n','Model,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
% fprintf(fid,'%s,','RTG 3.9');
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);
% 
% % ColdPix
% metricsWRF = wrf_metrics(ndbc_ws2(ind),wrf_wsc(ind));
% disp(metricsWRF);
% 
% fprintf(fid,'%s,','Coldestpix 3.9');
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);
% 
% % RTG 4
% 
% metricsNAMS = wrf_metrics(ndbc_ws3(ind2),wrf_ws4(ind2));
% disp(metricsNAMS);
% fprintf(fid,'%s,','RTG 4.0');
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsNAMS.mo,metricsNAMS.mf,metricsNAMS.so,metricsNAMS.sf);
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsNAMS.rms,metricsNAMS.crms,metricsNAMS.mb,metricsNAMS.cc,metricsNAMS.mae);
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsNAMS.c1,metricsNAMS.c2,metricsNAMS.c3,metricsNAMS.count);
% 
% % Coldpix 4
% 
% metricsGFS = wrf_metrics(ndbc_ws3(ind2),wrf_wsc4(ind2));
% disp(metricsGFS);
% fprintf(fid,'%s,','Coldest Pix 4.0');
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsGFS.mo,metricsGFS.mf,metricsGFS.so,metricsGFS.sf);
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsGFS.rms,metricsGFS.crms,metricsGFS.mb,metricsGFS.cc,metricsGFS.mae);
% fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsGFS.c1,metricsGFS.c2,metricsGFS.c3,metricsGFS.count);
% 
% fclose(fid);
% toc