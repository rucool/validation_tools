function [start_date,end_date,months,sn,sc] = metseason(season)
%% Season Month Selector
if strcmp(season,'summer') == 1
    start_date = datenum(2015,06,01);
    end_date = datenum(2015,08,31);
    months = [2015 06; 2015 07; 2015 08; 2015 09;];
    sn = 1; sc = 'red';
elseif strcmp(season,'fall') == 1
    start_date = datenum(2015,09,01);
    end_date = datenum(2015,11,30);
    months = [2015 9; 2015 10; 2015 011; 2015 12;];
    sn = 2; sc = [1 0.5 0.2];
elseif strcmp(season,'winter') == 1
    start_date = datenum(2015,12,01);
    end_date = datenum(2016,02,29);
    months = [2015 12; 2016 01; 2016 02; 2016 03;];
    sn =3; sc = 'cyan';
elseif strcmp(season,'spring') == 1
    start_date = datenum(2016,03,01);
    end_date = datenum(2016,05,31);
    months = [2016 03; 2016 04; 2016 05; 2016 06;];
    sn = 4; sc = 'green';
else
    disp('Input a valid season: summer, fall, winter, spring')
end

end