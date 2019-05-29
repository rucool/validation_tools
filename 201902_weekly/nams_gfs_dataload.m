function [time_gfs, ws_gfs, time_nams, ws_nams] = nams_gfs_dataload(end_date)
%clear; clc; close all;
%end_date = datenum(2019,3,3);
start_date = addtodate(end_date,-13,'day');
timespan = string(datestr(start_date:end_date,'yyyymmdd'));

addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_weekly/gfsdata
addpath /Users/jadendicopoulos/Documents/MATLAB/COOL/wrf_sage/201902_weekly/namsdata

for ii = 1:length(timespan)
fidgfs{ii} = ['gfs_data_' char(timespan(ii)) '.nc']';
gfs_raw(ii).ws = ncread(fidgfs{ii}','wind_speed');
gfs_new(ii).ws = squeeze(gfs_raw(ii).ws(426,162,:));
gfs_new(ii).time = ncread(fidgfs{ii}','time')+datenum(2010,1,1);

fidnams{ii} = ['nams_data_' char(timespan(ii)) '.nc']';
nams_raw(ii).ws = ncread(fidnams{ii}','wind_speed');
nams_new(ii).ws = squeeze(nams_raw(ii).ws(500,222,:));
nams_new(ii).time = ncread(fidnams{ii}','time')+datenum(2010,1,1);
end

%% nams
ws_nams1 = nams_new(1).ws; ws_nams2 = nams_new(2).ws; ws_nams3 = nams_new(3).ws;
ws_nams4 = nams_new(4).ws; ws_nams5 = nams_new(5).ws; ws_nams6 = nams_new(6).ws;
ws_nams7 = nams_new(7).ws; ws_nams8 = nams_new(8).ws; ws_nams9 = nams_new(9).ws;
ws_nams10 = nams_new(10).ws; ws_nams11 = nams_new(11).ws; ws_nams12 = nams_new(12).ws;
ws_nams13 = nams_new(13).ws; ws_nams14 = nams_new(14).ws;

ws_nams = [ws_nams1;ws_nams2;ws_nams3;ws_nams4;ws_nams5;ws_nams6;ws_nams7;ws_nams8;ws_nams9;...
    ws_nams10;ws_nams11;ws_nams12;ws_nams13;ws_nams14];

time_nams1 = nams_new(1).time; time_nams2 = nams_new(2).time; time_nams3 = nams_new(3).time;
time_nams4 = nams_new(4).time; time_nams5 = nams_new(5).time; time_nams6 = nams_new(6).time;
time_nams7 = nams_new(7).time; time_nams8 = nams_new(8).time; time_nams9 = nams_new(9).time;
time_nams10 = nams_new(10).time; time_nams11 = nams_new(11).time; time_nams12 = nams_new(12).time;
time_nams13 = nams_new(13).time; time_nams14 = nams_new(14).time;

time_nams = [time_nams1;time_nams2;time_nams3;time_nams4;time_nams5;time_nams6;time_nams7;...
    time_nams8;time_nams9;time_nams10;time_nams11;time_nams12;time_nams13;time_nams14];

%% gfs
ws_gfs1 = gfs_new(1).ws; ws_gfs2 = gfs_new(2).ws; ws_gfs3 = gfs_new(3).ws;
ws_gfs4 = gfs_new(4).ws; ws_gfs5 = gfs_new(5).ws; ws_gfs6 = gfs_new(6).ws;
ws_gfs7 = gfs_new(7).ws; ws_gfs8 = gfs_new(8).ws; ws_gfs9 = gfs_new(9).ws;
ws_gfs10 = gfs_new(10).ws; ws_gfs11 = gfs_new(11).ws; ws_gfs12 = gfs_new(12).ws;
ws_gfs13 = gfs_new(13).ws; ws_gfs14 = gfs_new(14).ws;

ws_gfs = [ws_gfs1;ws_gfs2;ws_gfs3;ws_gfs4;ws_gfs5;ws_gfs6;ws_gfs7;ws_gfs8;ws_gfs9;...
    ws_gfs10;ws_gfs11;ws_gfs12;ws_gfs13;ws_gfs14];

time_gfs1 = gfs_new(1).time; time_gfs2 = gfs_new(2).time; time_gfs3 = gfs_new(3).time;
time_gfs4 = gfs_new(4).time; time_gfs5 = gfs_new(5).time; time_gfs6 = gfs_new(6).time;
time_gfs7 = gfs_new(7).time; time_gfs8 = gfs_new(8).time; time_gfs9 = gfs_new(9).time;
time_gfs10 = gfs_new(10).time; time_gfs11 = gfs_new(11).time; time_gfs12 = gfs_new(12).time;
time_gfs13 = gfs_new(13).time; time_gfs14 = gfs_new(14).time;

time_gfs = [time_gfs1;time_gfs2;time_gfs3;time_gfs4;time_gfs5;time_gfs6;time_gfs7;time_gfs8;...
    time_gfs9;time_gfs10;time_gfs11;time_gfs12;time_gfs13;time_gfs14];

end