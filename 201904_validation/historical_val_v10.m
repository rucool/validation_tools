%% WRF 3.6 comparison to NAM and GFS Data
close all; clear; clc; 
%% Set up
start_date = datenum(2016,7,22);
end_date = datenum(2016,7,24);
buoy = 'DOEFL';

%% Data load
lvl = 2; %100m
[wrf_ws,wrf_wd,wrf_time] = wrf_rerun_loader(start_date,end_date,lvl);
lvl = 2; %80m
[nam_time, nam_ws, nam_wd] = nam_dataload_historical(start_date,end_date,lvl,buoy);
lvl = 3; %100m
[gfs_time, gfs_ws, gfs_wd] = gfs_dataload_historical(start_date,end_date,lvl,buoy);

%% DoE Load
tic
%90m
[doe_time_i,doe_90_ws_i,doe_90_wd_i] = doeflb_loader(start_date,end_date);
n = 600; % average every n values (600 = 10 minutes)
doe_90_ws_i2 = arrayfun(@(i) nanmean(doe_90_ws_i(i:i+n-1)),1:n:length(doe_90_ws_i)-n+1); % the averaged vector
%doe_130_ws_i2 = arrayfun(@(i) nanmean(doe_130_ws_i(i:i+n-1)),1:n:length(doe_130_ws_i)-n+1); % the averaged vector

doe_time_i2 = start_date:minutes(10):end_date+1;

% hourly winds
doe_time_i3 = start_date:hours(1):end_date+1;
[hind,~] = ismember(datenum(doe_time_i2),datenum(doe_time_i3(1:end-1)));
hind = find(hind==1);
% 3 hourly winds
doe_time_i4 = start_date:hours(3):end_date+1;
[hind2,~] = ismember(datenum(doe_time_i2),datenum(doe_time_i4(1:end-1)));
hind2 = find(hind2==1);

disp('DoE Buoy Load Time:')
toc

%% Plotting
figure(1)
hold on
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/loaders_and_functions
N = 3;
lcolor = linspecer(N);

plot(datenum(doe_time_i2(2:end)),doe_90_ws_i2,'k-','linewidth',1.5,'displayname','DoE Buoy 90m');

plot(gfs_time,gfs_ws,'color',lcolor(3,:),'linewidth',1.3,'displayname','GFS 100m')
plot(wrf_time,wrf_ws,'color',lcolor(2,:),'linewidth',1.3,'displayname','WRF 3.6 100m')
plot(nam_time,nam_ws,'color',lcolor(1,:),'linewidth',1.3,'displayname','NAM 80m')

%% Plot setup
title(sprintf('Wind Speeds at %s',buoy));
legend('location','best','autoupdate','off');
datetick('x','mm/dd','keepticks');

xlim([start_date end_date]);
xlabel(sprintf('Start date: %s',datestr(start_date,1)));
ylabel('m/s');
ylim([0 25])
grid on
% figure save
set(gcf,'PaperPosition',[0.25 0.5 10 5]);
fname = sprintf('output/WRF36_DoE/new_pt_6ho_comp/buoy%s_NAM_GFS_WRF36_6ho_comparison_%s_%s',buoy,datestr(start_date,29),datestr(end_date,29));
print(gcf,'-dpng','-r300', fname);


%% Metrics
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel
ind = find(wrf_time>=start_date & wrf_time < end_date+1);
ind2 = find(nam_time>=start_date & nam_time < end_date+1);
ind3 = find(gfs_time>=start_date & gfs_time < end_date+1);

metricsWRF = wrf_metrics(doe_90_ws_i2(hind)',wrf_ws);
disp('WRF 3.6');
% disp(datestr(doe_time_i2(hind(1))));
% disp(datestr(wrf_time(1)));
% disp(datestr(doe_time_i2(hind(end))));
% disp(datestr(wrf_time(end)));
disp(metricsWRF);

outfile = sprintf('output/WRF36_DoE/new_pt_6ho_comp/metrics_buoy%s_NAM_GFS_WRF36_6ho_%s_%s.csv',buoy,datestr(start_date,29),datestr(end_date,29));
fid = fopen(outfile,'w');

fprintf(fid,'%s\n','Model,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
fprintf(fid,'%s,','WRF 3.6 100m');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);

metricsNAMS = wrf_metrics(doe_90_ws_i2(hind),nam_ws);
disp('NAM')
% disp(datestr(doe_time_i2(hind(1))));
% disp(datestr(nam_time(1)));
% disp(datestr(doe_time_i2(hind(end))));
% disp(datestr(nam_time(end)));
disp(metricsNAMS);

fprintf(fid,'%s,','NAM 80m');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsNAMS.mo,metricsNAMS.mf,metricsNAMS.so,metricsNAMS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsNAMS.rms,metricsNAMS.crms,metricsNAMS.mb,metricsNAMS.cc,metricsNAMS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsNAMS.c1,metricsNAMS.c2,metricsNAMS.c3,metricsNAMS.count);

metricsGFS = wrf_metrics(doe_90_ws_i2(hind2),gfs_ws);
disp('GFS')
% disp(datestr(doe_time_i2(hind2(1))));
% disp(datestr(gfs_time(1)));
% disp(datestr(doe_time_i2(hind2(end))));
% disp(datestr(gfs_time(end)));
disp(metricsGFS);

fprintf(fid,'%s,','GFS 100m');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsGFS.mo,metricsGFS.mf,metricsGFS.so,metricsGFS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsGFS.rms,metricsGFS.crms,metricsGFS.mb,metricsGFS.cc,metricsGFS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsGFS.c1,metricsGFS.c2,metricsGFS.c3,metricsGFS.count);

fclose(fid);