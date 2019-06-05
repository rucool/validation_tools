% Weekly validation figures
% BPU Wind Energy Project [The one with DoE buoy]
% Written by Sage 2/5/19
% Editted by Jaden 6/03/19
%------------------------------------------------
close all; clear; clc;
addpath /Users/jadendicopoulos/Documents/GitHub/validation_tools/loaders_and_functions

% Select a Station
buoy = '44065';

% Specify Model File
addpath /Volumes/home/jad438/wrf_converters/2weeks
dfile = '2week_20190528_20190603.nc';
end_date = datenum(2019,6,04);
total_days = 7;
glvl = 1; %height level for gfs, 10,80,100
nlvl = 1; %height level for nam, 10,80
hlvl = 1; %height level for h3r, 10,80

%% Load Data
% GFS and NAM
[gfs_time, gfs_ws, ~, nam_time, nam_ws, ~, ~] = nams_gfs_dataload(end_date,total_days,buoy,glvl,nlvl);

% HRRR
[hrrr_time, hrrr_ws, hrrr_wd, start_date] = hrrr_dataload(end_date,total_days,buoy,hlvl);

% WRF model data
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_stations = ncread(dfile,'station')';
% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
wrf_ws = squeeze(wrf_ws(1,ind,:));
%%
% Load Realtime Buoy Data
% ndbc_url = sprintf('https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/%s/%sh9999.nc',buoy,buoy);
% ndbc_dtime = double(ncread(ndbc_url,'time'))/(24*60*60)+datenum(1970,1,1);
% ind = find(ndbc_dtime>=min(wrf_dtime) & ndbc_dtime<max(wrf_dtime));
% ndbc_dtime = ndbc_dtime(ind);
% ndbc_ws = squeeze(ncread(ndbc_url,'wind_spd',[1 1 min(ind)],[1 1 length(ind)],[1 1 1]));
% 
% % Interpolate buoy data to nearest hour
% for jj=1:length(wrf_dtime)
%   dtime = wrf_dtime(jj);
%   ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12)); %Limit to 4h window
%   if length(ind)>1
%     buoy_ws(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
%   else
%     buoy_ws(jj,1) = NaN;
%   end
% end
% 
% % Interpolate NAM data to nearest hour
% for jj=1:length(nam_time)
%   dtime = wrf_dtime(jj);
%   ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12)); %Limit to 4h window
%   if length(ind)>1
%     buoy_ws2(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
%   else
%     buoy_ws2(jj,1) = NaN;
%   end
% end
% 
% % Interpolate GFS data to nearest hour
% for jj=1:length(gfs_time)
%   dtime = wrf_dtime(jj);
%   ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12)); %Limit to 4h window
%   if length(ind)>1
%     buoy_ws3(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
%   else
%     buoy_ws3(jj,1) = NaN;
%   end
% end
% 
% % Scale Buoy Data
% zo = .5/1000;
% us = log(10/zo)/log(5/zo);
% buoy_ws = buoy_ws*us;
% buoy_ws2 = buoy_ws2*us;
% buoy_ws3 = buoy_ws3*us;

%% Plotting
% Plot the data
hold on

% plot(wrf_dtime,buoy_ws,'k-','linewidth',1,'displayname','Buoy');
plot(nam_time,nam_ws,'color',[0 0.4470 0.7410],'linewidth',.5,'displayname','NAM');
plot(gfs_time,gfs_ws,'color',[0.4660 0.6740 0.1880],'linewidth',.5,'displayname','GFS');
plot(hrrr_time,hrrr_ws,'linewidth',.5,'displayname','HRRR');
plot(wrf_dtime,wrf_ws,'r','linewidth',.8,'displayname','WRF 3.9');

datetick('x','keepticks');
set(gca,'xlim',[wrf_dtime(1) wrf_dtime(end)]);
xlabel(sprintf('Start date: %s',datestr(wrf_dtime(1),1)));
ylabel('m/s');
yline(12.5,'color',[.5 .5 .5],'linestyle','--','displayname','12.5 Cutoff');
grid on;
title(sprintf('Wind Speeds at %s',buoy));
l = legend('Location','Best');

% Output plot
set(gcf,'PaperPosition',[0.25 0.5 10 5]);
fname = sprintf('output/buoy_nams_gfs_comparison_%s_%s_%s',buoy,datestr(start_date(1),29),datestr(end_date(end),29));
%print(gcf,'-dpng','-r300', fname);

%% Metrics
% Calculate and Output Statistics

ind = find(wrf_dtime>=start_date & wrf_dtime < end_date);
ind2 = find(nam_time>=start_date & nam_time < end_date);
ind3 = find(gfs_time>=start_date & gfs_time < end_date);

outfile = sprintf('output/metrics_all_%s_%s_%s.csv',buoy,datestr(start_date,29),datestr(end_date,29));
fid = fopen(outfile,'w');
fprintf(fid,'%s\n','Model,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');

% WRF
metricsWRF = wrf_metrics(buoy_ws(ind),wrf_ws(ind));
disp(metricsWRF);
fprintf(fid,'%s,','WRF 3.9');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsWRF.mo,metricsWRF.mf,metricsWRF.so,metricsWRF.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsWRF.rms,metricsWRF.crms,metricsWRF.mb,metricsWRF.cc,metricsWRF.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsWRF.c1,metricsWRF.c2,metricsWRF.c3,metricsWRF.count);

% NAM
metricsNAM = wrf_metrics(buoy_ws2(ind2),nam_ws(ind2));
disp(metricsNAM);
fprintf(fid,'%s,','NAM');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsNAM.mo,metricsNAM.mf,metricsNAM.so,metricsNAM.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsNAM.rms,metricsNAM.crms,metricsNAM.mb,metricsNAM.cc,metricsNAM.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsNAM.c1,metricsNAM.c2,metricsNAM.c3,metricsNAM.count);

% GFS
metricsGFS = wrf_metrics(buoy_ws3(ind3),gfs_ws(ind3));
disp(metricsGFS);
fprintf(fid,'%s,','GFS');
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metricsGFS.mo,metricsGFS.mf,metricsGFS.so,metricsGFS.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metricsGFS.rms,metricsGFS.crms,metricsGFS.mb,metricsGFS.cc,metricsGFS.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metricsGFS.c1,metricsGFS.c2,metricsGFS.c3,metricsGFS.count);

fclose(fid);

%% Thresholds for data colors

disp('wrf'); disp(datestr(wrf_dtime(1))); disp(datestr(wrf_dtime(end)));
disp('nam'); disp(datestr(nam_time(1))); disp(datestr(nam_time(end)));
disp('gfs'); disp(datestr(gfs_time(1))); disp(datestr(gfs_time(end)));

