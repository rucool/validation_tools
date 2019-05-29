% Figure 5 - Power Potential (sum of power binned by speed)
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear; clc;

% Load data
season = ["summer","fall","winter","spring"];
for ss = season
[start_date,end_date,months,sn,sc] = metseason(ss);

% Setup monthly axes
noplots = length(months)-1;
monthi.m1 = datestr(start_date,'yyyymmdd');
monthi.m2 = datestr(eomdate(year(monthi.m1,'yyyymmdd'),month(monthi.m1,"yyyymmdd")),'yyyymmdd');
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

figure(1)

% Load Power Curve
lw8mw = csvread('wrf_lw8mw_power.csv',2);
wind_power = interp1(lw8mw(:,1),lw8mw(:,2),wrf_ws);

% Select a Buoy
buoys = ncread('nrel_20150601_20150630.nc','station')';
bb=7;

% Calculate Power Totals
centers = 0.5:25.5;
power_sum = centers*NaN;

for jj=1:length(centers)
    ind = find(wrf_ws(bb,:) >= centers(jj)-0.5 & wrf_ws(bb,:) < centers(jj)+0.5);
    power_sum(jj) = sum(wind_power(bb,ind));
end

% Convert to percentage of total
% power_sum = power_sum / nansum(power_sum)*100;
subplot(2,2,sn)
bar(centers,power_sum,1,'FaceColor',[116,169,207]/255);
grid on;
title(ss)
xlabel('Wind Speed Bin (m/s)');
ylabel('Total Energy (kWh)');
set(gca,'xlim',[0 25]);

% Plot max power line
hold all;
yl=get(gca,'ylim');
plot([12.5 12.5],yl,'k--','linewidth',2);

% Calculte Cumulative Sum
cs = cumsum(power_sum,'omitnan');
cs = cs/max(cs)*100;
yyaxis right
%hold on
plot(centers,cs,'linewidth',2,'color','k')
ylabel('Cumulative Sum (%)')
set(gca,'ycolor','k')

while strcmp(ss,'summer') == 1
    txt = {'\leftarrow Turbine', '     Rated Speed'};
    text(12.6,50,txt,'fontsize',11)
    break
end

%% new figure for centers cs
figure(2)
hold all
%legendname = ['X = ',num2str(k)];
plot(centers,cs,'-','linewidth',2,'DisplayName',ss,'color',sc);
ylabel('Cumulative Sum (%)')
xlabel('Wind Speed Bin (m/s)');
grid('on')
legend()

end

figure(1)
sgtitle(sprintf('Total Energy by Wind Speed at %s for the Period 2015/06/01 to 2016/05/31',buoys(bb,:)));
set(gcf,'PaperPosition',[0.25 0.5 8 5])
print(gcf,'-dpng','-r300', 'output/fig5_power_all');

figure(2)
yl=get(gca,'ylim');
plot([12.5 12.5],yl,'k--','linewidth',2,'HandleVisibility','off');
sgtitle(sprintf('Total Energy by Wind Speed at %s for the Period 2015/06/01 to 2016/05/31',buoys(bb,:)));
set(gcf,'PaperPosition',[0.25 0.5 8 5])
print(gcf,'-dpng','-r300', 'output/fig5_power_curves_all');

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

