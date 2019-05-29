%% Historical Validation of RU-WRF in the NREL Period w/ GFS and NAM data
%% setup
clear; clc; close all;
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel/wrf_nrel
addpath /Volumes/home/jad438/wrf_converters/
%% Setup Variables
buoy = '44025';
start_date = datenum(2015,07,30);
end_date = datenum(2015,08,06);

% wrf4_cold_20150803_20150804.nc                              
% wrf4_cold_full_20150803_20150804.nc                   
% wrf4_rtg_20150803_20150804.nc                                 
% wrf4_rtg_full_20150803_20150804.nc

%% Load in NREL period RU-WRF Dataset
tic
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

%% Load in NAM historical
tic
[time_nam, ws_nam, wd_nams] = nam_dataload_historical(start_date,end_date,buoy);
disp('NAM Load Time:')
toc
% Interpolate NAM to nearest hour to buoy and fill gaps with NaNs
for cc=1:length(time_nam)
  dtime = time_nam(cc);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12));
  if isempty(ind) == 0
  ndbc_ws3(cc,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
  elseif isempty(ind) == 1 
  ndbc_ws3(cc,1) = NaN;
  else
  disp('empty error')
  end
end

%% Load in GFS historical
tic
[time_gfs, ws_gfs, wd_gfs] = gfs_dataload_historical(start_date,end_date,buoy);
disp('GFS Load Time:')
toc
% Interpolate NAM to nearest hour to buoy and fill gaps with NaNs
for cc=1:length(time_gfs)
  dtime = time_gfs(cc);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12));
  if isempty(ind) == 0
  ndbc_ws4(cc,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
  elseif isempty(ind) == 1 
  ndbc_ws4(cc,1) = NaN;
  else
  disp('empty error')
  end
end


tic
disp('Indexing, Plotting, and Metrics Load time:')
% indexing for plotting and metrics
ind = find(wrf_dtime>=start_date & wrf_dtime < end_date);
ind2 = find(time_nam>=start_date & time_nam < end_date);
ind3 = find(time_gfs>=start_date & time_gfs < end_date);

%% Plotting
hold on;
plot(time_nam,ws_nam,'linewidth',1,'color',[0 0.4470 0.7410]);
plot(time_gfs,ws_gfs,'linewidth',1,'color',[0.4660 0.6740 0.1880]);
plot(wrf_dtimec(ind),wrf_wsc(ind),'blue','linewidth',2); 
plot(wrf_dtime(ind),wrf_ws(ind),'r','linewidth',1.5);
plot(wrf_dtime(ind),ndbc_ws2(ind),'k-','linewidth',2);

title(sprintf('Wind Speeds at %s',buoy));
l = legend({'NAM','GFS','Coldestpix','RTG','Buoy'}, 'Location','best');
datetick('x');
%set(gca,'xlim',[wrf_dtime(1) wrf_dtime(end)]);
xlabel(sprintf('Start date: %s',datestr(start_date,1)));
ylabel('m/s')
grid on
% figure save
set(gcf,'PaperPosition',[0.25 0.5 8 5]);
fname = sprintf('output/RTG_COLD/buoy%s_RC_nam_gfs_hist__comparison_%s_%s',buoy,datestr(wrf_dtime(ind(1)),29),datestr(wrf_dtime(ind(end)),29));
print(gcf,'-dpng','-r300', fname);

%% Metrics
metricsWRF = wrf_metrics(ndbc_ws2(ind),wrf_ws(ind));
disp(metricsWRF);

outfile = sprintf('output/RTG_COLD/metrics_RC_all_%s_%s_%s.csv',buoy,datestr(wrf_dtime(ind(1)),29),datestr(wrf_dtime(ind(end)),29));
fid = fopen(outfile,'w');

fprintf(fid,'%s\n','Model,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
fprintf(fid,'%s,','RTG');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);

% ColdPix
metricsWRF = wrf_metrics(ndbc_ws2(ind),wrf_wsc(ind));
disp(metricsWRF);

fprintf(fid,'%s,','Coldestpix');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);

% NAMS to Buoy

metricsNAMS = wrf_metrics(ndbc_ws3(ind2)',ws_nam(ind2));
disp(metricsNAMS);
fprintf(fid,'%s,','NAMS');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsNAMS.mo,metricsNAMS.mf,metricsNAMS.so,metricsNAMS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsNAMS.rms,metricsNAMS.crms,metricsNAMS.mb,metricsNAMS.cc,metricsNAMS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsNAMS.c1,metricsNAMS.c2,metricsNAMS.c3,metricsNAMS.count);

% GFS to Buoy

metricsGFS = wrf_metrics(ndbc_ws4(ind3)',ws_gfs(ind3));
disp(metricsGFS);
fprintf(fid,'%s,','GFS');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsGFS.mo,metricsGFS.mf,metricsGFS.so,metricsGFS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsGFS.rms,metricsGFS.crms,metricsGFS.mb,metricsGFS.cc,metricsGFS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsGFS.c1,metricsGFS.c2,metricsGFS.c3,metricsGFS.count);

fclose(fid);
toc