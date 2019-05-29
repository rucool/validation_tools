function [time,windspeed] = ndbc_loader(start_date,end_date,buoyid)
%% Created by Jaden Dicopoulos to deal with year gaps with Buoy Data
time_span = start_date:end_date;

if numel(unique(year(time_span))) == 1
    yearstr = num2str(unique(year(time_span)));
    ndbc_url = ['http://dods.ndbc.noaa.gov//thredds/dodsC/data/stdmet/' buoyid '/' buoyid 'h' yearstr '.nc'];
    time = double(ncread(ndbc_url,'time'))/(24*60*60)+datenum(1970,1,1);
    windspeed = squeeze(ncread(ndbc_url,'wind_spd'));
elseif numel(unique(year(time_span))) == 2
    years = unique(year(time_span));
    yearstr.a = num2str(years(1));
    yearstr.b = num2str(years(2));
    ndbc_url.a = ['http://dods.ndbc.noaa.gov//thredds/dodsC/data/stdmet/' buoyid '/' buoyid 'h' yearstr.a '.nc'];
    ndbc_url.b = ['http://dods.ndbc.noaa.gov//thredds/dodsC/data/stdmet/' buoyid '/' buoyid 'h' yearstr.b '.nc'];
    
    time1 = double(ncread(ndbc_url.a,'time'))/(24*60*60)+datenum(1970,1,1);
    time2 = double(ncread(ndbc_url.b,'time'))/(24*60*60)+datenum(1970,1,1);
    time = [time1;time2];
    
    windspeed1 = squeeze(ncread(ndbc_url.a,'wind_spd'));
    windspeed2 = squeeze(ncread(ndbc_url.b,'wind_spd'));
    windspeed = [windspeed1;windspeed2];
else
    disp('Buoy Loader Error; Possibly more than two year span')
end
end
%ndbc_url = 'http://dods.ndbc.noaa.gov//thredds/dodsC/data/stdmet/44025/44025h2015.nc';




%end