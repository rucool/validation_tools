% Figure 6 - Wind Roses
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

% Wind Roses
addpath ../mat_libs/WindRose
set(gcf,'units','normalized','position',[0 0 .4 1]);
for jj=1:6
if jj==1
  lt = 2;
else 
  lt = 0;
end
rplotloc = [1 3 5 2 4 6];
WindRose(wind_dir(jj,:),wind_spd(jj,:),{ ...
    'axes',subplot(3,2,rplotloc(jj)), ...
    'LegendType',lt, ...
    'freqlabelangle',-45, ...
    'nFreq',3, ...
    'FreqRound',3,... %'MaxFrequency',9, ...
    'TitleString',{sprintf('Winds at %s',buoys(jj,:));''}, ...
    'AngleNorth',0,'AngleEast',90 });
end

set(gcf, 'Color', 'w');
addpath ../mat_libs/export_fig
export_fig images/fig6_windroses.png -painters -m2
