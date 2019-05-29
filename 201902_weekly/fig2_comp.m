%------------------------------------------------
close all; clear; clc;

% Select a Station
buoy = '44065';

% Specify Model File
% dfile = 'wrf_data_20190121_20190203.nc';
dfile = 'nams_gfs_comp_20190223_20190308.nc';
end_date = datenum(2019,3,8);
start_date = addtodate(end_date,-13,'day');
[time_gfs, ws_gfs, wd_gfs, time_nams, ws_nams, wd_nams] = nams_gfs_dataload_v2(end_date);
%load('nams_data.mat')
%------------------------------------------------
% Load model data
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_wd = ncread(dfile,'wind_dir');
wrf_stations = ncread(dfile,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
wrf_ws = squeeze(wrf_ws(1,ind,:)); 
wrf_wd = squeeze(wrf_wd(1,ind,:));

% Load Realtime Buoy Data
ndbc_url = sprintf('https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/%s/%sh9999.nc',buoy,buoy);
ndbc_dtime = double(ncread(ndbc_url,'time'))/(24*60*60)+datenum(1970,1,1);
ind = find(ndbc_dtime>=min(wrf_dtime) & ndbc_dtime<max(wrf_dtime));
ndbc_dtime = ndbc_dtime(ind);
ndbc_wd = squeeze(ncread(ndbc_url,'wind_dir',[1 1 min(ind)],[1 1 length(ind)],[1 1 1]));
ndbc_ws = squeeze(ncread(ndbc_url,'wind_spd',[1 1 min(ind)],[1 1 length(ind)],[1 1 1]));

% Interpolate buoy data to nearest hour
for jj=1:length(wrf_dtime)
  dtime = wrf_dtime(jj);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12)); %Limit to 4h window
  if length(ind)>1
    buoy_wd(jj,1) = interp1(ndbc_dtime(ind),ndbc_wd(ind),dtime);
  else
    buoy_wd(jj,1) = NaN;
  end
end

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
% zo = .5/1000;
% us = log(10/zo)/log(5/zo);
% buoy_ws = buoy_ws*us;

%%
% Plot the data
hold on

ind = find(wrf_dtime>=start_date & wrf_dtime < end_date);
xlim = [start_date end_date];
ylim = [-28 28];
set(gca,'units','pixels'); ppos = get(gca,'position'); set(gca,'units','norm');
uscale = (diff(xlim)/diff(ylim))*(ppos(4)/ppos(3));

%% buoy
% Calculate components
u = cos((270-buoy_wd-180)*pi/180).*buoy_ws;
v = sin((270-buoy_wd-180)*pi/180).*buoy_ws;
w = u+1i*v;

xx = [wrf_dtime(ind) wrf_dtime(ind)+uscale*u(ind) wrf_dtime(ind)]';
yy = [zeros(length(wrf_dtime(ind)),1) v(ind) NaN*zeros(length(wrf_dtime(ind)),1)]';

subplot(2,1,1)
plot(xx(:),yy(:),'b-','linewidth',.5); hold on
plot(xlim,[0 0],'k-');

set(gca,'xlim',xlim,'ylim',ylim);  
datetick('keeplimits');
xlabel(sprintf('Start date: %s',datestr(wrf_dtime(1),1)));
title('Buoy Wind Direction')

%% wrf
% Calculate components
u = cos((270-wrf_wd-180)*pi/180).*wrf_ws;
v = sin((270-wrf_wd-180)*pi/180).*wrf_ws;
w = u+1i*v;

xx2 = [wrf_dtime(ind) wrf_dtime(ind)+uscale*u(ind) wrf_dtime(ind)]';
yy2 = [zeros(length(wrf_dtime(ind)),1) v(ind) NaN*zeros(length(wrf_dtime(ind)),1)]';

subplot(2,1,2)
plot(xx2(:),yy2(:),'b-','linewidth',.5); hold on
plot(xlim,[0 0],'k-');

set(gca,'xlim',xlim,'ylim',ylim);  
datetick('keeplimits');
xlabel(sprintf('Start date: %s',datestr(wrf_dtime(1),1)));
title('Wrf Wind Direction')

set(gcf,'PaperPosition',[0.25 0.5 8 5]);
fname = sprintf('wd_comparison_1_%s_%s',buoy,datestr(wrf_dtime(1),29));
print(gcf,'-dpng','-r300', fname);

%%
figure(2)
%% GFS
% Calculate components
u = cos((270-wd_gfs-180)*pi/180).*ws_gfs;
v = sin((270-wd_gfs-180)*pi/180).*ws_gfs;
w = u+1i*v;

xx2 = [wrf_dtime(ind) wrf_dtime(ind)+uscale*u(ind) wrf_dtime(ind)]';
yy2 = [zeros(length(wrf_dtime(ind)),1) v(ind) NaN*zeros(length(wrf_dtime(ind)),1)]';

subplot(2,1,1)
plot(xx2(:),yy2(:),'b-','linewidth',.5); hold on
plot(xlim,[0 0],'k-');

set(gca,'xlim',xlim,'ylim',ylim);  
datetick('keeplimits');
xlabel(sprintf('Start date: %s',datestr(wrf_dtime(1),1)));
title('GFS Wind Direction')

%% NAMS
% Calculate components
u = cos((270-wd_nams-180)*pi/180).*ws_nams;
v = sin((270-wd_nams-180)*pi/180).*ws_nams;
w = u+1i*v;

xx2 = [wrf_dtime(ind) wrf_dtime(ind)+uscale*u(ind) wrf_dtime(ind)]';
yy2 = [zeros(length(wrf_dtime(ind)),1) v(ind) NaN*zeros(length(wrf_dtime(ind)),1)]';

subplot(2,1,2)
plot(xx2(:),yy2(:),'b-','linewidth',.5); hold on
plot(xlim,[0 0],'k-');

set(gca,'xlim',xlim,'ylim',ylim);  
datetick('keeplimits');
xlabel(sprintf('Start date: %s',datestr(wrf_dtime(1),1)));
title('NAM Wind Direction')

set(gcf,'PaperPosition',[0.25 0.5 8 5]);
fname = sprintf('wd_comparison_2_%s_%s',buoy,datestr(wrf_dtime(1),29));
print(gcf,'-dpng','-r300', fname);

%% metrics
% Calculate and Output Statistics
addpath ../18q4_report/
metrics = wrf_metrics(buoy_wd,wrf_wd);
disp(metrics);

%%
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

ys = 19.5:-.8:0;

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

% disp('wrf'); disp(datestr(wrf_dtime(1))); disp(datestr(wrf_dtime(end)));
% disp('nam'); disp(datestr(time_nams(1))); disp(datestr(time_nams(end)));
% disp('gfs'); disp(datestr(time_gfs(1))); disp(datestr(time_gfs(end)));

%g = get(gca,'position');
%ano = annotation('textbox',[g(1) g(2)+g(4)-.3 .3 .3],'fitboxtotext','off','String',s,'linestyle','none');

% Output plot
% set(gcf,'PaperPosition',[0.25 0.5 8 5]);
% fname = sprintf('buoy_wrf_nams_gfs_comparison_wd_%s_%s',buoy,datestr(wrf_dtime(1),29));
% print(gcf,'-dpng','-r300', fname);

