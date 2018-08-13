% fill the missing s & t on ooi moorings with data from Argo
ooi_nan=find(isnan(day_mean));
ooi_nan_time=uniq_day(ooi_nan);
ooi_nan_sal=nan.*ones(length(ooi_nan_time),1);
ooi_nan_temp=ooi_nan_sal;
ooi_nan_dens=ooi_nan_sal;
ooi_nan_do=ooi_nan_sal;
S0=0;
B0 = -6.24097e-3;
B1 = -6.93498e-3;
B2 = -6.90358e-3;
B3 = -4.29155e-3;
C0 = -3.11680e-7;
for i=1:length(ooi_nan_time)
    idx=find(Argo.time(1,:)==ooi_nan_time(i));
    ooi_nan_sal(i)=Argo.sal(10,idx);
    S=ooi_nan_sal(i);
    ooi_nan_temp(i)=Argo.temp(10,idx);
    T=ooi_nan_temp(i);
    ooi_nan_dens(i)=sw_dens0(S,T);
    dens=ooi_nan_dens(i);
    do_nosal=day_mean_raw(ooi_nan(i)).*1000./dens.*(1+0.032.*30./1000);
    ts=log((298.15-T)/(273.15+T));
    Bts=B0 + B1.*ts + B2.*(ts.^2) + B3.*(ts.^3);
    ooi_nan_do(i)=exp((S-S0).*Bts + C0*(S.^2)).*do_nosal;
end

    