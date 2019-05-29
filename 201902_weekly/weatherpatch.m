function []=weatherpatch(start_date,end_date,event)

zz = gca;
Ymax = zz.YLim(2);

if strcmp(event,'highwind') == 1
v = [datenum(start_date,'yyyymmddHH') 0;datenum(start_date,'yyyymmddHH') Ymax;...
    datenum(end_date,'yyyymmddHH') Ymax;datenum(end_date,'yyyymmddHH') 0];
f = [1 2 3 4];
patch('Faces',f,'Vertices',v,'FaceColor','yellow','facealpha',.1,'edgecolor','none')
text(datenum(start_date,'yyyymmddHH'),zz.YLim(2)-1.3,'H.W.','rotation',45)

elseif strcmp(event,'rain') == 1
v = [datenum(start_date,'yyyymmddHH') 0;datenum(start_date,'yyyymmddHH') Ymax;...
    datenum(end_date,'yyyymmddHH') Ymax;datenum(end_date,'yyyymmddHH') 0];
f = [1 2 3 4];
patch('Faces',f,'Vertices',v,'FaceColor','blue','facealpha',.1,'edgecolor','none')
text(datenum(start_date,'yyyymmddHH'),zz.YLim(2)-1.3,'Rain','rotation',45)

elseif strcmp(event,'snow') == 1
v = [datenum(start_date,'yyyymmddHH') 0;datenum(start_date,'yyyymmddHH') Ymax;...
    datenum(end_date,'yyyymmddHH') Ymax;datenum(end_date,'yyyymmddHH') 0];
f = [1 2 3 4];
patch('Faces',f,'Vertices',v,'FaceColor','cyan','facealpha',.1,'edgecolor','none')
text(datenum(start_date,'yyyymmddHH'),zz.YLim(2)-1.3,'Snow','rotation',45)

else
    disp('weatherpatch error: invalid date or event')

end