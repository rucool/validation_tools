%% Historical Validation of RU-WRF in the NREL Period w/ GFS and NAM data
% the one where it plots WRF4.0 to WRF3.9
%% setup
clear; clc; close all;
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel/wrf_nrel
addpath /Volumes/home/jad438/wrf_converters/
%% Setup Variables
buoy = '44065';
start_date = datenum(2015,08,03);
end_date = datenum(2015,08,05);

% wrf4_cold_20150803_20150804.nc                              
% wrf4_cold_full_20150803_20150804.nc                   
% wrf4_rtg_20150803_20150804.nc                                 
% wrf4_rtg_full_20150803_20150804.nc

%% Load in NREL period RU-WRF Dataset
tic
dfile4 = 'wrf4_rtg_20150803_20150804.nc';
wrf_dtime4 = ncread(dfile4,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws4 = ncread(dfile4,'wind_speed');
wrf_stations = ncread(dfile4,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
wrf_ws4 = squeeze(wrf_ws4(1,ind,:)); 

dfilec4 = 'wrf4_cold_20150803_20150804.nc';
wrf_dtimec4 = ncread(dfilec4,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_wsc4 = ncread(dfilec4,'wind_speed');
wrf_stationsc = ncread(dfilec4,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stationsc);
wrf_wsc4 = squeeze(wrf_wsc4(1,ind,:)); 

dfile = 'wrf_rtg_20150730_20150805.nc';
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_stations = ncread(dfile,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
wrf_ws = squeeze(wrf_ws(1,ind,:)); 

dfilec = 'wrf_coldestpix_20150730_20150805.nc';
wrf_dtimec = ncread(dfilec,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_wsc = ncread(dfilec,'wind_speed');
wrf_stationsc = ncread(dfilec,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stationsc);
wrf_wsc = squeeze(wrf_wsc(1,ind,:)); 

disp('RU-WRF Load Time:')
toc

%% Load in Buoy data
tic
[ndbc_dtime,ndbc_ws] = ndbc_loader(start_date,end_date,buoy);
disp('Buoy Load Time:')
toc
% Scale Buoy Data
zo = .5/1000;
us = log(10/zo)/log(5/zo);
ndbc_ws = ndbc_ws*us;

% Interpolate buoy to nearest hour
for jj=1:length(wrf_dtime)
  dtime = wrf_dtime(jj);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12));
  ndbc_ws2(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
end

for jj=1:length(wrf_dtime4)
  dtime = wrf_dtime4(jj);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12));
  ndbc_ws3(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
end


tic
disp('Indexing, Plotting, and Metrics Load time:')
% indexing for plotting and metrics
ind = find(wrf_dtime>=start_date & wrf_dtime < end_date);
ind2 = find(wrf_dtime4>=start_date & wrf_dtime4 < end_date);
%% Plotting
hold on;
plot(wrf_dtimec(ind),wrf_wsc(ind),'color',[0.3010, 0.7450, 0.9330],'linewidth',2,'displayname','WRF 3.9 Coldpix'); 
plot(wrf_dtime(ind),wrf_ws(ind),'color',[0.8500, 0.3250, 0.0980],'linewidth',2,'displayname','WRF 3.9 RTG');
plot(wrf_dtimec4(ind2),wrf_wsc4(ind2),'color',[0, 0.4470, 0.7410],'linewidth',2,'displayname','WRF 4.0 Coldpix'); 
plot(wrf_dtime4(ind2),wrf_ws4(ind2),'color',[0.6350, 0.0780, 0.1840],'linewidth',2,'displayname','WRF 4.0 RTG');

plot(wrf_dtime(ind),ndbc_ws2(ind),'k-','linewidth',3,'displayname','Buoy');

title(sprintf('Wind Speeds at %s',buoy));
legend('location','best')%{'Coldestpix','RTG','Buoy'}, 'Location','best');
datetick('x');

plot_date_start = datenum(2015,08,03,6,0,0);
plot_date_end = datenum(2015,08,04,6,0,0);
xlim([plot_date_start plot_date_end])

%set(gca,'xlim',[wrf_dtime(1) wrf_dtime(end)]);
xlabel(sprintf('Start date: %s',datestr(start_date,1)));
ylabel('m/s')
grid on
% figure save
set(gcf,'PaperPosition',[0.25 0.5 8 5]);
fname = sprintf('output/WRF4_RTG_COLD/buoy%s_WRF4_WRF3_nam_gfs_hist_comparison_%s_%s',buoy,datestr(wrf_dtime(ind(1)),29),datestr(wrf_dtime(ind(end)),29));
print(gcf,'-dpng','-r300', fname);

%% Metrics
metricsWRF = wrf_metrics(ndbc_ws2(ind),wrf_ws(ind));
disp(metricsWRF);

outfile = sprintf('output/WRF4_RTG_COLD/metrics_WRF4_WRF3_all_%s_%s_%s.csv',buoy,datestr(wrf_dtime(ind(1)),29),datestr(wrf_dtime(ind(end)),29));
fid = fopen(outfile,'w');

% RTG
fprintf(fid,'%s\n','Model,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
fprintf(fid,'%s,','RTG 3.9');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);

% ColdPix
metricsWRF = wrf_metrics(ndbc_ws2(ind),wrf_wsc(ind));
disp(metricsWRF);

fprintf(fid,'%s,','Coldestpix 3.9');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);

% RTG 4

metricsNAMS = wrf_metrics(ndbc_ws3(ind2),wrf_ws4(ind2));
disp(metricsNAMS);
fprintf(fid,'%s,','RTG 4.0');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsNAMS.mo,metricsNAMS.mf,metricsNAMS.so,metricsNAMS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsNAMS.rms,metricsNAMS.crms,metricsNAMS.mb,metricsNAMS.cc,metricsNAMS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsNAMS.c1,metricsNAMS.c2,metricsNAMS.c3,metricsNAMS.count);

% Coldpix 4

metricsGFS = wrf_metrics(ndbc_ws3(ind2),wrf_wsc4(ind2));
disp(metricsGFS);
fprintf(fid,'%s,','Coldest Pix 4.0');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsGFS.mo,metricsGFS.mf,metricsGFS.so,metricsGFS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsGFS.rms,metricsGFS.crms,metricsGFS.mb,metricsGFS.cc,metricsGFS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsGFS.c1,metricsGFS.c2,metricsGFS.c3,metricsGFS.count);

fclose(fid);
toc