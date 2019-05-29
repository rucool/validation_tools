% Figure 5 - Power Potential (sum of power binned by speed)
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear all;

% Load data
ncfile = 'q4_20180801_20181031.nc';
dtime = ncread(ncfile,'time');
dtime = double(dtime)+datenum(2010,1,1); %Convert to Matlab time
wind_spd = ncread(ncfile,'wind_speed');
buoys = ncread(ncfile,'station')';

% Extract 120m level (bin 3)
wind_spd = squeeze(wind_spd(3,:,:));

% Load Power Curve
lw8mw = csvread('../wrf_converters/wrf_lw8mw_power.csv',2);
wind_power = interp1(lw8mw(:,1),lw8mw(:,2),wind_spd);

% Select a Buoy
bb=2;
    
% Calculate Power Totals
centers = 0.5:25.5;
power_sum = centers*NaN;

for jj=1:length(centers)
    ind = find(wind_spd(bb,:) >= centers(jj)-0.5 & wind_spd(bb,:) < centers(jj)+0.5);
    power_sum(jj) = sum(wind_power(bb,ind));
end

% Convert to percentage of total
% power_sum = power_sum / nansum(power_sum)*100;

bar(centers,power_sum,1,'FaceColor',[116,169,207]/255);
grid on;
xlabel('Wind Speed Bin (m/s)');
ylabel('Total Energy (kWh)');
title(sprintf('Total Energy by Wind Speed at %s for the Period %s to %s',buoys(bb,:),datestr(dtime(1),2),datestr(dtime(end),2)));
set(gca,'xlim',[0 25]);

% Plot max power line
hold on;
yl=get(gca,'ylim');
plot([12.5 12.5],yl,'k--','linewidth',2);

% Calculte Cumulative Sum
cs = cumsum(power_sum,'omitnan');
cs = cs/max(cs)*100;
yyaxis right
hold on
plot(centers,cs,'linewidth',2,'color','k')
ylabel('Cumulative Sum (%)')
set(gca,'ycolor','k')

set(gcf,'PaperPosition',[0.25 0.5 8 5])
print(gcf,'-dpng','-r300', 'images/fig5_power');


% Calculate the total capacity factor
hour_count = length(find(~isnan(wind_power(bb,:))));
capacity = hour_count*8000;
energy = nansum(wind_power(bb,:));
cf = energy*.9 / capacity;

fprintf('Total Energy: %g kWh \n',energy);
fprintf('Less 10%%: %g kWh \n',energy*.9);
fprintf('Capacity (%d hours): %g kWh \n',hour_count, capacity);
fprintf('CF: %4.2f%% \n\n',cf*100);

fprintf('Percent coverage: %4.2f%% \n\n',hour_count/length(wind_power(bb,:))*100);

