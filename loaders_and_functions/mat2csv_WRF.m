%% WRF v4.1 .mat to .csv
clear; clc;

%% load
load('temp_data/ru-wrf_v4.1_domains.mat')

csvwrite('XLAT_M_1km_WRF41.csv',XLATM1km)
csvwrite('XLAT_M_3km_WRF41.csv',XLATM3km)
csvwrite('XLAT_M_9km_WRF41.csv',XLATM9km)
csvwrite('XLONG_M_1km_WRF41.csv',XLONGM1km)
csvwrite('XLONG_M_3km_WRF41.csv',XLONGM3km)
csvwrite('XLONG_M_9km_WRF41.csv',XLONGM9km)
