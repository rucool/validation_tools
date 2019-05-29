% Figure 9 - Example QQ Plot
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear all;

% Select a Station
buoy = 'BRND1';
start_date = datenum(2018,8,1);
end_date = datenum(2018,11,1);

% Load Model Data
dfile = 'q4ndbc_20180801_20181031.nc';
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_stations = ncread(dfile,'station')';

% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
wrf_ws = squeeze(wrf_ws(1,ind,:)); 

% Load Buoy Data
ndbc_url = sprintf('../ndbc_data/%sh2018.nc',buoy);
ndbc_dtime = double(ncread(ndbc_url,'time'))/(24*60*60)+datenum(1970,1,1);
ndbc_ws = squeeze(ncread(ndbc_url,'wind_spd'));

% Interpolate buoy to nearest hour
for jj=1:length(wrf_dtime)
  dtime = wrf_dtime(jj);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12));
  ndbc_ws2(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
end

% Scale factor
sf = log(10/.0005)/log(5/.0005); 

% Calculate percentiles
px = quantile(ndbc_ws2*sf,[0:.01:1]);
py = quantile(wrf_ws,[0:.01:1]);

% Create the plot
plot(px,py,'.','markersize',12); hold on;
plot([0 25],[0 25],'k-');
title(sprintf('QQ plot of Model & Observed Wind Speeds at %s',buoy),'fontsize',11);
xlabel('NDBC Observations');
ylabel('RU-WRF Model');
% axis equal;
set(gca,'xlim',[0 25],'ylim',[0 25],'dataaspectratio',[1 1 1])
set(gcf,'PaperPosition',[0.25 0.5 5 5],'renderer','opengl')
fname = sprintf('images/fig9_qq_%s',buoy);
print(gcf,'-dpng','-r300', fname);

