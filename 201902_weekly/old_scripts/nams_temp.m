clear; close all; clc;

fid1 = 'nams_data_20190223.nc';
fid2 = 'nams_data_20190224.nc';
fid3 = 'nams_data_20190225.nc';
fid4 = 'nams_data_20190226.nc';
fid5 = 'nams_data_20190227.nc';
fid6 = 'nams_data_20190228.nc';

fid7 = 'gfs_data_20190223.nc';
fid8 = 'gfs_data_20190224.nc';
fid9 = 'gfs_data_20190225.nc';
fid10 = 'gfs_data_20190226.nc';
fid11 = 'gfs_data_20190227.nc';
fid12 = 'gfs_data_20190228.nc';

ws.A = ncread(fid1,'wind_speed');
ws.B = ncread(fid2,'wind_speed');
ws.C = ncread(fid3,'wind_speed');
ws.D = ncread(fid4,'wind_speed');
ws.E = ncread(fid5,'wind_speed');
ws.F = ncread(fid6,'wind_speed');

ws.G = ncread(fid7,'wind_speed');
ws.H = ncread(fid8,'wind_speed');
ws.I = ncread(fid9,'wind_speed');
ws.J = ncread(fid10,'wind_speed');
ws.K = ncread(fid11,'wind_speed');
ws.L = ncread(fid12,'wind_speed');

%buoy.lat = csvread('wrf_ndbc_points.csv',8,0,[8,0,8,1]);
%buoycoords = [40.369 -73.703];
%162 426
% temp = [40.3690910339356 -73.7029647827148];
% buoyind = [222 500];
%gfs.lat = ncread(fid6,'lat_0');
%gfs.lon = ncread(fid6,'lon_0');
% 
%latm = abs(gfs.lat-buoycoords(1));
%lonm = abs(gfs.lon-buoycoords(2));
% 
% latmin = min(min(latm));
% [lat1,lat2] = find(latm==latmin);
% lonmin = min(min(lonm));
% [lon1,lon2] = find(lonm==lonmin);

wsN.A = squeeze(ws.A(500,222,:));
wsN.B = squeeze(ws.B(500,222,:));
wsN.C = squeeze(ws.C(500,222,:));
wsN.D = squeeze(ws.D(500,222,:));
wsN.E = squeeze(ws.E(500,222,:));
wsN.F = squeeze(ws.F(500,222,:));

wsN.G = squeeze(ws.G(426,162,:));
wsN.H = squeeze(ws.H(426,162,:));
wsN.I = squeeze(ws.I(426,162,:));
wsN.J = squeeze(ws.J(426,162,:));
wsN.K = squeeze(ws.K(426,162,:));
wsN.L = squeeze(ws.L(426,162,:));

nams_ws = [wsN.A; wsN.B; wsN.C; wsN.D; wsN.E; wsN.F];
gfs_ws  = [wsN.G; wsN.H; wsN.I; wsN.J; wsN.K; wsN.L];

time.A = ncread(fid1,'time')+datenum(2010,1,1);
time.B = ncread(fid2,'time')+datenum(2010,1,1);
time.C = ncread(fid3,'time')+datenum(2010,1,1);
time.D = ncread(fid4,'time')+datenum(2010,1,1);
time.E = ncread(fid5,'time')+datenum(2010,1,1);
time.F = ncread(fid6,'time')+datenum(2010,1,1);

time.G = ncread(fid7,'time')+datenum(2010,1,1);
time.H = ncread(fid8,'time')+datenum(2010,1,1);
time.I = ncread(fid9,'time')+datenum(2010,1,1);
time.J = ncread(fid10,'time')+datenum(2010,1,1);
time.K = ncread(fid11,'time')+datenum(2010,1,1);
time.L = ncread(fid12,'time')+datenum(2010,1,1);

nams_time = [time.A; time.B; time.C; time.D; time.E; time.F];
gfs_time  = [time.G; time.H; time.I; time.J; time.K; time.L];

hold on
plot(nams_time,nams_ws)
plot(gfs_time,gfs_ws)

save('nams_data.mat','nams_ws','nams_time','gfs_time','gfs_ws')










