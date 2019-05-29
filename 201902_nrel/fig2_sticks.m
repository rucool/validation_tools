% Figure 2 - Stickplots Yipee!!!
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

% Extract 120m level (bin 3) for N2 (index 2)
wind_spd = squeeze(wind_spd(3,2,:));
wind_dir = squeeze(wind_dir(3,2,:));

% Calculate components
u = cos((270-wind_dir-180)*pi/180).*wind_spd;
v = sin((270-wind_dir-180)*pi/180).*wind_spd;
w = u+1i*v;

%--------------------------------------
% Setup monthly axes
months = [2018 08; 2018 09; 2018 10; 2018 11]; 
noplots = length(months)-1;

% Plot by month
for jj=1:noplots
  subplot(noplots,1,jj);
  ind = find(dtime>=datenum(months(jj,1),months(jj,2),1) & dtime < datenum(months(jj+1,1),months(jj+1,2),1));

  xlim = [datenum(months(jj,1),months(jj,2),1) datenum(months(jj+1,1),months(jj+1,2),1)];
  ylim = [-28 28];
  set(gca,'units','pixels'); ppos = get(gca,'position'); set(gca,'units','norm');
  uscale = (diff(xlim)/diff(ylim))*(ppos(4)/ppos(3));

  xx = [dtime(ind) dtime(ind)+uscale*u(ind) dtime(ind)]';
  yy = [zeros(length(dtime(ind)),1) v(ind) NaN*zeros(length(dtime(ind)),1)]';
  plot(xx(:),yy(:),'r-','linewidth',.5); hold on
  plot(xlim,[0 0],'k-');
  
  set(gca,'xlim',xlim,'ylim',ylim);  
  datetick('keeplimits');
  ylabel(datestr(datenum(months(jj,1),months(jj,2),1),'mmm yyyy'));
end

subplot(noplots,1,1);
title('120m Winds at N2');

set(gcf,'PaperPosition',[0.25 0.5 8 5]);
print(gcf,'-dpng','-r300', 'images/fig2_sticks');
