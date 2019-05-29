function [start_date,end_date,months,sn,sc] = metseason_v2(season)
%% Season Month Selector
if strcmp(season,'summer') == 1
    start_date = datenum(2018,06,01);
    end_date = datenum(2018,08,31);
    months = [2018 06; 2018 07; 2018 08; 2018 09;];
    sn = 1; sc = 'red';
elseif strcmp(season,'fall') == 1
    start_date = datenum(2018,09,01);
    end_date = datenum(2018,11,30);
    months = [2018 9; 2018 10; 2018 011; 2018 12;];
    sn = 2; sc = [1 0.5 0.2];
elseif strcmp(season,'winter') == 1
    start_date = datenum(2018,12,01);
    end_date = datenum(2019,02,29);
    months = [2018 12; 2019 01; 2019 02; 2019 03;];
    sn =3; sc = 'cyan';
elseif strcmp(season,'spring') == 1
    start_date = datenum(2018,03,01);
    end_date = datenum(2018,05,31);
    months = [2018 03; 2018 04; 2018 05; 2018 06;];
    sn = 4; sc = 'green';
else
    disp('Input a valid season: summer, fall, winter, spring')
end

end