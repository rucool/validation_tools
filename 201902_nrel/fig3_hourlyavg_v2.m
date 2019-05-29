% Figure 3 - Hourly averages of speed/energy
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
% Editted by Jaden 2/14/18
%------------------------------------------------
close all; clear; clc;

% Load data
season = 'spring';
[start_date,end_date,months] = metseason(season);

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
wrf_dtime = [time.t1;time.t2;time.t3]; 

% ws
wrf_ws = ncread(dfile,['/nrel_' monthi.m1 '_' monthi.m2 '/wind_speed']);
wrf_wsA = squeeze(wrf_ws(3,:,:));
wrf_ws = ncread(dfile,['/nrel_' monthi.m3 '_' monthi.m4 '/wind_speed']);
wrf_wsB = squeeze(wrf_ws(3,:,:));
wrf_ws = ncread(dfile,['/nrel_' monthi.m5 '_' monthi.m6 '/wind_speed']);
wrf_wsC = squeeze(wrf_ws(3,:,:));

wrf_ws = [wrf_wsA wrf_wsB wrf_wsC];

% Calculate Averages
[hrs,hr] = hravg(wrf_dtime,wrf_ws);

% Create vectors for Filled Area Plot
x = hrs;
X = [x; flipud(x)]; 
Y = [hr.q3; flipud(hr.q1)];

%--------------------------------------
% Hourly Averages plots
buoys = ncread('nrel_20150601_20150630.nc','station')';

subplot(2,1,1)
bb=8; % Select a Buoy
fill(X,Y(:,bb),[255,255,235]/255);
hold on;
p1 = plot(hrs,hr.q2(:,bb),'linewidth',2,'color','k');
set(gca,'xlim',[0 23]);
set(gca,'ylim',[0 20]);
title(sprintf('Hourly Wind Speed Quartiles at %s for the Period %s to %s',buoys(bb,:),datestr(wrf_dtime(1),2),datestr(wrf_dtime(end),2)));
ylabel('Wind Speed (m/s)');
hold on;
p2 = plot(hrs,hr.mm(:,bb,months(1,2)),'--','color',[127,201,127]/255,'linewidth',1.5);
p3 = plot(hrs,hr.mm(:,bb,months(2,2)),'--','color',[190,174,212]/255,'linewidth',1.5);
p4 = plot(hrs,hr.mm(:,bb,months(3,2)),'--','color',[253,192,134]/255,'linewidth',1.5);
legend([p1 p2 p3 p4],{'3 months','Mar','Apr','May'},'location','NorthEast');

subplot(2,1,2)
bb=2; % Select a Buoy
fill(X,Y(:,bb),[255,255,235]/255);
hold on;
p1 = plot(hrs,hr.q2(:,bb),'linewidth',2,'color','k');
set(gca,'xlim',[0 23]);
set(gca,'ylim',[0 20]);
title(sprintf('Hourly Wind Speed Quartiles at %s',buoys(bb,:)));
ylabel('Wind Speed (m/s)');
xlabel('Hour (GMT)');
hold on;
p2 = plot(hrs,hr.mm(:,bb,months(1,2)),'--','color',[127,201,127]/255,'linewidth',1.5);
p3 = plot(hrs,hr.mm(:,bb,months(2,2)),'--','color',[190,174,212]/255,'linewidth',1.5);
p4 = plot(hrs,hr.mm(:,bb,months(3,2)),'--','color',[253,192,134]/255,'linewidth',1.5);

set(gcf,'PaperPosition',[0.25 0.5 8 5]);
print(gcf,'-dpng','-r300', ['output/fig3_hourlyavg_' season]);

%--------------------------------------
% Hourly averages of Power

figure(2)
% Load Power Curve
lw8mw = csvread('wrf_lw8mw_power.csv',2);
wind_power = interp1(lw8mw(:,1),lw8mw(:,2),wrf_ws);

% Calculate Averages
[hrs,hr] = hravg(wrf_dtime,wind_power);

% Create vectors for Filled Area Plot
x = hrs;
X=[x; flipud(x)]; 
Y=[hr.q3; flipud(hr.q1)];

% Hourly Averages plot
subplot(2,1,1)
bb=8; % Select a Buoy
fill(X,Y(:,bb),[255,255,235]/255);
hold on;
p1 = plot(hrs,hr.q2(:,2),'linewidth',2,'color','k');
set(gca,'xlim',[0 23]);
set(gca,'ylim',[0 8000]);
title(sprintf('Hourly Wind Power Quartiles at %s for the Period %s to %s',buoys(bb,:),datestr(wrf_dtime(1),2),datestr(wrf_dtime(end),2)));
ylabel('Wind Power (kW)');
hold on;
p2 = plot(hrs,hr.mm(:,bb,months(1,2)),'--','color',[127,201,127]/255,'linewidth',1.5);
p3 = plot(hrs,hr.mm(:,bb,months(2,2)),'--','color',[190,174,212]/255,'linewidth',1.5);
p4 = plot(hrs,hr.mm(:,bb,months(3,2)),'--','color',[253,192,134]/255,'linewidth',1.5);
legend([p1 p2 p3 p4],{'3 months','Mar','Apr','May'},'location','NorthEast');

subplot(2,1,2)
bb=2; % Select a Buoy
fill(X,Y(:,bb),[255,255,235]/255);
hold on;
p1 = plot(hrs,hr.q2(:,5),'linewidth',2,'color','k');
set(gca,'xlim',[0 23]);
set(gca,'ylim',[0 8000]);
title(sprintf('Hourly Wind Power Quartiles at %s',buoys(bb,:)));
ylabel('Wind Power (kW)');
xlabel('Hour (GMT)');
hold on;
p2 = plot(hrs,hr.mm(:,bb,months(1,2)),'--','color',[127,201,127]/255,'linewidth',1.5);
p3 = plot(hrs,hr.mm(:,bb,months(2,2)),'--','color',[190,174,212]/255,'linewidth',1.5);
p4 = plot(hrs,hr.mm(:,bb,months(3,2)),'--','color',[253,192,134]/255,'linewidth',1.5);

set(gcf,'PaperPosition',[0.25 0.5 8 5]);
print(gcf,'-dpng','-r300', ['output/fig3_hourlyavg_power_' season]);


%--------------------------------------
function [hrs,out] = hravg(wrf_dtime,data)
  [nr,nc] = size(data);
  hr = hour(wrf_dtime);
  mo = month(wrf_dtime);
  hrs = unique(hr); %Hard way to get 0:23
  mos = unique(mo);
  
  % Setup output matrices
  out.avg = zeros(24,nr);
  out.std = zeros(24,nr);
  out.q1 = zeros(24,nr);
  out.q2 = zeros(24,nr);
  out.q3 = zeros(24,nr);
  out.mm = zeros(24,nr,12); %monthly median
  
  % Loop over hours and stations
  for jj=1:length(hrs)
    sel_hr = hrs(jj);
    for kk=1:nr %Each station
      ind = find(hr==sel_hr);
      out.avg(jj,kk) = nanmean(data(kk,ind));
      out.std(jj,kk) = nanstd(data(kk,ind));
      out.q1(jj,kk) = quantile(data(kk,ind),.25);
      out.q2(jj,kk) = quantile(data(kk,ind),.50);
      out.q3(jj,kk) = quantile(data(kk,ind),.75);
      for mm=1:12 %Each month
        ind2 = find(mo==mm);
        ind3 = intersect(ind,ind2);
        out.mm(jj,kk,mm) = quantile(data(kk,ind3),.5);
      end
    end
  end
end

