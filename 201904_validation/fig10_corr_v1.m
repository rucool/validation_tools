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
doe_90_ws_i2 = doe_90_ws_i2(hind)';
disp('DoE Buoy Load Time:')
toc

%% plot
%buoy01i is ndbc
hold on
Good = isnan(doe_90_ws_i2) + isnan(wrf_ws);
plot(doe_90_ws_i2(Good==0),wrf_ws(Good==0),'b*')
P=polyfit(doe_90_ws_i2(Good==0),wrf_ws(Good==0),1);
RHO = corr(doe_90_ws_i2(Good==0),wrf_ws(Good==0));
R = corrcoef(doe_90_ws_i2(Good==0),wrf_ws(Good==0));
Rsq = R.^2;
X = 0:1:30;
Y = polyval(P,X);
plot(X,Y,'k-')

% Create the plot
grid on
text(1,28,['y=' num2str(P(1)) 'x+' num2str(P(2))])
text(1,27,['Nonforced Corr: ' num2str(RHO)])
text(1,26,['R squared: ' num2str(Rsq(2))])
title(sprintf('Scatter Plot for Wind Speeds at %s with 6ho',buoy),'fontsize',11);
xlabel('DoEFL Observations 90m');
ylabel('RU-WRF Model 90m');
% axis equal;
%set(gca,'xlim',[0 25],'ylim',[0 25],'dataaspectratio',[1 1 1])
set(gcf,'PaperPosition',[0.25 0.5 5 5],'renderer','opengl')
fname = sprintf('output/corr/fig10_corr_6ho_%s_%s-%s',buoy,datestr(start_date,'yyyymmdd'),datestr(end_date,'yyyymmdd'));
print(gcf,'-dpng','-r300', fname);
