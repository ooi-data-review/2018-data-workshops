% get daily mean from mooring
round_day=round(Flma.time);
uniq_day=unique(round_day);
day_mean=nan.*ones(length(uniq_day),1);
day_mean_raw=day_mean;
for kk=1:length(uniq_day)
    idx=find(round_day==uniq_day(kk));
    day_mean(kk)=mean(Flma.DO(idx));
    day_mean_raw(kk)=mean(Flma.DO_raw(idx));
end

hold on;
scatter(uniq_day,day_mean,'or');

scatter(uniq_day,day_mean_raw,'+k');


