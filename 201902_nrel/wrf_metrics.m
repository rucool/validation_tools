function metrics = wrf_metrics(observations,forecast)
% Script to calculate valiation metrics
% Inputs must be the same length of matched observations

ind = find(~isnan(observations) & ~isnan(forecast));

metrics.mo = mean(observations(ind));
metrics.mf = mean(forecast(ind));
metrics.so = std(observations(ind));
metrics.sf = std(forecast(ind));

metrics.rms = rms(forecast(ind)-observations(ind));
metrics.crms = rms( (forecast(ind)-metrics.mf) - (observations(ind)-metrics.mo) );
metrics.mb = metrics.mf - metrics.mo;
cc = corrcoef(forecast(ind),observations(ind));
metrics.cc = cc(1,2);
metrics.mae = mean(abs(forecast(ind)-observations(ind)));

metrics.c1 = (metrics.sf / metrics.so - 1) * 100;
metrics.c2 = (metrics.rms / metrics.so) * 100;
metrics.c3 = (metrics.crms / metrics.so) * 100;
metrics.count = length(ind);
