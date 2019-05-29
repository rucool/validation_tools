function []=weatherpatch(start_date,end_date,event)

zz = gca;
Ymax = zz.YLim(2);

if event == strcmp(season,'highwind') == 1
v = [datenum(start_date) 0;datenum(start_date) Ymax;...
    datenum(end_date) Ymax;datenum(end_date) 0];
f = [1 2 3 4];
patch('Faces',f,'Vertices',v,'FaceColor','yellow','facealpha',.1,'edgecolor','none')

elseif event == strcmp(season,'rain') == 1
v = [datenum(start_date) 0;datenum(start_date) Ymax;...
    datenum(end_date) Ymax;datenum(end_date) 0];
f = [1 2 3 4];
patch('Faces',f,'Vertices',v,'FaceColor','blue','facealpha',.1,'edgecolor','none')

elseif event == strcmp(season,'snow') == 1
v = [datenum(start_date) 0;datenum(start_date) Ymax;...
    datenum(end_date) Ymax;datenum(end_date) 0];
f = [1 2 3 4];
patch('Faces',f,'Vertices',v,'FaceColor','cyan','facealpha',.1,'edgecolor','none')

end