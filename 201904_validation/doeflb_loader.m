function [doe_time_i,doe_90_ws_i,doe_90_wd_i] = doeflb_loader(start_date,end_date)
%% Loader for the DoE Buoy
%clear; clc; close all;
addpath /Volumes/home/jad438/doe/buoy.z02.a0/
% fid = 'buoy.z02.a0.20160724.000000.nj1buoyvindicatorb1.nc'; % Sample file
%start_date = datenum(2016,06,01,00,00,00);
%end_date = datenum(2016,06,02,00,00,00);
time_span = start_date:end_date;

%% Load the data
    for ii = 1:length(time_span)
        fid = ['buoy.z02.a0.' datestr(time_span(ii),'yyyymmdd') '.000000.nj1buoyvindicatorb1.nc'];
        try
        doe_time(ii).days = datenum(seconds(ncread(fid,'time'))+time_span(ii))';
        doe_wind_dir(ii).days = ncread(fid,'horizontal_wdir');
        doe_wind_spd(ii).days = ncread(fid,'horizontal_wspd');
        doe_qc(ii).days = ncread(fid,'qc_wind')';
        disp('day passed')
        catch
            disp('day failed')
            doe_time(ii).days = [];
            doe_wind_dir(ii).days = double.empty(6,0);
            doe_wind_spd(ii).days = double.empty(6,0);
            doe_qc(ii).days = [];
        end
        
    end

%doe_heights = ncread(fid,'range');
%doe_heights = doe_heights(:,1);
%% Create separate height arrays
    for jj = 1:length(time_span)
        %wind_dir_55m(jj).days = doe_wind_dir(jj).days(1,:);
        %wind_spd_55m(jj).days = doe_wind_spd(jj).days(1,:);

        %wind_dir_70m(jj).days = doe_wind_dir(jj).days(2,:);
        %wind_spd_70m(jj).days = doe_wind_spd(jj).days(2,:);

        wind_dir_90m(jj).days = doe_wind_dir(jj).days(3,:);
        wind_spd_90m(jj).days = doe_wind_spd(jj).days(3,:);

        %wind_dir_111m(jj).days = doe_wind_dir(jj).days(4,:);
        %wind_spd_111m(jj).days = doe_wind_spd(jj).days(4,:);

        %wind_dir_130m(jj).days = doe_wind_dir(jj).days(5,:);
        %wind_spd_130m(jj).days = doe_wind_spd(jj).days(5,:);

        %wind_dir_160m(jj).days = doe_wind_dir(jj).days(6,:);
        %wind_spd_160m(jj).days = doe_wind_spd(jj).days(6,:);

    end

%% Reshaping and NaN filling
time_span_s = start_date:seconds(1):end_date+1;
doe_timet = reshape([doe_time(:).days],1,[]);
[~,j] = ismembertol(doe_timet,datenum(time_span_s));

doe_time_i = nan(size(time_span_s));
doe_time_i(j) = doe_timet;

%%
wind_spd_90mt = reshape([wind_spd_90m(:).days],1,[]);
wind_dir_90mt = reshape([wind_dir_90m(:).days],1,[]);

doe_90_ws_i = nan(size(time_span_s));
doe_90_ws_i(j) = wind_spd_90mt;

doe_90_wd_i = nan(size(time_span_s));
doe_90_wd_i(j) = wind_dir_90mt;

%%
% wind_spd_130mt = reshape([wind_spd_130m(:).days],1,[]);
% wind_dir_130mt = reshape([wind_dir_130m(:).days],1,[]);
% 
% doe_130_ws_i = nan(size(time_span_s));
% doe_130_ws_i(j) = wind_spd_130mt;
% 
% doe_130_wd_i = nan(size(time_span_s));
% doe_130_wd_i(j) = wind_dir_130mt;

%% QC Variable decoder
doe_qct = reshape([doe_qc(:).days],1,[]);

for pp = 1:length(doe_qct)
doe_qct_bit = bitget(doe_qct(pp),6:-1:1);

if doe_qct_bit(3) == 1
    qcind_90m(pp) = pp;
end

% if doe_qct_bit(5) == 1
%     qcind_130m(pp) = pp;
% end

end

if exist('qcind_90m','var') == 1
qcindnz = qcind_90m(qcind_90m~=0);
doe_90_ws_i(qcindnz) = NaN;
end

% if exist('qcind_130m','var') == 1
% qcindnz = qcind_130m(qcind_130m~=0);
% doe_130_ws_i(qcindnz) = NaN;
% end

end