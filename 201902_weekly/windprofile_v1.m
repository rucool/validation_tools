%% Wind Profile code
close all; clear; clc;
WRF_v39.file = '/Volumes/home/jad438/wrf_wp/wp_W39_20190710_20190723.nc';
WRF_v41.file = '/Volumes/home/jad438/wrf_wp/wp_W41_20190710_20190723.nc';

%% Loading and Data Structure Formatting
WRF_v39.st = ncread(WRF_v39.file, 'station')';
WRF_v41.st = ncread(WRF_v41.file, 'station')';

WRF_v39.ht = ncread(WRF_v39.file, 'height');
WRF_v41.ht = ncread(WRF_v41.file, 'height');

WRF_v39.ws = ncread(WRF_v39.file, 'wind_speed');
WRF_v41.ws = ncread(WRF_v41.file, 'wind_speed');

WRF_v39.dt = ncread(WRF_v39.file, 'time')+datenum(2010,1,1);
WRF_v41.dt = ncread(WRF_v41.file, 'time')+datenum(2010,1,1);

%% Similarity Checking
if strcmp(WRF_v41.st, WRF_v39.st) == 1
    disp('Stations Matched');
elseif strcmp(WRF_v41.st, WRF_v39.st) == 0
    disp('Stations Mismatched');
else
    disp('Check Stations')
end

%% var manip and plotting
for jj = 1:length(WRF_v41.dt)
    for ii = 1:length(WRF_v41.st)
     figure(ii)
     hold on
     plot(WRF_v39.ws(:,ii,jj),WRF_v39.ht,'linewidth',2,'DisplayName','WRF V3.9')
     plot(WRF_v41.ws(:,ii,jj),WRF_v41.ht,'linewidth',2,'DisplayName','WRF V4.1')
     title(['Wind Profile at ' WRF_v41.st(ii,:) ' on ' datestr(WRF_v41.dt(jj),'mm/dd/yy HH')])
     ylabel('Height (m)')
     xlabel('Wind Speed (m/s)')
     xlim([0 21])%winds go from 0 to 21
     legend()
     set(gcf,'PaperPosition',[0.25 0.5 8 8]);
     fname = sprintf('output/wrf_wp/%s/wp_%s_%s',WRF_v41.st(ii,:),WRF_v41.st(ii,:),datestr(WRF_v41.dt(jj),'yyyymmdd_HH'));
     print(gcf,'-dpng','-r300', fname);
     close
    end
end
