%% Stick plots for the DoE Buoy
close all; clear; clc;
addpath /Volumes/home/jad438/doe/buoy.z02.a0/
% fid = 'buoy.z02.a0.20160724.000000.nj1buoyvindicatorb1.nc'; % Sample file
start_date = datenum(2016,07,23);
end_date = datenum(2016,07,25);
time_span = start_date:end_date;

%% Load the data

%doe_time = datenum(seconds(ncread(fid,'time'))+time_span(1));
%doe_wind_dir = ncread(fid,'horizontal_wdir');
%doe_wind_spd = ncread(fid,'horizontal_wspd');

n = 2; % average every n values
a = 1:1:11; % arbitrary data
b = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)'; % the averaged vector





%plot(doe_time,doe_wind_spd(1,:))
%% Load the data
for ii = 1:length(time_span)
    fid = ['buoy.z02.a0.' datestr(time_span(ii),'yyyymmdd') '.000000.nj1buoyvindicatorb1.nc'];
    doe_time(ii).days = datenum(seconds(ncread(fid,'time'))+time_span(ii));
    doe_wind_dir(ii).days = ncread(fid,'horizontal_wdir');
    doe_wind_spd(ii).days = ncread(fid,'horizontal_wspd');
    
end

doe_heights = ncread(fid,'range');
doe_heights = doe_heights(:,1);
%% Create separate height arrays

for jj = 1:length(time_span)
    wind_dir_55m(jj).days = doe_wind_dir(jj).days(1,:);
    wind_spd_55m(jj).days = doe_wind_spd(jj).days(1,:);
    
    wind_dir_70m(jj).days = doe_wind_dir(jj).days(2,:);
    wind_spd_70m(jj).days = doe_wind_spd(jj).days(2,:);
    
    wind_dir_90m(jj).days = doe_wind_dir(jj).days(3,:);
    wind_spd_90m(jj).days = doe_wind_spd(jj).days(3,:);
    
    wind_dir_111m(jj).days = doe_wind_dir(jj).days(4,:);
    wind_spd_111m(jj).days = doe_wind_spd(jj).days(4,:);
    
    wind_dir_130m(jj).days = doe_wind_dir(jj).days(5,:);
    wind_spd_130m(jj).days = doe_wind_spd(jj).days(5,:);
    
    wind_dir_160m(jj).days = doe_wind_dir(jj).days(6,:);
    wind_spd_160m(jj).days = doe_wind_spd(jj).days(6,:);
    
end
%% Changing directions
    %plot(doe_time(kk).days,wind_spd_111m(kk).days,'color','blue')
    %plot(doe_time(kk).days,wind_dir_55m(kk).days,'color','red')


for kk = 1:length(time_span)
    figure(1)
    hold on; grid on;
    
    u = cos((270-wind_dir_111m(kk).days)*pi/180).*wind_spd_111m(kk).days;
    v = sin((270-wind_dir_111m(kk).days)*pi/180).*wind_spd_111m(kk).days;
    w = u+1i*v;
    
    xlim = [time_span(1) time_span(end)];
    ylim = [-28 28];
    set(gca,'units','pixels'); ppos = get(gca,'position'); set(gca,'units','norm');
    uscale = (diff(xlim)/diff(ylim))*(ppos(4)/ppos(3));
    
    xx = [doe_time(kk).days doe_time(kk).days+uscale*u doe_time(kk).days]';
    yy = [zeros(length(doe_time(kk).days),1) v(ind) NaN*zeros(length(doe_time(kk).days),1)]';
    plot(xx(:),yy(:),'r-','linewidth',.5); hold on
    plot(xlim,[0 0],'k-');
    
    set(gca,'xlim',xlim,'ylim',ylim);  
    datetick('x','mm/dd','keeplimits')
    
end