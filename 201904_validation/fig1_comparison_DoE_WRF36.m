%% WRF 3.6 and DoE Floating Lidar Comparison
close all; clear; clc;

%% Establish time frame and point of interest
start_date = datenum(2016,07,01);
end_date = datenum(2016,08,01);
time_span = start_date:end_date;
point = 'DOEFL';
level = 3;

%% Establish Paths
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel/wrf_nrel
addpath /Volumes/home/jad438/wrf_converters/

%% Load the data and index
% WRF 3.6

[ws_wrf,wd_wrf,time_wrf] = wrf_rerun_loader(start_date,end_date,level);



% DoE Floating Lidar
[doe_time_i,doe_111_ws_i,doe_111_wd_i,doe_130_ws_i,doe_130_wd_i] = doeflb_loader(start_date,end_date);

doe_time_i2 = start_date:minutes(10):end_date+1;

n = 600; % average every n values (600 = 10 minutes)
doe_111_ws_i2 = arrayfun(@(i) nanmean(doe_111_ws_i(i:i+n-1)),1:n:length(doe_111_ws_i)-n+1); % the averaged vector
doe_130_ws_i2 = arrayfun(@(i) nanmean(doe_130_ws_i(i:i+n-1)),1:n:length(doe_130_ws_i)-n+1); % the averaged vector

%% Plot data
hold on
% DoE FL
plot(datenum(doe_time_i2(2:end)),doe_111_ws_i2,'k-','linewidth',1,'displayname','DoE Buoy 111m');
%plot(datenum(doe_time_i2(2:end)),doe_130_ws_i2,'color',[.75 .75 .75],'linewidth',1,'displayname','DoE Buoy 130m');

% WRF 3.6
plot(time_wrf,ws_wrf,'r-','linewidth',1,'displayname','WRF 3.6')

%% Set up and save figure
title(sprintf('Wind Speeds at %s',point));
legend('location','best','autoupdate','off');
datetick('x','mm/dd','keepticks');

xlim([start_date end_date]);
ylim([0 25])
xlabel(sprintf('Start date: %s',datestr(start_date,1)));
ylabel('m/s');
grid on
% figure save
set(gcf,'PaperPosition',[0.25 0.5 10 5]);
fname = sprintf('output/%s_WRF36_comparison_%s_%s',point,datestr(start_date,29),datestr(end_date,29));
print(gcf,'-dpng','-r300', fname);
