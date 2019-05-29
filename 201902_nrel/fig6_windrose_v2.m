% Figure 6 - Wind Roses
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear; clc;

% Load data
ncfile = 'q4_20180801_20181031.nc';
dtime = ncread(ncfile,'time');
dtime = double(dtime)+datenum(2010,1,1); %Convert to Matlab time
wrf_ws = ncread(ncfile,'wind_speed');
wrf_wd = ncread(ncfile,'wind_dir');
buoys = ncread(ncfile,'station')';

wrf_ws = squeeze(wrf_ws(3,:,:));
wrf_wd = squeeze(wrf_wd(3,:,:));
% Wind Roses

set(gcf,'units','normalized','position',[0 0 .4 1]);
for jj=1:6
if jj==1
  lt = 2;
else 
  lt = 0;
end
rplotloc = [1 3 5 2 4 6];
WindRose(wrf_wd(jj,:),wrf_ws(jj,:),{ ...
    'axes',subplot(3,2,rplotloc(jj)), ...
    'LegendType',lt, ...
    'freqlabelangle',-45, ...
    'nFreq',3, ...
    'FreqRound',3,... %'MaxFrequency',9, ...
    'TitleString',{sprintf('Winds at %s',buoys(jj,:));''}, ...
    'AngleNorth',0,'AngleEast',90 });
end

set(gcf, 'Color', 'w');

export_fig output/fig6_windroses.png -painters -m2
