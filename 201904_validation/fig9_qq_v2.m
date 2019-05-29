% Figure 9 - Example QQ Plot
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
close all; clear; clc;
%------------------------------------------------
start_date = datenum(2016,01,01);
end_date = datenum(2017,01,01)-1;
buoy = 'DOEFL';

%% Data load
lvl = 2; %100m
[wrf_ws,~,wrf_time] = wrf_rerun_loader(start_date,end_date,lvl);
zo = .5/1000;
us = log(90/zo)/log(100/zo);
wrf_ws = wrf_ws*us;

%% DoE Load
tic
%111m
[doe_time_i,doe_90_ws_i,~] = doeflb_loader(start_date,end_date);
n = 600; % average every n values (600 = 10 minutes)
doe_90_ws_i2 = arrayfun(@(i) nanmean(doe_90_ws_i(i:i+n-1)),1:n:length(doe_90_ws_i)-n+1); % the averaged vector
%doe_130_ws_i2 = arrayfun(@(i) nanmean(doe_130_ws_i(i:i+n-1)),1:n:length(doe_130_ws_i)-n+1); % the averaged vector

doe_time_i2 = start_date:minutes(10):end_date+1;

% hourly winds
doe_time_i3 = start_date:hours(1):end_date+1;
[hind,~] = ismember(datenum(doe_time_i2),datenum(doe_time_i3(1:end-1)));
hind = find(hind==1);

disp('DoE Buoy Load Time:')
toc

%% plot
% Calculate percentiles
px = quantile(doe_90_ws_i2(hind)',[0:.01:1]);
py = quantile(wrf_ws,[0:.01:1]);

% Create the plot
plot(px,py,'.','markersize',12); hold on;
plot([0 25],[0 25],'k-');
title(sprintf('QQ plot of Model & Observed Wind Speeds at %s',buoy),'fontsize',11);
xlabel('DoEFL Observations 90m');
ylabel('RU-WRF Model 90m');
% axis equal;
set(gca,'xlim',[0 25],'ylim',[0 25],'dataaspectratio',[1 1 1])
set(gcf,'PaperPosition',[0.25 0.5 5 5],'renderer','opengl')
fname = sprintf('output/QQ/fig9_qq_6ho_%s_%s-%s',buoy,datestr(start_date,'yyyymmdd'),datestr(end_date,'yyyymmdd'));
print(gcf,'-dpng','-r300', fname);
