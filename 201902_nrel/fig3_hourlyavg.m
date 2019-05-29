% Figure 3 - Hourly averages of speed/energy
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear all;

% Load data
ncfile = 'q4_20180801_20181031.nc';
dtime = ncread(ncfile,'time');
dtime = double(dtime)+datenum(2010,1,1); %Convert to Matlab time
wind_spd = ncread(ncfile,'wind_speed');
wind_dir = ncread(ncfile,'wind_dir');
buoys = ncread(ncfile,'station')';

% Extract 120m level (bin 3)
wind_spd = squeeze(wind_spd(3,:,:));
wind_dir = squeeze(wind_dir(3,:,:));

% Calculate Averages
[hrs,hr] = hravg(dtime,wind_spd);

% Create vectors for Filled Area Plot
x = hrs;
X = [x; flipud(x)]; 
Y = [hr.q3; flipud(hr.q1)];

%--------------------------------------
% Hourly Averages plots

subplot(2,1,1)
bb=2; % Select a Buoy
fill(X,Y(:,bb),[255,255,235]/255);
hold on;
p1 = plot(hrs,hr.q2(:,bb),'linewidth',2,'color','k');
set(gca,'xlim',[0 23]);
set(gca,'ylim',[0 20]);
title(sprintf('Hourly Wind Speed Quartiles at %s for the Period %s to %s',buoys(bb,:),datestr(dtime(1),2),datestr(dtime(end),2)));
ylabel('Wind Speed (m/s)');
hold on;
p2 = plot(hrs,hr.mm(:,bb,8),'--','color',[127,201,127]/255,'linewidth',1.5);
p3 = plot(hrs,hr.mm(:,bb,9),'--','color',[190,174,212]/255,'linewidth',1.5);
p4 = plot(hrs,hr.mm(:,bb,10),'--','color',[253,192,134]/255,'linewidth',1.5);
legend([p1 p2 p3 p4],{'3 months','Aug','Sep','Oct'},'location','NorthEast');

subplot(2,1,2)
bb=5; % Select a Buoy
fill(X,Y(:,bb),[255,255,235]/255);
hold on;
p1 = plot(hrs,hr.q2(:,bb),'linewidth',2,'color','k');
set(gca,'xlim',[0 23]);
set(gca,'ylim',[0 20]);
title(sprintf('Hourly Wind Speed Quartiles at %s',buoys(bb,:)));
ylabel('Wind Speed (m/s)');
xlabel('Hour (GMT)');
hold on;
p2 = plot(hrs,hr.mm(:,bb,8),'--','color',[127,201,127]/255,'linewidth',1.5);
p3 = plot(hrs,hr.mm(:,bb,9),'--','color',[190,174,212]/255,'linewidth',1.5);
p4 = plot(hrs,hr.mm(:,bb,10),'--','color',[253,192,134]/255,'linewidth',1.5);

set(gcf,'PaperPosition',[0.25 0.5 8 5]);
print(gcf,'-dpng','-r300', 'images/fig3_hourlyavg');

%--------------------------------------
% Hourly averages of Power

figure(2)
% Load Power Curve
lw8mw = csvread('../wrf_converters/wrf_lw8mw_power.csv',2);
wind_power = interp1(lw8mw(:,1),lw8mw(:,2),wind_spd);

% Calculate Averages
[hrs,hr] = hravg(dtime,wind_power);

% Create vectors for Filled Area Plot
x = hrs;
X=[x; flipud(x)]; 
Y=[hr.q3; flipud(hr.q1)];

% Hourly Averages plot
subplot(2,1,1)
bb=2; % Select a Buoy
fill(X,Y(:,bb),[255,255,235]/255);
hold on;
p1 = plot(hrs,hr.q2(:,2),'linewidth',2,'color','k');
set(gca,'xlim',[0 23]);
set(gca,'ylim',[0 8000]);
title(sprintf('Hourly Wind Power Quartiles at %s for the Period %s to %s',buoys(bb,:),datestr(dtime(1),2),datestr(dtime(end),2)));
ylabel('Wind Power (kW)');
hold on;
p2 = plot(hrs,hr.mm(:,bb,8),'--','color',[127,201,127]/255,'linewidth',1.5);
p3 = plot(hrs,hr.mm(:,bb,9),'--','color',[190,174,212]/255,'linewidth',1.5);
p4 = plot(hrs,hr.mm(:,bb,10),'--','color',[253,192,134]/255,'linewidth',1.5);
legend([p1 p2 p3 p4],{'3 months','Aug','Sep','Oct'},'location','NorthEast');

subplot(2,1,2)
bb=5; % Select a Buoy
fill(X,Y(:,bb),[255,255,235]/255);
hold on;
p1 = plot(hrs,hr.q2(:,5),'linewidth',2,'color','k');
set(gca,'xlim',[0 23]);
set(gca,'ylim',[0 8000]);
title(sprintf('Hourly Wind Power Quartiles at %s',buoys(bb,:)));
ylabel('Wind Power (kW)');
xlabel('Hour (GMT)');
hold on;
p2 = plot(hrs,hr.mm(:,bb,8),'--','color',[127,201,127]/255,'linewidth',1.5);
p3 = plot(hrs,hr.mm(:,bb,9),'--','color',[190,174,212]/255,'linewidth',1.5);
p4 = plot(hrs,hr.mm(:,bb,10),'--','color',[253,192,134]/255,'linewidth',1.5);

set(gcf,'PaperPosition',[0.25 0.5 8 5]);
print(gcf,'-dpng','-r300', 'images/fig3_hourlyavg_power');




%--------------------------------------
function [hrs,out] = hravg(dtime,data)
  [nr,nc] = size(data);
  hr = hour(dtime);
  mo = month(dtime);
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
