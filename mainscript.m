%Define extremes and compare against observations

%Calculations
reloadprevcalcs=0; %1 min; necessary when starting up

calcprecippercentiles_mpi=0; %50 min
calcprecippercentiles_chirps=0; %10 min
readallprecipdata_mpi=0; %5 min for first 10 ensemble members; necessary when starting up
defineextremeprecipandcompounding_mpi_all100ensmems=0; %12 hr
    saveresult=0;
defineextremeprecipcompounding_chirps=0; %2 min; necessary for regionalcalcs.m

volatilityanalysisanddroughtdefn_mpi=0; %looks at precip integrated over the water year
volatilityanalysisanddroughtdefn_chirps=0; %ditto but for reanalysis

readalltempdata_mpi=0; %3 min for first 10 ensemble members; necessary for regionalcalcs.m
defineextremeheatandcompounding_mpi_all100ensmems=0; %12 hr
readtempdata_merra2=0; %1 hour
defineextremeheatcompounding_merra2=0; %1 min; required for regionalcalcs.m

readalltempandprecipdata_mpi_saveasreglmeans=0; %3 hr for all variables and 100 ensemble members
readalltempandprecipdata_reana_saveasreglmeans=0; %10 sec
applygauppdefnsandmakeplot=0; %1 min; produces Figure 4
applygauppdefnsandmakeplot_reana=1; %1 min; produces Figure S4

    
compoundheatdefinitionsensitivity=0; %1 min; produces Figure S2
compoundprecipdefinitionsensitivity=0; %1 min; produces Figure S3



%Critical settings
numregs=24;
memstodo=10; %to do temporary things speedily
extrprecippctile=0.95; %default is 0.95
extrheatpctile=0.95; %default is 0.95

    
    
precipdataloc='/Volumes/ExternalDriveF/swift.dkrz.de/precip-colin/';
tmaxdataloc='/Volumes/ExternalDriveF/swift.dkrz.de/tmax-colin/';
icloud='~/Library/Mobile Documents/com~apple~CloudDocs/';
figloc=strcat(icloud,'General_Academics/Research/Raymondetal2022_ERL_TippingPts/');

mlens=[31;28;31;30;31;30;31;31;30;31;30;31];
numlons=192;numlats=64; %MPI dimensions
numdaysinmon=31;
numyrs=30;
nummonsinyr=12;


exist mpilats;
if ans==0
    mpilat=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0201-daily-mmday.nc'),'lat');
    mpilon=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0201-daily-mmday.nc'),'lon');
    clear mpilats;clear mpilons;
    for i=1:size(mpilat,1)
        for j=1:size(mpilon,1)
            mpilats(i,j)=mpilat(i);
            mpilons(i,j)=mpilon(j);
        end
    end
end

exist gpcplats;
if ans==0
    gpcplat=ncread('/Volumes/ExternalDriveF/GPCP_precip/gpcp_v01r03_daily_d19970101.nc','latitude');
    gpcplon=ncread('/Volumes/ExternalDriveF/GPCP_precip/gpcp_v01r03_daily_d19970101.nc','longitude');
    clear gpcplats;clear gpcplons;
    for i=1:size(gpcplat,1)
        for j=1:size(gpcplon,1)
            gpcplats(i,j)=gpcplat(i);
            gpcplons(i,j)=gpcplon(j);
        end
    end
    westernhem=gpcplons>=180;gpcplons(westernhem)=gpcplons(westernhem)-360;
    gpcplats=double(gpcplats);gpcplons=double(gpcplons);
    gpcplats=flipud(gpcplats);
    gpcplons=[gpcplons(:,181:360) gpcplons(:,1:180)];
    
    gpcplats60n60s=gpcplats(31:149,:);gpcplons60n60s=gpcplons(31:149,:);
end

%Set up regions
mpilatsfl=mpilats';mpilonsfl=mpilons';
regnums=NaN.*ones(192,64);
for i=1:192
    for j=1:64
        if (mpilatsfl(i,j)<=85 && mpilatsfl(i,j)>=50 && mpilonsfl(i,j)>=-105 && mpilonsfl(i,j)<=-10) || ...
            (mpilatsfl(i,j)<=75 && mpilatsfl(i,j)>=60 && mpilonsfl(i,j)>=-170 && mpilonsfl(i,j)<=-105)  %n N America
            regnums(i,j)=1;
        elseif mpilatsfl(i,j)<=60 && mpilatsfl(i,j)>=30 && mpilonsfl(i,j)>=-130 && mpilonsfl(i,j)<=-105 %w N America
            regnums(i,j)=2;
        elseif mpilatsfl(i,j)<=50 && mpilatsfl(i,j)>=30 && mpilonsfl(i,j)>=-105 && mpilonsfl(i,j)<=-85 %central N America
            regnums(i,j)=3;
        elseif mpilatsfl(i,j)<=50 && mpilatsfl(i,j)>=25 && mpilonsfl(i,j)>=-85 && mpilonsfl(i,j)<=-60 %e N America
            regnums(i,j)=4;
        elseif (mpilatsfl(i,j)<=20 && mpilatsfl(i,j)>=5 && mpilonsfl(i,j)>=-105 && mpilonsfl(i,j)<=-75) || ...
                (mpilatsfl(i,j)<=30 && mpilatsfl(i,j)>=20 && mpilonsfl(i,j)>=-115 && mpilonsfl(i,j)<=-85) %Mexico & Central America
            regnums(i,j)=5;
        elseif (mpilatsfl(i,j)<=10 && mpilatsfl(i,j)>=-20 && mpilonsfl(i,j)>=-75 && mpilonsfl(i,j)<=-50) || ...
                (mpilatsfl(i,j)<=5 && mpilatsfl(i,j)>=-20 && mpilonsfl(i,j)>=-85 && mpilonsfl(i,j)<=-75) %n S America
            regnums(i,j)=6;
        elseif mpilatsfl(i,j)<=0 && mpilatsfl(i,j)>=-20 && mpilonsfl(i,j)>=-50 && mpilonsfl(i,j)<=-35 %e S America
            regnums(i,j)=7;
        elseif mpilatsfl(i,j)<=-20 && mpilatsfl(i,j)>=-60 && mpilonsfl(i,j)>=-75 && mpilonsfl(i,j)<=-40 %s S America
            regnums(i,j)=8;
        elseif (mpilatsfl(i,j)<=70 && mpilatsfl(i,j)>=55 && mpilonsfl(i,j)>=-10 && mpilonsfl(i,j)<=40) || ...
               (mpilatsfl(i,j)<=70 && mpilatsfl(i,j)>=50 && mpilonsfl(i,j)>=-10 && mpilonsfl(i,j)<=5) %n Europe
            regnums(i,j)=9;
        elseif (mpilatsfl(i,j)<=55 && mpilatsfl(i,j)>=45 && mpilonsfl(i,j)>=5 && mpilonsfl(i,j)<=40) || ...
               (mpilatsfl(i,j)<=50 && mpilatsfl(i,j)>=45 && mpilonsfl(i,j)>=-5 && mpilonsfl(i,j)<=40) %central Europe
            regnums(i,j)=10;
        elseif mpilatsfl(i,j)<=45 && mpilatsfl(i,j)>=30 && mpilonsfl(i,j)>=-10 && mpilonsfl(i,j)<=40 %Mediterranean
            regnums(i,j)=11;
        elseif mpilatsfl(i,j)<=30 && mpilatsfl(i,j)>=15 && mpilonsfl(i,j)>=-20 && mpilonsfl(i,j)<=40 %Sahara
            regnums(i,j)=12;
        elseif mpilatsfl(i,j)<=15 && mpilatsfl(i,j)>=-15 && mpilonsfl(i,j)>=-20 && mpilonsfl(i,j)<=25 %West Africa
            regnums(i,j)=13;
        elseif mpilatsfl(i,j)<=15 && mpilatsfl(i,j)>=-15 && mpilonsfl(i,j)>=25 && mpilonsfl(i,j)<=50 %East Africa
            regnums(i,j)=14;
        elseif mpilatsfl(i,j)<=-15 && mpilatsfl(i,j)>=-35 && mpilonsfl(i,j)>=10 && mpilonsfl(i,j)<=50 %s Africa
            regnums(i,j)=15;
        elseif mpilatsfl(i,j)<=70 && mpilatsfl(i,j)>=50 && mpilonsfl(i,j)>=40 && mpilonsfl(i,j)<=180 %n Eurasia
            regnums(i,j)=16;
        elseif mpilatsfl(i,j)<=50 && mpilatsfl(i,j)>=15 && mpilonsfl(i,j)>=40 && mpilonsfl(i,j)<=60 %w Asia
            regnums(i,j)=17;
        elseif mpilatsfl(i,j)<=50 && mpilatsfl(i,j)>=30 && mpilonsfl(i,j)>=60 && mpilonsfl(i,j)<=100 %central Asia
            regnums(i,j)=18;
        elseif mpilatsfl(i,j)<=50 && mpilatsfl(i,j)>=20 && mpilonsfl(i,j)>=100 && mpilonsfl(i,j)<=145 %East Asia
            regnums(i,j)=19;
        elseif (mpilatsfl(i,j)<=30 && mpilatsfl(i,j)>=5 && mpilonsfl(i,j)>=60 && mpilonsfl(i,j)<=95) || ...
               (mpilatsfl(i,j)<=30 && mpilatsfl(i,j)>=20 && mpilonsfl(i,j)>=95 && mpilonsfl(i,j)<=100) %South Asia
            regnums(i,j)=20;
        elseif mpilatsfl(i,j)<=20 && mpilatsfl(i,j)>=-10 && mpilonsfl(i,j)>=95 && mpilonsfl(i,j)<=155 %Southeast Asia
            regnums(i,j)=21;
        elseif mpilatsfl(i,j)<=-10 && mpilatsfl(i,j)>=-30 && mpilonsfl(i,j)>=110 && mpilonsfl(i,j)<=155 %n Australia
            regnums(i,j)=22;
        elseif mpilatsfl(i,j)<=-30 && mpilatsfl(i,j)>=-45 && mpilonsfl(i,j)>=110 && mpilonsfl(i,j)<=155 %n Australia
            regnums(i,j)=23;
        elseif mpilatsfl(i,j)<=-30 && mpilatsfl(i,j)>=-50 && mpilonsfl(i,j)>=165 && mpilonsfl(i,j)<=180 %New Zealand
            regnums(i,j)=24;
        end
    end
end
regnums=regnums';

if reloadprevcalcs==1
    f=load(strcat(precipdataloc,'alldata_mpi.mat'));allyearsdata_mpi=f.allyearsdata_mpi;
    
    f=load(strcat(precipdataloc,'percentilethreshold.mat'));meanannualp99precip_mpi=f.meanannualp99_mpi;meanannualp95precip_mpi=f.meanannualp95_mpi;
    meanannualp90precip_mpi=f.meanannualp90_mpi;meanannualp75precip_mpi=f.meanannualp75_mpi;meanannualp50precip_mpi=f.meanannualp50_mpi;meanannualmaxprecip_mpi=f.meanannualmax_mpi;
    maxdaysabovep99_mpi_mean=f.maxdaysabovep99_mpi_mean;
    f=load(strcat(precipdataloc,'percentilethreshold_gpcp.mat'));meanannualp95_gpcp_interp=f.meanannualp95_gpcp_interp;maxdaysabovep99_gpcp_interp=f.maxdaysabovep99_gpcp_interp;
    f=load(strcat(precipdataloc,'percentilethreshold_chirps.mat'));meanannualp95_chirps_interp=f.meanannualp95_chirps_interp;meanannualp99_chirps_interp=f.meanannualp99_chirps_interp;

    f=load(strcat(precipdataloc,'wateryearprecip_mpi.mat'));wyprecip_mpi_hist=f.wyprecip_mpi_hist;wyprecip_mpi_fut=f.wyprecip_mpi_fut;
    
    f=load(strcat(precipdataloc,'dailyprecipdata_chirps.mat'));allyearsdata_chirps=f.allyearsdata_chirps;
    
    f=load(strcat(precipdataloc,'extremepreciparray_mpi.mat'));
    regextremeprecipdays_hist=f.regextremeprecipdays_hist;regextremeprecipdays_fut=f.regextremeprecipdays_fut;
    numdaysabovep95_bygridpt_hist=f.numdaysabovep95_bygridpt_hist;
    numdaysabovep95_bygridpt_fut=f.numdaysabovep95_bygridpt_fut;
    finalfreqbyreg_hist_ensmem1=f.finalfreqbyreg_hist_ensmem1;finalfreqbyreg_fut_ensmem1=f.finalfreqbyreg_fut_ensmem1;
    arealthreshold_extremeprecip=f.arealthreshold_extremeprecip;
    f=load(strcat(tmaxdataloc,'extremeheatarray_mpi.mat'));
    regextremeheatdays_hist=f.regextremeheatdays_hist;
    regextremeheatdays_fut=f.regextremeheatdays_fut;
    numtempdaysabovep99_bygridpt_hist=f.numtempdaysabovep99_bygridpt_hist;
    numtempdaysabovep99_bygridpt_fut=f.numtempdaysabovep99_bygridpt_fut;
    finalextremeheatfreqbyreg_hist_ensmem1=f.finalextremeheatfreqbyreg_hist_ensmem1;
    finalextremeheatfreqbyreg_fut_ensmem1=f.finalextremeheatfreqbyreg_fut_ensmem1;
    arealthreshold_extremeheat=f.arealthreshold_extremeheat;
        
    f=load(strcat(tmaxdataloc,'tmaxpctiles'));
    meanannualp99tmax_mpi_hist=f.meanannualp99tmax_mpi_hist;meanannualp95tmax_mpi_hist=f.meanannualp95tmax_mpi_hist;meanannualp90tmax_mpi_hist=f.meanannualp90tmax_mpi_hist;
    meanannualp99tmax_mpi_fut=f.meanannualp99tmax_mpi_fut;meanannualp95tmax_mpi_fut=f.meanannualp95tmax_mpi_fut;meanannualp90tmax_mpi_fut=f.meanannualp90tmax_mpi_fut;
    f=load(strcat(tmaxdataloc,'tmaxregionaldata'));
    alldailytempbyregion_mpi_hist=f.alldailytempbyregion_mpi_hist;alldailytempbyregion_mpi_fut=f.alldailytempbyregion_mpi_fut;
    thismonthtemp_centralus_hist=f.thismonthtemp_centralus_hist;thismonthtemp_centralus_fut=f.thismonthtemp_centralus_fut;
    f=load(strcat(tmaxdataloc,'precipregionaldata'));
    alldailyprecipbyregion_mpi_hist=f.alldailyprecipbyregion_mpi_hist;
    alldailyprecipbyregion_mpi_fut=f.alldailyprecipbyregion_mpi_fut;
    
    f=load(strcat(precipdataloc,'mpiprecipextremes_gridcelldefn'));
    probofconsecextremeprecipdays_hist_p99_2days=f.probofconsecextremeprecipdays_hist_p99_2days;
    probofconsecextremeprecipdays_fut_p99_2days=f.probofconsecextremeprecipdays_fut_p99_2days;
    probofconsecextremeprecipdays_fut_vsfut_p99_2days=f.probofconsecextremeprecipdays_fut_vsfut_p99_2days;
    probofconsecextremeprecipdays_hist_p99_3days=f.probofconsecextremeprecipdays_hist_p99_3days;
    probofconsecextremeprecipdays_fut_p99_3days=f.probofconsecextremeprecipdays_fut_p99_3days;
    probofconsecextremeprecipdays_fut_vsfut_p99_3days=f.probofconsecextremeprecipdays_fut_vsfut_p99_3days;
    probofconsecextremeprecipdays_hist_p99_5days=f.probofconsecextremeprecipdays_hist_p99_5days;
    probofconsecextremeprecipdays_fut_p99_5days=f.probofconsecextremeprecipdays_fut_p99_5days;
    probofconsecextremeprecipdays_fut_vsfut_p99_5days=f.probofconsecextremeprecipdays_fut_vsfut_p99_5days;
    probofconsecextremeprecipdays_hist_p95_2days=f.probofconsecextremeprecipdays_hist_p95_2days;
    probofconsecextremeprecipdays_fut_p95_2days=f.probofconsecextremeprecipdays_fut_p95_2days;
    probofconsecextremeprecipdays_fut_vsfut_p95_2days=f.probofconsecextremeprecipdays_fut_vsfut_p95_2days;
    probofconsecextremeprecipdays_hist_p95_3days=f.probofconsecextremeprecipdays_hist_p95_3days;
    probofconsecextremeprecipdays_fut_p95_3days=f.probofconsecextremeprecipdays_fut_p95_3days;
    probofconsecextremeprecipdays_fut_vsfut_p95_3days=f.probofconsecextremeprecipdays_fut_vsfut_p95_3days;
    probofconsecextremeprecipdays_hist_p95_5days=f.probofconsecextremeprecipdays_hist_p95_5days;
    probofconsecextremeprecipdays_fut_p95_5days=f.probofconsecextremeprecipdays_fut_p95_5days;
    probofconsecextremeprecipdays_fut_vsfut_p95_5days=f.probofconsecextremeprecipdays_fut_vsfut_p95_5days;
    probofconsecextremeprecipdays_hist_p90_2days=f.probofconsecextremeprecipdays_hist_p90_2days;
    probofconsecextremeprecipdays_fut_p90_2days=f.probofconsecextremeprecipdays_fut_p90_2days;
    probofconsecextremeprecipdays_fut_vsfut_p90_2days=f.probofconsecextremeprecipdays_fut_vsfut_p90_2days;
    probofconsecextremeprecipdays_hist_p90_3days=f.probofconsecextremeprecipdays_hist_p90_3days;
    probofconsecextremeprecipdays_fut_p90_3days=f.probofconsecextremeprecipdays_fut_p90_3days;
    probofconsecextremeprecipdays_fut_vsfut_p90_3days=f.probofconsecextremeprecipdays_fut_vsfut_p90_3days;
    probofconsecextremeprecipdays_hist_p90_5days=f.probofconsecextremeprecipdays_hist_p90_5days;
    probofconsecextremeprecipdays_fut_p90_5days=f.probofconsecextremeprecipdays_fut_p90_5days;
    probofconsecextremeprecipdays_fut_vsfut_p90_5days=f.probofconsecextremeprecipdays_fut_vsfut_p90_5days;
    
    consecprextr_hist_vsp99_2days=f.consecprextr_hist_vsp99_2days;
    consecprextr_fut_vsp99_2days=f.consecprextr_fut_vsp99_2days;
    consecprextr_fut_vsfut_vsp99_2days=f.consecprextr_fut_vsfut_vsp99_2days;
    consecprextr_hist_vsp99_3days=f.consecprextr_hist_vsp99_3days;
    consecprextr_fut_vsp99_3days=f.consecprextr_fut_vsp99_3days;
    consecprextr_fut_vsfut_vsp99_3days=f.consecprextr_fut_vsfut_vsp99_3days;
    consecprextr_hist_vsp99_5days=f.consecprextr_hist_vsp99_5days;
    consecprextr_fut_vsp99_5days=f.consecprextr_fut_vsp99_5days;
    consecprextr_fut_vsfut_vsp99_5days=f.consecprextr_fut_vsfut_vsp99_5days;
    consecprextr_hist_vsp95_2days=f.consecprextr_hist_vsp95_2days;
    consecprextr_fut_vsp95_2days=f.consecprextr_fut_vsp95_2days;
    consecprextr_fut_vsfut_vsp95_2days=f.consecprextr_fut_vsfut_vsp95_2days;
    consecprextr_hist_vsp95_3days=f.consecprextr_hist_vsp95_3days;
    consecprextr_fut_vsp95_3days=f.consecprextr_fut_vsp95_3days;
    consecprextr_fut_vsfut_vsp95_3days=f.consecprextr_fut_vsfut_vsp95_3days;
    consecprextr_hist_vsp95_5days=f.consecprextr_hist_vsp95_5days;
    consecprextr_fut_vsp95_5days=f.consecprextr_fut_vsp95_5days;
    consecprextr_fut_vsfut_vsp95_5days=f.consecprextr_fut_vsfut_vsp95_5days;
    consecprextr_hist_vsp90_2days=f.consecprextr_hist_vsp90_2days;
    consecprextr_fut_vsp90_2days=f.consecprextr_fut_vsp90_2days;
    consecprextr_fut_vsfut_vsp90_2days=f.consecprextr_fut_vsfut_vsp90_2days;
    consecprextr_hist_vsp90_3days=f.consecprextr_hist_vsp90_3days;
    consecprextr_fut_vsp90_3days=f.consecprextr_fut_vsp90_3days;
    consecprextr_fut_vsfut_vsp90_3days=f.consecprextr_fut_vsfut_vsp90_3days;
    consecprextr_hist_vsp90_5days=f.consecprextr_hist_vsp90_5days;
    consecprextr_fut_vsp90_5days=f.consecprextr_fut_vsp90_5days;
    consecprextr_fut_vsfut_vsp90_5days=f.consecprextr_fut_vsfut_vsp90_5days;

    numprextrsthisreg_hist_p99=f.numprextrsthisreg_hist_p99;
    numprextrsthisreg_fut_p99=f.numprextrsthisreg_fut_p99;
    numprextrsthisreg_fut_vsfut_p99=f.numprextrsthisreg_fut_vsfut_p99;
    numprextrsthisreg_hist_p95=f.numprextrsthisreg_hist_p95;
    numprextrsthisreg_fut_p95=f.numprextrsthisreg_fut_p95;
    numprextrsthisreg_fut_vsfut_p95=f.numprextrsthisreg_fut_vsfut_p95;
    numprextrsthisreg_hist_p90=f.numprextrsthisreg_hist_p90;
    numprextrsthisreg_fut_p90=f.numprextrsthisreg_fut_p90;
    numprextrsthisreg_fut_vsfut_p90=f.numprextrsthisreg_fut_vsfut_p90;
    
    f=load(strcat(tmaxdataloc,'mpiheatextremes_gridcelldefn'));
    probofconsecextremeheatdays_hist_p99_2days=f.probofconsecextremeheatdays_hist_p99_2days;
    probofconsecextremeheatdays_fut_p99_2days=f.probofconsecextremeheatdays_fut_p99_2days;
    probofconsecextremeheatdays_fut_vsfut_p99_2days=f.probofconsecextremeheatdays_fut_vsfut_p99_2days;
    probofconsecextremeheatdays_hist_p99_3days=f.probofconsecextremeheatdays_hist_p99_3days;
    probofconsecextremeheatdays_fut_p99_3days=f.probofconsecextremeheatdays_fut_p99_3days;
    probofconsecextremeheatdays_fut_vsfut_p99_3days=f.probofconsecextremeheatdays_fut_vsfut_p99_3days;
    probofconsecextremeheatdays_hist_p99_5days=f.probofconsecextremeheatdays_hist_p99_5days;
    probofconsecextremeheatdays_fut_p99_5days=f.probofconsecextremeheatdays_fut_p99_5days;
    probofconsecextremeheatdays_fut_vsfut_p99_5days=f.probofconsecextremeheatdays_fut_vsfut_p99_5days;
    probofconsecextremeheatdays_hist_p95_2days=f.probofconsecextremeheatdays_hist_p95_2days;
    probofconsecextremeheatdays_fut_p95_2days=f.probofconsecextremeheatdays_fut_p95_2days;
    probofconsecextremeheatdays_fut_vsfut_p95_2days=f.probofconsecextremeheatdays_fut_vsfut_p95_2days;
    probofconsecextremeheatdays_hist_p95_3days=f.probofconsecextremeheatdays_hist_p95_3days;
    probofconsecextremeheatdays_fut_p95_3days=f.probofconsecextremeheatdays_fut_p95_3days;
    probofconsecextremeheatdays_fut_vsfut_p95_3days=f.probofconsecextremeheatdays_fut_vsfut_p95_3days;
    probofconsecextremeheatdays_hist_p95_5days=f.probofconsecextremeheatdays_hist_p95_5days;
    probofconsecextremeheatdays_fut_p95_5days=f.probofconsecextremeheatdays_fut_p95_5days;
    probofconsecextremeheatdays_fut_vsfut_p95_5days=f.probofconsecextremeheatdays_fut_vsfut_p95_5days;
    probofconsecextremeheatdays_hist_p90_2days=f.probofconsecextremeheatdays_hist_p90_2days;
    probofconsecextremeheatdays_fut_p90_2days=f.probofconsecextremeheatdays_fut_p90_2days;
    probofconsecextremeheatdays_fut_vsfut_p90_2days=f.probofconsecextremeheatdays_fut_vsfut_p90_2days;
    probofconsecextremeheatdays_hist_p90_3days=f.probofconsecextremeheatdays_hist_p90_3days;
    probofconsecextremeheatdays_fut_p90_3days=f.probofconsecextremeheatdays_fut_p90_3days;
    probofconsecextremeheatdays_fut_vsfut_p90_3days=f.probofconsecextremeheatdays_fut_vsfut_p90_3days;
    probofconsecextremeheatdays_hist_p90_5days=f.probofconsecextremeheatdays_hist_p90_5days;
    probofconsecextremeheatdays_fut_p90_5days=f.probofconsecextremeheatdays_fut_p90_5days;
    probofconsecextremeheatdays_fut_vsfut_p90_5days=f.probofconsecextremeheatdays_fut_vsfut_p90_5days;
    
    consecheatextr_hist_vsp99_2days=f.consecheatextr_hist_vsp99_2days;
    consecheatextr_fut_vsp99_2days=f.consecheatextr_fut_vsp99_2days;
    consecheatextr_fut_vsfut_vsp99_2days=f.consecheatextr_fut_vsfut_vsp99_2days;
    consecheatextr_hist_vsp99_3days=f.consecheatextr_hist_vsp99_3days;
    consecheatextr_fut_vsp99_3days=f.consecheatextr_fut_vsp99_3days;
    consecheatextr_fut_vsfut_vsp99_3days=f.consecheatextr_fut_vsfut_vsp99_3days;
    consecheatextr_hist_vsp99_5days=f.consecheatextr_hist_vsp99_5days;
    consecheatextr_fut_vsp99_5days=f.consecheatextr_fut_vsp99_5days;
    consecheatextr_fut_vsfut_vsp99_5days=f.consecheatextr_fut_vsfut_vsp99_5days;
    consecheatextr_hist_vsp95_2days=f.consecheatextr_hist_vsp95_2days;
    consecheatextr_fut_vsp95_2days=f.consecheatextr_fut_vsp95_2days;
    consecheatextr_fut_vsfut_vsp95_2days=f.consecheatextr_fut_vsfut_vsp95_2days;
    consecheatextr_hist_vsp95_3days=f.consecheatextr_hist_vsp95_3days;
    consecheatextr_fut_vsp95_3days=f.consecheatextr_fut_vsp95_3days;
    consecheatextr_fut_vsfut_vsp95_3days=f.consecheatextr_fut_vsfut_vsp95_3days;
    consecheatextr_hist_vsp95_5days=f.consecheatextr_hist_vsp95_5days;
    consecheatextr_fut_vsp95_5days=f.consecheatextr_fut_vsp95_5days;
    consecheatextr_fut_vsfut_vsp95_5days=f.consecheatextr_fut_vsfut_vsp95_5days;
    consecheatextr_hist_vsp90_2days=f.consecheatextr_hist_vsp90_2days;
    consecheatextr_fut_vsp90_2days=f.consecheatextr_fut_vsp90_2days;
    consecheatextr_fut_vsfut_vsp90_2days=f.consecheatextr_fut_vsfut_vsp90_2days;
    consecheatextr_hist_vsp90_3days=f.consecheatextr_hist_vsp90_3days;
    consecheatextr_fut_vsp90_3days=f.consecheatextr_fut_vsp90_3days;
    consecheatextr_fut_vsfut_vsp90_3days=f.consecheatextr_fut_vsfut_vsp90_3days;
    consecheatextr_hist_vsp90_5days=f.consecheatextr_hist_vsp90_5days;
    consecheatextr_fut_vsp90_5days=f.consecheatextr_fut_vsp90_5days;
    consecheatextr_fut_vsfut_vsp90_5days=f.consecheatextr_fut_vsfut_vsp90_5days;

    numheatextrsthisreg_hist_p99=f.numheatextrsthisreg_hist_p99;
    numheatextrsthisreg_fut_p99=f.numheatextrsthisreg_fut_p99;
    numheatextrsthisreg_fut_vsfut_p99=f.numheatextrsthisreg_fut_vsfut_p99;
    numheatextrsthisreg_hist_p95=f.numheatextrsthisreg_hist_p95;
    numheatextrsthisreg_fut_p95=f.numheatextrsthisreg_fut_p95;
    numheatextrsthisreg_fut_vsfut_p95=f.numheatextrsthisreg_fut_vsfut_p95;
    numheatextrsthisreg_hist_p90=f.numheatextrsthisreg_hist_p90;
    numheatextrsthisreg_fut_p90=f.numheatextrsthisreg_fut_p90;
    numheatextrsthisreg_fut_vsfut_p90=f.numheatextrsthisreg_fut_vsfut_p90;
    
    f=load(strcat(tmaxdataloc,'tmaxregionaldata_merra2'));
    alldailytempbyregion_reana_hist=f.alldailytempbyregion_reana_hist;
    thismonthtemp_centralus_reana_hist=f.thismonthtemp_centralus_reana_hist;
    
    f=load(strcat(precipdataloc,'precipregionaldata_merra2'));
    alldailyprecipbyregion_reana_hist=f.alldailyprecipbyregion_reana_hist;
    
    f=load(strcat(tmaxdataloc,'failures_hist_reana'));
    failures_hist_reana=f.failures_hist_reana;
end





gpcplsmask_181x360=ncread(strcat(icloud,'General_Academics/Research/KeyFiles/lsmask1by1.nc'),'lsm')';
gpcplsmask_181x360=[gpcplsmask_181x360(:,181:360) gpcplsmask_181x360(:,1:180)];
lat_181x360=90:-1:-90;lon_181x360=-179.5:1:179.5;
for i=1:181
    for j=1:360
        lats_181x360(i,j)=lat_181x360(i);lons_181x360(i,j)=lon_181x360(j);
    end
end
    
X=lons_181x360;Y=lats_181x360;V=gpcplsmask_181x360;Xq=gpcplons;Yq=gpcplats;
    gpcplsmask=interp2(X,Y,V,Xq,Yq);gpcplsmask60n60s=gpcplsmask(31:149,:);
X=gpcplons60n60s;Y=fliplr(gpcplats60n60s);V=gpcplsmask60n60s;Xq=mpilons;Yq=mpilats;
    mpilsmask=interp2(X,Y,V,Xq,Yq);anywater=mpilsmask<1;mpilsmask(anywater)=0;
iswater=mpilsmask<1;iswater(:,1)=1;


%Calculate percentiles for precip
if calcprecippercentiles_mpi==1
    clear meanannualp99precip_mpi;clear meanannualp95precip_mpi;clear meanannualp90precip_mpi;clear meanannualp75precip_mpi;clear meanannualp50precip_mpi;clear meanannualmaxprecip_mpi;
    clear maxdaysabovep99precip_mpi;
    for memnum=201:300
        thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
            'precip',[1 1 51500],[192 64 10958]);
        curyear=1991;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
        clear annualp99;clear annualp95;clear annualp90;clear annualp75;clear annualp50;clear annualmax;
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                annualmax(:,:,curyear-1990)=max(thisfile(:,:,i-thisyearlen+1:i),[],3);
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        meanannualmaxprecip_mpi(memnum-200,:,:)=squeeze(mean(annualmax,3))';
        meanannualp99precip_mpi(memnum-200,:,:)=squeeze(quantile(thisfile,0.99,3))';
        meanannualp95precip_mpi(memnum-200,:,:)=squeeze(quantile(thisfile,0.95,3))';
        meanannualp90precip_mpi(memnum-200,:,:)=squeeze(quantile(thisfile,0.90,3))';
        meanannualp75precip_mpi(memnum-200,:,:)=squeeze(quantile(thisfile,0.75,3))';
        meanannualp50precip_mpi(memnum-200,:,:)=squeeze(quantile(thisfile,0.50,3))';
        
        
        %For more verification: get max days above p99 in a 30-day period
        maxdaysabovep99=zeros(size(meanannualp99precip_mpi,2),size(meanannualp99precip_mpi,3));
        for i=30:size(thisfile,3)
            thisdata=permute(thisfile(:,:,i-29:i),[3 1 2]);
            numdaysabovep99here=zeros(size(meanannualp99precip_mpi,2),size(meanannualp99precip_mpi,3));
            for iwithin=1:30
                numdaysabovep99here=numdaysabovep99here+double(squeeze(thisdata(iwithin,:,:))'>=squeeze(meanannualp99precip_mpi(memnum-200,:,:)));
            end
            maxdaysabovep99=max(maxdaysabovep99,numdaysabovep99here);
        end
        maxdaysabovep99precip_mpi(memnum-200,:,:)=maxdaysabovep99;
        
        
        if rem(memnum,10)==0;disp(memnum);end
    end
    maxdaysabovep99_mpi_mean=squeeze(mean(maxdaysabovep99precip_mpi));
    invalid=maxdaysabovep99_mpi_mean==0;maxdaysabovep99_mpi_mean(invalid)=NaN;
    save(strcat(precipdataloc,'percentilethreshold.mat'),...
        'meanannualp99precip_mpi','meanannualp95precip_mpi','meanannualp90precip_mpi','meanannualp75precip_mpi',...
        'meanannualp50precip_mpi','meanannualmaxprecip_mpi','maxdaysabovep99precip_mpi_mean');
end



  
%Compare against CHIRPS
if calcprecippercentiles_chirps==1
    clear annualp95_chirps;clear annualp90_chirps;clear annualp75_chirps;clear annualp50_chirps;
    clear allyearsdata;
    allyearsdata_chirps_interp=NaN.*ones(365,30,192,64);
    startyear=1991;stopyear=2020;
    for year=startyear:stopyear
        thisfile=ncread(strcat('/Volumes/ExternalDriveC/CHIRPS_Precipitation/chirps-v2.0.',num2str(year),'.days_p25.nc'),'precip');
        annualp95_chirps(:,:,year-1990)=flipud(quantile(thisfile,0.95,3)');
        annualp90_chirps(:,:,year-1990)=flipud(quantile(thisfile,0.90,3)');
        annualp75_chirps(:,:,year-1990)=flipud(quantile(thisfile,0.75,3)');
        annualp50_chirps(:,:,year-1990)=flipud(quantile(thisfile,0.50,3)');
        
        if year==startyear
            lat_chirps=ncread(strcat('/Volumes/ExternalDriveC/CHIRPS_Precipitation/chirps-v2.0.',num2str(year),'.days_p25.nc'),'latitude');
            lon_chirps=ncread(strcat('/Volumes/ExternalDriveC/CHIRPS_Precipitation/chirps-v2.0.',num2str(year),'.days_p25.nc'),'longitude');
            for i=1:size(lat_chirps,1)
                for j=1:size(lon_chirps,1)
                    lats_chirps(i,j)=lat_chirps(i);lons_chirps(i,j)=lon_chirps(j);
                end
            end
            lats_chirps=flipud(lats_chirps);
        end
        
        %Interpolate right now, otherwise all-data array would be enormous and Matlab would crash
        X=lons_chirps;Y=lats_chirps;Xq=mpilons;Yq=mpilats;
        for doy=1:365
            V=squeeze(thisfile(:,:,doy));allyearsdata_chirps_interp(doy,year-(startyear-1),:,:)=squeeze(interp2(X,Y,V',Xq,Yq)');
        end
        if rem(year,5)==0;disp(year);disp(clock);end
    end

    clear meanannualp99_chirps_interp;clear meanannualp95_chirps_interp;
    tmp=reshape(allyearsdata_chirps_interp,[365*30 192 64]);
    for i=1:192;for j=1:64;meanannualp99_chirps_interp(i,j)=squeeze(quantile(tmp(:,i,j),0.99));end;end
        figure(207);clf;imagescnan(flipud(meanannualp99_chirps_interp'));colorbar;
    for i=1:192;for j=1:64;meanannualp95_chirps_interp(i,j)=squeeze(quantile(tmp(:,i,j),0.95));end;end
        figure(208);clf;imagescnan(flipud(meanannualp95_chirps_interp'));colorbar;
    
    meanannualp99_chirps_interp=flipud(meanannualp99_chirps_interp');meanannualp95_chirps_interp=flipud(meanannualp95_chirps_interp');
    save(strcat(precipdataloc,'percentilethreshold_chirps.mat'),'meanannualp99_chirps_interp','meanannualp95_chirps_interp');

    figure(989);clf;curpart=1;highqualityfiguresetup;
    data={mpilats;mpilons;meanannualp95_chirps_interp};
    vararginnew={'underlayvariable';'wet-bulb temp';'contour';0;...
    'underlaycaxismin';0;'underlaycaxismax';80;'mystepunderlay';5;'overlaynow';0;'datatounderlay';data;'conttoplot';'all';'stateboundaries';0;'nonewfig';1};
    datatype='custom';region='world';
    plotModelData(data,region,vararginnew,datatype);
    colormap(colormaps('q','more','not'));
    figname='chirpsannualp95';curpart=2;highqualityfiguresetup;
    
    
    allyearsdata_chirps_3d=reshape(allyearsdata_chirps_interp,[30*365 192 64]);
    numvalidchirps=squeeze(sum(~isnan(allyearsdata_chirps_3d)));
    invalid=numvalidchirps==0;numvalidchirps(invalid)=NaN;
    
    
    %Ensure that all arrays are rotated to standard orientation, then save
    for doy=1:365
        for y=1:30
            tmp=squeeze(allyearsdata_chirps_interp(doy,y,:,:));
            allyearsdata_chirps(doy,y,:,:)=flipud(tmp');
        end
    end
    save(strcat(precipdataloc,'dailyprecipdata_chirps.mat'),'allyearsdata_chirps');
    
    disp('Finished CHIRPS');disp(clock);
end




%Useful for both precip and drought portions
%Historical: 1991-2020
%Future: 2070-2099
if readallprecipdata_mpi==1
    alldailyprecipbymonth_mpi_hist=NaN.*ones(memstodo,192,64,31,30,12);
    meanannualp99precip_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp99precip_mpi_fut=NaN.*ones(memstodo,192,64);
    meanannualp95precip_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp95precip_mpi_fut=NaN.*ones(memstodo,192,64);
    meanannualp90precip_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp90precip_mpi_fut=NaN.*ones(memstodo,192,64);
    meanannualp25precip_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp25precip_mpi_fut=NaN.*ones(memstodo,192,64);
    meanannualp10precip_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp10precip_mpi_fut=NaN.*ones(memstodo,192,64);
    meanannualp99precipNOZEROS_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp99precipNOZEROS_mpi_fut=NaN.*ones(memstodo,192,64);
    meanannualp95precipNOZEROS_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp95precipNOZEROS_mpi_fut=NaN.*ones(memstodo,192,64);
    meanannualp90precipNOZEROS_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp90precipNOZEROS_mpi_fut=NaN.*ones(memstodo,192,64);
    for memnum=201:200+memstodo
        thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
            'precip',[1 1 51500],[192 64 10958]);
        curyear=1991;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
        
        meanannualp99precip_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfile,0.99,3));
        meanannualp95precip_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfile,0.95,3));
        meanannualp90precip_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfile,0.90,3));
        meanannualp25precip_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfile,0.25,3));
        meanannualp10precip_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfile,0.10,3));
        
        thisfileNOZEROS=thisfile;zerostoremove=thisfile<0.001;thisfileNOZEROS(zerostoremove)=NaN;
        meanannualp99precipNOZEROS_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfileNOZEROS,0.99,3));
        meanannualp95precipNOZEROS_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfileNOZEROS,0.95,3));
        meanannualp90precipNOZEROS_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfileNOZEROS,0.90,3));
        
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,1)=thisfile(:,:,i-364:i-334);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:28,curyear-1990,2)=thisfile(:,:,i-333:i-306);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,3)=thisfile(:,:,i-305:i-275);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:30,curyear-1990,4)=thisfile(:,:,i-274:i-245);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,5)=thisfile(:,:,i-244:i-214);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:30,curyear-1990,6)=thisfile(:,:,i-213:i-184);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,7)=thisfile(:,:,i-183:i-153);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,8)=thisfile(:,:,i-152:i-122);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:30,curyear-1990,9)=thisfile(:,:,i-121:i-92);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,10)=thisfile(:,:,i-91:i-61);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:30,curyear-1990,11)=thisfile(:,:,i-60:i-31);
                alldailyprecipbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,12)=thisfile(:,:,i-30:i);
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
    end
    
    alldailyprecipbymonth_mpi_fut=NaN.*ones(memstodo,192,64,31,30,12);
    for memnum=201:200+memstodo
        thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
            'precip',[1 1 80355],[192 64 10957]);
        curyear=2070;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
        
        meanannualp99precip_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfile,0.99,3));
        meanannualp95precip_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfile,0.95,3));
        meanannualp90precip_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfile,0.90,3));
        meanannualp25precip_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfile,0.25,3));
        meanannualp10precip_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfile,0.10,3));
        
        thisfileNOZEROS=thisfile;zerostoremove=thisfile<0.001;thisfileNOZEROS(zerostoremove)=NaN;
        meanannualp99precipNOZEROS_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfileNOZEROS,0.99,3));
        meanannualp95precipNOZEROS_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfileNOZEROS,0.95,3));
        meanannualp90precipNOZEROS_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfileNOZEROS,0.90,3));
        
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,1)=thisfile(:,:,i-364:i-334);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:28,curyear-2069,2)=thisfile(:,:,i-333:i-306);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,3)=thisfile(:,:,i-305:i-275);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:30,curyear-2069,4)=thisfile(:,:,i-274:i-245);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,5)=thisfile(:,:,i-244:i-214);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:30,curyear-2069,6)=thisfile(:,:,i-213:i-184);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,7)=thisfile(:,:,i-183:i-153);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,8)=thisfile(:,:,i-152:i-122);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:30,curyear-2069,9)=thisfile(:,:,i-121:i-92);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,10)=thisfile(:,:,i-91:i-61);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:30,curyear-2069,11)=thisfile(:,:,i-60:i-31);
                alldailyprecipbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,12)=thisfile(:,:,i-30:i);
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
    end
    
    save(strcat(precipdataloc,'precippctiles'),'meanannualp99precip_mpi_hist','meanannualp95precip_mpi_hist','meanannualp90precip_mpi_hist',...
        'meanannualp25precip_mpi_hist','meanannualp10precip_mpi_hist',...
        'meanannualp99precip_mpi_fut','meanannualp95precip_mpi_fut','meanannualp90precip_mpi_fut',...
        'meanannualp25precip_mpi_fut','meanannualp10precip_mpi_fut',...
        'meanannualp99precipNOZEROS_mpi_hist','meanannualp95precipNOZEROS_mpi_hist','meanannualp90precipNOZEROS_mpi_hist',...
        'meanannualp99precipNOZEROS_mpi_fut','meanannualp95precipNOZEROS_mpi_fut','meanannualp90precipNOZEROS_mpi_fut','-append');
end




if defineextremeprecipandcompounding_mpi_all100ensmems==1
    %Get historical and future annual p99, p95, and p90 precip
    p99precipthreshannual_mpi_hist=squeeze(mean(meanannualp99precip_mpi_hist))';
    p95precipthreshannual_mpi_hist=squeeze(mean(meanannualp95precip_mpi_hist))';
    p90precipthreshannual_mpi_hist=squeeze(mean(meanannualp90precip_mpi_hist))';
    p99precipthreshannual_mpi_fut=squeeze(mean(meanannualp99precip_mpi_fut))';
    p95precipthreshannual_mpi_fut=squeeze(mean(meanannualp95precip_mpi_fut))';
    p90precipthreshannual_mpi_fut=squeeze(mean(meanannualp90precip_mpi_fut))';
    
    p99precipthreshannualNOZEROS_mpi_hist=squeeze(mean(meanannualp99precipNOZEROS_mpi_hist))';
    p95precipthreshannualNOZEROS_mpi_hist=squeeze(mean(meanannualp95precipNOZEROS_mpi_hist))';
    p90precipthreshannualNOZEROS_mpi_hist=squeeze(mean(meanannualp90precipNOZEROS_mpi_hist))';
    p99precipthreshannualNOZEROS_mpi_fut=squeeze(mean(meanannualp99precipNOZEROS_mpi_fut))';
    p95precipthreshannualNOZEROS_mpi_fut=squeeze(mean(meanannualp95precipNOZEROS_mpi_fut))';
    p90precipthreshannualNOZEROS_mpi_fut=squeeze(mean(meanannualp90precipNOZEROS_mpi_fut))';
        
    

    %Find gridpoints above the historical ANNUAL p99 or p95
    %Use these to calculate compounding
    extremeprecip_mpi_hist=NaN.*ones(size(alldailyprecipbymonth_mpi_hist));extremeprecip_mpi_fut=NaN.*ones(size(alldailyprecipbymonth_mpi_fut));
    extremeprecip_mpi_fut_vsfut=NaN.*ones(size(alldailyprecipbymonth_mpi_fut));
    consecprextr_hist_vsp99_2days=zeros(100,365,numregs);consecprextr_hist_vsp99_3days=zeros(100,365,numregs);consecprextr_hist_vsp99_5days=zeros(100,365,numregs);
    consecprextr_hist_vsp95_2days=zeros(100,365,numregs);consecprextr_hist_vsp95_3days=zeros(100,365,numregs);consecprextr_hist_vsp95_5days=zeros(100,365,numregs);
    consecprextr_hist_vsp90_2days=zeros(100,365,numregs);consecprextr_hist_vsp90_3days=zeros(100,365,numregs);consecprextr_hist_vsp90_5days=zeros(100,365,numregs);
    consecprextr_fut_vsp99_2days=zeros(100,365,numregs);consecprextr_fut_vsp99_3days=zeros(100,365,numregs);consecprextr_fut_vsp99_5days=zeros(100,365,numregs);
    consecprextr_fut_vsp95_2days=zeros(100,365,numregs);consecprextr_fut_vsp95_3days=zeros(100,365,numregs);consecprextr_fut_vsp95_5days=zeros(100,365,numregs);
    consecprextr_fut_vsp90_2days=zeros(100,365,numregs);consecprextr_fut_vsp90_3days=zeros(100,365,numregs);consecprextr_fut_vsp90_5days=zeros(100,365,numregs);
    consecprextr_fut_vsfut_vsp99_2days=zeros(100,365,numregs);consecprextr_fut_vsfut_vsp99_3days=zeros(100,365,numregs);consecprextr_fut_vsfut_vsp99_5days=zeros(100,365,numregs);
    consecprextr_fut_vsfut_vsp95_2days=zeros(100,365,numregs);consecprextr_fut_vsfut_vsp95_3days=zeros(100,365,numregs);consecprextr_fut_vsfut_vsp95_5days=zeros(100,365,numregs);
    consecprextr_fut_vsfut_vsp90_2days=zeros(100,365,numregs);consecprextr_fut_vsfut_vsp90_3days=zeros(100,365,numregs);consecprextr_fut_vsfut_vsp90_5days=zeros(100,365,numregs);

    consecprextr_hist_vsp95NOZEROS_3days=zeros(100,365,numregs);
    consecprextr_fut_vsp95NOZEROS_3days=zeros(100,365,numregs);
    consecprextr_fut_vsfut_vsp95NOZEROS_3days=zeros(100,365,numregs);
    
    for memnum=201:300
        thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
                    'precip',[1 1 51500],[192 64 10958]);
                thisfile=permute(thisfile,[2 1 3]);
        curyear=1991;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                
        temporaryhist_vsp99=NaN.*ones(30,64,192,365);temporaryhist_vsp95=NaN.*ones(30,64,192,365);temporaryhist_vsp90=NaN.*ones(30,64,192,365);
        temporaryhistNOZEROS_vsp99=NaN.*ones(30,64,192,365);temporaryhistNOZEROS_vsp95=NaN.*ones(30,64,192,365);temporaryhistNOZEROS_vsp90=NaN.*ones(30,64,192,365);
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                temporaryhistNOZEROS_vsp99(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p99precipthreshannualNOZEROS_mpi_hist;
                temporaryhistNOZEROS_vsp95(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p95precipthreshannualNOZEROS_mpi_hist;    
                temporaryhistNOZEROS_vsp90(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p90precipthreshannualNOZEROS_mpi_hist; 
                temporaryhist_vsp99(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p99precipthreshannual_mpi_hist;
                temporaryhist_vsp95(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p95precipthreshannual_mpi_hist;    
                temporaryhist_vsp90(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p90precipthreshannual_mpi_hist;   
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
        
        
        for k=2:size(temporaryhist_vsp99,4)
            tmp=squeeze(sum(temporaryhist_vsp99(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp99_2days(memnum-200,k,thisreg)=consecprextr_hist_vsp99_2days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==2));
            end
            tmp=squeeze(sum(temporaryhist_vsp95(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp95_2days(memnum-200,k,thisreg)=consecprextr_hist_vsp95_2days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==2));
            end
            tmp=squeeze(sum(temporaryhist_vsp90(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp90_2days(memnum-200,k,thisreg)=consecprextr_hist_vsp90_2days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==2));
            end
        end
        
        for k=3:size(temporaryhist_vsp99,4)
            tmp=squeeze(sum(temporaryhist_vsp99(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp99_3days(memnum-200,k,thisreg)=consecprextr_hist_vsp99_3days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==3));
            end
            tmp=squeeze(sum(temporaryhist_vsp95(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp95_3days(memnum-200,k,thisreg)=consecprextr_hist_vsp95_3days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==3));
            end
            tmp=squeeze(sum(temporaryhistNOZEROS_vsp95(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp95NOZEROS_3days(memnum-200,k,thisreg)=consecprextr_hist_vsp95NOZEROS_3days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==3));
            end
            tmp=squeeze(sum(temporaryhist_vsp90(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp90_3days(memnum-200,k,thisreg)=consecprextr_hist_vsp90_3days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==3));
            end
        end
        
        for k=5:size(temporaryhist_vsp99,4)
            tmp=squeeze(sum(temporaryhist_vsp99(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp99_5days(memnum-200,k,thisreg)=consecprextr_hist_vsp99_5days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==5));
            end
            tmp=squeeze(sum(temporaryhist_vsp95(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp95_5days(memnum-200,k,thisreg)=consecprextr_hist_vsp95_5days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==5));
            end
            tmp=squeeze(sum(temporaryhist_vsp90(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecprextr_hist_vsp90_5days(memnum-200,k,thisreg)=consecprextr_hist_vsp90_5days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==5));
            end
        end
        
        
        
                
        thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
                    'precip',[1 1 80355],[192 64 10957]);       
                thisfile=permute(thisfile,[2 1 3]);
        curyear=2070;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end                
                
        temporaryfut_vshistNOZEROS_vsp99=NaN.*ones(30,64,192,365);temporaryfut_vshistNOZEROS_vsp95=NaN.*ones(30,64,192,365);temporaryfut_vshistNOZEROS_vsp90=NaN.*ones(30,64,192,365);
        temporaryfut_vsfutNOZEROS_vsp99=NaN.*ones(30,64,192,365);temporaryfut_vsfutNOZEROS_vsp95=NaN.*ones(30,64,192,365);temporaryfut_vsfutNOZEROS_vsp90=NaN.*ones(30,64,192,365);
        temporaryfut_vshist_vsp99=NaN.*ones(30,64,192,365);temporaryfut_vshist_vsp95=NaN.*ones(30,64,192,365);temporaryfut_vshist_vsp90=NaN.*ones(30,64,192,365);
        temporaryfut_vsfut_vsp99=NaN.*ones(30,64,192,365);temporaryfut_vsfut_vsp95=NaN.*ones(30,64,192,365);temporaryfut_vsfut_vsp90=NaN.*ones(30,64,192,365);
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                temporaryfut_vshistNOZEROS_vsp99(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p99precipthreshannualNOZEROS_mpi_hist;
                temporaryfut_vsfutNOZEROS_vsp99(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p99precipthreshannualNOZEROS_mpi_fut;
                temporaryfut_vshistNOZEROS_vsp95(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p95precipthreshannualNOZEROS_mpi_hist;
                temporaryfut_vsfutNOZEROS_vsp95(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p95precipthreshannualNOZEROS_mpi_fut;
                temporaryfut_vshistNOZEROS_vsp90(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p90precipthreshannualNOZEROS_mpi_hist;
                temporaryfut_vsfutNOZEROS_vsp90(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p90precipthreshannualNOZEROS_mpi_fut;
                temporaryfut_vshist_vsp99(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p99precipthreshannual_mpi_hist;
                temporaryfut_vsfut_vsp99(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p99precipthreshannual_mpi_fut;
                temporaryfut_vshist_vsp95(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p95precipthreshannual_mpi_hist;
                temporaryfut_vsfut_vsp95(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p95precipthreshannual_mpi_fut;
                temporaryfut_vshist_vsp90(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p90precipthreshannual_mpi_hist;
                temporaryfut_vsfut_vsp90(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p90precipthreshannual_mpi_fut;
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
        
        
        for k=2:size(temporaryfut_vshist_vsp99,4)
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp99(:,:,:,k-1:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp99(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp99_2days(memnum-200,k,thisreg)=consecprextr_fut_vsp99_2days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==2));
                consecprextr_fut_vsfut_vsp99_2days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp99_2days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==2));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp95(:,:,:,k-1:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp95(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp95_2days(memnum-200,k,thisreg)=consecprextr_fut_vsp95_2days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==2));
                consecprextr_fut_vsfut_vsp95_2days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp95_2days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==2));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp90(:,:,:,k-1:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp90(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp90_2days(memnum-200,k,thisreg)=consecprextr_fut_vsp90_2days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==2));
                consecprextr_fut_vsfut_vsp90_2days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp90_2days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==2));
            end
        end
        
        for k=3:size(temporaryfut_vshist_vsp99,4)
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp99(:,:,:,k-2:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp99(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp99_3days(memnum-200,k,thisreg)=consecprextr_fut_vsp99_3days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==3));
                consecprextr_fut_vsfut_vsp99_3days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp99_3days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==3));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp95(:,:,:,k-2:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp95(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp95_3days(memnum-200,k,thisreg)=consecprextr_fut_vsp95_3days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==3));
                consecprextr_fut_vsfut_vsp95_3days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp95_3days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==3));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshistNOZEROS_vsp95(:,:,:,k-2:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfutNOZEROS_vsp95(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp95NOZEROS_3days(memnum-200,k,thisreg)=consecprextr_fut_vsp95NOZEROS_3days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==3));
                consecprextr_fut_vsfut_vsp95NOZEROS_3days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp95NOZEROS_3days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==3));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp90(:,:,:,k-2:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp90(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp90_3days(memnum-200,k,thisreg)=consecprextr_fut_vsp90_3days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==3));
                consecprextr_fut_vsfut_vsp90_3days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp90_3days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==3));
            end
        end
        
        for k=5:size(temporaryfut_vshist_vsp99,4)
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp99(:,:,:,k-4:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp99(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp99_5days(memnum-200,k,thisreg)=consecprextr_fut_vsp99_5days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==5));
                consecprextr_fut_vsfut_vsp99_5days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp99_5days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==5));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp95(:,:,:,k-4:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp95(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp95_5days(memnum-200,k,thisreg)=consecprextr_fut_vsp95_5days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==5));
                consecprextr_fut_vsfut_vsp95_5days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp95_5days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==5));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp90(:,:,:,k-4:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp90(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecprextr_fut_vsp90_5days(memnum-200,k,thisreg)=consecprextr_fut_vsp90_5days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==5));
                consecprextr_fut_vsfut_vsp90_5days(memnum-200,k,thisreg)=consecprextr_fut_vsfut_vsp90_5days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==5));
            end
        end

        disp(memnum-200);disp(clock);
        
        
        %Historical and future probabilities that an extreme-precip day is part of a compound extreme-precip event
        for reg=1:numregs
            numprextrsthisreg_hist_p99(memnum-200,reg)=0;numprextrsthisreg_fut_p99(memnum-200,reg)=0;numprextrsthisreg_fut_vsfut_p99(memnum-200,reg)=0;
            numprextrsthisreg_hist_p95(memnum-200,reg)=0;numprextrsthisreg_fut_p95(memnum-200,reg)=0;numprextrsthisreg_fut_vsfut_p95(memnum-200,reg)=0;
            numprextrsthisreg_hist_p90(memnum-200,reg)=0;numprextrsthisreg_fut_p90(memnum-200,reg)=0;numprextrsthisreg_fut_vsfut_p90(memnum-200,reg)=0;
            for yr=1:30
                for doy=1:365
                    tmp=squeeze(temporaryhist_vsp99(yr,:,:,doy));
                    numprextrsthisreg_hist_p99(memnum-200,reg)=numprextrsthisreg_hist_p99(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vshist_vsp99(yr,:,:,doy));
                    numprextrsthisreg_fut_p99(memnum-200,reg)=numprextrsthisreg_fut_p99(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vsfut_vsp99(yr,:,:,doy));
                    numprextrsthisreg_fut_vsfut_p99(memnum-200,reg)=numprextrsthisreg_fut_vsfut_p99(memnum-200,reg)+sum(tmp(regnums==reg));
                    
                    tmp=squeeze(temporaryhist_vsp95(yr,:,:,doy));
                    numprextrsthisreg_hist_p95(memnum-200,reg)=numprextrsthisreg_hist_p95(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vshist_vsp95(yr,:,:,doy));
                    numprextrsthisreg_fut_p95(memnum-200,reg)=numprextrsthisreg_fut_p95(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vsfut_vsp95(yr,:,:,doy));
                    numprextrsthisreg_fut_vsfut_p95(memnum-200,reg)=numprextrsthisreg_fut_vsfut_p95(memnum-200,reg)+sum(tmp(regnums==reg));
                    
                    tmp=squeeze(temporaryhist_vsp90(yr,:,:,doy));
                    numprextrsthisreg_hist_p90(memnum-200,reg)=numprextrsthisreg_hist_p90(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vshist_vsp90(yr,:,:,doy));
                    numprextrsthisreg_fut_p90(memnum-200,reg)=numprextrsthisreg_fut_p90(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vsfut_vsp90(yr,:,:,doy));
                    numprextrsthisreg_fut_vsfut_p90(memnum-200,reg)=numprextrsthisreg_fut_vsfut_p90(memnum-200,reg)+sum(tmp(regnums==reg));
                end
            end
            probofconsecextremeprecipdays_hist_p99_2days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp99_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p99(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p99_2days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp99_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p99(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p99_2days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp99_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p99(memnum-200,reg));
            
            probofconsecextremeprecipdays_hist_p99_3days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp99_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p99(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p99_3days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp99_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p99(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p99_3days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp99_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p99(memnum-200,reg));
            
            probofconsecextremeprecipdays_hist_p99_5days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp99_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p99(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p99_5days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp99_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p99(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p99_5days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp99_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p99(memnum-200,reg));
            
            
            probofconsecextremeprecipdays_hist_p95_2days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp95_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p95(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p95_2days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp95_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p95(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p95_2days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp95_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p95(memnum-200,reg));
            
            probofconsecextremeprecipdays_hist_p95_3days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp95_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p95(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p95_3days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp95_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p95(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p95_3days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp95_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p95(memnum-200,reg));
            
            probofconsecextremeprecipdays_hist_p95_5days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp95_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p95(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p95_5days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp95_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p95(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p95_5days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp95_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p95(memnum-200,reg));
            
            
            probofconsecextremeprecipdays_hist_p90_2days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp90_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p90(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p90_2days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp90_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p90(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p90_2days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp90_2days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p90(memnum-200,reg));
            
            probofconsecextremeprecipdays_hist_p90_3days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp90_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p90(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p90_3days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp90_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p90(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p90_3days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp90_3days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p90(memnum-200,reg));
            
            probofconsecextremeprecipdays_hist_p90_5days(memnum-200,reg)=sum(sum(consecprextr_hist_vsp90_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_hist_p90(memnum-200,reg));
            probofconsecextremeprecipdays_fut_p90_5days(memnum-200,reg)=sum(sum(consecprextr_fut_vsp90_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_p90(memnum-200,reg));
            probofconsecextremeprecipdays_fut_vsfut_p90_5days(memnum-200,reg)=sum(sum(consecprextr_fut_vsfut_vsp90_5days(memnum-200,:,reg)))./...
                (numprextrsthisreg_fut_vsfut_p90(memnum-200,reg));
        end
    
        if saveresult==1
        if rem(memnum,10)==0
            save(strcat(precipdataloc,'mpiprecipextremes_gridcelldefn'),...
            'probofconsecextremeprecipdays_hist_p99_2days','probofconsecextremeprecipdays_fut_p99_2days','probofconsecextremeprecipdays_fut_vsfut_p99_2days',...
            'probofconsecextremeprecipdays_hist_p99_3days','probofconsecextremeprecipdays_fut_p99_3days','probofconsecextremeprecipdays_fut_vsfut_p99_3days',...
            'probofconsecextremeprecipdays_hist_p99_5days','probofconsecextremeprecipdays_fut_p99_5days','probofconsecextremeprecipdays_fut_vsfut_p99_5days',...
            'probofconsecextremeprecipdays_hist_p95_2days','probofconsecextremeprecipdays_fut_p95_2days','probofconsecextremeprecipdays_fut_vsfut_p95_2days',...
            'probofconsecextremeprecipdays_hist_p95_3days','probofconsecextremeprecipdays_fut_p95_3days','probofconsecextremeprecipdays_fut_vsfut_p95_3days',...
            'probofconsecextremeprecipdays_hist_p95_5days','probofconsecextremeprecipdays_fut_p95_5days','probofconsecextremeprecipdays_fut_vsfut_p95_5days',...
            'probofconsecextremeprecipdays_hist_p90_2days','probofconsecextremeprecipdays_fut_p90_2days','probofconsecextremeprecipdays_fut_vsfut_p90_2days',...
            'probofconsecextremeprecipdays_hist_p90_3days','probofconsecextremeprecipdays_fut_p90_3days','probofconsecextremeprecipdays_fut_vsfut_p90_3days',...
            'probofconsecextremeprecipdays_hist_p90_5days','probofconsecextremeprecipdays_fut_p90_5days','probofconsecextremeprecipdays_fut_vsfut_p90_5days',...
            'consecprextr_hist_vsp99_2days','consecprextr_fut_vsp99_2days','consecprextr_fut_vsfut_vsp99_2days',...
            'consecprextr_hist_vsp99_3days','consecprextr_fut_vsp99_3days','consecprextr_fut_vsfut_vsp99_3days',...
            'consecprextr_hist_vsp99_5days','consecprextr_fut_vsp99_5days','consecprextr_fut_vsfut_vsp99_5days',...
            'consecprextr_hist_vsp95_2days','consecprextr_fut_vsp95_2days','consecprextr_fut_vsfut_vsp95_2days',...
            'consecprextr_hist_vsp95_3days','consecprextr_fut_vsp95_3days','consecprextr_fut_vsfut_vsp95_3days',...
            'consecprextr_hist_vsp95_5days','consecprextr_fut_vsp95_5days','consecprextr_fut_vsfut_vsp95_5days',...
            'consecprextr_hist_vsp90_2days','consecprextr_fut_vsp90_2days','consecprextr_fut_vsfut_vsp90_2days',...
            'consecprextr_hist_vsp90_3days','consecprextr_fut_vsp90_3days','consecprextr_fut_vsfut_vsp90_3days',...
            'consecprextr_hist_vsp90_5days','consecprextr_fut_vsp90_5days','consecprextr_fut_vsfut_vsp90_5days',...
            'numprextrsthisreg_hist_p99','numprextrsthisreg_fut_p99','numprextrsthisreg_fut_vsfut_p99',...
            'numprextrsthisreg_hist_p95','numprextrsthisreg_fut_p95','numprextrsthisreg_fut_vsfut_p95',...
            'numprextrsthisreg_hist_p90','numprextrsthisreg_fut_p90','numprextrsthisreg_fut_vsfut_p90',...
            '-v7.3');
        end
        end
    end
end



if defineextremeprecipcompounding_chirps==1
    %Get historical extreme thresholds
    tmp=reshape(allyearsdata_chirps,[365*40 64 192]);
    tmpNOZEROS=tmp;invalid=tmp<0.001;tmpNOZEROS(invalid)=NaN;
    p95precipthreshannualNOZEROS_chirps_hist=squeeze(quantile(tmpNOZEROS,0.95));
    p95precipthreshannual_chirps_hist=squeeze(quantile(tmp,0.95));
    
    %Find exceedances
    precipp95_chirps_hist=NaN.*ones(size(allyearsdata_chirps));precipp95_chirps_histNOZEROS=NaN.*ones(size(allyearsdata_chirps));
    for i=1:365
        for j=11:40
            precipp95_chirps_histNOZEROS(i,j,:,:)=squeeze(allyearsdata_chirps(i,j,:,:))>=p95precipthreshannualNOZEROS_chirps_hist;
            precipp95_chirps_hist(i,j,:,:)=squeeze(allyearsdata_chirps(i,j,:,:))>=p95precipthreshannual_chirps_hist;
        end
    end
    precipp95_chirps_histNOZEROS=precipp95_chirps_histNOZEROS(:,11:40,:,:);
    precipp95_chirps_hist=precipp95_chirps_hist(:,11:40,:,:);
    
    regnums_precip=regnums;
    invalid=p95precipthreshannual_chirps_hist==0;regnums_precip(invalid)=NaN;
    regnums_precip_chirps=regnums_precip;
    invalid=(isnan(p95precipthreshannual_chirps_hist));regnums_precip_chirps(invalid)=NaN;
    
    %Find consecutive extremes (CHIRPS)
    consecprextr_hist_vsp95_3days_chirpsNOZEROS=zeros(365,numregs);consecprextr_hist_vsp95_3days_chirps=zeros(365,numregs);
    for k=3:365
        tmpNOZEROS=squeeze(sum(precipp95_chirps_histNOZEROS(k-2:k,:,:,:),1));tmp=squeeze(sum(precipp95_chirps_hist(k-2:k,:,:,:),1));
        for thisreg=1:numregs
            consecprextr_hist_vsp95_3days_chirpsNOZEROS(k,thisreg)=...
                consecprextr_hist_vsp95_3days_chirpsNOZEROS(k,thisreg)+sum(sum(tmpNOZEROS(:,regnums_precip==thisreg)==3));
            consecprextr_hist_vsp95_3days_chirps(k,thisreg)=...
                consecprextr_hist_vsp95_3days_chirps(k,thisreg)+sum(sum(tmp(:,regnums_precip==thisreg)==3));
        end
    end
    
    %Historical probabilities that an extreme-precip day is part of a
    %compound extreme-precip event (CHIRPS)
    continueon=0;
    if continueon==1
    numprextrsthisreg_hist_p95_chirps=zeros(numregs,1);
    for reg=1:numregs
        for yr=1:30
            for doy=1:365
                tmp=squeeze(precipp95_chirps_hist(yr,:,:,doy));
                numprextrsthisreg_hist_p95_chirps(reg)=numprextrsthisreg_hist_p95_chirps(reg)+sum(tmp(regnums_precip==reg));
            end
        end
        probofconsecextremeprecipdays_hist_p95_3days_chirps(reg)=sum(sum(consecprextr_hist_vsp95_3days_chirpsNOZEROS(:,reg)))./...
            (numprextrsthisreg_hist_p95_chirps(reg));
    end
    end
end

     
     
%Evaluate drought and extreme precip over water years, not calendar years
%Water years are defined as the 6 consecutive months with the highest mean integrated precip at a location
%Drought is bottom 10% of integrated precip, extreme precip is top 10%
if volatilityanalysisanddroughtdefn_mpi==1
    %Determine the water year for each gridpt
    beststartmonth=NaN.*ones(192,64);
    for i=1:numlons
        for j=1:numlats
            mostsofar=0;
            for trialwystart=1:12
                for ensmem=1:1
                    if trialwystart<=7
                        trialprecipsum=sum(sum(sum(alldailyprecipbymonth_mpi_hist(ensmem,i,j,:,:,trialwystart:trialwystart+5),'omitnan'),'omitnan'),'omitnan');
                    else
                        p1=squeeze(sum(sum(sum(alldailyprecipbymonth_mpi_hist(ensmem,i,j,:,:,trialwystart:12),'omitnan'),'omitnan'),'omitnan'));
                        p2=squeeze(sum(sum(sum(alldailyprecipbymonth_mpi_hist(ensmem,i,j,:,:,1:trialwystart-7),'omitnan'),'omitnan'),'omitnan'));
                        trialprecipsum=p1+p2;
                    end
                    if trialprecipsum>mostsofar
                        mostsofar=trialprecipsum;
                        beststartmonth(i,j)=trialwystart;
                    end
                end
            end
        end
    end
    
    
    %Read in data for all ensemble members
    needtorepeat=0;
    if needtorepeat==1
    for ensmem=1:100
        memnum=200+ensmem;
        
        for loop=1:2 %historical, then future
            regextremeprecipdays=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
            if loop==1
                curyear=1991;
                thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
                    'precip',[1 1 51500],[numlons numlats 10958]);
            elseif loop==2
                curyear=2070;
                thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
                    'precip',[1 1 80355],[numlons numlats 10957]);
            end
            startyear=curyear;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end

            precipdata_thisensmem=NaN.*ones(numlons,numlats,31,30,12);
            for i=1:size(thisfile,3)
                if reli==thisyearlen %last day of a year
                    precipdata_thisensmem(:,:,1:31,curyear-(startyear-1),1)=thisfile(:,:,i-364:i-334);
                    precipdata_thisensmem(:,:,1:28,curyear-(startyear-1),2)=thisfile(:,:,i-333:i-306);
                    precipdata_thisensmem(:,:,1:31,curyear-(startyear-1),3)=thisfile(:,:,i-305:i-275);
                    precipdata_thisensmem(:,:,1:30,curyear-(startyear-1),4)=thisfile(:,:,i-274:i-245);
                    precipdata_thisensmem(:,:,1:31,curyear-(startyear-1),5)=thisfile(:,:,i-244:i-214);
                    precipdata_thisensmem(:,:,1:30,curyear-(startyear-1),6)=thisfile(:,:,i-213:i-184);
                    precipdata_thisensmem(:,:,1:31,curyear-(startyear-1),7)=thisfile(:,:,i-183:i-153);
                    precipdata_thisensmem(:,:,1:31,curyear-(startyear-1),8)=thisfile(:,:,i-152:i-122);
                    precipdata_thisensmem(:,:,1:30,curyear-(startyear-1),9)=thisfile(:,:,i-121:i-92);
                    precipdata_thisensmem(:,:,1:31,curyear-(startyear-1),10)=thisfile(:,:,i-91:i-61);
                    precipdata_thisensmem(:,:,1:30,curyear-(startyear-1),11)=thisfile(:,:,i-60:i-31);
                    precipdata_thisensmem(:,:,1:31,curyear-(startyear-1),12)=thisfile(:,:,i-30:i);
                    reli=0;curyear=curyear+1;
                end
                reli=reli+1;
            end
            
            %Sum precip over each WY
            %The first WY always begins in year 1, e.g. Mar year 1 to Aug year 1, or Nov year 1 to Apr year 2
            wyprecip=zeros(29,numlons,numlats);
            for i=1:numlons
                for j=1:numlats
                    if ~isnan(beststartmonth(i,j))
                    for wycount=1:29
                        yearhere=wycount;yearsum=0;
                        for monthinwy=1:6
                            monthhere=beststartmonth(i,j)+(monthinwy-1);
                            if monthhere==13;yearhere=yearhere+1;end
                            if monthhere>=13;monthhere=monthhere-12;end
                            yearsum=yearsum+sum(precipdata_thisensmem(i,j,:,yearhere,monthhere),'omitnan');
                        end
                        wyprecip(wycount,i,j)=yearsum;
                    end
                    end
                end
            end
            
            if loop==1
                wyprecip_mpi_hist(ensmem,:,:,:)=wyprecip;
            elseif loop==2
                wyprecip_mpi_fut(ensmem,:,:,:)=wyprecip;
            end
        end
    end
    save(strcat(precipdataloc,'wateryearprecip_mpi.mat'),'wyprecip_mpi_hist','wyprecip_mpi_fut');
    end
end


%Evaluate drought and extreme precip over water years, not calendar years
%Water years are defined as the 6 consecutive months with the highest mean integrated precip at a location
%Drought is bottom 10% of integrated precip, extreme precip is top 10%
if volatilityanalysisanddroughtdefn_chirps==1
    %Make a 5D array that separates out CHIRPS precip data by month
    clear alldailyprecipbymonth_chirps_hist;
    for yr=1:size(allyearsdata_chirps,2)
        alldailyprecipbymonth_chirps_hist(:,:,1:31,yr,1)=permute(squeeze(allyearsdata_chirps(1:31,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:28,yr,2)=permute(squeeze(allyearsdata_chirps(32:59,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:31,yr,3)=permute(squeeze(allyearsdata_chirps(60:90,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:30,yr,4)=permute(squeeze(allyearsdata_chirps(91:120,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:31,yr,5)=permute(squeeze(allyearsdata_chirps(121:151,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:30,yr,6)=permute(squeeze(allyearsdata_chirps(152:181,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:31,yr,7)=permute(squeeze(allyearsdata_chirps(182:212,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:31,yr,8)=permute(squeeze(allyearsdata_chirps(213:243,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:30,yr,9)=permute(squeeze(allyearsdata_chirps(244:273,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:31,yr,10)=permute(squeeze(allyearsdata_chirps(274:304,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:30,yr,11)=permute(squeeze(allyearsdata_chirps(305:334,yr,:,:)),[3 2 1]);
        alldailyprecipbymonth_chirps_hist(:,:,1:31,yr,12)=permute(squeeze(allyearsdata_chirps(335:365,yr,:,:)),[3 2 1]);
    end
    
    %Determine the water year for each gridpt
    beststartmonth=NaN.*ones(numlons,numlats);
    for i=1:numlons
        for j=1:numlats
            mostsofar=0;
            for trialwystart=1:12
                if trialwystart<=7
                    trialprecipsum=sum(sum(sum(alldailyprecipbymonth_chirps_hist(i,j,:,:,trialwystart:trialwystart+5),'omitnan'),'omitnan'),'omitnan');
                else
                    p1=squeeze(sum(sum(sum(alldailyprecipbymonth_chirps_hist(i,j,:,:,trialwystart:12),'omitnan'),'omitnan'),'omitnan'));
                    p2=squeeze(sum(sum(sum(alldailyprecipbymonth_chirps_hist(i,j,:,:,1:trialwystart-7),'omitnan'),'omitnan'),'omitnan'));
                    trialprecipsum=p1+p2;
                end
                if trialprecipsum>mostsofar
                    mostsofar=trialprecipsum;
                    beststartmonth(i,j)=trialwystart;
                end
            end
        end
    end
    
    
    %Now, implement definition by summing precip over each WY
    %The first WY always begins in year 1, e.g. Mar year 1 to Aug year 1, or Nov year 1 to Apr year 2
    regextremeprecipdays_chirps=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
    wyprecip=zeros(29,numlons,numlats);
    for i=1:numlons
        for j=1:numlats
            if ~isnan(beststartmonth(i,j))
            for wycount=1:29
                yearhere=wycount;yearsum=0;
                for monthinwy=1:6
                    monthhere=beststartmonth(i,j)+(monthinwy-1);
                    if monthhere==13;yearhere=yearhere+1;end
                    if monthhere>=13;monthhere=monthhere-12;end
                    yearsum=yearsum+sum(alldailyprecipbymonth_chirps_hist(i,j,:,yearhere,monthhere),'omitnan');
                end
                wyprecip(wycount,i,j)=yearsum;
            end
            end
        end
    end

    wyprecip_chirps_hist=wyprecip;
    save(strcat(precipdataloc,'wateryearprecip_chirps.mat'),'wyprecip_chirps_hist');
end



if readalltempdata_mpi==1
    alldailytempbymonth_mpi_hist=NaN.*ones(memstodo,192,64,31,30,12);
    meanannualp99tmax_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp95tmax_mpi_hist=NaN.*ones(memstodo,192,64);meanannualp90tmax_mpi_hist=NaN.*ones(memstodo,192,64);
    meanannualp99tmax_mpi_fut=NaN.*ones(memstodo,192,64);meanannualp95tmax_mpi_fut=NaN.*ones(memstodo,192,64);meanannualp90tmax_mpi_fut=NaN.*ones(memstodo,192,64);
    for memnum=201:200+memstodo
        thisfile=ncread(strcat(tmaxdataloc,'MPI-GE_hist_rcp45_1850-2099_dailymax_t2max_member_0',num2str(memnum),'-1991-2020.nc'),'t2max');
        curyear=1991;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
        
        meanannualp99tmax_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfile,0.99,3));
        meanannualp95tmax_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfile,0.95,3));
        meanannualp90tmax_mpi_hist(memnum-200,:,:)=squeeze(quantile(thisfile,0.90,3));
        
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,1)=thisfile(:,:,i-364:i-334);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:28,curyear-1990,2)=thisfile(:,:,i-333:i-306);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,3)=thisfile(:,:,i-305:i-275);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:30,curyear-1990,4)=thisfile(:,:,i-274:i-245);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,5)=thisfile(:,:,i-244:i-214);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:30,curyear-1990,6)=thisfile(:,:,i-213:i-184);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,7)=thisfile(:,:,i-183:i-153);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,8)=thisfile(:,:,i-152:i-122);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:30,curyear-1990,9)=thisfile(:,:,i-121:i-92);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,10)=thisfile(:,:,i-91:i-61);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:30,curyear-1990,11)=thisfile(:,:,i-60:i-31);
                alldailytempbymonth_mpi_hist(memnum-200,:,:,1:31,curyear-1990,12)=thisfile(:,:,i-30:i);
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
    end
    
    alldailytempbymonth_mpi_fut=NaN.*ones(memstodo,192,64,31,30,12);
    for memnum=201:200+memstodo
        thisfile=ncread(strcat(tmaxdataloc,'MPI-GE_hist_rcp45_1850-2099_dailymax_t2max_member_0',num2str(memnum),'-2070-2099.nc'),'t2max');
        curyear=2070;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
        
        meanannualp99tmax_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfile,0.99,3));
        meanannualp95tmax_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfile,0.95,3));
        meanannualp90tmax_mpi_fut(memnum-200,:,:)=squeeze(quantile(thisfile,0.90,3));
        
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,1)=thisfile(:,:,i-364:i-334);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:28,curyear-2069,2)=thisfile(:,:,i-333:i-306);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,3)=thisfile(:,:,i-305:i-275);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:30,curyear-2069,4)=thisfile(:,:,i-274:i-245);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,5)=thisfile(:,:,i-244:i-214);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:30,curyear-2069,6)=thisfile(:,:,i-213:i-184);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,7)=thisfile(:,:,i-183:i-153);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,8)=thisfile(:,:,i-152:i-122);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:30,curyear-2069,9)=thisfile(:,:,i-121:i-92);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,10)=thisfile(:,:,i-91:i-61);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:30,curyear-2069,11)=thisfile(:,:,i-60:i-31);
                alldailytempbymonth_mpi_fut(memnum-200,:,:,1:31,curyear-2069,12)=thisfile(:,:,i-30:i);
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
    end
    save(strcat(tmaxdataloc,'tmaxpctiles'),'meanannualp99tmax_mpi_hist','meanannualp95tmax_mpi_hist','meanannualp90tmax_mpi_hist',...
        'meanannualp99tmax_mpi_fut','meanannualp95tmax_mpi_fut','meanannualp90tmax_mpi_fut','-append');
end



if defineextremeheatandcompounding_mpi_all100ensmems==1

    %Get historical and future annual p99, p95, and p90 temperature
    p99heatthreshannual_mpi_hist=squeeze(mean(meanannualp99tmax_mpi_hist));
    p95heatthreshannual_mpi_hist=squeeze(mean(meanannualp95tmax_mpi_hist));
    p90heatthreshannual_mpi_hist=squeeze(mean(meanannualp90tmax_mpi_hist));
    p99heatthreshannual_mpi_fut=squeeze(mean(meanannualp99tmax_mpi_fut));
    p95heatthreshannual_mpi_fut=squeeze(mean(meanannualp95tmax_mpi_fut));
    p90heatthreshannual_mpi_fut=squeeze(mean(meanannualp90tmax_mpi_fut));
        
    

    %Find gridpoints above the historical ANNUAL p99 or p95
    %Use these to calculate compounding
    consecheatextr_hist_vsp99_2days=zeros(100,365,numregs);consecheatextr_hist_vsp99_3days=zeros(100,365,numregs);consecheatextr_hist_vsp99_5days=zeros(100,365,numregs);
    consecheatextr_hist_vsp95_2days=zeros(100,365,numregs);consecheatextr_hist_vsp95_3days=zeros(100,365,numregs);consecheatextr_hist_vsp95_5days=zeros(100,365,numregs);
    consecheatextr_hist_vsp90_2days=zeros(100,365,numregs);consecheatextr_hist_vsp90_3days=zeros(100,365,numregs);consecheatextr_hist_vsp90_5days=zeros(100,365,numregs);
    consecheatextr_fut_vsp99_2days=zeros(100,365,numregs);consecheatextr_fut_vsp99_3days=zeros(100,365,numregs);consecheatextr_fut_vsp99_5days=zeros(100,365,numregs);
    consecheatextr_fut_vsp95_2days=zeros(100,365,numregs);consecheatextr_fut_vsp95_3days=zeros(100,365,numregs);consecheatextr_fut_vsp95_5days=zeros(100,365,numregs);
    consecheatextr_fut_vsp90_2days=zeros(100,365,numregs);consecheatextr_fut_vsp90_3days=zeros(100,365,numregs);consecheatextr_fut_vsp90_5days=zeros(100,365,numregs);
    consecheatextr_fut_vsfut_vsp99_2days=zeros(100,365,numregs);consecheatextr_fut_vsfut_vsp99_3days=zeros(100,365,numregs);consecheatextr_fut_vsfut_vsp99_5days=zeros(100,365,numregs);
    consecheatextr_fut_vsfut_vsp95_2days=zeros(100,365,numregs);consecheatextr_fut_vsfut_vsp95_3days=zeros(100,365,numregs);consecheatextr_fut_vsfut_vsp95_5days=zeros(100,365,numregs);
    consecheatextr_fut_vsfut_vsp90_2days=zeros(100,365,numregs);consecheatextr_fut_vsfut_vsp90_3days=zeros(100,365,numregs);consecheatextr_fut_vsfut_vsp90_5days=zeros(100,365,numregs);

    for memnum=201:300
        thisfile=ncread(strcat(tmaxdataloc,'MPI-GE_hist_rcp45_1850-2099_dailymax_t2max_member_0',num2str(memnumtopull),'-1991-2020.nc'),'t2max');
        curyear=1991;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                
        temporaryhist_vsp99=NaN.*ones(30,192,64,365);temporaryhist_vsp95=NaN.*ones(30,192,64,365);temporaryhist_vsp90=NaN.*ones(30,192,64,365);
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                temporaryhist_vsp99(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p99heatthreshannual_mpi_hist;
                temporaryhist_vsp95(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p95heatthreshannual_mpi_hist;    
                temporaryhist_vsp90(curyear-1990,:,:,:)=thisfile(:,:,i-364:i)>=p90heatthreshannual_mpi_hist;    
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
        
        
        for k=2:size(temporaryhist_vsp99,4)
            tmp=squeeze(sum(temporaryhist_vsp99(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp99_2days(memnum-200,k,thisreg)=consecheatextr_hist_vsp99_2days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==2));
            end
            tmp=squeeze(sum(temporaryhist_vsp95(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp95_2days(memnum-200,k,thisreg)=consecheatextr_hist_vsp95_2days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==2));
            end
            tmp=squeeze(sum(temporaryhist_vsp90(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp90_2days(memnum-200,k,thisreg)=consecheatextr_hist_vsp90_2days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==2));
            end
        end
        
        for k=3:size(temporaryhist_vsp99,4)
            tmp=squeeze(sum(temporaryhist_vsp99(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp99_3days(memnum-200,k,thisreg)=consecheatextr_hist_vsp99_3days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==3));
            end
            tmp=squeeze(sum(temporaryhist_vsp95(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp95_3days(memnum-200,k,thisreg)=consecheatextr_hist_vsp95_3days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==3));
            end
            tmp=squeeze(sum(temporaryhist_vsp90(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp90_3days(memnum-200,k,thisreg)=consecheatextr_hist_vsp90_3days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==3));
            end
        end
        
        for k=5:size(temporaryhist_vsp99,4)
            tmp=squeeze(sum(temporaryhist_vsp99(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp99_5days(memnum-200,k,thisreg)=consecheatextr_hist_vsp99_5days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==5));
            end
            tmp=squeeze(sum(temporaryhist_vsp95(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp95_5days(memnum-200,k,thisreg)=consecheatextr_hist_vsp95_5days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==5));
            end
            tmp=squeeze(sum(temporaryhist_vsp90(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecheatextr_hist_vsp90_5days(memnum-200,k,thisreg)=consecheatextr_hist_vsp90_5days(memnum-200,k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==5));
            end
        end
        
        
        thisfile=ncread(strcat(tmaxdataloc,'MPI-GE_hist_rcp45_1850-2099_dailymax_t2max_member_0',num2str(memnumtopull),'-2070-2099.nc'),'t2max');
        curyear=2070;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                
        temporaryfut_vshist_vsp99=NaN.*ones(30,192,64,365);temporaryfut_vshist_vsp95=NaN.*ones(30,192,64,365);temporaryfut_vshist_vsp90=NaN.*ones(30,192,64,365);
        temporaryfut_vsfut_vsp99=NaN.*ones(30,192,64,365);temporaryfut_vsfut_vsp95=NaN.*ones(30,192,64,365);temporaryfut_vsfut_vsp90=NaN.*ones(30,192,64,365);
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                temporaryfut_vshist_vsp99(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p99heatthreshannual_mpi_hist;
                temporaryfut_vsfut_vsp99(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p99heatthreshannual_mpi_fut;
                temporaryfut_vshist_vsp95(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p95heatthreshannual_mpi_hist;
                temporaryfut_vsfut_vsp95(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p95heatthreshannual_mpi_fut;
                temporaryfut_vshist_vsp90(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p90heatthreshannual_mpi_hist;
                temporaryfut_vsfut_vsp90(curyear-2069,:,:,:)=thisfile(:,:,i-364:i)>=p90heatthreshannual_mpi_fut;
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
        
        
        for k=2:size(temporaryfut_vshist_vsp99,4)
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp99(:,:,:,k-1:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp99(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp99_2days(memnum-200,k,thisreg)=consecheatextr_fut_vsp99_2days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==2));
                consecheatextr_fut_vsfut_vsp99_2days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp99_2days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==2));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp95(:,:,:,k-1:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp95(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp95_2days(memnum-200,k,thisreg)=consecheatextr_fut_vsp95_2days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==2));
                consecheatextr_fut_vsfut_vsp95_2days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp95_2days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==2));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp90(:,:,:,k-1:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp90(:,:,:,k-1:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp90_2days(memnum-200,k,thisreg)=consecheatextr_fut_vsp90_2days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==2));
                consecheatextr_fut_vsfut_vsp90_2days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp90_2days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==2));
            end
        end
        
        for k=3:size(temporaryfut_vshist_vsp99,4)
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp99(:,:,:,k-2:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp99(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp99_3days(memnum-200,k,thisreg)=consecheatextr_fut_vsp99_3days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==3));
                consecheatextr_fut_vsfut_vsp99_3days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp99_3days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==3));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp95(:,:,:,k-2:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp95(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp95_3days(memnum-200,k,thisreg)=consecheatextr_fut_vsp95_3days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==3));
                consecheatextr_fut_vsfut_vsp95_3days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp95_3days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==3));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp90(:,:,:,k-2:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp90(:,:,:,k-2:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp90_3days(memnum-200,k,thisreg)=consecheatextr_fut_vsp90_3days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==3));
                consecheatextr_fut_vsfut_vsp90_3days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp90_3days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==3));
            end
        end
        
        for k=5:size(temporaryfut_vshist_vsp99,4)
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp99(:,:,:,k-4:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp99(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp99_5days(memnum-200,k,thisreg)=consecheatextr_fut_vsp99_5days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==5));
                consecheatextr_fut_vsfut_vsp99_5days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp99_5days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==5));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp95(:,:,:,k-4:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp95(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp95_5days(memnum-200,k,thisreg)=consecheatextr_fut_vsp95_5days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==5));
                consecheatextr_fut_vsfut_vsp95_5days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp95_5days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==5));
            end
            tmp_vshist=squeeze(sum(temporaryfut_vshist_vsp90(:,:,:,k-4:k),4));tmp_vsfut=squeeze(sum(temporaryfut_vsfut_vsp90(:,:,:,k-4:k),4));
            for thisreg=1:numregs
                consecheatextr_fut_vsp90_5days(memnum-200,k,thisreg)=consecheatextr_fut_vsp90_5days(memnum-200,k,thisreg)+sum(sum(tmp_vshist(:,regnums==thisreg)==5));
                consecheatextr_fut_vsfut_vsp90_5days(memnum-200,k,thisreg)=consecheatextr_fut_vsfut_vsp90_5days(memnum-200,k,thisreg)+sum(sum(tmp_vsfut(:,regnums==thisreg)==5));
            end
        end

        disp(memnum-200);disp(clock);
        
        
        %Historical and future probabilities that an extreme-heat day is part of a compound extreme-heat event
        for reg=1:numregs
            numheatextrsthisreg_hist_p99(memnum-200,reg)=0;numheatextrsthisreg_fut_p99(memnum-200,reg)=0;numheatextrsthisreg_fut_vsfut_p99(memnum-200,reg)=0;
            numheatextrsthisreg_hist_p95(memnum-200,reg)=0;numheatextrsthisreg_fut_p95(memnum-200,reg)=0;numheatextrsthisreg_fut_vsfut_p95(memnum-200,reg)=0;
            numheatextrsthisreg_hist_p90(memnum-200,reg)=0;numheatextrsthisreg_fut_p90(memnum-200,reg)=0;numheatextrsthisreg_fut_vsfut_p90(memnum-200,reg)=0;
            for yr=1:30
                for doy=1:365
                    tmp=squeeze(temporaryhist_vsp99(yr,:,:,doy));
                    numheatextrsthisreg_hist_p99(memnum-200,reg)=numheatextrsthisreg_hist_p99(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vshist_vsp99(yr,:,:,doy));
                    numheatextrsthisreg_fut_p99(memnum-200,reg)=numheatextrsthisreg_fut_p99(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vsfut_vsp99(yr,:,:,doy));
                    numheatextrsthisreg_fut_vsfut_p99(memnum-200,reg)=numheatextrsthisreg_fut_vsfut_p99(memnum-200,reg)+sum(tmp(regnums==reg));
                    
                    tmp=squeeze(temporaryhist_vsp95(yr,:,:,doy));
                    numheatextrsthisreg_hist_p95(memnum-200,reg)=numheatextrsthisreg_hist_p95(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vshist_vsp95(yr,:,:,doy));
                    numheatextrsthisreg_fut_p95(memnum-200,reg)=numheatextrsthisreg_fut_p95(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vsfut_vsp95(yr,:,:,doy));
                    numheatextrsthisreg_fut_vsfut_p95(memnum-200,reg)=numheatextrsthisreg_fut_vsfut_p95(memnum-200,reg)+sum(tmp(regnums==reg));
                    
                    tmp=squeeze(temporaryhist_vsp90(yr,:,:,doy));
                    numheatextrsthisreg_hist_p90(memnum-200,reg)=numheatextrsthisreg_hist_p90(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vshist_vsp90(yr,:,:,doy));
                    numheatextrsthisreg_fut_p90(memnum-200,reg)=numheatextrsthisreg_fut_p90(memnum-200,reg)+sum(tmp(regnums==reg));
                    tmp=squeeze(temporaryfut_vsfut_vsp90(yr,:,:,doy));
                    numheatextrsthisreg_fut_vsfut_p90(memnum-200,reg)=numheatextrsthisreg_fut_vsfut_p90(memnum-200,reg)+sum(tmp(regnums==reg));
                end
            end
            probofconsecextremeheatdays_hist_p99_2days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp99_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p99(memnum-200,reg));
            probofconsecextremeheatdays_fut_p99_2days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp99_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p99(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p99_2days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp99_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p99(memnum-200,reg));
            
            probofconsecextremeheatdays_hist_p99_3days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp99_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p99(memnum-200,reg));
            probofconsecextremeheatdays_fut_p99_3days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp99_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p99(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p99_3days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp99_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p99(memnum-200,reg));
            
            probofconsecextremeheatdays_hist_p99_5days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp99_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p99(memnum-200,reg));
            probofconsecextremeheatdays_fut_p99_5days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp99_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p99(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p99_5days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp99_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p99(memnum-200,reg));
            
            
            probofconsecextremeheatdays_hist_p95_2days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp95_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p95(memnum-200,reg));
            probofconsecextremeheatdays_fut_p95_2days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp95_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p95(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p95_2days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp95_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p95(memnum-200,reg));
            
            probofconsecextremeheatdays_hist_p95_3days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp95_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p95(memnum-200,reg));
            probofconsecextremeheatdays_fut_p95_3days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp95_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p95(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p95_3days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp95_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p95(memnum-200,reg));
            
            probofconsecextremeheatdays_hist_p95_5days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp95_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p95(memnum-200,reg));
            probofconsecextremeheatdays_fut_p95_5days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp95_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p95(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p95_5days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp95_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p95(memnum-200,reg));
            
            
            probofconsecextremeheatdays_hist_p90_2days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp90_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p90(memnum-200,reg));
            probofconsecextremeheatdays_fut_p90_2days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp90_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p90(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p90_2days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp90_2days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p90(memnum-200,reg));
            
            probofconsecextremeheatdays_hist_p90_3days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp90_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p90(memnum-200,reg));
            probofconsecextremeheatdays_fut_p90_3days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp90_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p90(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p90_3days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp90_3days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p90(memnum-200,reg));
            
            probofconsecextremeheatdays_hist_p90_5days(memnum-200,reg)=sum(sum(consecheatextr_hist_vsp90_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_hist_p90(memnum-200,reg));
            probofconsecextremeheatdays_fut_p90_5days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsp90_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_p90(memnum-200,reg));
            probofconsecextremeheatdays_fut_vsfut_p90_5days(memnum-200,reg)=sum(sum(consecheatextr_fut_vsfut_vsp90_5days(memnum-200,:,reg)))./...
                (numheatextrsthisreg_fut_vsfut_p90(memnum-200,reg));
        end
    
        if rem(memnum,10)==0
            save(strcat(tmaxdataloc,'mpiheatextremes_gridcelldefn'),...
            'probofconsecextremeheatdays_hist_p99_2days','probofconsecextremeheatdays_fut_p99_2days','probofconsecextremeheatdays_fut_vsfut_p99_2days',...
            'probofconsecextremeheatdays_hist_p99_3days','probofconsecextremeheatdays_fut_p99_3days','probofconsecextremeheatdays_fut_vsfut_p99_3days',...
            'probofconsecextremeheatdays_hist_p99_5days','probofconsecextremeheatdays_fut_p99_5days','probofconsecextremeheatdays_fut_vsfut_p99_5days',...
            'probofconsecextremeheatdays_hist_p95_2days','probofconsecextremeheatdays_fut_p95_2days','probofconsecextremeheatdays_fut_vsfut_p95_2days',...
            'probofconsecextremeheatdays_hist_p95_3days','probofconsecextremeheatdays_fut_p95_3days','probofconsecextremeheatdays_fut_vsfut_p95_3days',...
            'probofconsecextremeheatdays_hist_p95_5days','probofconsecextremeheatdays_fut_p95_5days','probofconsecextremeheatdays_fut_vsfut_p95_5days',...
            'probofconsecextremeheatdays_hist_p90_2days','probofconsecextremeheatdays_fut_p90_2days','probofconsecextremeheatdays_fut_vsfut_p90_2days',...
            'probofconsecextremeheatdays_hist_p90_3days','probofconsecextremeheatdays_fut_p90_3days','probofconsecextremeheatdays_fut_vsfut_p90_3days',...
            'probofconsecextremeheatdays_hist_p90_5days','probofconsecextremeheatdays_fut_p90_5days','probofconsecextremeheatdays_fut_vsfut_p90_5days',...
            'consecheatextr_hist_vsp99_2days','consecheatextr_fut_vsp99_2days','consecheatextr_fut_vsfut_vsp99_2days',...
            'consecheatextr_hist_vsp99_3days','consecheatextr_fut_vsp99_3days','consecheatextr_fut_vsfut_vsp99_3days',...
            'consecheatextr_hist_vsp99_5days','consecheatextr_fut_vsp99_5days','consecheatextr_fut_vsfut_vsp99_5days',...
            'consecheatextr_hist_vsp95_2days','consecheatextr_fut_vsp95_2days','consecheatextr_fut_vsfut_vsp95_2days',...
            'consecheatextr_hist_vsp95_3days','consecheatextr_fut_vsp95_3days','consecheatextr_fut_vsfut_vsp95_3days',...
            'consecheatextr_hist_vsp95_5days','consecheatextr_fut_vsp95_5days','consecheatextr_fut_vsfut_vsp95_5days',...
            'consecheatextr_hist_vsp90_2days','consecheatextr_fut_vsp90_2days','consecheatextr_fut_vsfut_vsp90_2days',...
            'consecheatextr_hist_vsp90_3days','consecheatextr_fut_vsp90_3days','consecheatextr_fut_vsfut_vsp90_3days',...
            'consecheatextr_hist_vsp90_5days','consecheatextr_fut_vsp90_5days','consecheatextr_fut_vsfut_vsp90_5days',...
            'numheatextrsthisreg_hist_p99','numheatextrsthisreg_fut_p99','numheatextrsthisreg_fut_vsfut_p99',...
            'numheatextrsthisreg_hist_p95','numheatextrsthisreg_fut_p95','numheatextrsthisreg_fut_vsfut_p95',...
            'numheatextrsthisreg_hist_p90','numheatextrsthisreg_fut_p90','numheatextrsthisreg_fut_vsfut_p90',...
            '-v7.3');
        end
    end
end


if readtempdata_merra2==1
    repeatreadingofdailymaxes=1;
    if repeatreadingofdailymaxes==1
        setup_nctoolbox;
        alldailymaxes_merra2=NaN.*ones(30,365,size(mpilats,1),size(mpilats,2));
        for year=2020:2020
            if year<=1991;namepart='100';elseif year<=2000;namepart='200';elseif year<=2010;namepart='300';elseif year<=2020;namepart='400';end
            for doy=1:365
                thismon=DOYtoMonth(doy,1991);thisdom=DOYtoDOM(doy,1991);
                if thismon<=9;thismon_str=strcat('0',num2str(thismon));else;thismon_str=num2str(thismon);end
                if thisdom<=9;thisdom_str=strcat('0',num2str(thisdom));else;thisdom_str=num2str(thisdom);end
                thisfilename=strcat('/Volumes/ExternalDriveF/MERRA2/MERRA2_',namepart,'.tavg1_2d_slv_Nx.',num2str(year),thismon_str,thisdom_str,'.SUB.nc');
                t2mtemp=ncread(thisfilename,'T2M');
                
                if year==1991 && doy==1
                    lattemp=ncread(thisfilename,'lat');
                    lontemp=ncread(thisfilename,'lon');
                    lat=double(lattemp);lon=double(lontemp);
                    for row=1:size(lat,1)
                        for col=1:size(lon,1)
                            merra2lats(row,col)=lat(row);merra2lons(row,col)=lon(col);
                        end
                    end
                    westernhem=merra2lons>=180;merra2lons(westernhem)=merra2lons(westernhem)-360;
                end
                
                t2mtemp_daily=flipud(squeeze(max(t2mtemp,[],3))');
                X=merra2lons;Y=flipud(merra2lats);V=t2mtemp_daily;Xq=mpilons;Yq=mpilats;
                alldailymaxes_merra2(year-1990,doy,:,:)=interp2(X,Y,V,Xq,Yq);
            end

            clear t2mtemp;disp(year);disp(clock);
        end
        save(strcat(tmaxdataloc,'alldata_merra2.mat'),'alldailymaxes_merra2','-v7.3');
    end
    
    %Convert to monthly data (5 sec)
    clear alldailytempbymonth_merra2_hist;
    for curyear=1:30
        alldailytempbymonth_merra2_hist(:,:,1:31,curyear,1)=permute(squeeze(alldailymaxes_merra2(curyear,1:31,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:28,curyear,2)=permute(squeeze(alldailymaxes_merra2(curyear,32:59,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:31,curyear,3)=permute(squeeze(alldailymaxes_merra2(curyear,60:90,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:30,curyear,4)=permute(squeeze(alldailymaxes_merra2(curyear,91:120,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:31,curyear,5)=permute(squeeze(alldailymaxes_merra2(curyear,121:151,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:30,curyear,6)=permute(squeeze(alldailymaxes_merra2(curyear,152:181,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:31,curyear,7)=permute(squeeze(alldailymaxes_merra2(curyear,182:212,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:31,curyear,8)=permute(squeeze(alldailymaxes_merra2(curyear,213:243,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:30,curyear,9)=permute(squeeze(alldailymaxes_merra2(curyear,244:273,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:31,curyear,10)=permute(squeeze(alldailymaxes_merra2(curyear,274:304,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:30,curyear,11)=permute(squeeze(alldailymaxes_merra2(curyear,305:334,:,:)),[3 2 1]);
        alldailytempbymonth_merra2_hist(:,:,1:31,curyear,12)=permute(squeeze(alldailymaxes_merra2(curyear,335:365,:,:)),[3 2 1]);
    end
    
    tmp=reshape(alldailymaxes_merra2,[size(alldailymaxes_merra2,1)*size(alldailymaxes_merra2,2) 64 192]);
    meanannualp99tmax_merra2=squeeze(quantile(tmp,0.99));
    meanannualp95tmax_merra2=squeeze(quantile(tmp,0.95));
    save(strcat(tmaxdataloc,'tmaxpctiles_merra2'),'meanannualp99tmax_merra2','meanannualp95tmax_merra2','-append');
end



if defineextremeheatcompounding_merra2==1
    p95heatthresh_merra2_hist=squeeze(quantile(reshape(alldailymaxes_merra2,[size(alldailymaxes_merra2,1)*size(alldailymaxes_merra2,2) 64 192]),0.95));
    %Add NaNs where there are NaNs in the equivalent model array, to ensure complete accuracy of comparison
    nansinmodel=isnan(p95precipthreshannual_mpi_hist);
    p95heatthresh_merra2_hist(nansinmodel)=NaN;
    
    alldailymaxes_merra2_permuted=permute(alldailymaxes_merra2,[1 4 3 2]);
    tempp95_merra2_hist=NaN.*ones(numyrs,64,192,365);
    for dim5=1:numyrs
        for doy=1:365
            tempp95_merra2_hist(dim5,:,:,doy)=squeeze(alldailymaxes_merra2_permuted(dim5,:,:,doy))'>=p95heatthresh_merra2_hist;
        end
    end
    
    consecheatextr_hist_vsp95_2days_merra2=zeros(365,numregs);
    consecheatextr_hist_vsp95_3days_merra2=zeros(365,numregs);
    consecheatextr_hist_vsp95_5days_merra2=zeros(365,numregs);
    
    for k=2:size(tempp95_merra2_hist,4)
        tmp=squeeze(sum(tempp95_merra2_hist(:,:,:,k-1:k),4));
        for thisreg=1:numregs
            consecheatextr_hist_vsp95_2days_merra2(k,thisreg)=consecheatextr_hist_vsp95_2days_merra2(k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==2));
        end
    end
    
    for k=3:size(tempp95_merra2_hist,4)
        tmp=squeeze(sum(tempp95_merra2_hist(:,:,:,k-2:k),4));
        for thisreg=1:numregs
            consecheatextr_hist_vsp95_3days_merra2(k,thisreg)=consecheatextr_hist_vsp95_3days_merra2(k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==3));
        end
    end
    
    for k=5:size(tempp95_merra2_hist,4)
        tmp=squeeze(sum(tempp95_merra2_hist(:,:,:,k-4:k),4));
        for thisreg=1:numregs
            consecheatextr_hist_vsp95_5days_merra2(k,thisreg)=consecheatextr_hist_vsp95_5days_merra2(k,thisreg)+sum(sum(tmp(:,regnums==thisreg)==5));
        end
    end
    
    %Historical and future probabilities that an extreme-heat day is part of a compound extreme-heat event
    numheatextrsthisreg_hist_p95_merra2=zeros(numregs,1);
    for reg=1:numregs
        for yr=1:numyrs
            for doy=1:365
                tmp=squeeze(tempp95_merra2_hist(yr,:,:,doy));
                numheatextrsthisreg_hist_p95_merra2(reg)=numheatextrsthisreg_hist_p95_merra2(reg)+sum(tmp(regnums==reg));
            end
        end
        probofconsecextremeheatdays_hist_p95_2days_merra2(reg)=sum(sum(consecheatextr_hist_vsp95_2days_merra2(:,reg)))./...
            (numheatextrsthisreg_hist_p95_merra2(reg));
        probofconsecextremeheatdays_hist_p95_3days_merra2(reg)=sum(sum(consecheatextr_hist_vsp95_3days_merra2(:,reg)))./...
            (numheatextrsthisreg_hist_p95_merra2(reg));
        probofconsecextremeheatdays_hist_p95_5days_merra2(reg)=sum(sum(consecheatextr_hist_vsp95_5days_merra2(:,reg)))./...
            (numheatextrsthisreg_hist_p95_merra2(reg));
    end
end


%Regional-mean temperature and precipitation for each day
%For Central US only: days above p95, to approximate days above 29C
%Both definitions are for maize and come from Gaupp et al. 2020 (supplemental figure 4)
%What we are doing here is using the pctiles from Gaupp et al. but applying
    %them over our bigger regions (i.e., assuming that pctile anomalies in the Gaupp et
    %al. provinces are represented well by anomalies over our regions)
if readalltempandprecipdata_mpi_saveasreglmeans==1
    alldailytempbyregion_mpi_hist=NaN.*ones(100,24,30,12);
    thismonthtemp_centralus_hist=NaN.*ones(100,30,12,31,106);
    alldailytempbyregion_mpi_fut=NaN.*ones(100,24,30,12);
    thismonthtemp_centralus_fut=NaN.*ones(100,30,12,31,106);
    monthsubtract1=[364;333;305;274;244;213;183;152;121;91;60;30];
    monthsubtract2=[334;306;275;245;214;184;153;122;92;61;31;0];
    monthlens=[31;28;31;30;31;30;31;31;30;31;30;31];
    
    for memnum=201:300
        if memnum==260;memnum=290;elseif memnum==261;memnum=291;end
        
        thisfile=ncread(strcat(tmaxdataloc,'MPI-GE_hist_rcp45_1850-2099_dailymax_t2max_member_0',num2str(memnum),'-1991-2020.nc'),'t2max');
        curyear=1991;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                for month=1:12
                    for reg=1:24
                        thismonthdata=thisfile(:,:,i-monthsubtract1(month):i-monthsubtract2(month));
                        alldailytempbyregion_mpi_hist(memnum-200,reg,curyear-1990,month)=mean(thismonthdata(regnums==reg),'omitnan')-273.15;

                        %For Central US, save daily data to eventually compute extreme days
                        %Model bias in p95 Tmax is essentially zero, so fortunately no quantile-matching is necessary here
                        if reg==3
                            for day=1:monthlens(month)
                                thisdaydata=thismonthdata(:,:,day);
                                thisdaydata_thisreg=thisdaydata(regnums==reg);
                                thismonthtemp_centralus_hist(memnum-200,curyear-1990,month,day,1:landgridptsum(reg))=thisdaydata_thisreg(~isnan(thisdaydata_thisreg));
                            end
                        end
                    end
                end
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        
        
        thisfile=ncread(strcat(tmaxdataloc,'MPI-GE_hist_rcp45_1850-2099_dailymax_t2max_member_0',num2str(memnum),'-2070-2099.nc'),'t2max');
        curyear=2070;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                for month=1:12
                    for reg=1:24
                        thismonthdata=thisfile(:,:,i-monthsubtract1(month):i-monthsubtract2(month));
                        alldailytempbyregion_mpi_fut(memnum-200,reg,curyear-2069,month)=mean(thismonthdata(regnums==reg),'omitnan')-273.15;

                        %For Central US, save daily data to eventually compute extreme days
                        %Model bias in p95 Tmax is essentially zero, so fortunately no quantile-matching is necessary here
                        if reg==3
                            for day=1:monthlens(month)
                                thisdaydata=thismonthdata(:,:,day);
                                thisdaydata_thisreg=thisdaydata(regnums==reg);
                                thismonthtemp_centralus_fut(memnum-200,curyear-2069,month,day,1:landgridptsum(reg))=thisdaydata_thisreg(~isnan(thisdaydata_thisreg));
                            end
                        end
                    end
                end
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
    end
    save(strcat(tmaxdataloc,'tmaxregionaldata'),'alldailytempbyregion_mpi_hist','thismonthtemp_centralus_hist',...
        'alldailytempbyregion_mpi_fut','thismonthtemp_centralus_fut','-v7.3');
    
    
    
    alldailyprecipbyregion_mpi_hist=NaN.*ones(100,24,30,12);
    alldailyprecipbyregion_mpi_fut=NaN.*ones(100,24,30,12);
    
    for memnum=201:300        
        thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
            'precip',[1 1 51500],[192 64 10958]);
        curyear=1991;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                for month=1:12
                    for reg=1:24
                        thismonthdata=thisfile(:,:,i-monthsubtract1(month):i-monthsubtract2(month));
                        alldailyprecipbyregion_mpi_hist(memnum-200,reg,curyear-1990,month)=mean(thismonthdata(regnums==reg),'omitnan');
                    end
                end
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        
        
        thisfile=ncread(strcat(precipdataloc,'MPI-GE_hist_rcp45_1850-2099_precip_member_0',num2str(memnum),'-daily-mmday.nc'),...
            'precip',[1 1 80355],[192 64 10957]);
        curyear=2070;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                
        for i=1:size(thisfile,3)
            if reli==thisyearlen %last day of a year
                for month=1:12
                    for reg=1:24
                        thismonthdata=thisfile(:,:,i-monthsubtract1(month):i-monthsubtract2(month));
                        alldailyprecipbyregion_mpi_fut(memnum-200,reg,curyear-2069,month)=mean(thismonthdata(regnums==reg),'omitnan');
                    end
                end
                reli=0;curyear=curyear+1;
            end
            reli=reli+1;
        end
        clear thisfile;
    end
    save(strcat(precipdataloc,'precipregionaldata'),'alldailyprecipbyregion_mpi_hist','alldailyprecipbyregion_mpi_fut','-v7.3');
end


%Regional-mean temperature and precipitation for each day
%For Central US only: days above p95, to approximate days above 29C
%Both definitions are for maize and come from Gaupp et al. 2020 (supplemental figure 4)
%What we are doing here is using the pctiles from Gaupp et al. but applying
    %them over our bigger regions (i.e., assuming that pctile anomalies in the Gaupp et
    %al. provinces are represented well by anomalies over our regions)
if readalltempandprecipdata_reana_saveasreglmeans==1
    alldailytempbyregion_reana_hist=NaN.*ones(24,30,12);
    thismonthtemp_centralus_reana_hist=NaN.*ones(30,12,31,106);
    
    monthsubtract1=[364;333;305;274;244;213;183;152;121;91;60;30];
    monthsubtract2=[334;306;275;245;214;184;153;122;92;61;31;0];
    monthlens=[31;28;31;30;31;30;31;31;30;31;30;31];
    
    for year=1:numyrs
        for mon=1:12
            thismonthdata=permute(alldailytempbymonth_merra2_hist(:,:,:,year,mon),[2 1 3]);
            for reg=1:24
                alldailytempbyregion_reana_hist(reg,year,mon)=mean(thismonthdata(regnums==reg),'omitnan')-273.15;
                %For Central US, save daily data to eventually compute extreme days
                if reg==3
                    for day=1:monthlens(mon)
                        thisdaydata=thismonthdata(:,:,day);
                        thisdaydata_thisreg=thisdaydata(regnums==reg);
                        numgridptshere=min(landgridptsum(reg),size(~isnan(thisdaydata_thisreg),1));
                        tmp=thisdaydata_thisreg(~isnan(thisdaydata_thisreg));
                        thismonthtemp_centralus_reana_hist(year,mon,day,1:numgridptshere)=tmp(1:numgridptshere);
                    end
                end
            end
        end
    end
    save(strcat(tmaxdataloc,'tmaxregionaldata_merra2'),'alldailytempbyregion_reana_hist','thismonthtemp_centralus_reana_hist','-v7.3');
    
    
    
    alldailyprecipbyregion_reana_hist=NaN.*ones(24,30,12);
    
    for year=1:numyrs
        for mon=1:12
            thismonthdata=permute(alldailyprecipbymonth_chirps_hist(:,:,:,year,mon),[2 1 3]);
            for reg=1:24
                alldailyprecipbyregion_reana_hist(reg,year,mon)=mean(thismonthdata(regnums==reg),'omitnan');
            end
        end
    end
    save(strcat(precipdataloc,'precipregionaldata_merra2'),'alldailyprecipbyregion_reana_hist','-v7.3');
end


if applygauppdefnsandmakeplot==1
    %Unlike Gaupp et al. 2020, also add sensitivity tests to consider possible CO2-fertilization effects
    
    %Breadbasket regions
    %Central US, NE Brazil, S South America, Central Europe, E Asia, S Asia
    breadbasketregs=[3;7;8;10;19;20];
    
    %India/S Asia: max temperature Jun-Oct -- threshold 0.58
    %China/E Asia: max temperature May-Sep -- threshold 0.65
    %Also E Asia: cumulative precip Jun-Aug -- threshold 0.45
    %Argentina/S South America: max temperature Dec-Feb -- threshold 0.67
    %Also Argentina: cumulative precip Nov-Jan -- threshold 0.36
    %Brazil: cumulative precip Nov-Feb -- threshold 0.55
    %Europe: cumulative precip Mar-Aug -- threshold 0.38
    %Also Europe: temperature May-Aug -- threshold 0.56
    %Central US: days above p75 May-Nov
    temperaturethreshs=[0.58;0.65;0.67;0;0.56];
    precipthreshs=[0;0.45;0.36;0.55;0.38];
    
    clear failures_hist;clear failures_fut;
    
    for breadbasket=1:size(temperaturethreshs,1)
        if temperaturethreshs(breadbasket)~=0
            if breadbasket==1
                data_hist=mean(squeeze(alldailytempbyregion_mpi_hist(:,20,:,6:10)),3);
                data_fut=mean(squeeze(alldailytempbyregion_mpi_fut(:,20,:,6:10)),3);
            elseif breadbasket==2
                data_hist=mean(squeeze(alldailytempbyregion_mpi_hist(:,19,:,5:9)),3);
                data_fut=mean(squeeze(alldailytempbyregion_mpi_fut(:,19,:,5:9)),3);
            elseif breadbasket==3
                a=squeeze(alldailytempbyregion_mpi_hist(:,8,:,12));b=squeeze(alldailytempbyregion_mpi_hist(:,8,:,1:2));
                c=cat(3,a,b);data_hist=mean(squeeze(c),3);
                a=squeeze(alldailytempbyregion_mpi_fut(:,8,:,12));b=squeeze(alldailytempbyregion_mpi_fut(:,8,:,1:2));
                c=cat(3,a,b);data_fut=mean(squeeze(c),3);
            elseif breadbasket==5
                data_hist=mean(squeeze(alldailytempbyregion_mpi_hist(:,10,:,5:8)),3);
                data_fut=mean(squeeze(alldailytempbyregion_mpi_fut(:,10,:,5:8)),3);
            end

            temperaturethresh=quantile(data_hist,temperaturethreshs(breadbasket),2);
            failures1_hist=data_hist>=temperaturethresh;failures1_fut=data_fut>=temperaturethresh;
            failures1_fut_topt1=data_fut>=(temperaturethresh+0.5);
            failures1_fut_topt2=data_fut>=(temperaturethresh+1);
        end
        
        
        if precipthreshs(breadbasket)~=0
            if breadbasket==2
                a=squeeze(alldailyprecipbyregion_mpi_hist(:,19,:,6:8));b=[];c=cat(3,a,b);data_hist=sum(squeeze(c),3);
                a=squeeze(alldailyprecipbyregion_mpi_fut(:,19,:,6:8));b=[];c=cat(3,a,b);data_fut=sum(squeeze(c),3);
            elseif breadbasket==3
                a=squeeze(alldailyprecipbyregion_mpi_hist(:,8,:,11:12));b=squeeze(alldailyprecipbyregion_mpi_hist(:,8,:,1));
                c=cat(3,a,b);data_hist=sum(squeeze(c),3);
                a=squeeze(alldailyprecipbyregion_mpi_fut(:,8,:,11:12));b=squeeze(alldailyprecipbyregion_mpi_fut(:,8,:,1));
                c=cat(3,a,b);data_fut=sum(squeeze(c),3);
            elseif breadbasket==4
                a=squeeze(alldailyprecipbyregion_mpi_hist(:,7,:,11:12));b=squeeze(alldailyprecipbyregion_mpi_hist(:,7,:,1:2));
                c=cat(3,a,b);data_hist=sum(squeeze(c),3);
                a=squeeze(alldailyprecipbyregion_mpi_fut(:,7,:,11:12));b=squeeze(alldailyprecipbyregion_mpi_fut(:,7,:,1:2));
                c=cat(3,a,b);data_fut=sum(squeeze(c),3);
            elseif breadbasket==5
                a=squeeze(alldailyprecipbyregion_mpi_hist(:,10,:,3:8));b=[];c=cat(3,a,b);data_hist=sum(squeeze(c),3);
                a=squeeze(alldailyprecipbyregion_mpi_fut(:,10,:,3:8));b=[];c=cat(3,a,b);data_fut=sum(squeeze(c),3);
            end
            
            precipthresh=quantile(data_hist,precipthreshs(breadbasket),2);
            failures2_hist=data_hist<=precipthresh;failures2_fut=data_fut<=precipthresh;
            failures2_fut_popt1=data_fut<=(precipthresh-0.05.*precipthresh);
            failures2_fut_popt2=data_fut<=(precipthresh-0.1.*precipthresh);
        end
        
        %Combine temperature & precip info together
        if temperaturethreshs(breadbasket)~=0 && precipthreshs(breadbasket)~=0
            failures_hist_temp=failures1_hist+failures2_hist;
            failures_hist_temp(failures_hist_temp==1)=0;failures_hist_temp(failures_hist_temp==2)=1;
            failures_hist(breadbasket,:,:)=failures_hist_temp;
            
            failures_fut_temp=failures1_fut+failures2_fut;
            failures_fut_temp(failures_fut_temp==1)=0;failures_fut_temp(failures_fut_temp==2)=1;
            failures_fut(breadbasket,:,:)=failures_fut_temp;
            
            failures_fut_temp=failures1_fut_topt1+failures2_fut_popt1;
            failures_fut_temp(failures_fut_temp==1)=0;failures_fut_temp(failures_fut_temp==2)=1;
            failures_fut_topt1popt1(breadbasket,:,:)=failures_fut_temp;
            
            failures_fut_temp=failures1_fut_topt2+failures2_fut_popt2;
            failures_fut_temp(failures_fut_temp==1)=0;failures_fut_temp(failures_fut_temp==2)=1;
            failures_fut_topt2popt2(breadbasket,:,:)=failures_fut_temp;
        elseif precipthreshs(breadbasket)==0 %temperature only
            failures_hist(breadbasket,:,:)=failures1_hist;
            failures_fut(breadbasket,:,:)=failures1_fut;
            failures_fut_topt1popt1(breadbasket,:,:)=failures1_fut_topt1;
            failures_fut_topt2popt2(breadbasket,:,:)=failures1_fut_topt2;
        elseif temperaturethreshs(breadbasket)==0 %precip only
            failures_hist(breadbasket,:,:)=failures2_hist;
            failures_fut(breadbasket,:,:)=failures2_fut;
            failures_fut_topt1popt1(breadbasket,:,:)=failures2_fut_popt1;
            failures_fut_topt2popt2(breadbasket,:,:)=failures2_fut_popt2;
        end
    end
    
    %Now do Central US
    %Threshold is at 0.62 -- i.e., look for seasons whose count of p75 days is above the 62nd percentile of the distribution
    maynovtemperatures_hist=reshape(squeeze(mean(thismonthtemp_centralus_hist(:,:,5:11,:,:),5)),[100 30 7*31]);
    daysabovep75_hist=maynovtemperatures_hist>=quantile(reshape(maynovtemperatures_hist,[100 30*217]),0.75,2);
    for i=1:100;for j=1:30;seasonsum_daysabovep75_hist(i,j)=squeeze(sum(daysabovep75_hist(i,j,:)));end;end
    failures_hist(breadbasket+1,:,:)=seasonsum_daysabovep75_hist>=quantile(reshape(seasonsum_daysabovep75_hist,[100*30 1]),0.62);
    
    maynovtemperatures_fut=reshape(squeeze(mean(thismonthtemp_centralus_fut(:,:,5:11,:,:),5)),[100 30 7*31]);
    daysabovep75_fut=maynovtemperatures_fut>=quantile(reshape(maynovtemperatures_fut,[100 30*217]),0.75,2);
    for i=1:100;for j=1:30;seasonsum_daysabovep75_fut(i,j)=squeeze(sum(daysabovep75_fut(i,j,:)));end;end
    failures_fut(breadbasket+1,:,:)=seasonsum_daysabovep75_fut>=quantile(reshape(seasonsum_daysabovep75_fut,[100*30 1]),0.62);
    
    daysabovep75_fut_topt1=maynovtemperatures_fut>=(quantile(reshape(maynovtemperatures_fut,[100 30*217]),0.75,2)+1);
    for i=1:100;for j=1:30;seasonsum_daysabovep75_fut_topt1(i,j)=squeeze(sum(daysabovep75_fut_topt1(i,j,:)));end;end
    failures_fut_topt1popt1(breadbasket+1,:,:)=seasonsum_daysabovep75_fut_topt1>=quantile(reshape(seasonsum_daysabovep75_fut_topt1,[100*30 1]),0.62);
    
    daysabovep75_fut_topt2=maynovtemperatures_fut>=(quantile(reshape(maynovtemperatures_fut,[100 30*217]),0.75,2)+2);
    for i=1:100;for j=1:30;seasonsum_daysabovep75_fut_topt2(i,j)=squeeze(sum(daysabovep75_fut_topt2(i,j,:)));end;end
    failures_fut_topt2popt2(breadbasket+1,:,:)=seasonsum_daysabovep75_fut_topt2>=quantile(reshape(seasonsum_daysabovep75_fut_topt2,[100*30 1]),0.62);
    
    
    
    %Compare risks of different multiple-breadbasket failures
    %Compare to Gaupp et al. 2020 figure 2c
    numbreadbasketfailures_hist=reshape(squeeze(sum(failures_hist)),[100*30 1]);
    numbreadbasketfailures_fut=reshape(squeeze(sum(failures_fut)),[100*30 1]);
    numbreadbasketfailures_fut_topt1popt1=reshape(squeeze(sum(failures_fut_topt1popt1)),[100*30 1]);
    numbreadbasketfailures_fut_topt2popt2=reshape(squeeze(sum(failures_fut_topt2popt2)),[100*30 1]);
    for numfailures=0:6
        prob_hist(numfailures+1)=sum(numbreadbasketfailures_hist==numfailures)./3000;
        prob_fut(numfailures+1)=sum(numbreadbasketfailures_fut==numfailures)./3000;
        prob_fut_topt1popt1(numfailures+1)=sum(numbreadbasketfailures_fut_topt1popt1==numfailures)./3000;
        prob_fut_topt2popt2(numfailures+1)=sum(numbreadbasketfailures_fut_topt2popt2==numfailures)./3000;
    end
    figure(707);clf;subplot(2,1,1);boxplot(prob_hist);subplot(2,1,2);boxplot(prob_fut);
    
    %Using ensemble members separately, rather than pooled
    x=[];g=[];
    for ensmem=1:100
        numbreadbasketfailures_hist=squeeze(sum(failures_hist(:,ensmem,:)));
        numbreadbasketfailures_fut=squeeze(sum(failures_fut(:,ensmem,:)));
        numbreadbasketfailures_fut_topt1popt1=squeeze(sum(failures_fut_topt1popt1(:,ensmem,:)));
        numbreadbasketfailures_fut_topt2popt2=squeeze(sum(failures_fut_topt2popt2(:,ensmem,:)));
        for numfailures=0:6
            prob_hist(ensmem,numfailures+1)=sum(numbreadbasketfailures_hist==numfailures)./30;
            prob_fut(ensmem,numfailures+1)=sum(numbreadbasketfailures_fut==numfailures)./30;
            prob_fut_topt1popt1(ensmem,numfailures+1)=sum(numbreadbasketfailures_fut_topt1popt1==numfailures)./30;
            prob_fut_topt2popt2(ensmem,numfailures+1)=sum(numbreadbasketfailures_fut_topt2popt2==numfailures)./30;
            
            x=[x;prob_hist(ensmem,numfailures+1);prob_fut(ensmem,numfailures+1);...
                prob_fut_topt1popt1(ensmem,numfailures+1);prob_fut_topt2popt2(ensmem,numfailures+1)];
            g=[g;((numfailures+1)*4-3);(numfailures+1)*4-2;(numfailures+1)*4-1;(numfailures+1)*4];
        end
    end
    figure(708);clf;subplot(2,1,1);boxplot(prob_hist);subplot(2,1,2);boxplot(prob_fut);
    

    %Future regional risk analysis
    %For each pair of regions, when there are e.g. 3 breadbasket failures, how often are these two regions among the 3?
    %Repeat for 4, 5, 6
    failures_fut2d=reshape(failures_fut,[6 100*30]);
    countmatrix_3=zeros(6,6);countmatrix_4=zeros(6,6);countmatrix_5=zeros(6,6);
    numfailures_eachyear=sum(failures_fut2d);
    threefailurescount=sum(numfailures_eachyear==3);
    fourfailurescount=sum(numfailures_eachyear==4);
    fivefailurescount=sum(numfailures_eachyear==5);
    for regc1=1:6
        for regc2=1:6
            if regc1>regc2
                for i=1:size(failures_fut2d,2)
                    if sum(failures_fut2d(:,i))==3 
                        if failures_fut2d(regc1,i)==1 && failures_fut2d(regc2,i)==1
                            countmatrix_3(regc1,regc2)=countmatrix_3(regc1,regc2)+1;
                        end
                    end
                    if sum(failures_fut2d(:,i))==4
                        if failures_fut2d(regc1,i)==1 && failures_fut2d(regc2,i)==1
                            countmatrix_4(regc1,regc2)=countmatrix_4(regc1,regc2)+1;
                        end
                    end
                    if sum(failures_fut2d(:,i))==5
                        if failures_fut2d(regc1,i)==1 && failures_fut2d(regc2,i)==1
                            countmatrix_5(regc1,regc2)=countmatrix_5(regc1,regc2)+1;
                        end
                    end
                end
            end
        end
    end
    pairlikelihood_3failures=100.*countmatrix_3./threefailurescount; %percent likelihood of each pair when there are 3 failures
    pairlikelihood_4failures=100.*countmatrix_4./fourfailurescount;
    pairlikelihood_5failures=100.*countmatrix_5./fivefailurescount;
    
    
    
    figc=709;figure(figc);clf;curpart=1;highqualityfiguresetup;hold on;
    subplot(2,1,1);
    boxplot(x,g);hold on;
    %For each region, make historical boxes light red and future boxes crimson
    color1=colors('light red');color2=colors('crimson');color3=colors('pink');color4=colors('purple');
    temp=max(max(color3))-color3;color3_pale=color3+0.3*temp;temp=max(max(color4))-color4;color4_pale=color4+0.3*temp;
    boxplot_4datasetsalternating;
    set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    set(gca,'xtick',2.5:4:28.5,'xticklabel',{'0','1','2','3','4','5','6'});
    ylabel('Annual Probability','fontweight','bold','fontname','arial','fontsize',12);
    xlabel('Number of Maize Breadbasket Regions','fontweight','bold','fontname','arial','fontsize',12);
    t=text(0.78,0.9,'1991-2020','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',12,'color',color1);
    t=text(0.78,0.8,'2070-2099','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',12,'color',color2);
    t=text(0.78,0.7,'2070-2099 (T+0.5,P-5%)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',12,'color',color3_pale);
    t=text(0.78,0.6,'2070-2099 (T+1.0,P-10%)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',12,'color',color4_pale);
    t=text(-0.08,1.01,'a)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16,'color','k');
    
    x=[];
    numbreadbasketfailures_hist_reana=squeeze(sum(failures_hist_reana));
    for numfailures=0:6
        prob_hist_reana(numfailures+1)=sum(numbreadbasketfailures_hist_reana==numfailures)./30;

        x=[x;prob_hist_reana(numfailures+1)];
    end
    g=[1.05:4:28]';
    s=scatter(g,x,100,'k','filled');
    set(gca,'Position',[0.1 0.69 0.8 0.28]);
    
    
    axes('Position',[-0.01 -0.05 0.53 0.73]);
    plotBlankMap(figc,'world60s60n_mainlandareasonly',0,'ghost white',0,{'stateboundaries';0});hold on;
    regcolors=colormaps('classy rainbow','more','not');
    for reg=1:numregs
        thiscolor=regcolors(round(128*(reg-0.5)/24),:);
        if ismember(reg,breadbasketregs)
            [lat,lon]=outlinegeoquad([regsouthedges(reg) regnorthedges(reg)],[regwestedges(reg) regeastedges(reg)],2,2);
            if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                [lat2,lon2]=outlinegeoquad([regsouthedges2(reg) regnorthedges2(reg)],[regwestedges2(reg) regeastedges2(reg)],2,2);
            end
            g1=geoshow(lat,lon,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',0.7);
            if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20;g2=geoshow(lat2,lon2,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',0.7);end
        end
    end
    
    %Add thick lines corresponding to pair likelihoods for the 3-breadbasket-failure scenario
    regord=0;otherregord=0;
    for reg=1:numregs
        regcenterlat=(regsouthedges(reg)+regnorthedges(reg))/2;regcenterlon=(regwestedges(reg)+regeastedges(reg))/2;
        for test=1:6;if breadbasketregs(test)==reg;regord=test;end;end
        if regord==5;regcenterlat=regcenterlat-2;elseif regord==2;regcenterlat=regcenterlat+2;elseif regord==3;regcenterlat=regcenterlat-7;...
        elseif regord==6;regcenterlat=regcenterlat-2;end
        if regord==3;regcenterlon=regcenterlon-2;elseif regord==5;regcenterlon=regcenterlon+5;elseif regord==6;regcenterlon=regcenterlon+3;end
        
        for otherreg=1:numregs
            otherregcenterlat=(regsouthedges(otherreg)+regnorthedges(otherreg))/2;otherregcenterlon=(regwestedges(otherreg)+regeastedges(otherreg))/2;
            for test=1:6;if breadbasketregs(test)==otherreg;otherregord=test;end;end
            if otherregord==5;otherregcenterlat=otherregcenterlat-2;elseif otherregord==2;otherregcenterlat=otherregcenterlat+2;...
            elseif otherregord==3;otherregcenterlat=otherregcenterlat-7;elseif otherregord==6;otherregcenterlat=otherregcenterlat-2;end
            if otherregord==3;otherregcenterlon=otherregcenterlon-2;elseif otherregord==5;otherregcenterlon=otherregcenterlon+5;...
            elseif otherregord==6;otherregcenterlon=otherregcenterlon+3;end
            
            if ismember(reg,breadbasketregs) && ismember(otherreg,breadbasketregs) && reg>otherreg
                thispairlikelihood=pairlikelihood_3failures(regord,otherregord);
                lw=6*thispairlikelihood/75;
                geoshow(gca,[regcenterlat otherregcenterlat],[regcenterlon otherregcenterlon],'DisplayType','line','LineWidth',lw,'color','k');
            end
        end
    end
    t=text(0.03,1.02,'b)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16,'color','k');
    
    
    %Repeat for the 5-breadbasket-failure scenario
    axes('Position',[0.49 -0.05 0.53 0.73]);
    plotBlankMap(figc,'world60s60n_mainlandareasonly',0,'ghost white',0,{'stateboundaries';0});hold on;
    regcolors=colormaps('classy rainbow','more','not');
    for reg=1:numregs
        thiscolor=regcolors(round(128*(reg-0.5)/24),:);
        if ismember(reg,breadbasketregs)
            [lat,lon]=outlinegeoquad([regsouthedges(reg) regnorthedges(reg)],[regwestedges(reg) regeastedges(reg)],2,2);
            if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                [lat2,lon2]=outlinegeoquad([regsouthedges2(reg) regnorthedges2(reg)],[regwestedges2(reg) regeastedges2(reg)],2,2);
            end
            g1=geoshow(lat,lon,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',0.7);
            if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20;g2=geoshow(lat2,lon2,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',0.7);end
        end
    end
    
    %Add thick lines corresponding to pair likelihoods
    for reg=1:numregs
        regcenterlat=(regsouthedges(reg)+regnorthedges(reg))/2;regcenterlon=(regwestedges(reg)+regeastedges(reg))/2;
        for test=1:6;if breadbasketregs(test)==reg;regord=test;end;end
        if regord==5;regcenterlat=regcenterlat-2;elseif regord==2;regcenterlat=regcenterlat+2;elseif regord==3;regcenterlat=regcenterlat-7;...
        elseif regord==6;regcenterlat=regcenterlat-2;end
        if regord==3;regcenterlon=regcenterlon-2;elseif regord==5;regcenterlon=regcenterlon+5;elseif regord==6;regcenterlon=regcenterlon+3;end
        
        for otherreg=1:numregs
            otherregcenterlat=(regsouthedges(otherreg)+regnorthedges(otherreg))/2;otherregcenterlon=(regwestedges(otherreg)+regeastedges(otherreg))/2;
            for test=1:6;if breadbasketregs(test)==otherreg;otherregord=test;end;end
            if otherregord==5;otherregcenterlat=otherregcenterlat-2;elseif otherregord==2;otherregcenterlat=otherregcenterlat+2;...
            elseif otherregord==3;otherregcenterlat=otherregcenterlat-7;elseif otherregord==6;otherregcenterlat=otherregcenterlat-2;end
            if otherregord==3;otherregcenterlon=otherregcenterlon-2;elseif otherregord==5;otherregcenterlon=otherregcenterlon+5;...
            elseif otherregord==6;otherregcenterlon=otherregcenterlon+3;end
            
            if ismember(reg,breadbasketregs) && ismember(otherreg,breadbasketregs) && reg>otherreg
                thispairlikelihood=pairlikelihood_5failures(regord,otherregord);
                lw=6*thispairlikelihood/75;
                geoshow(gca,[regcenterlat otherregcenterlat],[regcenterlon otherregcenterlon],'DisplayType','line','LineWidth',lw,'color','k');
            end
        end
    end
    t=text(0.03,1.02,'c)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16,'color','k');
    
    
    set(gcf,'color','w');
    figname='breadbasketboxplot';curpart=2;highqualityfiguresetup;
end


if applygauppdefnsandmakeplot_reana==1
    %Unlike Gaupp et al. 2020, also add sensitivity tests to consider a range of possible CO2-fertilization effects
    
    %Breadbasket regions
    breadbasketregs=[3;7;8;10;19;20]; %Central US, NE Brazil, S South America, Central Europe, E Asia, S Asia
    %Order used in below arrays: S Asia, E Asia, SSA, NEB, Central Europe, Central US
    
    %Empirical thresholds from Gaupp et al.:
    
    %Central US: days above p75 May-Nov
    
    %NE Brazil: cumulative precip Nov-Feb -- threshold 0.55
    
    %Argentina/S South America: max temperature Dec-Feb -- threshold 0.67
    %Also S South America: cumulative precip Nov-Jan -- threshold 0.36
    
    %Europe: temperature May-Aug -- threshold 0.56
    %Also Europe: cumulative precip Mar-Aug -- threshold 0.38
    
    %China/E Asia: max temperature May-Sep -- threshold 0.65
    %Also E Asia: cumulative precip Jun-Aug -- threshold 0.45
    
    %India/S Asia: max temperature Jun-Oct -- threshold 0.58
    
    temperaturethreshs=[0;0;0.67;0.56;0.65;0.58];
    precipthreshs=[0;0.55;0.36;0.38;0.45;0];
    
    clear failures_hist_reana;
    
    for breadbasket=2:size(temperaturethreshs,1) %need to leave room for Central US at position 1
        if temperaturethreshs(breadbasket)~=0
            if breadbasket==6
                data_hist=mean(squeeze(alldailytempbyregion_reana_hist(20,:,6:10)),2);
            elseif breadbasket==5
                data_hist=mean(squeeze(alldailytempbyregion_reana_hist(19,:,5:9)),2);
            elseif breadbasket==3
                a=squeeze(alldailytempbyregion_reana_hist(8,:,12))';b=squeeze(alldailytempbyregion_reana_hist(8,:,1:2));
                c=cat(2,a,b);data_hist=mean(squeeze(c),2);
            elseif breadbasket==4
                data_hist=mean(squeeze(alldailytempbyregion_reana_hist(10,:,5:8)),2);
            end

            temperaturethresh=quantile(data_hist,temperaturethreshs(breadbasket));
            failures1_hist=data_hist>=temperaturethresh;
        end
        
        
        if precipthreshs(breadbasket)~=0
            if breadbasket==5
                a=squeeze(alldailyprecipbyregion_reana_hist(19,:,6:8));b=[];c=cat(3,a,b);data_hist=sum(squeeze(c),2);
            elseif breadbasket==3
                a=squeeze(alldailyprecipbyregion_reana_hist(8,:,11:12));b=squeeze(alldailyprecipbyregion_reana_hist(8,:,1))';
                c=cat(2,a,b);data_hist=sum(squeeze(c),2);
            elseif breadbasket==2
                a=squeeze(alldailyprecipbyregion_reana_hist(7,:,11:12));b=squeeze(alldailyprecipbyregion_reana_hist(7,:,1:2));
                c=cat(2,a,b);data_hist=sum(squeeze(c),2);
            elseif breadbasket==4
                a=squeeze(alldailyprecipbyregion_reana_hist(10,:,3:8));b=[];c=cat(3,a,b);data_hist=sum(squeeze(c),2);
            end
            
            precipthresh=quantile(data_hist,precipthreshs(breadbasket));
            failures2_hist=data_hist<=precipthresh;
        end
        
        %Combine temperature & precip info together
        if temperaturethreshs(breadbasket)~=0 && precipthreshs(breadbasket)~=0
            failures_hist_temp=failures1_hist+failures2_hist;
            failures_hist_temp(failures_hist_temp==1)=0;failures_hist_temp(failures_hist_temp==2)=1;
            failures_hist_reana(breadbasket,:,:)=failures_hist_temp;
        elseif precipthreshs(breadbasket)==0 %temperature only
            failures_hist_reana(breadbasket,:,:)=failures1_hist;
        elseif temperaturethreshs(breadbasket)==0 %precip only
            failures_hist_reana(breadbasket,:,:)=failures2_hist;
        end
    end
    
    %Now do Central US
    %Threshold is at 0.62 -- i.e., look for seasons whose count of p75 days is above the 62nd percentile of the distribution
    clear seasonsum_daysabovep75_hist;
    maynovtemperatures_hist=reshape(squeeze(mean(thismonthtemp_centralus_reana_hist(:,5:11,:,:),4)),[30 7*31]);
    daysabovep75_hist=maynovtemperatures_hist>=quantile(reshape(maynovtemperatures_hist,[30*217 1]),0.75);
    for j=1:30;seasonsum_daysabovep75_hist(j)=squeeze(sum(daysabovep75_hist(j,:)));end
    failures_hist_reana(1,:,:)=seasonsum_daysabovep75_hist>=quantile(seasonsum_daysabovep75_hist,0.62);
    
    save(strcat(tmaxdataloc,'failures_hist_reana'),'failures_hist_reana');
    
    
    %Compare risks of different multiple-breadbasket failures
    %Compare to Gaupp et al. 2020 figure 2c 
    
    %Regional risk analysis
    %For each pair of regions, when there are e.g. 3 breadbasket failures, how often are these two regions among the 3?
    failures_hist2d_reana=reshape(failures_hist_reana,[6 30]);
    countmatrix_3=zeros(6,6);countmatrix_4=zeros(6,6);countmatrix_5=zeros(6,6);
    numfailures_eachyear=sum(failures_hist2d_reana);
    threefailurescount_reana=sum(numfailures_eachyear==3);
    fourfailurescount_reana=sum(numfailures_eachyear==4);
    fivefailurescount_reana=sum(numfailures_eachyear==5);
    for regc1=1:6
        for regc2=1:6
            if regc1>regc2
                for i=1:size(failures_hist2d_reana,2)
                    if sum(failures_hist2d_reana(:,i))==3 
                        if failures_hist2d_reana(regc1,i)==1 && failures_hist2d_reana(regc2,i)==1
                            countmatrix_3(regc1,regc2)=countmatrix_3(regc1,regc2)+1;
                        end
                    end
                    if sum(failures_hist2d_reana(:,i))==4
                        if failures_hist2d_reana(regc1,i)==1 && failures_hist2d_reana(regc2,i)==1
                            countmatrix_4(regc1,regc2)=countmatrix_4(regc1,regc2)+1;
                        end
                    end
                    if sum(failures_hist2d_reana(:,i))==5
                        if failures_hist2d_reana(regc1,i)==1 && failures_hist2d_reana(regc2,i)==1
                            countmatrix_5(regc1,regc2)=countmatrix_5(regc1,regc2)+1;
                        end
                    end
                end
            end
        end
    end
    pairlikelihood_3failures_reana=100.*countmatrix_3./threefailurescount_reana; %percent likelihood of each pair when there are 3 failures
    pairlikelihood_4failures_reana=100.*countmatrix_4./fourfailurescount_reana;
    pairlikelihood_5failures_reana=100.*countmatrix_5./fivefailurescount_reana;
    
        
    figc=809;figure(figc);clf;curpart=1;highqualityfiguresetup;hold on;
    
    plotBlankMap(figc,'world60s60n_mainlandareasonly',0,'ghost white',0,{'stateboundaries';0});hold on;
    regcolors=colormaps('classy rainbow','more','not');
    for reg=1:numregs
        thiscolor=regcolors(round(128*(reg-0.5)/24),:);
        if ismember(reg,breadbasketregs)
            [lat,lon]=outlinegeoquad([regsouthedges(reg) regnorthedges(reg)],[regwestedges(reg) regeastedges(reg)],2,2);
            if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                [lat2,lon2]=outlinegeoquad([regsouthedges2(reg) regnorthedges2(reg)],[regwestedges2(reg) regeastedges2(reg)],2,2);
            end
            g1=geoshow(lat,lon,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',0.7);
            if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20;g2=geoshow(lat2,lon2,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',0.7);end
        end
    end
    
    %Add thick lines corresponding to pair likelihoods for the 3-breadbasket-failure scenario
    regord=0;otherregord=0;
    for reg=1:numregs
        regcenterlat=(regsouthedges(reg)+regnorthedges(reg))/2;regcenterlon=(regwestedges(reg)+regeastedges(reg))/2;
        for test=1:6;if breadbasketregs(test)==reg;regord=test;end;end
        
        if regord==5;regcenterlat=regcenterlat-2;elseif regord==2;regcenterlat=regcenterlat+2;elseif regord==3;regcenterlat=regcenterlat-7;...
        elseif regord==6;regcenterlat=regcenterlat-2;end
        if regord==3;regcenterlon=regcenterlon-2;elseif regord==5;regcenterlon=regcenterlon+5;elseif regord==6;regcenterlon=regcenterlon+3;end
        
        for otherreg=1:numregs
            otherregcenterlat=(regsouthedges(otherreg)+regnorthedges(otherreg))/2;otherregcenterlon=(regwestedges(otherreg)+regeastedges(otherreg))/2;
            for test=1:6;if breadbasketregs(test)==otherreg;otherregord=test;end;end
            
            if otherregord==5;otherregcenterlat=otherregcenterlat-2;elseif otherregord==2;otherregcenterlat=otherregcenterlat+2;...
            elseif otherregord==3;otherregcenterlat=otherregcenterlat-7;elseif otherregord==6;otherregcenterlat=otherregcenterlat-2;end
            if otherregord==3;otherregcenterlon=otherregcenterlon-2;elseif otherregord==5;otherregcenterlon=otherregcenterlon+5;...
            elseif otherregord==6;otherregcenterlon=otherregcenterlon+3;end
            
            if ismember(reg,breadbasketregs) && ismember(otherreg,breadbasketregs) && reg>otherreg
                thispairlikelihood=pairlikelihood_3failures_reana(regord,otherregord);
                lw=6*thispairlikelihood/75;
                if lw>0
                    geoshow(gca,[regcenterlat otherregcenterlat],[regcenterlon otherregcenterlon],'DisplayType','line','LineWidth',lw,'color','k');
                end
            end
        end
    end   
    
    set(gcf,'color','w');
    figname='breadbasketboxplot_reana';curpart=2;highqualityfiguresetup;
end





if compoundprecipdefinitionsensitivity==1
    histvecs=[squeeze(mean(mean(consecprextr_hist_vsp99_2days))) squeeze(mean(mean(consecprextr_hist_vsp99_3days))) squeeze(mean(mean(consecprextr_hist_vsp99_5days))) ...
        squeeze(mean(mean(consecprextr_hist_vsp95_2days))) squeeze(mean(mean(consecprextr_hist_vsp95_3days))) squeeze(mean(mean(consecprextr_hist_vsp95_5days))) ...
        squeeze(mean(mean(consecprextr_hist_vsp90_2days))) squeeze(mean(mean(consecprextr_hist_vsp90_3days))) squeeze(mean(mean(consecprextr_hist_vsp90_5days)))];
    futvecs=[squeeze(mean(mean(consecprextr_fut_vsp99_2days))) squeeze(mean(mean(consecprextr_fut_vsp99_3days))) squeeze(mean(mean(consecprextr_fut_vsp99_5days))) ...
        squeeze(mean(mean(consecprextr_fut_vsp95_2days))) squeeze(mean(mean(consecprextr_fut_vsp95_3days))) squeeze(mean(mean(consecprextr_fut_vsp95_5days))) ...
        squeeze(mean(mean(consecprextr_fut_vsp90_2days))) squeeze(mean(mean(consecprextr_fut_vsp90_3days))) squeeze(mean(mean(consecprextr_fut_vsp90_5days)))];
    for difftype=1:9
        for reg=1:numregs
            histvec=histvecs(reg,difftype);futvec=futvecs(reg,difftype);
            diffmatrix(difftype,reg)=100.*(futvec-histvec)./histvec;
        end
    end
    
    regcolors=colormaps('classy rainbow','more','not');
    figure(900);clf;hold on;curpart=1;highqualityfiguresetup;
    for reg=1:numregs
        thiscolor=regcolors(round(128*(reg-0.5)/24),:);
        scatter(reg,diffmatrix(1,reg),100,thiscolor,'s','filled');scatter(reg,diffmatrix(2,reg),100,thiscolor,'d','filled');
        scatter(reg,diffmatrix(3,reg),100,thiscolor,'^','filled');scatter(reg,diffmatrix(4,reg),100,thiscolor,'v','filled');
        scatter(reg,diffmatrix(6,reg),100,thiscolor,'>','filled');
        scatter(reg,diffmatrix(7,reg),100,thiscolor,'<','filled');scatter(reg,diffmatrix(8,reg),100,thiscolor,'p','filled');
        scatter(reg,diffmatrix(9,reg),100,thiscolor,'h','filled');
        scatter(reg,diffmatrix(5,reg),250,'k','o','filled');
    end
    set(gca,'fontweight','bold','fontname','arial','fontsize',12);ylim([-50 300]);
    set(gca,'xtick',1:24,'xticklabel',regnames);xtickangle(45);set(gca,'ytick',-50:50:300);
    ylabel('% Change','fontweight','bold','fontname','arial','fontsize',14);
    
    %Add label
    row1=280;row2=267;row3=254;
    col1=21.5;col2=22.5;col3=23.5;
    t=text(19.5,245,'Percentile');set(t,'fontweight','bold','fontname','arial','fontsize',12,'rotation',90);
    t=text(20,row1,'99th');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(20,row2,'95th');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(20,row3,'90th');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(22,300,'Days');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(col1-0.1,290,'2');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(col2-0.1,290,'3');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(col3-0.1,290,'5');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    scatter(col1,row1,100,'k','s','filled');
    scatter(col2,row1,100,'k','d','filled');
    scatter(col3,row1,100,'k','^','filled');
    scatter(col1,row2,100,'k','v','filled');
    scatter(col2,row2,100,'k','o','filled');
    scatter(col3,row2,100,'k','>','filled');
    scatter(col1,row3,100,'k','<','filled');
    scatter(col2,row3,100,'k','p','filled');
    scatter(col3,row3,100,'k','h','filled');
    
    figname='definitionsensitivity_precip';curpart=2;highqualityfiguresetup;
end


if compoundheatdefinitionsensitivity==1
    exist consecheatextr_hist_vsp99_2days;
    if ans==0
        f=load(strcat(tmaxdataloc,'mpiheatextremes_gridcelldefn'));
        consecheatextr_hist_vsp99_2days=f.consecheatextr_hist_vsp99_2days;consecheatextr_fut_vsp99_2days=f.consecheatextr_fut_vsp99_2days;
        consecheatextr_hist_vsp95_2days=f.consecheatextr_hist_vsp95_2days;consecheatextr_fut_vsp95_2days=f.consecheatextr_fut_vsp95_2days;
        consecheatextr_hist_vsp90_2days=f.consecheatextr_hist_vsp90_2days;consecheatextr_fut_vsp90_2days=f.consecheatextr_fut_vsp90_2days;
        consecheatextr_hist_vsp99_3days=f.consecheatextr_hist_vsp99_3days;consecheatextr_fut_vsp99_3days=f.consecheatextr_fut_vsp99_3days;
        consecheatextr_hist_vsp95_3days=f.consecheatextr_hist_vsp95_3days;consecheatextr_fut_vsp95_3days=f.consecheatextr_fut_vsp95_3days;
        consecheatextr_hist_vsp90_3days=f.consecheatextr_hist_vsp90_3days;consecheatextr_fut_vsp90_3days=f.consecheatextr_fut_vsp90_3days;
        consecheatextr_hist_vsp99_5days=f.consecheatextr_hist_vsp99_5days;consecheatextr_fut_vsp99_5days=f.consecheatextr_fut_vsp99_5days;
        consecheatextr_hist_vsp95_5days=f.consecheatextr_hist_vsp95_5days;consecheatextr_fut_vsp95_5days=f.consecheatextr_fut_vsp95_5days;
        consecheatextr_hist_vsp90_5days=f.consecheatextr_hist_vsp90_5days;consecheatextr_fut_vsp90_5days=f.consecheatextr_fut_vsp90_5days;
    end
    
    histvecs=[squeeze(mean(mean(consecheatextr_hist_vsp99_2days))) squeeze(mean(mean(consecheatextr_hist_vsp99_3days))) squeeze(mean(mean(consecheatextr_hist_vsp99_5days))) ...
        squeeze(mean(mean(consecheatextr_hist_vsp95_2days))) squeeze(mean(mean(consecheatextr_hist_vsp95_3days))) squeeze(mean(mean(consecheatextr_hist_vsp95_5days))) ...
        squeeze(mean(mean(consecheatextr_hist_vsp90_2days))) squeeze(mean(mean(consecheatextr_hist_vsp90_3days))) squeeze(mean(mean(consecheatextr_hist_vsp90_5days)))];
    futvecs=[squeeze(mean(mean(consecheatextr_fut_vsp99_2days))) squeeze(mean(mean(consecheatextr_fut_vsp99_3days))) squeeze(mean(mean(consecheatextr_fut_vsp99_5days))) ...
        squeeze(mean(mean(consecheatextr_fut_vsp95_2days))) squeeze(mean(mean(consecheatextr_fut_vsp95_3days))) squeeze(mean(mean(consecheatextr_fut_vsp95_5days))) ...
        squeeze(mean(mean(consecheatextr_fut_vsp90_2days))) squeeze(mean(mean(consecheatextr_fut_vsp90_3days))) squeeze(mean(mean(consecheatextr_fut_vsp90_5days)))];
    for difftype=1:9
        for reg=1:numregs
            histvec=histvecs(reg,difftype);futvec=futvecs(reg,difftype);
            diffmatrix(difftype,reg)=100.*(futvec-histvec)./histvec;
        end
    end
    
    regcolors=colormaps('classy rainbow','more','not');
    figure(900);clf;hold on;curpart=1;highqualityfiguresetup;
    for reg=1:numregs
        thiscolor=regcolors(round(128*(reg-0.5)/24),:);
        scatter(reg,diffmatrix(1,reg),100,thiscolor,'s','filled');scatter(reg,diffmatrix(2,reg),100,thiscolor,'d','filled');
        scatter(reg,diffmatrix(3,reg),100,thiscolor,'^','filled');scatter(reg,diffmatrix(4,reg),100,thiscolor,'v','filled');
        scatter(reg,diffmatrix(6,reg),100,thiscolor,'>','filled');
        scatter(reg,diffmatrix(7,reg),100,thiscolor,'<','filled');scatter(reg,diffmatrix(8,reg),100,thiscolor,'p','filled');
        scatter(reg,diffmatrix(9,reg),100,thiscolor,'h','filled');
        scatter(reg,diffmatrix(5,reg),250,'k','o','filled');
    end
    set(gca,'fontweight','bold','fontname','arial','fontsize',12);ylim([0 1600]);
    set(gca,'xtick',1:24,'xticklabel',regnames);xtickangle(45);set(gca,'ytick',0:250:1600);
    ylabel('% Change','fontweight','bold','fontname','arial','fontsize',14);
    
    %Add label
    row1=1450;row2=1400;row3=1350;
    col1=21.5;col2=22.5;col3=23.5;
    t=text(19.5,1300,'Percentile');set(t,'fontweight','bold','fontname','arial','fontsize',12,'rotation',90);
    t=text(20,row1,'99th');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(20,row2,'95th');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(20,row3,'90th');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(22,1550,'Days');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(col1-0.1,1500,'2');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(col2-0.1,1500,'3');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    t=text(col3-0.1,1500,'5');set(t,'fontweight','bold','fontname','arial','fontsize',12);
    scatter(col1,row1,100,'k','s','filled');
    scatter(col2,row1,100,'k','d','filled');
    scatter(col3,row1,100,'k','^','filled');
    scatter(col1,row2,100,'k','v','filled');
    scatter(col2,row2,100,'k','o','filled');
    scatter(col3,row2,100,'k','>','filled');
    scatter(col1,row3,100,'k','<','filled');
    scatter(col2,row3,100,'k','p','filled');
    scatter(col3,row3,100,'k','h','filled');
    
    figname='definitionsensitivity_heat';curpart=2;highqualityfiguresetup;
end



