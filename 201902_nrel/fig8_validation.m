% Figure 8 - Example Validation
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear all;

% Select a Station
buoy = '44025';
start_date = datenum(2018,8,1);
end_date = datenum(2018,11,1);

% Setup monthly axes
months = [2018 08; 2018 09; 2018 10; 2018 11]; 
noplots = length(months)-1;

% Load Model Data
dfile = 'q4ndbc_20180801_20181031.nc';
wrf_dtime = ncread(dfile,'time')+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(dfile,'wind_speed');
wrf_stations = ncread(dfile,'station')';

% Extract 10m level (bin 1 of 4) for the selected buoy
ind = strmatch(buoy,wrf_stations);
wrf_ws = squeeze(wrf_ws(1,ind,:)); 

% Load Buoy Data
ndbc_url = sprintf('../ndbc_data/%sh2018.nc',buoy);
ndbc_dtime = double(ncread(ndbc_url,'time'))/(24*60*60)+datenum(1970,1,1);
ndbc_ws = squeeze(ncread(ndbc_url,'wind_spd'));

% Interpolate buoy to nearest hour
for jj=1:length(wrf_dtime)
  dtime = wrf_dtime(jj);
  ind = find(ndbc_dtime>(dtime-2/12) & ndbc_dtime<(dtime+2/12));
  ndbc_ws2(jj,1) = interp1(ndbc_dtime(ind),ndbc_ws(ind),dtime);
end

% Plot the data
figure(1)
for jj=1:noplots
  subplot(noplots,1,jj);
  ind = find(wrf_dtime>=datenum(months(jj,1),months(jj,2),1) & wrf_dtime < datenum(months(jj+1,1),months(jj+1,2),1));
  plot(wrf_dtime(ind),wrf_ws(ind)); hold on;
  plot(wrf_dtime(ind),ndbc_ws2(ind));  
  set(gca,'xlim',[datenum(months(jj,1),months(jj,2),1) datenum(months(jj+1,1),months(jj+1,2),1)]);
%   set(gca,'ylim',[0 28]);
  datetick('keeplimits');
  ylabel(datestr(datenum(months(jj,1),months(jj,2),1),'mmm yyyy'));
  grid on;
  hold on
  xl = get(gca,'xlim');
end

subplot(noplots,1,1);
title(sprintf('Wind Speeds at %s',buoy));
% subplot(noplots,1,noplots);
l = legend({'Model','Buoy'}, 'Location','best');
% set(l,'position',[0.65 0.035 0.2625 0.0345]);

% Output plot
set(gcf,'PaperPosition',[0.25 0.5 8 5]);
fname = sprintf('images/fig8_%s_%s%s',buoy);
print(gcf,'-dpng','-r300', fname);


% Calculate and Output Statistics
metrics = wrf_metrics(ndbc_ws2,wrf_ws);
disp(metrics);
outfile = sprintf('images/fig8_%s.csv',buoy);
fid = fopen(outfile,'w');
fprintf(fid,'%s\n','station,mo,mf,so,sf,rms,crms,mb,cc,mae,c1,c2,c3,count');
fprintf(fid,'%s,',buoy);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,',metrics.mo,metrics.mf,metrics.so,metrics.sf);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f,%4.2f,',metrics.rms,metrics.crms,metrics.mb,metrics.cc,metrics.mae);
fprintf(fid,'%5.3f,%5.3f,%5.3f,%5.3f\n',metrics.c1,metrics.c2,metrics.c3,metrics.count);
fclose(fid);

