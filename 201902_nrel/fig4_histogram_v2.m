% Figure 4 - Wind Histograms of Speed/Energy
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear; clc;

% Load data
% Load data
season = 'spring';
[start_date,end_date,months] = metseason(season);

% Setup monthly axes
noplots = length(months)-1;
monthi.m1 = datestr(start_date,'yyyymmdd');
monthi.m2 = datestr(eomdate(year(monthi.m1,'yyyymmdd'),month(monthi.m1,'yyyymmdd')),'yyyymmdd');
monthi.m3 = datestr(addtodate(datenum(monthi.m2,'yyyymmdd'),1,'day'),'yyyymmdd');
monthi.m4 = datestr(eomdate(year(monthi.m3,'yyyymmdd'),month(monthi.m3,'yyyymmdd')),'yyyymmdd');
monthi.m5 = datestr(addtodate(datenum(monthi.m4,'yyyymmdd'),1,'day'),'yyyymmdd');
monthi.m6 = datestr(end_date,'yyyymmdd');
% Load Model Data
addpath C:\Users\Jades\COOL\wrf_sage\201902_nrel\wrf_nrel
dfile = 'nrel_20150601_20160531.nc';
% dtime
time.t1 = ncread(dfile,['/nrel_' monthi.m1 '_' monthi.m2 '/time'])+ datenum(2010,1,1);
time.t2 = ncread(dfile,['/nrel_' monthi.m3 '_' monthi.m4 '/time'])+ datenum(2010,1,1);
time.t3 = ncread(dfile,['/nrel_' monthi.m5 '_' monthi.m6 '/time'])+ datenum(2010,1,1);
wrf_dtime = [time.t1;time.t2;time.t3]; 

% ws
wrf_ws = ncread(dfile,['/nrel_' monthi.m1 '_' monthi.m2 '/wind_speed']);
wrf_wsA = squeeze(wrf_ws(3,:,:));
wrf_ws = ncread(dfile,['/nrel_' monthi.m3 '_' monthi.m4 '/wind_speed']);
wrf_wsB = squeeze(wrf_ws(3,:,:));
wrf_ws = ncread(dfile,['/nrel_' monthi.m5 '_' monthi.m6 '/wind_speed']);
wrf_wsC = squeeze(wrf_ws(3,:,:));

wrf_ws = [wrf_wsA wrf_wsB wrf_wsC];

% Load Power Curve
lw8mw = csvread('wrf_lw8mw_power.csv',2);
wind_power = interp1(lw8mw(:,1),lw8mw(:,2),wrf_ws);

% Select a Buoy
buoys = ncread('nrel_20150601_20150630.nc','station')';
bb=8;

% Wind Speed Histogram
figure(1)
[counts,centers]=hist(wrf_ws(bb,:),0.5:25.5);
bar(centers,counts,1,'FaceColor',[116,169,207]/255);
grid on;
set(gca,'xlim',[0 25]);
ylabel('Number of hours');
xlabel('m/s');
title(sprintf('Histogram of 120m Winds at %s for the Period %s to %s',buoys(bb,:),datestr(wrf_dtime(1),2),datestr(wrf_dtime(end),2)));
yyaxis right
plot(lw8mw(:,1),lw8mw(:,2),'linewidth',2,'color','k')
ylabel('8MW Wind Turbine Power (kW)')
set(gca,'ycolor','k','ylim',[0 9000]);

set(gcf,'PaperPosition',[0.25 0.5 8 5])
print(gcf,'-dpng','-r300', ['output/fig4_speed_' season]);

% Wind Power Histogram
figure(2)
[counts,centers]=hist(wind_power(bb,:),250:500:8000);
bar(centers,counts,1,'FaceColor',[116,169,207]/255);
grid on;
ylabel('Number of hours');
xlabel('kW');
title(sprintf('Histogram of 120m Wind Energy at %s for the Period %s to %s',buoys(bb,:),datestr(wrf_dtime(1),2),datestr(wrf_dtime(end),2)));

set(gcf,'PaperPosition',[0.25 0.5 8 5])
print(gcf,'-dpng','-r300', ['output/fig4_power_' season]);
