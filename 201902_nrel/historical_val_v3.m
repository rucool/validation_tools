%% Historical Validation of RU-WRF in the NREL Period w/ GFS and NAM data
%% setup
clear; clc; close all;
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel/wrf_nrel

%% Setup Variables
buoy = '44025';
start_date = datenum(2015,09,14);
end_date = datenum(2015,09,19);

%% Load in NREL period RU-WRF Dataset
%fid1 = 'nrel_20150601_20150630.nc';
%fid1 = 'nrel_20150701_20150731.nc';
%fid1 = 'nrel_20150801_20150831.nc';
fid1 = 'nrel_20150901_20150930.nc';
%fid5 = 'nrel_20151001_20151031.nc';
%fid6 = 'nrel_20151101_20151130.nc';

% pull data corresponding to the correct buoy
wrf_stations = ncread('nrel_20150701_20150731.nc','station')';
ind = strmatch(buoy,wrf_stations);

wrf_wsa = ncread(fid1,'wind_speed');
wrf_wsa = squeeze(wrf_wsa(1,ind,:));
% wrf_wsb = ncread(fid2,'wind_speed');
% wrf_wsb = squeeze(wrf_wsb(1,ind,:));

wrf_ws = [wrf_wsa];%; wrf_wsb];

time.t1 = ncread(fid1,'time')+ datenum(2010,1,1);
%time.t2 = ncread(fid2,'time')+ datenum(2010,1,1);

wrf_dtime = [time.t1];% time.t2];

%% Load in Buoy data
tic
disp('Buoy Load Time:')
[ndbc_dtime,ndbc_ws] = ndbc_loader(start_date,end_date,buoy);
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
disp('NAM Load Time:')
[time_nam, ws_nam, wd_nams] = nam_dataload_historical(start_date,end_date,buoy);
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
disp('GFS Load Time:')
[time_gfs, ws_gfs, wd_gfs] = gfs_dataload_historical(start_date,end_date,buoy);
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
plot(wrf_dtime(ind),wrf_ws(ind),'r','linewidth',1.5); hold on;
plot(wrf_dtime(ind),ndbc_ws2(ind),'k-','linewidth',2);
plot(time_nam,ws_nam,'linewidth',1,'color',[0 0.4470 0.7410]);
plot(time_gfs,ws_gfs,'linewidth',1,'color',[0.4660 0.6740 0.1880]);

title(sprintf('Wind Speeds at %s',buoy));
l = legend({'Model','Buoy','NAM','GFS'}, 'Location','NorthEast');
datetick('x');
%set(gca,'xlim',[wrf_dtime(1) wrf_dtime(end)]);
xlabel(sprintf('Start date: %s',datestr(time_nam(1),1)));
ylabel('m/s')
grid on
% figure save
set(gcf,'PaperPosition',[0.25 0.5 8 5]);
fname = sprintf('output/buoy%s_ruwrf_nam_gfs_hist__comparison_%s_%s',buoy,datestr(wrf_dtime(ind(1)),29),datestr(wrf_dtime(ind(end)),29));
print(gcf,'-dpng','-r300', fname);

%% Metrics
metricsWRF = wrf_metrics(ndbc_ws2(ind),wrf_ws(ind));
disp(metricsWRF);

outfile = sprintf('output/metrics_all_%s_%s_%s.csv',buoy,datestr(wrf_dtime(ind(1)),29),datestr(wrf_dtime(ind(end)),29));
fid = fopen(outfile,'w');

fprintf(fid,'%s\n','Model,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
fprintf(fid,'%s,','RU-WRF');
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