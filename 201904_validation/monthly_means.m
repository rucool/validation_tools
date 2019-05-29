%% Monthly Wind Speeds Means
close all; clear; clc;
%addpath /Volumes/home/sage/bpu_project/201812_strategicplan/201901_v2_120m/
dir120m = '/Volumes/home/sage/bpu_project/201812_strategicplan/201901_v2_120m/wrf_monthly_wind_means.nc';
dir140m = '/Volumes/home/sage/bpu_project/201812_strategicplan/201901_v1_140m/wrf_monthly_wind_means.nc';

n21 = 183; n22 = 176;
s21 = 174; s22 = 168;

%%
wrf_newn.time = ncread(dir120m,'month');
wrf_rawn.ws = ncread(dir120m,'wind_mean');
wrf_newn.ws = squeeze(wrf_rawn.ws(n21,n22,:));
lat = ncread(dir120m,'lat');
lati = squeeze(lat(n22,n21));
lon = ncread(dir120m,'lon');
loni = squeeze(lon(n22,n21));
disp(lati)
disp(loni)

wrf_news.time = ncread(dir120m,'month');
wrf_raws.ws = ncread(dir120m,'wind_mean');
wrf_news.ws = squeeze(wrf_raws.ws(s21,s22,:));
lat = ncread(dir120m,'lat');
lati = squeeze(lat(s22,s21));
lon = ncread(dir120m,'lon');
loni = squeeze(lon(s22,s21));
disp(lati)
disp(loni)

%%
wrf_newn4.time = ncread(dir140m,'month');
wrf_rawn4.ws = ncread(dir140m,'wind_mean');
wrf_newn4.ws = squeeze(wrf_rawn4.ws(n21,n22,:));
lat = ncread(dir140m,'lat');
lati = squeeze(lat(n22,n21));
lon = ncread(dir140m,'lon');
loni = squeeze(lon(n22,n21));
disp(lati)
disp(loni)

wrf_news4.time = ncread(dir140m,'month');
wrf_raws4.ws = ncread(dir140m,'wind_mean');
wrf_news4.ws = squeeze(wrf_raws4.ws(s21,s22,:));
lat = ncread(dir140m,'lat');
lati = squeeze(lat(s22,s21));
lon = ncread(dir140m,'lon');
loni = squeeze(lon(s22,s21));
disp(lati)
disp(loni)

%%
hold on
timespan = datenum(2018,1:12,1);
plot(timespan,wrf_newn.ws,'color','green','displayname','N2 120m','linewidth',3)
%plot(timespan,wrf_news.ws,'displayname','S2 120m','linewidth',1.5)
%plot(timespan,wrf_newn4.ws,'displayname','N2 140m','linewidth',1.5)
%plot(timespan,wrf_news4.ws,'displayname','S2 140m','linewidth',1.5)
%legend('location','best')
%title('2018 Wind Speed Means')
xlim([timespan(1) timespan(end)])
ylim([0 11])
xlabel('month')
ylabel('m/s')
datetick('x','mmm','keeplimits');
axis tight

set(gcf,'PaperPosition',[0.25 0.5 8 8]);
ylim([0 11])
set(gca,'color','none')
fname = sprintf('output/monthly_wind_means');
print(gcf,'-dpng','-r300', fname);
export_fig monthly_wind_means_v2.png -transparent 
