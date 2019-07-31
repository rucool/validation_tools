%% Wind Profile code
close all; clear; clc;
WRF_v39.file = '/Volumes/home/jad438/wrf_converters/2weeks/v39_2w_W39_20190710_20190723.nc';
WRF_v41.file = '/Volumes/home/jad438/wrf_converters/2weeks/v41_2w_W41_20190710_20190723.nc';

%% Loading and Data Structure Formatting
WRF_v39.st = ncread(WRF_v39.file, 'station')';
WRF_v41.st = ncread(WRF_v41.file, 'station')';

WRF_v39.ht = ncread(WRF_v39.file, 'height');
WRF_v41.ht = ncread(WRF_v41.file, 'height');

WRF_v39.ws = ncread(WRF_v39.file, 'wind_speed');
WRF_v41.ws = ncread(WRF_v41.file, 'wind_speed');

WRF_v39.dt = ncread(WRF_v39.file, 'time')+datenum(2010,1,1);
WRF_v41.dt = ncread(WRF_v41.file, 'time')+datenum(2010,1,1);

wrf_dtime = WRF_v41.dt;
%% Buoy
buoy = '44065';
ndbc_url = sprintf('https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/%s/%sh9999.nc',buoy,buoy);
ndbc_dtime = double(ncread(ndbc_url,'time'))/(24*60*60)+datenum(1970,1,1);
ind = find(ndbc_dtime>=min(wrf_dtime) & ndbc_dtime<max(wrf_dtime));
ndbc_dtime = ndbc_dtime(ind);
ndbc_ws = squeeze(ncread(ndbc_url,'wind_spd',[1 1 min(ind)],[1 1 length(ind)],[1 1 1]));

% Interpolate buoy data to nearest hour
for jj=1:length(wrf_dtime)
  dtime = wrf_dtime(jj);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12)); %Limit to 4h window
  if length(ind)>1
    buoy_ws(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
  else
    buoy_ws(jj,1) = NaN;
  end
end

zo = .5/1000;
us = log(10/zo)/log(5/zo);
buoy_ws = buoy_ws*us;

%% Similarity Checking
if strcmp(WRF_v41.st, WRF_v39.st) == 1
    disp('Stations Matched');
elseif strcmp(WRF_v41.st, WRF_v39.st) == 0
    disp('Stations Mismatched');
else
    disp('Check Stations')
end

%% var manip and plotting

hold on
plot(wrf_dtime,buoy_ws,'k-','linewidth',1.5,'DisplayName','Buoy')
plot(WRF_v39.dt,squeeze(WRF_v39.ws(1,3,:)),'linewidth',1.5,'DisplayName','WRF V3.9')
plot(WRF_v41.dt,squeeze(WRF_v41.ws(1,3,:)),'linewidth',1.5,'DisplayName','WRF V4.1')
title(['Wind speeds at ' WRF_v41.st(3,:) ' on ' datestr(WRF_v41.dt(1),'mm/dd/yy')])
ylabel('Wind Speed (m/s)')
xlabel('time')
grid on
datetick('x')
legend()
set(gcf,'PaperPosition',[0.25 0.5 16 8]);
fname = sprintf('output/ws_y_v41_v39_comp_%s-%s', datestr(WRF_v41.dt(1),'yyyymmdd'),datestr(WRF_v41.dt(end),'yyyymmdd'));
print(gcf,'-dpng','-r300', fname);

