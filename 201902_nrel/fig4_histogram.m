% Figure 4 - Wind Histograms of Speed/Energy
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear; clc;

% Load data
ncfile = 'q4_20180801_20181031.nc';
dtime = ncread(ncfile,'time');
dtime = double(dtime)+datenum(2010,1,1); %Convert to Matlab time
wind_spd = ncread(ncfile,'wind_speed');
buoys = ncread(ncfile,'station')';

% Extract 120m level (bin 3)
wind_spd = squeeze(wind_spd(3,:,:));

% Load Power Curve
lw8mw = csvread('wrf_lw8mw_power.csv',2);
wind_power = interp1(lw8mw(:,1),lw8mw(:,2),wind_spd);

% Select a Buoy
bb=2;

% Wind Speed Histogram
figure(1)
[counts,centers]=hist(wind_spd(bb,:),0.5:25.5);
bar(centers,counts,1,'FaceColor',[116,169,207]/255);
grid on;
set(gca,'xlim',[0 25]);
ylabel('Number of hours');
xlabel('m/s');
title(sprintf('Histogram of 120m Winds at %s for the Period %s to %s',buoys(bb,:),datestr(dtime(1),2),datestr(dtime(end),2)));
yyaxis right
plot(lw8mw(:,1),lw8mw(:,2),'linewidth',2,'color','k')
ylabel('8MW Wind Turbine Power (kW)')
set(gca,'ycolor','k','ylim',[0 9000]);

set(gcf,'PaperPosition',[0.25 0.5 8 5])
print(gcf,'-dpng','-r300', 'output/fig4_speed');

% Wind Power Histogram
figure(2)
[counts,centers]=hist(wind_power(bb,:),250:500:8000);
bar(centers,counts,1,'FaceColor',[116,169,207]/255);
grid on;
ylabel('Number of hours');
xlabel('kW');
title(sprintf('Histogram of 120m Wind Energy at %s for the Period %s to %s',buoys(bb,:),datestr(dtime(1),2),datestr(dtime(end),2)));

set(gcf,'PaperPosition',[0.25 0.5 8 5])
print(gcf,'-dpng','-r300', 'output/fig4_power');
