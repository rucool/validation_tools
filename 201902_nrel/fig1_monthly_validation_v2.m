% Figure 1 - Monthly Validation
% BPU Wind Energy Project - NREL Validation Period
% Written by Sage 2/5/19
% Editted by Jaden 2/11/19
%------------------------------------------------
close all 
clear; clc;

% Select a Station and time span / season (make changes here)
buoy = '44025';
season = 'summer';
[start_date,end_date,months] = metseason(season);

%  start_date = datenum(2016,03,01);
%  end_date = datenum(2016,05,31);
%  months = [2016 03; 2016 04; 2016 05; 2016 06;];

% Setup monthly axes
noplots = length(months)-1;
monthi.m1 = datestr(start_date,'yyyymmdd');
monthi.m2 = datestr(eomdate(year(monthi.m1,'yyyymmdd'),month(monthi.m1,'yyyymmdd')),'yyyymmdd');
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
wrf_dtime = [time.t1;time.t2;time.t3]; %Convert to Matlab time
% stations
wrf_stations = ncread('nrel_20150601_20150630.nc','station')';
ind = strmatch(buoy,wrf_stations);
% ws
wrf_ws = ncread(dfile,['/nrel_' monthi.m1 '_' monthi.m2 '/wind_speed']);
wrf_wsG = squeeze(wrf_ws(1,ind,:));
wrf_ws = ncread(dfile,['/nrel_' monthi.m3 '_' monthi.m4 '/wind_speed']);
wrf_wsH = squeeze(wrf_ws(1,ind,:));
wrf_ws = ncread(dfile,['/nrel_' monthi.m5 '_' monthi.m6 '/wind_speed']);
wrf_wsI = squeeze(wrf_ws(1,ind,:));

wrf_ws = [wrf_wsG;wrf_wsH;wrf_wsI];

% Load Buoy Data
[ndbc_dtime,ndbc_ws] = ndbc_loader(start_date,end_date,buoy);

% Scale Buoy Data
zo = .5/1000;
us = log(10/zo)/log(5/zo);

% Interpolate buoy to nearest hour
for jj=1:length(wrf_dtime)
  dtime = wrf_dtime(jj);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12));
  ndbc_ws2(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
end
hold on
% Plot the data
figure(1)

for jj=1:noplots
  subplot(noplots,1,jj);
  ind = find(wrf_dtime>=datenum(months(jj,1),months(jj,2),1) & wrf_dtime < datenum(months(jj+1,1),months(jj+1,2),1));
  plot(wrf_dtime(ind),wrf_ws(ind)); hold on;
  plot(wrf_dtime(ind),ndbc_ws2(ind)*us);
  set(gca,'xlim',[datenum(months(jj,1),months(jj,2),1) datenum(months(jj+1,1),months(jj+1,2),1)]);
%   set(gca,'ylim',[0 28]);
  datetick('keeplimits');
  ylabel(datestr(datenum(months(jj,1),months(jj,2),1),'mmm yyyy'));
  grid on;
  hold on
  xl = get(gca,'xlim');
end

% activate top plot for title and legend
subplot(noplots,1,1);
title(sprintf('Wind Speeds at %s',buoy));
l = legend({'Model','Buoy'}, 'Location','best');

% Output plot
cd C:\Users\Jades\COOL\wrf_sage\201902_nrel\output
set(gcf,'PaperPosition',[0.25 0.5 8 5]);
fname = ['fig1_' buoy '_' datestr(start_date,'yyyymmdd') '_' datestr(end_date,'yyyymmdd')];
print(gcf,'-dpng','-r300', fname);

% Calculate and Output Statistics
metrics = wrf_metrics(ndbc_ws2,wrf_ws);
disp(metrics);
outfile = ['fig1_' buoy '_' datestr(start_date,'yyyymmdd') '_' datestr(end_date,'yyyymmdd') '.csv'];
fid = fopen(outfile,'w');
fprintf(fid,'%s\n','season,station,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
fprintf(fid,'%s,%s,',season,buoy);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metrics.mo,metrics.mf,metrics.so,metrics.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metrics.rms,metrics.crms,metrics.mb,metrics.cc,metrics.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metrics.c1,metrics.c2,metrics.c3,metrics.count);
fclose(fid);
cd C:\Users\Jades\COOL\wrf_sage\201902_nrel
