%% Hexscatter figure for RU-WRF
clear; clc; close all;


start_date = datenum(2016,01,01);
end_date = datenum(2017,01,01)-1;
lvl = 2; %100m
[wrf_ws,~,wrf_time] = wrf_rerun_loader(start_date,end_date,lvl);

hexscatter(wrf_time, wrf_ws, 'res', 35);

%% Figure Setup
title('Wind Speeds at DoE Buoy Location');
datetick('x');
xlim([start_date-5 end_date+5])
h = colorbar;
ylabel('Wind Speed m/s');
ylabel(h, 'Data Density');
xlabel([datestr(start_date) ' to ' datestr(end_date)]);
xlim([start_date-4 end_date+5])
ylim([-.2 30])

%% Saving the figure

set(gcf,'PaperPosition',[0.25 0.5 8 8]);
fname = sprintf('output/hexscatter/hex_%s-%s',datestr(start_date,29),datestr(end_date,29));
print(gcf,'-dpng','-r300', fname);
