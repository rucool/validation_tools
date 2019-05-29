% Figure 2 - Stickplots Yipee!!!
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
% Editted by Jaden 2/14/19
%------------------------------------------------
close all; clear; clc;

buoy = '44025';
season = 'fall';
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
%addpath C:\Users\Jades\COOL\wrf_sage\201902_nrel\wrf_nrel

dfile = 'nrel_20150601_20160531.nc';
% Select ref point
wrf_stations = ncread('nrel_20150601_20150630.nc','station')';
ind = strmatch(buoy,wrf_stations);
% dtime
time.t1 = ncread(dfile,['/nrel_' monthi.m1 '_' monthi.m2 '/time'])+ datenum(2010,1,1);
time.t2 = ncread(dfile,['/nrel_' monthi.m3 '_' monthi.m4 '/time'])+ datenum(2010,1,1);
time.t3 = ncread(dfile,['/nrel_' monthi.m5 '_' monthi.m6 '/time'])+ datenum(2010,1,1);
wrf_dtime = [time.t1;time.t2;time.t3]; 

% ws
wrf_ws = ncread(dfile,['/nrel_' monthi.m1 '_' monthi.m2 '/wind_speed']);
wrf_wsG = squeeze(wrf_ws(3,ind,:));
wrf_ws = ncread(dfile,['/nrel_' monthi.m3 '_' monthi.m4 '/wind_speed']);
wrf_wsH = squeeze(wrf_ws(3,ind,:));
wrf_ws = ncread(dfile,['/nrel_' monthi.m5 '_' monthi.m6 '/wind_speed']);
wrf_wsI = squeeze(wrf_ws(3,ind,:));

wrf_ws = [wrf_wsG;wrf_wsH;wrf_wsI];

% wd
wrf_wd = ncread(dfile,['/nrel_' monthi.m1 '_' monthi.m2 '/wind_dir']);
wrf_wdG = squeeze(wrf_wd(3,ind,:));
wrf_wd = ncread(dfile,['/nrel_' monthi.m3 '_' monthi.m4 '/wind_dir']);
wrf_wdH = squeeze(wrf_wd(3,ind,:));
wrf_wd = ncread(dfile,['/nrel_' monthi.m5 '_' monthi.m6 '/wind_dir']);
wrf_wdI = squeeze(wrf_wd(3,ind,:));

wrf_wd = [wrf_wdG;wrf_wdH;wrf_wdI];

% Extract 120m level (bin 3) for N2 (index 2)
%wrf_ws = squeeze(wrf_ws(3,2,:));
%wrf_wd = squeeze(wrf_wd(3,2,:));

% Calculate components
u = cos((270-wrf_wd-180)*pi/180).*wrf_ws;
v = sin((270-wrf_wd-180)*pi/180).*wrf_ws;
w = u+1i*v;

%--------------------------------------
% Plot by month
for jj=1:noplots
  subplot(noplots,1,jj);
  ind = find(wrf_dtime>=datenum(months(jj,1),months(jj,2),1) & wrf_dtime < datenum(months(jj+1,1),months(jj+1,2),1));
  
  xlim = [datenum(months(jj,1),months(jj,2),1) datenum(months(jj+1,1),months(jj+1,2),1)];
  ylim = [-28 28];
  set(gca,'units','pixels'); ppos = get(gca,'position'); set(gca,'units','norm');
  uscale = (diff(xlim)/diff(ylim))*(ppos(4)/ppos(3));
  
  xx = [wrf_dtime(ind) wrf_dtime(ind)+uscale*u(ind) wrf_dtime(ind)]';
  yy = [zeros(length(wrf_dtime(ind)),1) v(ind) NaN*zeros(length(wrf_dtime(ind)),1)]';
  plot(xx(:),yy(:),'r-','linewidth',.5); hold on
  plot(xlim,[0 0],'k-');
  
  set(gca,'xlim',xlim,'ylim',ylim);  
  datetick('keeplimits');
  ylabel(datestr(datenum(months(jj,1),months(jj,2),1),'mmm yyyy'));
end

subplot(noplots,1,1);
title(['120m Winds at ' buoy ' (Direction from which winds come from)']);

set(gcf,'PaperPosition',[0.25 0.5 8 5]);
print(gcf,'-dpng','-r300', ['output/fig2/fig2_sticks_' season]);
