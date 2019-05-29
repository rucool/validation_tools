function [wrf_ws,wrf_wd,wrf_time] = wrf_rerun_loader(start_date,end_date,lvl)
%% WRF rerun Loader
tic
disp('------------------')
disp('wrf_rerun_loader.m')
%close all; clear; clc;
addpath /Volumes/home/jad438/validation_data/wrf_rerun/ %wrf_data_rerun_20161105.nc % _v2 for 1ho


% DOE Period 2015/11/02 to 2017/02/07
%start_date = datenum(2016,01,01);
%end_date = datenum(2016,01,03);
timespan = string(datestr(start_date:end_date,'yyyymmdd'));
%lvl = 3; %10,100,120,140
c2 = 182; c1 = 165; % DoE Buoy Location 181 and 164 
%c1 = 209 c2 = 182

for ii = 1:length(timespan)
fid{ii} = ['wrf_data_rerun_' char(timespan(ii)) '.nc']';
 try
 wrf_new(ii).time = ncread(fid{ii}','time')+datenum(2010,1,1);
 wrf_raw(ii).ws = ncread(fid{ii}','wind_speed');
 wrf_raw(ii).wd = ncread(fid{ii}','wind_from_direction');
 wrf_new(ii).ws = squeeze(wrf_raw(ii).ws(c1,c2,lvl,:));
 wrf_new(ii).wd = squeeze(wrf_raw(ii).wd(c1,c2,lvl,:));

%39.314	-74.401 
%lat = ncread(fid{ii}','lat');
%lon = ncread(fid{ii}','lon');

[L,~] = size(wrf_new(ii).time);

  if L == 6 
    disp('6 fixed')
    wrf_new(ii).time(7:24) = NaN;
    wrf_new(ii).ws(7:24) = NaN;
    wrf_new(ii).wd(7:24) = NaN;
  elseif L == 7 
    disp('7 fixed')
    wrf_new(ii).time(8:24) = NaN;
    wrf_new(ii).ws(8:24) = NaN;
    wrf_new(ii).wd(8:24) = NaN;
  elseif L == 18
    disp('18 fixed')
    wrf_new(ii).time = [NaN(6,1); wrf_new(ii).time];
    wrf_new(ii).ws = [NaN(6,1); wrf_new(ii).ws];
    wrf_new(ii).wd = [NaN(6,1); wrf_new(ii).wd];
  elseif L == 24
    disp('Good')
  else
    disp('missed')
    wrf_new(ii).time = NaN(24,1);
    wrf_new(ii).ws = NaN(24,1);
    wrf_new(ii).wd = NaN(24,1);
  end
 catch
    disp('caught')
    disp(fid{ii}')
    wrf_new(ii).time = NaN(24,1);
    wrf_new(ii).ws = NaN(24,1);
    wrf_new(ii).wd = NaN(24,1);
 end
end

wrf_ws = reshape([wrf_new(:).ws],[],1);
wrf_wd = reshape([wrf_new(:).wd],[],1);
wrf_time = reshape([wrf_new(:).time],[],1);

disp('wrf_rerun_loader load time:');
toc

end
