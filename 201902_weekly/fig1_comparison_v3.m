% Weekly validation figures
% BPU Wind Energy Project
% Written by Sage 2/5/19
% Editted by Jaden 2/14/19
%------------------------------------------------
close all; clear; clc;

% Select a Station
buoy = '44065';

% Specify Model File
% dfile = 'wrf_data_20190121_20190203.nc';
dfile = 'nams_gfs_comp_20190223_20190308.nc';
end_date = datenum(2019,3,8);
[gfs_time, gfs_ws, nams_time, nams_ws] = nams_gfs_dataload(end_date);
%load('nams_data.mat')
%------------------------------------------------
% Load model data
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_stations = ncread(dfile,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
wrf_ws = squeeze(wrf_ws(1,ind,:)); 

% Load Realtime Buoy Data
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

% Scale Buoy Data
zo = .5/1000;
us = log(10/zo)/log(5/zo);

% Plot the data
hold on
plot(wrf_dtime,buoy_ws*us,'k-','linewidth',2);
plot(wrf_dtime,wrf_ws,'r','linewidth',1.5); 
plot(nams_time,nams_ws,'color',[0 0.4470 0.7410],'linewidth',1);
plot(gfs_time,gfs_ws,'color',[0.4660 0.6740 0.1880],'linewidth',1);

%% Plot weather patches
hold all
weatherpatch('2019022318','2019022406','rain')
weatherpatch('2019022420','2019022712','highwind')
weatherpatch('2019030100','2019030106','snow')
weatherpatch('2019030200','2019030212','snow')
weatherpatch('2019030312','2019030406','snow')

%% figure setup
datetick('x');
set(gca,'xlim',[wrf_dtime(1) wrf_dtime(end)]);
xlabel(sprintf('Start date: %s',datestr(wrf_dtime(1),1)));
ylabel('m/s')
grid on;
title(sprintf('Wind Speeds at %s',buoy));
l = legend({'Buoy','Model','NAM','GFS'}, 'Location','NorthEast');

% Calculate and Output Statistics
addpath ../18q4_report/
metrics = wrf_metrics(buoy_ws,wrf_ws);
disp(metrics);

% s = sprintf('MO: %4.2f\n',metrics.mo);
% s = sprintf('%sMF: %4.2f\n', s, metrics.mf);
% s = sprintf('%sSO: %4.2f\n', s, metrics.so);
% s = sprintf('%sSF: %4.2f\n', s, metrics.sf);
% s = sprintf('%sRMSE: %4.2f\n', s, metrics.rms);
% s = sprintf('%sCRMSE: %4.2f\n', s, metrics.crms);
% s = sprintf('%sMB: %4.2f\n', s, metrics.mb);
% s = sprintf('%sCC: %4.2f\n', s, metrics.cc);
% s = sprintf('%sMAE: %4.2f\n', s, metrics.mae);
% s = sprintf('%sC1: %4.2f%%\n', s, metrics.c1);
% s = sprintf('%sC2: %4.2f%%\n', s, metrics.c2);
% s = sprintf('%sC3: %4.2f%%\n', s, metrics.c3);



%% Thresholds for data colors

% ys = 19.5:-.8:0;

% ns = ['Model vs ' buoy];
% text(wrf_dtime(1)+.1,ys(1),ns,'fontweight','bold')
% ns = ['MO: ' num2str(metrics.mo,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(2),ns)
% ns = ['MF: ' num2str(metrics.mf,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(3),ns)
% ns = ['SO: ' num2str(metrics.so,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(4),ns)
% ns = ['SF: ' num2str(metrics.sf,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(5),ns)
% ns = ['RMSE: ' num2str(metrics.rms,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(6),ns,'color','black')
% ns = ['CRMSE: ' num2str(metrics.crms,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(7),ns)
% ns = ['MB: ' num2str(metrics.mb,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(8),ns)
% ns = ['CC: ' num2str(metrics.cc,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(9),ns)
% ns = ['MAE: ' num2str(metrics.mae,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(10),ns)
% ns = ['C1: ' num2str(metrics.c1,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(11),ns,'color','black')
% ns = ['C2: ' num2str(metrics.c2,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(12),ns,'color','black')
% ns = ['C3: ' num2str(metrics.c3,'%4.2f')];
% text(wrf_dtime(1)+.1,ys(13),ns,'color','black')

disp('wrf'); disp(datestr(wrf_dtime(1))); disp(datestr(wrf_dtime(end)));
disp('nam'); disp(datestr(nams_time(1))); disp(datestr(nams_time(end)));
disp('gfs'); disp(datestr(gfs_time(1))); disp(datestr(gfs_time(end)));

%g = get(gca,'position');
%ano = annotation('textbox',[g(1) g(2)+g(4)-.3 .3 .3],'fitboxtotext',...
%'off','String',s,'linestyle','none');

% Output plot
set(gcf,'PaperPosition',[0.25 0.5 8 5]);
fname = sprintf('buoy_nams_gfs_comparison_weather_%s_%s',buoy,datestr(wrf_dtime(1),29));
print(gcf,'-dpng','-r300', fname);

