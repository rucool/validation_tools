%% Historical Validation of RU-WRF in the NREL Period w/ GFS and NAM data
%% setup
clear; clc; close all;
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel/wrf_nrel

%% Setup Variables
buoy = '44025';
start_date = datenum(2015,06,01);
end_date = datenum(2015,11,30);

%% Load in NREL period RU-WRF Dataset
fid1 = 'nrel_20150601_20150630.nc';
fid2 = 'nrel_20150701_20150731.nc';
fid3 = 'nrel_20150801_20150831.nc';
%fid4 = 'nrel_20150901_20150930.nc';
%fid5 = 'nrel_20151001_20151031.nc';
%fid6 = 'nrel_20151101_20151130.nc';

% pull data corresponding to the correct buoy
wrf_stations = ncread('nrel_20150701_20150731.nc','station')';
ind = strmatch(buoy,wrf_stations);

wrf_wsa = ncread(fid1,'wind_speed');
wrf_wsa = squeeze(wrf_wsa(1,ind,:));
wrf_wsb = ncread(fid2,'wind_speed');
wrf_wsb = squeeze(wrf_wsb(1,ind,:));
wrf_wsc = ncread(fid3,'wind_speed');
wrf_wsc = squeeze(wrf_wsc(1,ind,:));
% wrf_wsd = ncread(fid4,'wind_speed');
% wrf_wsd = squeeze(wrf_wsd(1,ind,:));
% wrf_wse = ncread(fid5,'wind_speed');
% wrf_wse = squeeze(wrf_wse(1,ind,:));
% wrf_wsf = ncread(fid6,'wind_speed');
% wrf_wsf = squeeze(wrf_wsf(1,ind,:));

wrf_ws = [wrf_wsa; wrf_wsb; wrf_wsc];%; wrf_wsd; wrf_wse; wrf_wsf];%; wrf_wsb];

time.t1 = ncread(fid1,'time')+ datenum(2010,1,1);
time.t2 = ncread(fid2,'time')+ datenum(2010,1,1);
time.t3 = ncread(fid3,'time')+ datenum(2010,1,1);
% time.t4 = ncread(fid4,'time')+ datenum(2010,1,1);
% time.t5 = ncread(fid5,'time')+ datenum(2010,1,1);
% time.t6 = ncread(fid6,'time')+ datenum(2010,1,1);

wrf_dtime = [time.t1; time.t2; time.t3];%; time.t4; time.t5; time.t6];

%% Load in NAM historical
tic
disp('NAM Load Time:')
[nam_time, nam_ws, nam_wd] = nam_dataload_historical(start_date,end_date,buoy);
toc

%% Load in GFS historical
tic
disp('GFS Load Time:')
[gfs_time, gfs_ws, gfs_wd] = gfs_dataload_historical(start_date,end_date,buoy);
toc

%% Load in Buoy Data
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

%% Load Power Curve
lw8mw = csvread('wrf_lw8mw_power.csv',2);
wind_power_wrf = interp1(lw8mw(:,1),lw8mw(:,2),wrf_ws);
wind_power_NAM = interp1(lw8mw(:,1),lw8mw(:,2),nam_ws);
wind_power_GFS = interp1(lw8mw(:,1),lw8mw(:,2),gfs_ws);

tic
% indexing for plotting and metrics
ind = find(wrf_dtime>=start_date & wrf_dtime < end_date);
ind2 = find(nam_time>=start_date & nam_time < end_date);
ind3 = find(gfs_time>=start_date & gfs_time < end_date);

%% Plotting
hold on
%WRF
[counts,centers]=hist(wrf_ws(ind),0.5:25.5);
bar(centers,counts./numel(wrf_ws(ind)),.9,'FaceColor',[200,220,207]/255,'facealpha',1,'displayname','WRF');
%histogram(wrf_ws(ind),0.5:25.5,'displaystyle','stairs','normalization','probability','displayname','WRF','linewidth',5)
%histogram(wrf_ws(ind),0.5:25.5,'displaystyle','bar','normalization','probability','displayname','WRF','FaceColor',[200,220,207]/255)
disp(numel(wrf_ws(ind)));

%NAM
[counts,centers]=hist(nam_ws(ind2),0.5:25.5);
bar(centers,counts./numel(nam_ws(ind2)),.7,'FaceColor',[116,169,207]/255,'facealpha',1,'displayname','NAM');
%histogram(nam_ws(ind2),0.5:25.5,'displaystyle','stairs','normalization','probability','displayname','NAM','linewidth',3)
%histogram(nam_ws(ind2),0.5:25.5,'displaystyle','bar','normalization','probability','displayname','NAM','FaceColor',[116,169,207]/255)
disp(numel(nam_ws(ind2)));

%GFS
[counts,centers]=hist(gfs_ws(ind3),0.5:25.5);
bar(centers,counts./numel(gfs_ws(ind3)),.5,'FaceColor',[050,169,150]/255,'facealpha',1,'displayname','GFS');
%histogram(gfs_ws(ind3),0.5:25.5,'displaystyle','stairs','normalization','probability','displayname','GFS','linewidth',1)
%histogram(gfs_ws(ind3),0.5:25.5,'displaystyle','bar','normalization','probability','displayname','GFS','FaceColor',[050,169,150]/255)
disp(numel(gfs_ws(ind3)));

%BUOY
[counts,centers]=hist(ndbc_ws2(ind),0.5:25.5);
bar(centers,counts./numel(ndbc_ws2(ind)),1,'edgecolor',[0,0,0]/255,'linewidth',3,'facealpha',0,'displayname','Buoy');
%histogram(ndbc_ws2(ind),0.5:25.5,'displaystyle','bar','normalization','probability','displayname','Buoy','linewidth',2,'edgecolor','black')
%histogram(ndbc_ws2(ind),0.5:25.5,'displaystyle','bar','normalization','probability','displayname','GFS','FaceColor',[050,169,150]/255)
disp(numel(ndbc_ws2(ind)));

grid on;
grid minor;
set(gca,'xlim',[0 25]);
ylabel('Probability'); %(number of observations in bin / total number of observations)
xlabel('m/s');
title(sprintf('Histogram of 10m Winds at %s for the Period %s to %s',buoy,datestr(wrf_dtime(ind(1)),2),datestr(wrf_dtime(ind(end)),2)));
legend()
%yyaxis right
%plot(lw8mw(:,1),lw8mw(:,2),'linewidth',2,'color','k','displayname','Power Curve')
%ylabel('8MW Wind Turbine Power (kW)')
%set(gca,'ycolor','k','ylim',[0 9000]);

set(gcf,'PaperPosition',[0.25 0.5 8 5])
print(gcf,'-dpng','-r300', ['output/fig4_power_' datestr(start_date,'yyyymmdd') '_' datestr(end_date,'yyyymmdd')]);


disp('Indexing, Plotting, and Metrics Load time:')
toc