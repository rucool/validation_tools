function [hrrr_time, hrrr_ws, hrrr_wd, start_date] = hrrr_dataload(end_date,total_days,buoy,hlvl)
%clear; clc; close all;
%end_date = datenum(2019,6,01);
%total_days = 2;
%buoy = '44065';
%hlvl = 1; %height level for hrrr, 10,80

if strcmp(buoy,'44065') == 1
    %hrrr
    c1 = 1564+1;%lon
    c2 = 685+1;%lat
elseif strcmp(buoy,'44025') == 1
    %hrrr
    c1 = 1580+1;%lon
    c2 = 685+1;%lat
elseif strcmp(buoy,'44009') == 1
    %hrrr
    c1 = 1554+1;%lon 
    c2 = 609+1;%lat
end

start_date = addtodate(end_date,-total_days,'day');
timespan = string(datestr(start_date:end_date,'yyyymmdd'));

addpath /Volumes/home/jad438/validation_data/hrrrdata
%% Server

for ii = 1:length(timespan)
fidhrrr{ii} = ['hrrr_data_' char(timespan(ii)) '.nc']';

hrrr_raw(ii).ws = ncread(fidhrrr{ii}','wind_speed');
hrrr_new(ii).ws = squeeze(hrrr_raw(ii).ws(c1,c2,hlvl,:));
hrrr_raw(ii).wd = ncread(fidhrrr{ii}','wind_from_direction');
hrrr_new(ii).wd = squeeze(hrrr_raw(ii).wd(c1,c2,hlvl,:));
hrrr_new(ii).time = ncread(fidhrrr{ii}','time')+datenum(2010,1,1);

end

hrrr_ws = reshape([hrrr_new(:).ws],[],1);
hrrr_wd = reshape([hrrr_new(:).wd],[],1);
hrrr_time = reshape([hrrr_new(:).time],[],1);

%% lat lon checker
%lat = squeeze(ncread(fidhrrr{ii}','gridlat_0'));

end