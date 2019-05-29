% Figure 7 - NDBC Station Coverage
% BPU Wind Energy Project 2018-PQ4 Report Figures
% Written by Sage 1/18/19
%------------------------------------------------
close all; clear all;
addpath ../mat_libs/hexscatter/

buoys = ["44008","44009","44014","44017","44020","44022","44025","44065","44066"];
make_plot(buoys,'images/fig7_ndbc_offshore');
close;

buoys = ["brnd1","buzm3","cman4","ntkm3","tplm2","sdhn4","sjsn4"]; %Ommitted chlv2
make_plot(buoys,'images/fig7_ndbc_coastal');
close;

function make_plot(buoys,fname)
  for jj=1:length(buoys)
    url = sprintf('https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/%s/%s.ncml',buoys(jj),buoys(jj));
    dtime = double(ncread(url,'time'))/(24*60*60)+datenum(1970,1,1);
    ws = squeeze(ncread(url,'wind_spd'));
    subplot(length(buoys),1,jj);
    ind = find(dtime > datenum(2018,1,1) & dtime < datenum(2019,1,1));
%     hexscatter(dtime(ind:end),ws(ind:end),'res',60);
    plot(dtime(ind:end),ws(ind:end),'.');
    set(gca,'xlim',[datenum(2018,8,1) datenum(2018,11,1)]);
    set(gca,'ylim',[0 30]);
    datetick('keeplimits');
    ylabel(buoys(jj));
    if (jj==1)
      title('Wind Speeds at selected NDBC Buoys');
      %colorbar('East');
    end
    if jj~=length(buoys)
      set(gca,'xticklabel',[]);
    end
    set(gca,'fontsize',8)
  end
  set(gcf,'PaperPosition',[0.25 0.5 5 8]);
  print(gcf,'-dpng','-r300', fname);
end

