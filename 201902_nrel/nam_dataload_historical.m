function [nam_time, nam_ws, nam_wd] = nam_dataload_historical(start_date,end_date,lvl,buoy)
%clear; close all;
%start_date = datenum(2015,06,08);
%end_date = datenum(2015,06,12);
%buoy = 'DOEFL';
%lvl = 1; % Level 1,2 corresponds to 10m, 80m
forecast_offset = 0;

if strcmp(buoy,'44065') == 1
    %nam
    c3 = 500+1; c4 = 222+1;
elseif strcmp(buoy,'44025') == 1
    %nam
    c3 = 504+1; c4 = 222+1;
elseif strcmp(buoy,'44009') == 1
    %nam
    c3 = 495+1; c4 = 203+1;
elseif strcmp(buoy,'DOEFL') == 1
    %nam
    c3 = 496+1; c4 = 212+1;
end

%start_date = addtodate(end_date,-9,'day');
%start_date = start_date-1;
timespans = string(datestr(start_date:end_date-1,'yyyymmdd'));
timespan = addtodate(start_date,forecast_offset,'hour'):hours(1):addtodate(end_date,23,'hour');
%% Local
%addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_weekly/gfsdata
%addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_weekly/namsdata
%% Server Present
%addpath /Volumes/Home/jad438/validation_data/gfsdata
%addpath /Volumes/Home/jad438/validation_data/namdata
%% Server Historical
addpath /Volumes/home/jad438/validation_data/historicalnamdata
%addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_nrel/namhist

for ii = 1:length(timespans)
fidnams{ii} = ['nams_data_hist_' char(timespans(ii)) '.nc']';
nams_raw(ii).ws = ncread(fidnams{ii}','wind_speed');
nams_new(ii).ws = squeeze(nams_raw(ii).ws(c3,c4,lvl,:))';
nams_raw(ii).wd = ncread(fidnams{ii}','wind_from_direction');
nams_new(ii).wd = squeeze(nams_raw(ii).wd(c3,c4,lvl,:))';
nams_new(ii).time = [ncread(fidnams{ii}','time')+datenum(2010,1,1)]';
end

lat = ncread(fidnams{ii}','gridlat_0');
lati = squeeze(lat(c3,c4))';
lon = ncread(fidnams{ii}','gridlon_0');
loni = squeeze(lon(c3,c4))';
disp('------------')
disp('Nam Coords Used')
disp(lati)
disp(loni)


%% nams

ws_namst = reshape([nams_new(:).ws],1,[]);
wd_namst = reshape([nams_new(:).wd],1,[]);
time_namst = reshape([nams_new(:).time],1,[]);

[~,j] = ismember(time_namst,timespan);
nam_time = nan(size(timespan));
nam_time(j) = time_namst;

nam_ws = nan(size(timespan));
nam_ws(j) = ws_namst;

nam_wd = nan(size(timespan));
nam_wd(j) = wd_namst;




end