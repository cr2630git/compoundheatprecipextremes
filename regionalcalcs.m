%Colin Raymond, 2021-22
%Mainscript must be run first (even without any loops selected)


prelimthings=1; %5 sec; required upon starting up
regionmap=0; %1 min; produces Figure S1

regionalheatdefn=0; %2 hrs
    %threshold used (e.g. 95th or 99th) is determined by extrheatpctile in mainscript.m
regionalheatdefn_merra2=0; %3 min
regionalheatchangefigures=0; %produces Figure 1
    if regionalheatchangefigures==1
        makefigs=1; 
            boxplotandmap_consecdays=1; %30 sec
                if boxplotandmap_consecdays==1;addmap=1;end 
                        
        boxplot1color=colors('crimson');
        boxplot2color=colors('light red');
        smallboxplot1color=colors('orange');
        smallboxplot2color=colors('sand');
    end
    
regionalprecipdefn=0; %1.5 hrs
    extremeprecipthresh='95'; %'95' is default
regionalprecipdefn_chirps=0; %3 min
regionalprecipchangefigures=0; %produces Figure 2
    if regionalprecipchangefigures==1
        makefigs=1;
            boxplotandmap_consecdays=1; %40 sec
                if boxplotandmap_consecdays==1;addmap=1;end 

        boxplot1color=colors('purple');
        boxplot2color=colors('light purple');
        smallboxplot1color=colors('turquoise');
        smallboxplot2color=colors('pink');
    end

volatilitydefn=0; %2 min; required for volatilityfigures loop
volatilitydefn_chirps=0; %5 sec
volatilityfigures=0; %1 min; produces Figure 3
    if volatilityfigures==1
        boxplotandmap_consecyears=1;
        cmap=flipud(colormaps('redwhitegray','more','not'));
    end
    

%Note re: colormaps: use blue-white-orange for precip, green-white-brown for drought, and blue-white-red for T
    
    


regnames={'NNA';'WNA';'CNA';'ENA';'CAM';'NSA';'NEB';'SSA';'NEU';'CEU';'MED';'SAH';'WAF';'EAF';'SAF';'NAS';'WAS';'CAS';'EAS';'SAS';'SEA';'NAU';'SAU';'NZL'};
numregs=size(regnames,1);

%Number of total historical extreme-precip days at each gridpt
%This doubles as a land/ocean mask
if prelimthings==1
    exist alldailyprecipbymonth_mpi_hist;
    if ans==0
        disp('Need to run readallprecipdata_mpi loop of mainscript.m');return;
    end
    
    extrdayspergridpt=squeeze(sum(squeeze(sum(squeeze(sum(squeeze(sum(alldailyprecipbymonth_mpi_hist,'omitnan')),3,'omitnan')),3,'omitnan')),3,'omitnan'))';
    for reg=1:numregs
        landgridptsum(reg)=sum(sum(regnums==reg & extrdayspergridpt>0));
        landgridptsum50n50s(reg)=sum(sum(regnums(:,6:59)==reg & extrdayspergridpt(:,6:59)>0));
    end
    
    regwestedges=[-105;-130;-105;-85;-105;-75;-50;-75;-10;5;-10;-20;-20;25;10;40;40;60;100;60;95;110;110;165];
    regeastedges=[-10;-105;-85;-60;-75;-50;-35;-40;40;40;40;40;25;50;50;180;60;100;145;95;155;155;155;180];
    regsouthedges=[50;30;30;25;5;-20;-20;-60;55;45;30;15;-15;-15;-35;50;15;30;20;5;-10;-30;-45;-50];
    regnorthedges=[85;60;50;50;20;10;0;-20;70;55;45;30;15;15;-15;70;50;50;50;30;20;-10;-30;-30];

    regwestedges2=[-170;NaN;NaN;NaN;-115;-85;NaN;NaN;-10;-5;NaN.*ones(9,1);95;NaN.*ones(4,1)];
    regeastedges2=[-105;NaN;NaN;NaN;-85;-75;NaN;NaN;5;5;NaN.*ones(9,1);100;NaN.*ones(4,1)];
    regsouthedges2=[60;NaN;NaN;NaN;20;-20;NaN;NaN;50;45;NaN.*ones(9,1);20;NaN.*ones(4,1)];
    regnorthedges2=[75;NaN;NaN;NaN;30;5;NaN;NaN;55;50;NaN.*ones(9,1);30;NaN.*ones(4,1)];
end


if regionmap==1
    facealpha=0.7;

    figure(1);clf;curpart=1;highqualityfiguresetup;
    plotBlankMap(1,'world',0,'ghost white',0,{'stateboundaries';0});hold on;
    regcolors=colormaps('classy rainbow','more','not');
    textleft=[0.3;0.22;0.26;0.31;0.26;0.32;0.37;0.34;0.51;0.52;0.52;0.52;0.49;0.57;0.54;0.68;0.59;0.66;0.75;0.67;0.77;0.8;0.78;0.865];
    textbottom=[0.85;0.76;0.72;0.7;0.59;0.48;0.45;0.31;0.84;0.78;0.71;0.62;0.54;0.49;0.37;0.83;0.71;0.73;0.71;0.62;0.51;0.39;0.3;0.28];
    for reg=1:numregs
        [lat,lon]=outlinegeoquad([regsouthedges(reg) regnorthedges(reg)],[regwestedges(reg) regeastedges(reg)],2,2);
        if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
            [lat2,lon2]=outlinegeoquad([regsouthedges2(reg) regnorthedges2(reg)],[regwestedges2(reg) regeastedges2(reg)],2,2);
        end
        thiscolor=regcolors(round(128*(reg-0.5)/24),:);
        
        t=text(textleft(reg),textbottom(reg),regnames{reg},'units','normalized');set(t,'fontsize',14,'fontweight','bold','fontname','arial');

        geoshow(lat,lon,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',facealpha);
        if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20;geoshow(lat2,lon2,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',facealpha);end
    end

    h=findall(gca);
    for i=1:size(h,1)
        if strcmp(class(h(i)),'matlab.graphics.primitive.Patch') && h(i).FaceAlpha==facealpha %all colored patches
            h(i).EdgeColor=h(i).FaceColor;h(i).EdgeAlpha=0;h(i).LineWidth=0.01;h(i).LineStyle=':';
        end
    end
    dontclear=1;plotBlankMap(1,'world',0,'ghost white',0,{'stateboundaries';0}); %so all borders look the same 


    figname='regionmap';curpart=2;highqualityfiguresetup;
end


%Defines regional extreme-precip days
if regionalprecipdefn==1
    %For each region, vary the areal threshold (the percent of a region's gridpoints required to exceed p95 for a day to be considered a regional extreme), 
        %such that these days historically occur 10% of the time
    desiredmeanfreq=0.1;
    
    %45 min
    if strcmp(extremeprecipthresh,'95')
        precip_mpi_hist=precipp95_mpi_hist;precip_mpi_fut=precipp95_mpi_fut;precipchoice=1;
    elseif strcmp(extremeprecipthresh,'99')
        precip_mpi_hist=precipp99_mpi_hist;precip_mpi_fut=precipp99_mpi_fut;precipchoice=2;
    end
    
    
    for reg=1:numregs
        if precipchoice==1;arealthreshold_extremeprecip(reg)=0.1;else;arealthreshold_extremeprecip(reg)=0.06;end %default guess, to start
        if landgridptsum(reg)>10;requiredcloseness=0.012;else;requiredcloseness=0.02;end
        continueon=1;
        while continueon==1
            regextremeprecipdays_hist=zeros(10,numdaysinmon,numyrs,nummonsinyr);
            regextremeprecipdays_fut=zeros(10,numdaysinmon,numyrs,nummonsinyr);
            for dim1=1:10 %rather than 100, just to speed things up because having all members is not crucial at this stage
                for dim4=1:numdaysinmon
                    for dim5=1:numyrs
                        for dim6=1:nummonsinyr
                            tmp=squeeze(precipp95_mpi_hist(dim1,:,:,dim4,dim5,dim6));
                            if sum(tmp(regnums==reg))>=arealthreshold_extremeprecip(reg)*landgridptsum(reg)
                                regextremeprecipdays_hist(dim1,dim4,dim5,dim6)=1;
                            end

                            tmp=squeeze(precipp95_mpi_fut(dim1,:,:,dim4,dim5,dim6));
                            if sum(tmp(regnums==reg))>=arealthreshold_extremeprecip(reg)*landgridptsum(reg)
                                regextremeprecipdays_fut(dim1,dim4,dim5,dim6)=1;
                            end
                        end
                    end
                end
            end
            if arealthreshold_extremeprecip(reg)==0.1;initialmean(reg)=mean(mean(mean(mean(regextremeprecipdays_hist))));end
            mean_sofar=mean(mean(mean(mean(regextremeprecipdays_hist))));
            distfromgoal=abs(mean_sofar-desiredmeanfreq);

            %Adjust threshold and iterate
            if distfromgoal>requiredcloseness
                if mean_sofar>desiredmeanfreq
                    arealthreshold_extremeprecip(reg)=(1.1+rand()/100)*arealthreshold_extremeprecip(reg);
                else
                    arealthreshold_extremeprecip(reg)=(0.9+rand()/100)*arealthreshold_extremeprecip(reg);
                end
                fprintf('Threshold is %0.03f, meansofar is %0.03f, distfromgoal is %0.03f\n',arealthreshold_extremeprecip(reg),mean_sofar,distfromgoal);
            else
                continueon=0;fprintf('Good enough for reg %d!\n',reg);
            end
        end
    end
    
    
    %Implement definition
    %Read in data for each ensemble member and complete calculation before
    %moving on to the next one, because there's too many ensemble members to
    %store in memory simultaneously
    regextremeprecipdays_hist=zeros(100,numdaysinmon,numyrs,nummonsinyr,numregs);
    regextremeprecipdays_fut=zeros(100,numdaysinmon,numyrs,nummonsinyr,numregs);
    regextremeprecipdays_fut_vsfut=zeros(100,numdaysinmon,numyrs,nummonsinyr,numregs);
    numprecipdaysabove_bygridpt_hist=zeros(100,numlons,numlats,nummonsinyr);
    numprecipdaysabove_bygridpt_fut=zeros(100,numlons,numlats,nummonsinyr);
    numprecipdaysabove_bygridpt_fut_vsfut=zeros(100,numlons,numlats,nummonsinyr);
    extremeprecipthresholdbygridptandmonth_hist=zeros(100,numlons,numlats,nummonsinyr);
    extremeprecipthresholdbygridptandmonth_fut=zeros(100,numlons,numlats,nummonsinyr);
    if precipchoice==1
        precipannual_mpi_hist=p95precipannual_mpi_hist;precipannual_mpi_fut=p95precipannual_mpi_fut;
        arealthreshold_extremeprecip_p95=arealthreshold_extremeprecip;
    elseif precipchoice==2
        precipannual_mpi_hist=p99precipannual_mpi_hist;precipannual_mpi_fut=p99precipannual_mpi_fut;
        arealthreshold_extremeprecip_p99=arealthreshold_extremeprecip;
    end
    for dim1=1:100
        memnum=200+dim1;
        
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

            precipdata_thisensmem=NaN.*ones(numlons,numlats,numdaysinmon,numyrs,nummonsinyr);
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

            %Find gridpoints above the historical annual extreme threshold, and the future annual extreme threshold 
            extremeprecipvshist_thisensmem=NaN.*ones(size(precipdata_thisensmem));
            if loop==2
                extremeprecipvsfut_thisensmem=NaN.*ones(size(precipdata_thisensmem));
            end
            for dim4=1:numdaysinmon
                for dim5=1:numyrs
                    extremeprecipvshist_thisensmem(:,:,dim4,dim5,:)=squeeze(precipdata_thisensmem(:,:,dim4,dim5,:))>=precipannual_mpi_hist;
                    if loop==2
                        extremeprecipvsfut_thisensmem(:,:,dim4,dim5,:)=squeeze(precipdata_thisensmem(:,:,dim4,dim5,:))>=precipannual_mpi_fut;
                    end
                end
            end

            regextremeprecipdaysvshist=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
            if loop==2
                regextremeprecipdaysvsfut=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
            end
            for dim4=1:numdaysinmon
                for dim5=1:numyrs
                    for dim6=1:nummonsinyr
                        for reg=1:numregs
                            tmp=squeeze(extremeprecipvshist_thisensmem(:,:,dim4,dim5,dim6));
                            if sum(tmp(regnums==reg))>=arealthreshold_extremeprecip(reg)*landgridptsum(reg)
                                regextremeprecipdaysvshist(dim4,dim5,dim6,reg)=1;
                            end
                            
                            if loop==2
                                tmp=squeeze(extremeprecipvsfut_thisensmem(:,:,dim4,dim5,dim6));
                                if sum(tmp(regnums==reg))>=arealthreshold_extremeprecip(reg)*landgridptsum(reg)
                                    regextremeprecipdaysvsfut(dim4,dim5,dim6,reg)=1;
                                end
                            end
                        end
                    end
                end
            end
            
            
            %Also compute change in regional extreme thresholds
            numdaysabove_bygridpt=zeros(192,64,12);numdaysabove_bygridpt_fut_vsfut=zeros(192,64,12);
            extremethresholdbygridptandmonth=zeros(192,64,12);
            for month=1:12
                tmp=reshape(squeeze(precipdata_thisensmem(:,:,:,:,month)),[numlons numlats numdaysinmon*numyrs]);
                extremethresholdbygridptandmonth(:,:,month)=squeeze(quantile(tmp,str2double(extremeprecipthresh)/100,3));

                for i=1:192
                    for j=1:64
                        numdaysabove_bygridpt(i,j,month)=sum(squeeze(tmp(i,j,:)>=precipannual_mpi_hist(i,j)));
                        if loop==2
                            numdaysabove_bygridpt_fut_vsfut(i,j,month)=sum(squeeze(tmp(i,j,:)>=precipannual_mpi_fut(i,j)));
                        end
                    end
                end
            end
            
            
            if loop==1
                regextremeprecipdays_hist(dim1,:,:,:,:)=regextremeprecipdaysvshist;
                numprecipdaysabove_bygridpt_hist(dim1,:,:,:)=numdaysabove_bygridpt;
                extremeprecipthresholdbygridptandmonth_hist(dim1,:,:,:)=extremethresholdbygridptandmonth;
            elseif loop==2
                regextremeprecipdays_fut(dim1,:,:,:,:)=regextremeprecipdaysvshist;
                regextremeprecipdays_fut_vsfut(dim1,:,:,:,:)=regextremeprecipdaysvsfut;
                numprecipdaysabove_bygridpt_fut(dim1,:,:,:)=numdaysabove_bygridpt;
                numprecipdaysabove_bygridpt_fut_vsfut(dim1,:,:,:)=numdaysabove_bygridpt_fut_vsfut;
                extremeprecipthresholdbygridptandmonth_fut(dim1,:,:,:)=extremethresholdbygridptandmonth;
            end
            
        end
        
        disp(dim1);disp(clock);
    end
    if precipchoice==1 %p95
        extremeprecipp95vshist_thisensmem=extremeprecipvshist_thisensmem;
        extremeprecipp95vsfut_thisensmem=extremeprecipvsfut_thisensmem;
        p95bygridptandmonth_hist_precip=extremeprecipthresholdbygridptandmonth_hist;
        p95bygridptandmonth_fut_precip=extremeprecipthresholdbygridptandmonth_fut;
        regextremeprecipdaysp95_hist=regextremeprecipdays_hist;
        regextremeprecipdaysp95_fut=regextremeprecipdays_fut;
        regextremeprecipdaysp95_fut_vsfut=regextremeprecipdays_fut_vsfut;
        numdaysabovep95_bygridpt_hist_precip=numprecipdaysabove_bygridpt_hist;
        numdaysabovep95_bygridpt_fut_precip=numprecipdaysabove_bygridpt_fut;
        numdaysabovep95_bygridpt_fut_vsfut_precip=numprecipdaysabove_bygridpt_fut_vsfut;
        save(strcat(precipdataloc,'extremepreciparray_mpi.mat'),'regextremeprecipdaysp95_hist',...
            'regextremeprecipdaysp95_fut','regextremeprecipdaysp95_fut_vsfut',...
            'p95bygridptandmonth_hist_precip','p95bygridptandmonth_fut_precip',...
            'numdaysabovep95_bygridpt_hist_precip','numdaysabovep95_bygridpt_fut_precip','numdaysabovep95_bygridpt_fut_vsfut_precip',...
            'arealthreshold_extremeprecip_p95','-append');
    elseif precipchoice==2 %p99
        extremeprecipp99vshist_thisensmem=extremeprecipvshist_thisensmem;
        extremeprecipp99vsfut_thisensmem=extremeprecipvsfut_thisensmem;
        p99bygridptandmonth_hist_precip=extremeprecipthresholdbygridptandmonth_hist;
        p99bygridptandmonth_fut_precip=extremeprecipthresholdbygridptandmonth_fut;
        regextremeprecipdaysp99_hist=regextremeprecipdays_hist;
        regextremeprecipdaysp99_fut=regextremeprecipdays_fut;
        regextremeprecipdaysp99_fut_vsfut=regextremeprecipdays_fut_vsfut;
        numdaysabovep99_bygridpt_hist_precip=numprecipdaysabove_bygridpt_hist;
        numdaysabovep99_bygridpt_fut_precip=numprecipdaysabove_bygridpt_fut;
        numdaysabovep99_bygridpt_fut_vsfut_precip=numprecipdaysabove_bygridpt_fut_vsfut;
        save(strcat(precipdataloc,'extremepreciparray_mpi.mat'),'regextremeprecipdaysp99_hist',...
            'regextremeprecipdaysp99_fut','regextremeprecipdaysp99_fut_vsfut',...
            'p99bygridptandmonth_hist_precip','p99bygridptandmonth_fut_precip',...
            'numdaysabovep99_bygridpt_hist_precip','numdaysabovep99_bygridpt_fut_precip','numdaysabovep99_bygridpt_fut_vsfut_precip',...
            'arealthreshold_extremeprecip_p99','-append');
    end
end


if regionalprecipdefn_chirps==1
    %Defines regional extreme-precip days
    desiredmeanfreq=0.1;
    if extrprecippctile==0.99
        precip_chirps_hist=precipp99_chirps_hist;extremeprecipthreshannual_chirps_hist=p99precipthreshannual_chirps_hist;
    elseif extrprecippctile==0.95
        precip_chirps_hist=precipp95_chirps_hist;extremeprecipthreshannual_chirps_hist=p95precipthreshannual_chirps_hist;
    end
    for reg=1:numregs
        if reg~=1 && reg~=9 && reg~=16 %CHIRPS has no data for these regions, because it includes only 50N-50S
            arealthreshold_extremeprecip_chirps(reg)=0.08; %default guess, to start
            
            landgridptsum50n50s_no0(reg)=sum(sum(regnums(:,6:59)==reg & extrdayspergridpt(:,6:59)>0 & fliplr(extremeprecipthreshannual_chirps_hist(:,6:59)>0)));
    
            
            if landgridptsum50n50s_no0(reg)>100;requiredcloseness=0.013;elseif landgridptsum50n50s_no0(reg)>10;requiredcloseness=0.018;else;requiredcloseness=0.03;end
            if reg==12;requiredcloseness=0.025;end %special case of the Sahara
            continueon=1;
            while continueon==1
                regextremeprecipdays_hist_chirps=zeros(365,30);
                for dim1=1:size(precip_chirps_hist,1)
                    for dim2=1:size(precip_chirps_hist,2)
                        tmp=squeeze(precip_chirps_hist(dim1,dim2,:,:));tmp=fliplr(tmp);
                        if sum(tmp(regnums==reg))>=arealthreshold_extremeprecip_chirps(reg)*landgridptsum50n50s_no0(reg)
                            regextremeprecipdays_hist_chirps(dim1,dim2)=1;
                        end
                    end
                end
                mean_sofar=mean(mean(mean(mean(regextremeprecipdays_hist_chirps))));
                distfromgoal=abs(mean_sofar-desiredmeanfreq);

                %Adjust threshold and iterate
                if distfromgoal>requiredcloseness
                    if mean_sofar>desiredmeanfreq
                        arealthreshold_extremeprecip_chirps(reg)=(1.1+rand()/100)*arealthreshold_extremeprecip_chirps(reg);
                    else
                        arealthreshold_extremeprecip_chirps(reg)=(0.9+rand()/100)*arealthreshold_extremeprecip_chirps(reg);
                    end
                    fprintf('Threshold for extreme precip is %0.03f, meansofar is %0.03f, distfromgoal is %0.03f\n',arealthreshold_extremeprecip_chirps(reg),mean_sofar,distfromgoal);
                else
                    fprintf('Threshold for extreme precip is %0.03f, meansofar is %0.03f, distfromgoal is %0.03f\n',arealthreshold_extremeprecip_chirps(reg),mean_sofar,distfromgoal);
                    continueon=0;fprintf('Good enough for reg %d!\n',reg);
                end
            end
            arealthreshold_extremeprecip_p95_chirps=arealthreshold_extremeprecip_chirps;
        end
    end
    
    %Implement definition
    thisfile=permute(allyearsdata_chirps_3d,[2 1 4 3]);
    curyear=1991;startyear=1981;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
    tempdata=NaN.*ones(192,64,31,30,12);
    for curyear=1991:2020
        tempdata(:,:,1:31,curyear-(startyear-1),1)=permute(squeeze(thisfile(curyear-startyear+1,1:31,:,:)),[3 2 1]);
        tempdata(:,:,1:28,curyear-(startyear-1),2)=permute(squeeze(thisfile(curyear-startyear+1,32:59,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),3)=permute(squeeze(thisfile(curyear-startyear+1,61:91,:,:)),[3 2 1]);
        tempdata(:,:,1:30,curyear-(startyear-1),4)=permute(squeeze(thisfile(curyear-startyear+1,92:121,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),5)=permute(squeeze(thisfile(curyear-startyear+1,122:152,:,:)),[3 2 1]);
        tempdata(:,:,1:30,curyear-(startyear-1),6)=permute(squeeze(thisfile(curyear-startyear+1,153:182,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),7)=permute(squeeze(thisfile(curyear-startyear+1,183:213,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),8)=permute(squeeze(thisfile(curyear-startyear+1,214:244,:,:)),[3 2 1]);
        tempdata(:,:,1:30,curyear-(startyear-1),9)=permute(squeeze(thisfile(curyear-startyear+1,245:274,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),10)=permute(squeeze(thisfile(curyear-startyear+1,275:305,:,:)),[3 2 1]);
        tempdata(:,:,1:30,curyear-(startyear-1),11)=permute(squeeze(thisfile(curyear-startyear+1,305:334,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),12)=permute(squeeze(thisfile(curyear-startyear+1,335:365,:,:)),[3 2 1]);
    end
    
    
    regextremeprecipdays_chirps=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
    for reg=1:numregs
        for doy=1:365
            for yr=1:30
                tmp=squeeze(precipp95_chirps_hist(doy,yr,:,:));tmp=fliplr(tmp);
                if sum(tmp(regnums==reg),'omitnan')>=arealthreshold_extremeprecip_chirps(reg)*landgridptsum50n50s_no0(reg)
                    mon=DOYtoMonth(doy,1999);dom=DOYtoDOM(doy,1999);
                    regextremeprecipdays_chirps(dom,yr,mon,reg)=1;
                end
            end
        end
    end

    regp95extremeprecipdays_hist_chirps=regextremeprecipdays_chirps;
end


if regionalprecipchangefigures==1
    %Main focus of figure is boxplot across ensemble members
    if makefigs==1
        nameappend='consec';
        memsincl=99; %default is 99
        
        histprobdays=squeeze(sum(eval(['consecprextr_hist_vsp' num2str(100*extrprecippctile) '_3days;']),2));
        futureprobdays=squeeze(sum(eval(['consecprextr_fut_vsp' num2str(100*extrprecippctile) '_3days;']),2));
        futureprobdays_vsfut=squeeze(sum(eval(['consecprextr_fut_vsfut_vsp' num2str(100*extrprecippctile) '_3days;']),2));
        histprobdays_chirps=squeeze(sum(consecprextr_hist_vsp95_3days_chirps));
        
        %histprobdays comes from temporaryhist_vsp95
        %histprobdays_chirps comes from precipp95_chirps_hist
     
        toosmall=histprobdays<0.01;histprobdays(toosmall)=NaN;
        toosmall=histprobdays_chirps<0.01;histprobdays_chirps(toosmall)=NaN;

        if boxplotandmap_consecdays==1
            figc=792;
            figure(figc);clf;curpart=1;highqualityfiguresetup;
            if addmap==1;subplot(3,1,1);else;subplot(2,1,1);end
            
            %Top panel: historical boxplot of prob of compound extreme days
            probofadaybeingextremecompound=NaN.*ones(100,24);probofadaybeingextremecompound_chirps=NaN.*ones(100,24);
            for reg=1:numregs
                if sum(sum(regnums_precip==reg))>0
                    probofadaybeingextremecompound(:,reg)=100.*histprobdays(:,reg)./(365*30*sum(sum(regnums_precip==reg)));
                    probofadaybeingextremecompound_chirps(reg)=100.*histprobdays_chirps(reg)./(365*30*sum(sum(regnums_precip_chirps==reg)));
                end
            end
            
            x=[];g=[];
            for reg=1:numregs
                x=[x;probofadaybeingextremecompound(1:memsincl,reg)];
                g=[g;reg*2.*ones(memsincl,1);];
            end
            b=boxplot(x,g);hold on;
            
            box_h=findobj(gca,'Tag','Box');medianline=findobj(gca,'Tag','Median');
            upperwhisker=findobj(gca,'Tag','Upper Whisker');lowerwhisker=findobj(gca,'Tag','Lower Whisker');
            upperadjacentvalue=findobj(gca,'Tag','Upper Adjacent Value');loweradjacentvalue=findobj(gca,'Tag','Lower Adjacent Value');
            outliers=findobj(gca,'Tag','Outliers');
            for i=1:numregs
                set(box_h,'color',boxplot2color,'linewidth',2);set(medianline,'color',boxplot2color,'linewidth',2);
                set(upperwhisker,'color',boxplot2color,'linewidth',2);set(lowerwhisker,'color',boxplot2color,'linewidth',2);
                set(upperadjacentvalue,'color',boxplot2color,'linewidth',2);set(loweradjacentvalue,'color',boxplot2color,'linewidth',2);
                set(outliers,'MarkerEdgeColor','k');
            end
            
            %Add black dot showing historical temporal-compounding probability from CHIRPS
            for reg=1:numregs
                scatter(reg,probofadaybeingextremecompound_chirps(reg),75,'k','filled');
            end
            
            set(gca,'xtick','','xticklabel','');xtickangle(45);

           ymin=0;ymax=2;ylim([ymin ymax]);
           set(gca,'ytick',ymin:0.5:ymax);
            
            %Add background shading to make regions easier to distinguish
            regcolors=colormaps('classy rainbow','more','not');
            for reg=1:numregs
                thiscolor=regcolors(round(128*(reg-0.5)/24),:);
                x=[reg-0.5 reg+0.5 reg+0.5 reg-0.5];y=[ymin ymin ymax ymax];p=patch(x,y,thiscolor,'FaceAlpha',0.1,'EdgeColor','k');
            end
            
            set(gca,'fontweight','bold','fontname','arial','fontsize',axislabelsize);
            ylabel('Hist. Prob. (%)','fontweight','bold','fontname','arial','fontsize',axislabelsize);
            
            t=text(-0.1,1.01,'a)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
            if addmap==1;set(gca,'position',[0.15 0.78 0.7 0.2]);else;set(gca,'position',[0.15 0.69 0.7 0.29]);end
            
            
            
            %Middle section: projected changes
            if addmap==1;axes('Position',[0.15 0.4 0.7 0.36]);else;axes('Position',[0.15 0.1 0.7 0.54]);end
            x=[];g=[];
            clear pctdiff_compounding_total;clear pctdiff_compounding_thermodyn;clear pctdiff_compounding_nonlinear;
            for reg=1:numregs
                histcompounding=histprobdays(1:memsincl,reg);
                futurecompounding_histthresh=futureprobdays(1:memsincl,reg); %total change
                futurecompounding_futthresh=futureprobdays_vsfut(1:memsincl,reg);
                thermodyneffect=futurecompounding_histthresh-futurecompounding_futthresh;
                nonlineareffect=futurecompounding_histthresh-thermodyneffect; %aka dynamic effect
                
                %More-intuitive example: suppose there is historically 1
                %heat wave per year, measured against a threshold of 30C.
                %The future heat-wave count measured against 30C is 15,
                %while the future heat-wave count measured against 35C is
                %3. In this case, the diff_total is 14, the diff_thermodyn
                %is 12, and the diff_nonlinear is 2
                
                diff_compounding_total=futurecompounding_histthresh-histcompounding;
                pctdiff_compounding_total(:,reg)=100.*(diff_compounding_total)./histcompounding;
                
                diff_compounding_thermodyn=futurecompounding_histthresh-futurecompounding_futthresh;
                diff_compounding_nonlinear=futurecompounding_futthresh-histcompounding;
                
                pctdiff_compounding_thermodyn(:,reg)=(diff_compounding_thermodyn./diff_compounding_total).*pctdiff_compounding_total(:,reg);
                pctdiff_compounding_nonlinear(:,reg)=(diff_compounding_nonlinear./diff_compounding_total).*pctdiff_compounding_total(:,reg);
                
                x=[x;pctdiff_compounding_total(:,reg);pctdiff_compounding_thermodyn(:,reg);pctdiff_compounding_nonlinear(:,reg)];
                g=[g;(reg*3-2).*ones(memsincl,1);(reg*3-1).*ones(memsincl,1);(reg*3).*ones(memsincl,1)];
            end
            boxplot(x,g);hold on;
            
            %Color boxes differently for each dataset
            color1=boxplot1color;color2=smallboxplot1color;color3=smallboxplot2color;shrinkrighthandboxes=1;
            boxplot_3datasetsalternating;

            if addmap==1;axislabelsize=12;else;axislabelsize=14;end           
            set(gca,'fontweight','bold','fontname','arial','fontsize',axislabelsize);
            set(gca,'xtick','','xticklabel',{});
            if addmap==1;ymin=-75;ymax=150;y95th=ymin+0.96*(ymax-ymin);else;ymin=-75;ymax=225;end
            ylim([ymin ymax]);
            
            
            %Add dashed zero line
            x=[0 numregs*3+1];y=[0 0];plot(x,y,'k--','linewidth',1);
            
            %Add significance stars -- large for >95% of ensemble members
            %agreeing on sign, small for >67% of ensemble members agreeing on sign
            for reg=1:numregs
                if (quantile(pctdiff_compounding_total(:,reg),0.5)>=0 && quantile(pctdiff_compounding_total(:,reg),0.05)>=0) ||...
                       (quantile(pctdiff_compounding_total(:,reg),0.5)<=0 && quantile(pctdiff_compounding_total(:,reg),0.95)<=0) %very signif.
                    plot(reg*3-2,y95th,'p','MarkerSize',10,'MarkerFaceColor',boxplot1color,'MarkerEdgeColor',boxplot1color);
                elseif (quantile(pctdiff_compounding_total(:,reg),0.5)>=0 && quantile(pctdiff_compounding_total(:,reg),0.33)>=0) ||...
                       (quantile(pctdiff_compounding_total(:,reg),0.5)<=0 && quantile(pctdiff_compounding_total(:,reg),0.67)<=0) %moderately signif. increase
                    plot(reg*3-2,y95th,'p','MarkerSize',7,'MarkerFaceColor',boxplot1color,'MarkerEdgeColor',boxplot1color);
                end
                if (quantile(pctdiff_compounding_thermodyn(:,reg),0.5)>=0 && quantile(pctdiff_compounding_thermodyn(:,reg),0.05)>=0) ||...
                       (quantile(pctdiff_compounding_thermodyn(:,reg),0.5)<=0 && quantile(pctdiff_compounding_thermodyn(:,reg),0.95)<=0) %very signif.
                    plot(reg*3-1,y95th,'p','MarkerSize',10,'MarkerFaceColor',smallboxplot2color,'MarkerEdgeColor',smallboxplot2color);
                elseif (quantile(pctdiff_compounding_thermodyn(:,reg),0.5)>=0 && quantile(pctdiff_compounding_thermodyn(:,reg),0.33)>=0) ||...
                       (quantile(pctdiff_compounding_thermodyn(:,reg),0.5)<=0 && quantile(pctdiff_compounding_thermodyn(:,reg),0.67)<=0) %moderately signif. increase
                    plot(reg*3-1,y95th,'p','MarkerSize',7,'MarkerFaceColor',smallboxplot2color,'MarkerEdgeColor',smallboxplot2color);
                end
                if (quantile(pctdiff_compounding_nonlinear(:,reg),0.5)>=0 && quantile(pctdiff_compounding_nonlinear(:,reg),0.05)>=0) ||...
                       (quantile(pctdiff_compounding_nonlinear(:,reg),0.5)<=0 && quantile(pctdiff_compounding_nonlinear(:,reg),0.95)<=0) %very signif.
                    plot(reg*3,y95th,'p','MarkerSize',10,'MarkerFaceColor',smallboxplot1color,'MarkerEdgeColor',smallboxplot1color);
                elseif (quantile(pctdiff_compounding_nonlinear(:,reg),0.5)>=0 && quantile(pctdiff_compounding_nonlinear(:,reg),0.33)>=0) ||...
                       (quantile(pctdiff_compounding_nonlinear(:,reg),0.5)<=0 && quantile(pctdiff_compounding_nonlinear(:,reg),0.67)<=0) %moderately signif. increase
                    plot(reg*3,y95th,'p','MarkerSize',7,'MarkerFaceColor',smallboxplot1color,'MarkerEdgeColor',smallboxplot1color);
                end
            end
                        
            %Add background shading to make regions easier to distinguish
            regcolors=colormaps('classy rainbow','more','not');
            for reg=1:numregs
                thiscolor=regcolors(round(128*(reg-0.5)/24),:);
                if rem(reg,2)==0;weight=0.1;else;weight=0.1;end
                x=[reg*3-2.5 reg*3+0.5 reg*3+0.5 reg*3-2.5];y=[ymin ymin ymax ymax];p=patch(x,y,thiscolor,'FaceAlpha',weight,'EdgeColor','k');
            end
            
            
            %title('Regional Extreme Compound Precipitation, 1991-2020 Versus 2070-2099','fontweight','bold','fontname','arial','fontsize',16);
            ylabel('% Change','fontweight','bold','fontname','arial','fontsize',axislabelsize);
            set(gca,'xtick',2:3:numregs*3,'xticklabel',regnames);xtickangle(45);
            set(gcf,'color','w');            

            %Add scatterplot
            if addmap==0
                axes('Position',[0.3 0.81 0.12 0.12],'color','none');
                totalpctchangebyreg=100.*(mean(futureprobdays)-mean(histprobdays))./mean(histprobdays);
                thermodynpctchangebyreg=totalpctchangebyreg-(100.*(mean(futureprobdays_vsfut)-mean(histprobdays))./mean(histprobdays));
                scatter(totalpctchangebyreg,squeeze(mean(pctdaysabovep95change,2))',18,'k','filled');
                set(gca,'fontweight','bold','fontname','arial','fontsize',10,'XColor',boxplot1color,'YColor',smallboxplot2color);
                corr1=(mean(futureprobdays)-mean(histprobdays))./mean(histprobdays);corr2=squeeze(mean(pctdaysabovep95change,2));
                t=text(0.6,0.2,sprintf('r=%0.02f',corr(corr1',corr2)),'units','normalized');
                set(t,'fontweight','bold','fontname','arial','fontsize',10,'color','k');
            end

            t=text(-0.1,1.01,'b)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
            
            
            %Add map
            if addmap==1
                pctchange_compounding=quantile(pctdiff_compounding_total,0.5);

                facealpha=0.7;
                cmap=colormaps('bluewhiteorange','more','not');
                cutoffs=[-100;-50;-25;-10;0;10;25;50;100];
                intervals_displayonfigure=[0;0;1;1;1;1;1;1];
                endsopen=0; %specifies whether final interval is >=penultimate cutoff or {>penultimate & <final}

                axes('Position',[0.15 -0.05 0.7 0.42]);
                plotBlankMap(figc,'worldnorthof60s',0,'ghost white',0,{'stateboundaries';0});hold on;
                for reg=1:numregs
                    [lat,lon]=outlinegeoquad([regsouthedges(reg) regnorthedges(reg)],[regwestedges(reg) regeastedges(reg)],2,2);
                    if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                        [lat2,lon2]=outlinegeoquad([regsouthedges2(reg) regnorthedges2(reg)],[regwestedges2(reg) regeastedges2(reg)],2,2);
                    end

                    endsopen=0;
                    [thiscolor,startat,cmapintervalsize]=nicecolorcategories(pctchange_compounding(reg),cmap,cutoffs,endsopen,'dontuseendcolors');

                    g1=geoshow(lat,lon,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',facealpha);
                    if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20;g2=geoshow(lat2,lon2,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',facealpha);end

                    %Add hatching for regions where at least 2/3 of ensemble members DO NOT
                    %agree on the sign of the change (reversed from the old ways)
                    %Adding "hatches to patches"
                    if pctchange_compounding(reg)>=0 && quantile(pctdiff_compounding_total(:,reg),0.33)>=0
                    elseif pctchange_compounding(reg)<=0 && quantile(pctdiff_compounding_total(:,reg),0.67)<=0
                    else %insignificant, so YES add hatching
                        hatchfill2(g1,'single','HatchDensity',50,'HatchColor','k','HatchLineWidth',0.8);
                        if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                            hatchfill2(g2,'single','HatchDensity',50,'HatchColor','k','HatchLineWidth',0.8);
                        end
                    end
                end

                h=findall(gca);
                for i=1:size(h,1)
                    if strcmp(class(h(i)),'matlab.graphics.primitive.Patch') && h(i).FaceAlpha==facealpha %all colored patches
                        h(i).EdgeColor=h(i).FaceColor;h(i).EdgeAlpha=0;h(i).LineWidth=0.01;h(i).LineStyle=':';
                    end
                end
                dontclear=1;plotBlankMap(figc,'worldnorthof60s',0,'ghost white',0,{'stateboundaries';0}); %so all borders look the same 

                %Colorbar and its label
                cbleftpos=0.73;cbwidth=0.01;cbboxheight=0.03;cbbottomstart=0.16-size(cutoffs,1)/2*cbboxheight;
                textbottomstart=0.2;textspacing=cbboxheight*2.5;
                for intervalcount=1:size(intervals_displayonfigure,1)
                    if intervalcount==1
                        if endsopen==1
                            thistextdescrip=strcat(['<',num2str(cutoffs(1)),'%']);
                        else
                            thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                        end
                    elseif intervalcount==size(intervals_displayonfigure,1)
                        if endsopen==1
                            thistextdescrip=strcat(['>',num2str(cutoffs(end-1)),'%']);
                        else
                            thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                        end
                    else
                        thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                    end
                    if intervals_displayonfigure(intervalcount)==1
                        annotation('rectangle',[cbleftpos cbbottomstart+(intervalcount-1)*cbboxheight cbwidth cbboxheight],...
                            'FaceColor',cmap(round(startat+cmapintervalsize*(intervalcount-1)),:),...
                            'EdgeColor',cmap(round(startat+cmapintervalsize*(intervalcount-1)),:),'FaceAlpha',facealpha);
                        t=text(1,textbottomstart+(intervalcount-1)*textspacing,thistextdescrip,'units','normalized');
                        set(t,'fontsize',11,'fontweight','bold','fontname','arial');
                    end
                end
                
                t=text(-0.1,0.9,'c)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
            end

            
            figname=strcat('extrprecipchange_regs_3day',nameappend);curpart=2;highqualityfiguresetup;
        end
    end
end


if regionalheatdefn==1
    %Defines regional extreme-heat days
    %For each region, vary the areal threshold 
    %(the percent of a region's gridpoints required to exceed p95 for a day to be considered a regional extreme), 
        %such that these days historically occur 10% of the time
    %Note that historical compound extremes may occur more or less often than 10%,
        %depending on the spatial correlations in a region
    desiredmeanfreq=0.1;
    
    %45 min per loop
    %Loop 1: p95 thresh
    %Loop 2: p99 thresh
    if extrheatpctile==0.99
        temp_mpi_hist=tempp99_mpi_hist;temp_mpi_fut=tempp99_mpi_fut;heatchoice=1;
    elseif extrheatpctile==0.95
        temp_mpi_hist=tempp95_mpi_hist;temp_mpi_fut=tempp95_mpi_fut;heatchoice=2;
    end
        
    for reg=1:numregs
        if extrheatpctile==0.99;arealthreshold_extremeheat(reg)=0.08;elseif extrheatpctile==0.95;arealthreshold_extremeheat(reg)=0.15;end %default guess, to start
        if landgridptsum(reg)>100;requiredcloseness=0.01;elseif landgridptsum(reg)>10;requiredcloseness=0.02;else;requiredcloseness=0.025;end
        continueon=1;
        while continueon==1
            regextremeheatdays_hist=zeros(10,numdaysinmon,numyrs,nummonsinyr);
            regextremeheatdays_fut=zeros(10,numdaysinmon,numyrs,nummonsinyr);
            for dim1=1:10 %rather than 100, just to speed things up because having all members is not crucial at this stage
                for dim4=1:numdaysinmon
                    for dim5=1:numyrs
                        for dim6=1:nummonsinyr
                            tmp=squeeze(temp_mpi_hist(dim1,:,:,dim4,dim5,dim6));
                            if sum(tmp(regnums==reg))>=arealthreshold_extremeheat(reg)*landgridptsum(reg)
                                regextremeheatdays_hist(dim1,dim4,dim5,dim6)=1;
                            end

                            tmp=squeeze(temp_mpi_fut(dim1,:,:,dim4,dim5,dim6));
                            if sum(tmp(regnums==reg))>=arealthreshold_extremeheat(reg)*landgridptsum(reg)
                                regextremeheatdays_fut(dim1,dim4,dim5,dim6)=1;
                            end
                        end
                    end
                end
            end
            if arealthreshold_extremeheat(reg)==0.1;initialmean(reg)=mean(mean(mean(mean(regextremeheatdays_hist))));end
            mean_sofar=mean(mean(mean(mean(regextremeheatdays_hist))));
            distfromgoal=abs(mean_sofar-desiredmeanfreq);

            %Adjust threshold and iterate
            if distfromgoal>requiredcloseness
                if mean_sofar>desiredmeanfreq
                    arealthreshold_extremeheat(reg)=(1.1+rand()/100)*arealthreshold_extremeheat(reg);
                else
                    arealthreshold_extremeheat(reg)=(0.9+rand()/100)*arealthreshold_extremeheat(reg);
                end
                if extrheatpctile==0.99
                    fprintf('Threshold for p99 is %0.03f, meansofar is %0.03f, distfromgoal is %0.03f\n',arealthreshold_extremeheat(reg),mean_sofar,distfromgoal);
                elseif extrheatpctile==0.95
                    fprintf('Threshold for p95 is %0.03f, meansofar is %0.03f, distfromgoal is %0.03f\n',arealthreshold_extremeheat(reg),mean_sofar,distfromgoal);
                end
            else
                continueon=0;fprintf('Good enough for reg %d!\n',reg);
            end
        end
    end
    
    
    %Implement definition
    %Read in data for each ensemble member and complete calculation before
    %moving on to the next one, because there's too many ensemble members to
    %store in memory simultaneously
    regextremeheatdays_hist=zeros(100,numdaysinmon,numyrs,nummonsinyr,numregs);
    regextremeheatdays_fut=zeros(100,numdaysinmon,numyrs,nummonsinyr,numregs);
    regextremeheatdays_fut_vsfut=zeros(100,numdaysinmon,numyrs,nummonsinyr,numregs);
    numtempdaysabove_bygridpt_hist=zeros(100,192,64,12);
    numtempdaysabove_bygridpt_fut=zeros(100,192,64,12);
    numtempdaysabove_bygridpt_fut_vsfut=zeros(100,192,64,12);
    extremeheatthresholdbygridptandmonth_hist=zeros(100,192,64,12);
    extremeheatthresholdbygridptandmonth_fut=zeros(100,192,64,12);
    if extrheatpctile==0.99
        tempannual_mpi_hist=p99tempannual_mpi_hist;tempannual_mpi_fut=p99tempannual_mpi_fut;
        arealthreshold_extremeheat_p99=arealthreshold_extremeheat;
    elseif extrheatpctile==0.95
        tempannual_mpi_hist=p95tempannual_mpi_hist;tempannual_mpi_fut=p95tempannual_mpi_fut;
        arealthreshold_extremeheat_p95=arealthreshold_extremeheat;
    end
    for dim1=1:100
        memnum=200+dim1;
        if memnum==260;memnum=290;elseif memnum==261;memnum=291;end %missed downloading this file
        
        for loop=1:2 %historical, then future
            if loop==1
                curyear=1991;
                thisfile=ncread(strcat(tmaxdataloc,'MPI-GE_hist_rcp45_1850-2099_dailymax_t2max_member_0',num2str(memnum),'-1991-2020.nc'),'t2max');
            elseif loop==2
                curyear=2070;
                thisfile=ncread(strcat(tmaxdataloc,'MPI-GE_hist_rcp45_1850-2099_dailymax_t2max_member_0',num2str(memnum),'-2070-2099.nc'),'t2max');
            end
            startyear=curyear;reli=1;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end

            tempdata_thisensmem=NaN.*ones(192,64,31,30,12);
            for i=1:size(thisfile,3)
                if reli==thisyearlen %last day of a year
                    tempdata_thisensmem(:,:,1:31,curyear-(startyear-1),1)=thisfile(:,:,i-364:i-334);
                    tempdata_thisensmem(:,:,1:28,curyear-(startyear-1),2)=thisfile(:,:,i-333:i-306);
                    tempdata_thisensmem(:,:,1:31,curyear-(startyear-1),3)=thisfile(:,:,i-305:i-275);
                    tempdata_thisensmem(:,:,1:30,curyear-(startyear-1),4)=thisfile(:,:,i-274:i-245);
                    tempdata_thisensmem(:,:,1:31,curyear-(startyear-1),5)=thisfile(:,:,i-244:i-214);
                    tempdata_thisensmem(:,:,1:30,curyear-(startyear-1),6)=thisfile(:,:,i-213:i-184);
                    tempdata_thisensmem(:,:,1:31,curyear-(startyear-1),7)=thisfile(:,:,i-183:i-153);
                    tempdata_thisensmem(:,:,1:31,curyear-(startyear-1),8)=thisfile(:,:,i-152:i-122);
                    tempdata_thisensmem(:,:,1:30,curyear-(startyear-1),9)=thisfile(:,:,i-121:i-92);
                    tempdata_thisensmem(:,:,1:31,curyear-(startyear-1),10)=thisfile(:,:,i-91:i-61);
                    tempdata_thisensmem(:,:,1:30,curyear-(startyear-1),11)=thisfile(:,:,i-60:i-31);
                    tempdata_thisensmem(:,:,1:31,curyear-(startyear-1),12)=thisfile(:,:,i-30:i);
                    reli=0;curyear=curyear+1;
                end
                reli=reli+1;
            end

            %Find gridpoints above the historical annual extreme threshold, and the future annual extreme threshold 
            extremeheatvshist_thisensmem=NaN.*ones(size(tempdata_thisensmem));
            if loop==2
                extremeheatvsfut_thisensmem=NaN.*ones(size(tempdata_thisensmem));
            end
            for dim4=1:numdaysinmon
                for dim5=1:numyrs
                    extremeheatvshist_thisensmem(:,:,dim4,dim5,:)=squeeze(tempdata_thisensmem(:,:,dim4,dim5,:))>=tempannual_mpi_hist;
                    if loop==2
                        extremeheatvsfut_thisensmem(:,:,dim4,dim5,:)=squeeze(tempdata_thisensmem(:,:,dim4,dim5,:))>=tempannual_mpi_fut;
                    end
                end
            end

            regextremeheatdaysvshist=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
            if loop==2
                regextremeheatdaysvsfut=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
            end
            for dim4=1:numdaysinmon
                for dim5=1:numyrs
                    for dim6=1:nummonsinyr
                        for reg=1:numregs
                            tmp=squeeze(extremeheatvshist_thisensmem(:,:,dim4,dim5,dim6));
                            if sum(tmp(regnums==reg))>=arealthreshold_extremeheat(reg)*landgridptsum(reg)
                                regextremeheatdaysvshist(dim4,dim5,dim6,reg)=1;
                            end
                            
                            if loop==2
                                tmp=squeeze(extremeheatvsfut_thisensmem(:,:,dim4,dim5,dim6));
                                if sum(tmp(regnums==reg))>=arealthreshold_extremeheat(reg)*landgridptsum(reg)
                                    regextremeheatdaysvsfut(dim4,dim5,dim6,reg)=1;
                                end
                            end
                        end
                    end
                end
            end


            %Also compute change in regional extreme thresholds
            numdaysabove_bygridpt=zeros(192,64,12);numdaysabove_bygridpt_fut_vsfut=zeros(192,64,12);
            extremethresholdbygridptandmonth=zeros(192,64,12);
            for month=1:12
                tmp=reshape(squeeze(tempdata_thisensmem(:,:,:,:,month)),[numlons numlats numdaysinmon*numyrs]);
                extremethresholdbygridptandmonth(:,:,month)=squeeze(quantile(tmp,str2double(extrheatpctile)/100,3));

                for i=1:192
                    for j=1:64
                        numdaysabove_bygridpt(i,j,month)=sum(squeeze(tmp(i,j,:)>=tempannual_mpi_hist(i,j)));
                        if loop==2
                            numdaysabove_bygridpt_fut_vsfut(i,j,month)=sum(squeeze(tmp(i,j,:)>=tempannual_mpi_fut(i,j)));
                        end
                    end
                end
            end
            

            if loop==1
                regextremeheatdays_hist(dim1,:,:,:,:)=regextremeheatdaysvshist;
                numtempdaysabove_bygridpt_hist(dim1,:,:,:)=numdaysabove_bygridpt;
                extremeheatthresholdbygridptandmonth_hist(dim1,:,:,:)=extremethresholdbygridptandmonth;
            elseif loop==2
                regextremeheatdays_fut(dim1,:,:,:,:)=regextremeheatdaysvshist;
                regextremeheatdays_fut_vsfut(dim1,:,:,:,:)=regextremeheatdaysvsfut;
                numtempdaysabove_bygridpt_fut(dim1,:,:,:)=numdaysabove_bygridpt;
                numtempdaysabove_bygridpt_fut_vsfut(dim1,:,:,:)=numdaysabove_bygridpt_fut_vsfut;
                extremeheatthresholdbygridptandmonth_fut(dim1,:,:,:)=extremethresholdbygridptandmonth;
            end
        end
        
        disp(dim1);disp(clock);
    end
    if extrheatpctile==0.95
        extremeheatp95vshist_thisensmem=extremeheatvshist_thisensmem;
        extremeheatp95vsfut_thisensmem=extremeheatvsfut_thisensmem;
        p95bygridptandmonth_hist_temp=extremeheatthresholdbygridptandmonth_hist;
        p95bygridptandmonth_fut_temp=extremeheatthresholdbygridptandmonth_fut;
        regextremeheatdaysp95_hist=regextremeheatdays_hist;
        regextremeheatdaysp95_fut=regextremeheatdays_fut;
        regextremeheatdaysp95_fut_vsfut=regextremeheatdays_fut_vsfut;
        numdaysabovep95_bygridpt_hist_temp=numtempdaysabove_bygridpt_hist;
        numdaysabovep95_bygridpt_fut_temp=numtempdaysabove_bygridpt_fut;
        numdaysabovep95_bygridpt_fut_vsfut_temp=numtempdaysabove_bygridpt_fut_vsfut;
        save(strcat(tmaxdataloc,'extremeheatarray_mpi.mat'),'regextremeheatdaysp95_hist',...
            'regextremeheatdaysp95_fut','regextremeheatdaysp95_fut_vsfut',...
            'p95bygridptandmonth_hist_temp','p95bygridptandmonth_fut_temp',...
            'numdaysabovep95_bygridpt_hist_temp','numdaysabovep95_bygridpt_fut_temp','numdaysabovep95_bygridpt_fut_vsfut_temp',...
            'arealthreshold_extremeheat_p95','-append');
    elseif extrheatpctile==0.99
        extremeheatp99vshist_thisensmem=extremeheatvshist_thisensmem;
        extremeheatp99vsfut_thisensmem=extremeheatvsfut_thisensmem;
        p99bygridptandmonth_hist_temp=extremeheatthresholdbygridptandmonth_hist;
        p99bygridptandmonth_fut_temp=extremeheatthresholdbygridptandmonth_fut;
        regextremeheatdaysp99_hist=regextremeheatdays_hist;
        regextremeheatdaysp99_fut=regextremeheatdays_fut;
        regextremeheatdaysp99_fut_vsfut=regextremeheatdays_fut_vsfut;
        numdaysabovep99_bygridpt_hist_temp=numtempdaysabove_bygridpt_hist;
        numdaysabovep99_bygridpt_fut_temp=numtempdaysabove_bygridpt_fut;
        numdaysabovep99_bygridpt_fut_vsfut_temp=numtempdaysabove_bygridpt_fut_vsfut;
        save(strcat(tmaxdataloc,'extremeheatarray_mpi.mat'),'regextremeheatdaysp99_hist',...
            'regextremeheatdaysp99_fut','regextremeheatdaysp99_fut_vsfut',...
            'p99bygridptandmonth_hist_temp','p99bygridptandmonth_fut_temp',...
            'numdaysabovep99_bygridpt_hist_temp','numdaysabovep99_bygridpt_fut_temp','numdaysabovep99_bygridpt_fut_vsfut_temp',...
            'arealthreshold_extremeheat_p99','-append');
    end
end


if regionalheatdefn_merra2==1
    %Defines regional extreme-heat days
    desiredmeanfreq=0.1;
    if extrheatpctile==0.99;temp_merra2_hist=tempp99_merra2_hist;elseif extrheatpctile==0.95;temp_merra2_hist=tempp95_merra2_hist;end
    for reg=1:numregs
        arealthreshold_extremeheat_merra2(reg)=0.08; %default guess, to start
        if landgridptsum(reg)>100;requiredcloseness=0.012;elseif landgridptsum(reg)>10;requiredcloseness=0.018;else;requiredcloseness=0.024;end
        continueon=1;
        while continueon==1
            regextremeheatdays_hist_merra2=zeros(numyrs,365);
            for doy=1:365
                for yr=1:numyrs
                    tmp=squeeze(temp_merra2_hist(yr,:,:,doy));
                    if sum(tmp(regnums==reg))>=arealthreshold_extremeheat_merra2(reg)*landgridptsum(reg)
                        regextremeheatdays_hist_merra2(yr,doy)=1;
                    end
                end
            end
            if arealthreshold_extremeheat_merra2(reg)==0.1;initialmean(reg)=mean(mean(mean(mean(regextremeheatdays_hist_merra2))));end
            mean_sofar=mean(mean(mean(mean(regextremeheatdays_hist_merra2))));
            distfromgoal=abs(mean_sofar-desiredmeanfreq);

            %Adjust threshold and iterate
            if distfromgoal>requiredcloseness
                if mean_sofar>desiredmeanfreq
                    arealthreshold_extremeheat_merra2(reg)=(1.1+rand()/100)*arealthreshold_extremeheat_merra2(reg);
                else
                    arealthreshold_extremeheat_merra2(reg)=(0.9+rand()/100)*arealthreshold_extremeheat_merra2(reg);
                end
                fprintf('Threshold for p99 is %0.03f, meansofar is %0.03f, distfromgoal is %0.03f\n',arealthreshold_extremeheat_merra2(reg),mean_sofar,distfromgoal);
            else
                continueon=0;fprintf('Good enough for reg %d!\n',reg);
            end
        end
        if extrheatpctile==0.99
            arealthreshold_extremeheat_p99_merra2=arealthreshold_extremeheat_merra2;
        elseif extrheatpctile==0.95
            arealthreshold_extremeheat_p95_merra2=arealthreshold_extremeheat_merra2;
        end
    end
    
    %Implement definition
    thisfile=alldailymaxes_merra2;
    curyear=1991;startyear=curyear;if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
    tempdata=NaN.*ones(192,64,31,30,12);
    for curyear=1991:2020
        tempdata(:,:,1:31,curyear-(startyear-1),1)=permute(squeeze(thisfile(curyear-startyear+1,1:31,:,:)),[3 2 1]);
        tempdata(:,:,1:28,curyear-(startyear-1),2)=permute(squeeze(thisfile(curyear-startyear+1,32:59,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),3)=permute(squeeze(thisfile(curyear-startyear+1,61:91,:,:)),[3 2 1]);
        tempdata(:,:,1:30,curyear-(startyear-1),4)=permute(squeeze(thisfile(curyear-startyear+1,92:121,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),5)=permute(squeeze(thisfile(curyear-startyear+1,122:152,:,:)),[3 2 1]);
        tempdata(:,:,1:30,curyear-(startyear-1),6)=permute(squeeze(thisfile(curyear-startyear+1,153:182,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),7)=permute(squeeze(thisfile(curyear-startyear+1,183:213,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),8)=permute(squeeze(thisfile(curyear-startyear+1,214:244,:,:)),[3 2 1]);
        tempdata(:,:,1:30,curyear-(startyear-1),9)=permute(squeeze(thisfile(curyear-startyear+1,245:274,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),10)=permute(squeeze(thisfile(curyear-startyear+1,275:305,:,:)),[3 2 1]);
        tempdata(:,:,1:30,curyear-(startyear-1),11)=permute(squeeze(thisfile(curyear-startyear+1,305:334,:,:)),[3 2 1]);
        tempdata(:,:,1:31,curyear-(startyear-1),12)=permute(squeeze(thisfile(curyear-startyear+1,335:365,:,:)),[3 2 1]);
    end
    
    %Find gridpoints above the historical annual p99 (or p95)
    if extrheatpctile==0.99
        extremeheatp99vshist_merra2=NaN.*ones(size(tempdata));
    elseif extrheatpctile==0.95
        extremeheatp95vshist_merra2=NaN.*ones(size(tempdata));
    end
    for dim4=1:numdaysinmon
        for dim5=1:numyrs
            for month=1:12
                if extrheatpctile==0.99
                    extremeheatp99vshist_merra2(:,:,dim4,dim5,month)=squeeze(tempdata(:,:,dim4,dim5,month))>=p99heatthresh_merra2_hist';
                elseif extrheatpctile==0.95
                    extremeheatp95vshist_merra2(:,:,dim4,dim5,month)=squeeze(tempdata(:,:,dim4,dim5,month))>=p95heatthresh_merra2_hist';
                end
            end
        end
    end
    
    if extrheatpctile==0.99
        regextremeheatdaysp99vshist_temp_merra2=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
    elseif extrheatpctile==0.95
        regextremeheatdaysp95vshist_temp_merra2=zeros(numdaysinmon,numyrs,nummonsinyr,numregs);
    end
    for dim4=1:numdaysinmon
        for dim5=1:numyrs
            for dim6=1:nummonsinyr
                for reg=1:numregs
                    if extrheatpctile==0.99
                        tmp=squeeze(extremeheatp99vshist_merra2(:,:,dim4,dim5,dim6));
                        if sum(tmp(regnums==reg))>=arealthreshold_extremeheat_merra2(reg)*landgridptsum(reg)
                            regextremeheatdaysp99vshist_temp_merra2(dim4,dim5,dim6,reg)=1;
                        end
                    elseif extrheatpctile==0.95
                        tmp=squeeze(extremeheatp95vshist_merra2(:,:,dim4,dim5,dim6));
                        if sum(tmp(regnums==reg))>=arealthreshold_extremeheat_merra2(reg)*landgridptsum(reg)
                            regextremeheatdaysp95vshist_temp_merra2(dim4,dim5,dim6,reg)=1;
                        end
                    end
                end
            end
        end
    end
    
    if extrheatpctile==0.99
        regp99extremeheatdays_hist_merra2=regextremeheatdaysp99vshist_temp_merra2;
    elseif extrheatpctile==0.95
        regp95extremeheatdays_hist_merra2=regextremeheatdaysp95vshist_temp_merra2;
    end
end


if regionalheatchangefigures==1
    if makefigs==1
        nameappend='consec';
        histprobdays=squeeze(sum(eval(['consecheatextr_hist_vsp' num2str(100*extrheatpctile) '_3days;']),2));
        futureprobdays=squeeze(sum(eval(['consecheatextr_fut_vsp' num2str(100*extrheatpctile) '_3days;']),2));
        futureprobdays_vsfut=squeeze(sum(eval(['consecheatextr_fut_vsfut_vsp' num2str(100*extrheatpctile) '_3days;']),2));

        histprobdays_reana=squeeze(sum(consecheatextr_hist_vsp95_3days_merra2));
        
        toosmall=histprobdays<0.01;histprobdays(toosmall)=NaN;

        if boxplotandmap_consecdays==1
            figc=792;figure(figc);clf;
            if addmap==1;subplot(3,1,1);else;subplot(2,1,1);end
            
            %Top panel: historical boxplot of prob of compound extreme days
            for reg=1:numregs
                probofadaybeingextremecompound(:,reg)=100.*histprobdays(:,reg)./(365*numyrs*sum(sum(regnums==reg)));
                probofadaybeingextremecompound_reana(reg)=100.*histprobdays_reana(reg)./(365*numyrs*sum(sum(regnums==reg)));
            end
            
            x=[];g=[];
            for reg=1:numregs
                x=[x;probofadaybeingextremecompound(1:99,reg)];
                g=[g;reg*2.*ones(99,1);];
            end
            b=boxplot(x,g);hold on;
            
            box_h=findobj(gca,'Tag','Box');medianline=findobj(gca,'Tag','Median');
            upperwhisker=findobj(gca,'Tag','Upper Whisker');lowerwhisker=findobj(gca,'Tag','Lower Whisker');
            upperadjacentvalue=findobj(gca,'Tag','Upper Adjacent Value');loweradjacentvalue=findobj(gca,'Tag','Lower Adjacent Value');
            outliers=findobj(gca,'Tag','Outliers');
            for i=1:numregs
                set(box_h,'color',boxplot2color,'linewidth',2);set(medianline,'color',boxplot2color,'linewidth',2);
                set(upperwhisker,'color',boxplot2color,'linewidth',2);set(lowerwhisker,'color',boxplot2color,'linewidth',2);
                set(upperadjacentvalue,'color',boxplot2color,'linewidth',2);set(loweradjacentvalue,'color',boxplot2color,'linewidth',2);
                set(outliers,'MarkerEdgeColor','k');
            end
                        
            %Add black dot showing historical temporal-compounding probability from MERRA2
            for reg=1:numregs
                scatter(reg,probofadaybeingextremecompound_reana(reg),75,'k','filled');
            end
            
            axislabelsize=12;
            set(gca,'fontweight','bold','fontname','arial','fontsize',axislabelsize);
            ylabel('Hist. Prob. (%)','fontweight','bold','fontname','arial','fontsize',axislabelsize);
            set(gca,'xtick','','xticklabel','');
            ymin=0;ymax=4;ylim([ymin ymax]);
            set(gca,'ytick',ymin:1:ymax);
            
            %Add background shading to make regions easier to distinguish
            regcolors=colormaps('classy rainbow','more','not');
            for reg=1:numregs
                thiscolor=regcolors(round(128*(reg-0.5)/24),:);
                x=[reg-0.5 reg+0.5 reg+0.5 reg-0.5];y=[ymin ymin ymax ymax];p=patch(x,y,thiscolor,'FaceAlpha',0.1,'EdgeColor','k');
            end
            t=text(-0.1,1.01,'a)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
            if addmap==1;set(gca,'position',[0.15 0.78 0.7 0.2]);else;set(gca,'position',[0.15 0.69 0.7 0.29]);end
            
            
            
            %Middle section: projected changes
            if addmap==1;axes('Position',[0.15 0.4 0.7 0.36]);else;axes('Position',[0.15 0.1 0.7 0.54]);end
            x=[];g=[];
            for reg=1:numregs
                histcompounding=histprobdays(1:99,reg);
                futurecompounding_histthresh=futureprobdays(1:99,reg); %total change
                futurecompounding_futthresh=futureprobdays_vsfut(1:99,reg);
                thermodyneffect=futurecompounding_histthresh-futurecompounding_futthresh;
                nonlineareffect=futurecompounding_histthresh-thermodyneffect; %aka dynamic effect
                
                diff_compounding_total=futurecompounding_histthresh-histcompounding;
                pctdiff_compounding_total(:,reg)=100.*(diff_compounding_total)./histcompounding;
                
                diff_compounding_thermodyn=futurecompounding_histthresh-futurecompounding_futthresh;
                diff_compounding_nonlinear=futurecompounding_futthresh-histcompounding;
                
                pctdiff_compounding_thermodyn(:,reg)=(diff_compounding_thermodyn./diff_compounding_total).*pctdiff_compounding_total(:,reg);
                pctdiff_compounding_nonlinear(:,reg)=(diff_compounding_nonlinear./diff_compounding_total).*pctdiff_compounding_total(:,reg);
                
                x=[x;pctdiff_compounding_total(:,reg);pctdiff_compounding_thermodyn(:,reg);pctdiff_compounding_nonlinear(:,reg)];
                g=[g;(reg*3-2).*ones(99,1);(reg*3-1).*ones(99,1);(reg*3).*ones(99,1)];
            end
            boxplot(x,g);hold on;

            
            %Color boxplots differently for each dataset
            color1=boxplot1color;color2=smallboxplot1color;color3=smallboxplot2color;shrinkrighthandboxes=1;
            boxplot_3datasetsalternating;

            
            
            if addmap==1;axislabelsize=12;else;axislabelsize=14;end           
            set(gca,'fontweight','bold','fontname','arial','fontsize',axislabelsize);
            set(gca,'xtick','','xticklabel',{});
            if addmap==1
                ymin=-50;ymax=500;y95th=ymin+0.96*(ymax-ymin);
            else
                ymin=20;ymax=2000;set(gca,'yscale','log','ytick',[20;50;100;200;500;1000;2000]);
            end
            ylim([ymin ymax]);
            
            %Add dashed zero line
            x=[0 numregs*3+1];y=[0 0];plot(x,y,'k--','linewidth',1);
            
            %Add significance stars -- large for >95% of ensemble members
            %agreeing on sign, small for >67% of ensemble members agreeing on sign
            for reg=1:numregs
                if (quantile(pctdiff_compounding_total(:,reg),0.5)>=0 && quantile(pctdiff_compounding_total(:,reg),0.05)>=0) ||...
                       (quantile(pctdiff_compounding_total(:,reg),0.5)<=0 && quantile(pctdiff_compounding_total(:,reg),0.95)<=0) %very signif.
                    plot(reg*3-2,y95th,'p','MarkerSize',10,'MarkerFaceColor',boxplot1color,'MarkerEdgeColor',boxplot1color);
                elseif (quantile(pctdiff_compounding_total(:,reg),0.5)>=0 && quantile(pctdiff_compounding_total(:,reg),0.33)>=0) ||...
                       (quantile(pctdiff_compounding_total(:,reg),0.5)<=0 && quantile(pctdiff_compounding_total(:,reg),0.67)<=0) %moderately signif. increase
                    plot(reg*3-2,y95th,'p','MarkerSize',7,'MarkerFaceColor',boxplot1color,'MarkerEdgeColor',boxplot1color);
                end
                if (quantile(pctdiff_compounding_thermodyn(:,reg),0.5)>=0 && quantile(pctdiff_compounding_thermodyn(:,reg),0.05)>=0) ||...
                       (quantile(pctdiff_compounding_thermodyn(:,reg),0.5)<=0 && quantile(pctdiff_compounding_thermodyn(:,reg),0.95)<=0) %very signif.
                    plot(reg*3-1,y95th,'p','MarkerSize',10,'MarkerFaceColor',smallboxplot2color,'MarkerEdgeColor',smallboxplot2color);
                elseif (quantile(pctdiff_compounding_thermodyn(:,reg),0.5)>=0 && quantile(pctdiff_compounding_thermodyn(:,reg),0.33)>=0) ||...
                       (quantile(pctdiff_compounding_thermodyn(:,reg),0.5)<=0 && quantile(pctdiff_compounding_thermodyn(:,reg),0.67)<=0) %moderately signif. increase
                    plot(reg*3-1,y95th,'p','MarkerSize',7,'MarkerFaceColor',smallboxplot2color,'MarkerEdgeColor',smallboxplot2color);
                end
                if (quantile(pctdiff_compounding_nonlinear(:,reg),0.5)>=0 && quantile(pctdiff_compounding_nonlinear(:,reg),0.05)>=0) ||...
                       (quantile(pctdiff_compounding_nonlinear(:,reg),0.5)<=0 && quantile(pctdiff_compounding_nonlinear(:,reg),0.95)<=0) %very signif.
                    plot(reg*3,y95th,'p','MarkerSize',10,'MarkerFaceColor',smallboxplot1color,'MarkerEdgeColor',smallboxplot1color);
                elseif (quantile(pctdiff_compounding_nonlinear(:,reg),0.5)>=0 && quantile(pctdiff_compounding_nonlinear(:,reg),0.33)>=0) ||...
                       (quantile(pctdiff_compounding_nonlinear(:,reg),0.5)<=0 && quantile(pctdiff_compounding_nonlinear(:,reg),0.67)<=0) %moderately signif. increase
                    plot(reg*3,y95th,'p','MarkerSize',7,'MarkerFaceColor',smallboxplot1color,'MarkerEdgeColor',smallboxplot1color);
                end
            end
                        
            %Add background shading to make regions easier to distinguish
            regcolors=colormaps('classy rainbow','more','not');
            for reg=1:numregs
                thiscolor=regcolors(round(128*(reg-0.5)/24),:);
                if rem(reg,2)==0;weight=0.1;else;weight=0.1;end
                x=[reg*3-2.5 reg*3+0.5 reg*3+0.5 reg*3-2.5];y=[ymin ymin ymax ymax];p=patch(x,y,thiscolor,'FaceAlpha',weight,'EdgeColor','k');
            end
            ylabel('% Change','fontweight','bold','fontname','arial','fontsize',axislabelsize);
            set(gca,'xtick',2:3:numregs*3,'xticklabel',regnames);xtickangle(45);
            set(gcf,'color','w');


            %Add scatterplot
            if addmap==0
                axes('Position',[0.175 0.83 0.11 0.11],'color','none');
                scatter(100.*(mean(futureprobdays)-mean(histprobdays))./mean(histprobdays),squeeze(mean(pctdaysabovep95change,2))',18,'k','filled');
                set(gca,'fontweight','bold','fontname','arial','fontsize',10,'XColor',boxplot1color,'YColor',smallboxplot1color);
                corr1=(mean(futureprobdays)-mean(histprobdays))./mean(histprobdays);corr2=squeeze(mean(pctdaysabovep95change,2));
                t=text(0.6,0.2,sprintf('r=%0.02f',corr(corr1',corr2)),'units','normalized');
                set(t,'fontweight','bold','fontname','arial','fontsize',10,'color','k');
                set(gca,'xtick',100:100:200);
            end

            t=text(-0.1,1.01,'b)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
            
            
            %Bottom section: map of changes
            if addmap==1
                pctchange_compounding=quantile(pctdiff_compounding_total,0.5);

                facealpha=0.7;
                cmap=colormaps('t','more','not');
                cutoffs=[-400;-200;-150;-100;0;100;150;200;400];
                intervals_displayonfigure=[0;0;0;0;1;1;1;1];
                endsopen=0; %if ==1, final interval is >=penultimate cutoff; if ==0, final interval is {>penultimate & <final}

                axes('Position',[0.15 -0.05 0.7 0.42]);
                plotBlankMap(figc,'worldnorthof60s',0,'ghost white',0,{'stateboundaries';0});hold on;
                for reg=1:numregs
                    [lat,lon]=outlinegeoquad([regsouthedges(reg) regnorthedges(reg)],[regwestedges(reg) regeastedges(reg)],2,2);
                    if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                        [lat2,lon2]=outlinegeoquad([regsouthedges2(reg) regnorthedges2(reg)],[regwestedges2(reg) regeastedges2(reg)],2,2);
                    end
                    
                    endsopen=0;
                    [thiscolor,startat,cmapintervalsize]=nicecolorcategories(pctchange_compounding(reg),cmap,cutoffs,endsopen,'dontuseendcolors');

                    g1=geoshow(lat,lon,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',facealpha);
                    if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20;g2=geoshow(lat2,lon2,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',facealpha);end

                    %Add hatching for regions where at least 2/3 of ensemble members DO NOT
                        %agree on the sign of the change (reversed from the old ways)
                    %Adding "hatches to patches"
                    if pctchange_compounding(reg)>=0 && quantile(pctdiff_compounding_total(:,reg),0.33)>=0
                    elseif pctchange_compounding(reg)<=0 && quantile(pctdiff_compounding_total(:,reg),0.67)<=0
                    else %insignificant, so YES add hatching
                        hatchfill2(g1,'single','HatchDensity',50,'HatchColor','k','HatchLineWidth',0.8);
                        if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                            hatchfill2(g2,'single','HatchDensity',50,'HatchColor','k','HatchLineWidth',0.8);
                        end
                    end
                end

                h=findall(gca);
                for i=1:size(h,1)
                    if strcmp(class(h(i)),'matlab.graphics.primitive.Patch') && h(i).FaceAlpha==facealpha %all colored patches
                        h(i).EdgeColor=h(i).FaceColor;h(i).EdgeAlpha=0;h(i).LineWidth=0.01;h(i).LineStyle=':';
                    end
                end
                dontclear=1;plotBlankMap(figc,'worldnorthof60s',0,'ghost white',0,{'stateboundaries';0}); %so all borders look the same 

                %Colorbar and its label
                cbleftpos=0.73;cbwidth=0.01;cbboxheight=0.03;cbbottomstart=0.16-size(cutoffs,1)/2*cbboxheight;
                textbottomstart=0.2;textspacing=cbboxheight*2.45;
                for intervalcount=1:size(intervals_displayonfigure,1)
                    if intervalcount==1
                        if endsopen==1
                            thistextdescrip=strcat(['<',num2str(cutoffs(1)),'%']);
                        else
                            thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                        end
                    elseif intervalcount==size(intervals_displayonfigure,1)
                        if endsopen==1
                            thistextdescrip=strcat(['>',num2str(cutoffs(end-1)),'%']);
                        else
                            thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                        end
                    else
                        thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                    end
                    if intervals_displayonfigure(intervalcount)==1
                        annotation('rectangle',[cbleftpos cbbottomstart+(intervalcount-1)*cbboxheight cbwidth cbboxheight],...
                            'FaceColor',cmap(round(startat+cmapintervalsize*(intervalcount-1)),:),...
                            'EdgeColor',cmap(round(startat+cmapintervalsize*(intervalcount-1)),:),'FaceAlpha',facealpha);
                        t=text(1,textbottomstart+(intervalcount-1)*textspacing,thistextdescrip,'units','normalized');
                        set(t,'fontsize',11,'fontweight','bold','fontname','arial');
                    end
                end
                
                t=text(-0.1,0.9,'c)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
            end
            

            figname=strcat('extrheatchange_regs_3day',nameappend);curpart=2;highqualityfiguresetup;
        end
    end
end


if volatilitydefn==1
    %Probability of drought WY followed by or preceded by flood WY for each region, for both hist & future
    %Can't do indiv gridpts b/c doing ens spread is more important, and
        %doing both would reduce the sample size such that the uncertainty would be enormous
    
    latsrot=mpilats';lonsrot=mpilons';
    
    tmp_hist=permute(reshape(wyprecip_mpi_hist,[size(wyprecip_mpi_hist,1)*size(wyprecip_mpi_hist,2) size(wyprecip_mpi_hist,3) size(wyprecip_mpi_hist,4)]),[1 3 2]);
    tmp_fut=permute(reshape(wyprecip_mpi_fut,[size(wyprecip_mpi_hist,1)*size(wyprecip_mpi_hist,2) size(wyprecip_mpi_hist,3) size(wyprecip_mpi_hist,4)]),[1 3 2]);
    
    wyprecip_mpi_hist_64x192=permute(wyprecip_mpi_hist,[1 2 4 3]);
    wyprecip_mpi_fut_64x192=permute(wyprecip_mpi_fut,[1 2 4 3]);
    
    p10drought=NaN.*ones(100,numlats,numlons);p90flood=NaN.*ones(100,numlats,numlons);
        p10drought_fut=NaN.*ones(100,numlats,numlons);p90flood_fut=NaN.*ones(100,numlats,numlons);
    
    volatilityfreq_hist_1090=NaN.*ones(100,numregs);volatilityfreq_fut_1090=NaN.*ones(100,numregs);volatilityfreq_fut_vsfut_1090=NaN.*ones(100,numregs);
    
    c_hist_1090=zeros(100,numregs);c_fut_1090=zeros(100,numregs);c_fut_vsfut_1090=zeros(100,numregs);
    
    histvolatil=zeros(100,28,numlats,numlons);futvolatil=zeros(100,28,numlats,numlons);
    for i=1:numlats
        for j=1:numlons
            thisreg=regnums(i,j);
            if ~isnan(thisreg)
                if extrdayspergridpt(i,j)>=1 %land points only
                    for ensmem=1:100
                        %ensemble-member-specific drought & flood WY definitions
                        p10drought(ensmem,i,j)=quantile(wyprecip_mpi_hist_64x192(ensmem,:,i,j),0.1);
                        p90flood(ensmem,i,j)=quantile(wyprecip_mpi_hist_64x192(ensmem,:,i,j),0.9);
                            p10drought_fut(ensmem,i,j)=quantile(wyprecip_mpi_fut_64x192(ensmem,:,i,j),0.1);
                            p90flood_fut(ensmem,i,j)=quantile(wyprecip_mpi_fut_64x192(ensmem,:,i,j),0.9);
                        
                        for yr=2:28
                            if wyprecip_mpi_hist_64x192(ensmem,yr,i,j)<=p10drought(ensmem,i,j) && ...
                                    (wyprecip_mpi_hist_64x192(ensmem,yr-1,i,j)>=p90flood(ensmem,i,j) || wyprecip_mpi_hist_64x192(ensmem,yr+1,i,j)>=p90flood(ensmem,i,j))
                                c_hist_1090(ensmem,thisreg)=c_hist_1090(ensmem,thisreg)+1;
                                histvolatil(ensmem,yr,i,j)=1;
                            end

                            if wyprecip_mpi_fut_64x192(ensmem,yr,i,j)<=p10drought(ensmem,i,j) && ...
                                    (wyprecip_mpi_fut_64x192(ensmem,yr-1,i,j)>=p90flood(ensmem,i,j) || wyprecip_mpi_fut_64x192(ensmem,yr+1,i,j)>=p90flood(ensmem,i,j))
                                c_fut_1090(ensmem,thisreg)=c_fut_1090(ensmem,thisreg)+1;
                                futvolatil(ensmem,yr,i,j)=1;
                            end
                            
                            if wyprecip_mpi_fut_64x192(ensmem,yr,i,j)<=p10drought_fut(ensmem,i,j) && ...
                                    (wyprecip_mpi_fut_64x192(ensmem,yr-1,i,j)>=p90flood_fut(ensmem,i,j) || wyprecip_mpi_fut_64x192(ensmem,yr+1,i,j)>=p90flood_fut(ensmem,i,j))
                                c_fut_vsfut_1090(ensmem,thisreg)=c_fut_vsfut_1090(ensmem,thisreg)+1;
                            end
                        end
                    end
                end
            end
        end
    end
    %For troubleshooting
    clear droughts;clear floods;
    for ensmem=1:100
        for yr=2:28
            droughts(ensmem,yr,:,:)=squeeze(wyprecip_mpi_hist_64x192(ensmem,yr,:,:))<=squeeze(p10drought(ensmem,:,:));
            floods(ensmem,yr,:,:)=(squeeze(wyprecip_mpi_hist_64x192(ensmem,yr-1,:,:))>=squeeze(p90flood(ensmem,:,:)) | ...
                squeeze(wyprecip_mpi_hist_64x192(ensmem,yr+1,:,:))>=squeeze(p90flood(ensmem,:,:)));
        end
    end
    %%%
    
    for reg=1:numregs
        volatilityfreq_hist_1090(:,reg)=100.*(c_hist_1090(:,reg)./(28*landgridptsum(reg)));
        volatilityfreq_fut_1090(:,reg)=100.*(c_fut_1090(:,reg)./(28*landgridptsum(reg)));
        volatilityfreq_fut_vsfut_1090(:,reg)=100.*(c_fut_vsfut_1090(:,reg)./(28*landgridptsum(reg)));
    end
    
    invalid=volatilityfreq_hist_1090>10;volatilityfreq_hist_1090(invalid)=NaN;
    invalid=volatilityfreq_fut_1090>10;volatilityfreq_fut_1090(invalid)=NaN;
    invalid=volatilityfreq_fut_vsfut_1090>10;volatilityfreq_fut_vsfut_1090(invalid)=NaN;
    
    pctchange_1090=100.*(volatilityfreq_fut_1090-volatilityfreq_hist_1090)./volatilityfreq_hist_1090;
end


if volatilitydefn_chirps==1
    %Probability of drought WY followed by or preceded by flood WY for each region
    tmp_hist=permute(wyprecip_chirps_hist,[1 3 2]);
    p10drought=NaN.*ones(numlats,numlons);p90flood=NaN.*ones(numlats,numlons);
    volatilityfreq_hist_1090_chirps=NaN.*ones(numregs,1);
    c_hist_1090=zeros(numregs,1);
    
    for i=1:numlats
        for j=1:numlons
            thisreg=regnums(i,j);
            if ~isnan(thisreg)
                if extrdayspergridpt(i,j)>=1 %land points only
                    p10drought(i,j)=quantile(tmp_hist(:,i,j),0.1);if p10drought(i,j)==0;p10drought(i,j)=NaN;end
                    p90flood(i,j)=quantile(tmp_hist(:,i,j),0.9);if p90flood(i,j)==0;p90flood(i,j)=NaN;end
                    for yr=2:28
                        if tmp_hist(yr,i,j)<=p10drought(i,j) && ...
                                (tmp_hist(yr-1,i,j)>=p90flood(i,j) || tmp_hist(yr+1,i,j)>=p90flood(i,j))
                            c_hist_1090(thisreg)=c_hist_1090(thisreg)+1;
                        end
                    end
                end
            end
        end
    end
    for reg=1:numregs
        volatilityfreq_hist_1090_chirps(reg)=100.*(c_hist_1090(reg)./(28*landgridptsum(reg)));
    end
end



if volatilityfigures==1
    if boxplotandmap_consecyears==1
        figc=992;figure(figc);clf;
        
        %Top panel: historical boxplot of prob of compound extreme days
        subplot(3,1,1);
        x=[];g=[];
        for reg=1:numregs
            x=[x;volatilityfreq_hist_1090(1:99,reg)];
            g=[g;reg*2.*ones(99,1);];
        end
        b=boxplot(x,g);hold on;

        box_h=findobj(gca,'Tag','Box');medianline=findobj(gca,'Tag','Median');
        upperwhisker=findobj(gca,'Tag','Upper Whisker');lowerwhisker=findobj(gca,'Tag','Lower Whisker');
        upperadjacentvalue=findobj(gca,'Tag','Upper Adjacent Value');loweradjacentvalue=findobj(gca,'Tag','Lower Adjacent Value');
        outliers=findobj(gca,'Tag','Outliers');
        bplotcolor=colors('gray');
        for i=1:numregs
            set(box_h,'color',bplotcolor,'linewidth',2);set(medianline,'color',bplotcolor,'linewidth',2);
            set(upperwhisker,'color',bplotcolor,'linewidth',2);set(lowerwhisker,'color',bplotcolor,'linewidth',2);
            set(upperadjacentvalue,'color',bplotcolor,'linewidth',2);set(loweradjacentvalue,'color',bplotcolor,'linewidth',2);
            set(outliers,'MarkerEdgeColor','k');
        end

        %Add black dot showing historical volatility from reanalysis
        invalid=volatilityfreq_hist_1090_chirps==0;volatilityfreq_hist_1090_chirps(invalid)=NaN;
        for reg=1:numregs
            scatter(reg,volatilityfreq_hist_1090_chirps(reg),75,'k','filled');
        end

        set(gca,'fontweight','bold','fontname','arial','fontsize',axislabelsize);
        ylabel('Hist. Prob. (%)','fontweight','bold','fontname','arial','fontsize',axislabelsize);
        set(gca,'xtick',1:24,'xticklabel','');xtickangle(45);
        set(gca,'ytick',0:1:5);
        t=text(-0.1,1.01,'a)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
        set(gca,'position',[0.15 0.78 0.7 0.2]);
            
            
            
        %Middle section: projected changes
        %Due to paucity of data to calculate a spread, simply make a
        %modified bar graph showing the number of ens members with positive/negative changes
        axes('Position',[0.15 0.4 0.7 0.36]);
        
        x=[];g=[];y=[];
        for reg=1:numregs
            histvolatility=volatilityfreq_hist_1090(1:99,reg);
            futurevolatility_histthresh=volatilityfreq_fut_1090(1:99,reg);
            
            histvolatility_chirps=volatilityfreq_hist_1090_chirps(reg);

            diff_volatility_total=futurevolatility_histthresh-histvolatility;
            pctdiff_volatility_total(:,reg)=100.*(diff_volatility_total)./histvolatility;
            
            posdata=sum(pctdiff_volatility_total(:,reg)>0);
            negdata=-(99-posdata);
            y1(reg)=posdata;y2(reg)=negdata;
        end
        
        x=[[1:24]'];bplotcolor=colors('black');
        b=bar(x,y1,'FaceColor',bplotcolor,'EdgeColor',bplotcolor);alpha(b,0.7);hold on;
        b=bar(x,y2,'FaceColor',bplotcolor,'EdgeColor',bplotcolor);alpha(b,0.7);

        axislabelsize=12;         
        set(gca,'fontweight','bold','fontname','arial','fontsize',axislabelsize);
        set(gca,'xtick','','xticklabel',{});
        ylim([-100 100]);

        %Add dashed zero line
        %x=[0 numregs*1];y=[0 0];plot(x,y,'k--','linewidth',1);

        %Add significance stars -- large for >95% of ensemble members
        %agreeing on sign, small for >67% of ensemble members agreeing on sign
        for reg=1:numregs
            if y1(reg)>=95 || y2(reg)<=-95 %very signif.
                plot(reg,99,'p','MarkerSize',10,'MarkerFaceColor','k','MarkerEdgeColor','k');
            elseif y1(reg)>=67 || y2(reg)<=-67 %moderately signif. increase
                plot(reg,99,'p','MarkerSize',7,'MarkerFaceColor','k','MarkerEdgeColor','k');
            end
        end
        

        %Add background shading to make regions easier to distinguish
        regcolors=colormaps('classy rainbow','more','not');
        for reg=1:numregs
            thiscolor=regcolors(round(128*(reg-0.5)/24),:);
            if rem(reg,2)==0;weight=0.1;else;weight=0.1;end
            x=[reg*1-0.5 reg*1+0.5 reg*1+0.5 reg*1-0.5];y=[-100 -100 100 100];p=patch(x,y,thiscolor,'FaceAlpha',weight,'EdgeColor','k');
        end
        ylabel('Ens. Members with +/- Change','fontweight','bold','fontname','arial','fontsize',axislabelsize);
        set(gca,'xtick',1:1:numregs*1,'xticklabel',regnames);xtickangle(45);
        set(gcf,'color','w');set(gca,'xlim',[0.5 24.5]);
        
        t=text(-0.1,1.01,'b)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
        
        
        %Bottom section: map of changes
        if addmap==1
            pctchange_volatility=quantile(pctdiff_volatility_total,0.5);

            facealpha=0.7;
            cmap=flipud(colormaps('redwhitegray','more','not'));
            
            cutoffs=[-50;-25;-10;0;10;25;50];
            endsopen=0; %specifies whether final interval is >=penultimate cutoff or {>penultimate & <final}
            whethertouseendcolors='useendcolors';
            intervals_displayonfigure=[0;1;1;1;1;1];
            
            axes('Position',[0.15 -0.05 0.7 0.4]);
            plotBlankMap(figc,'worldnorthof60s',0,'ghost white',0,{'stateboundaries';0});hold on;
            for reg=1:numregs
                [lat,lon]=outlinegeoquad([regsouthedges(reg) regnorthedges(reg)],[regwestedges(reg) regeastedges(reg)],2,2);
                if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                    [lat2,lon2]=outlinegeoquad([regsouthedges2(reg) regnorthedges2(reg)],[regwestedges2(reg) regeastedges2(reg)],2,2);
                end

                [thiscolor,startat,cmapintervalsize]=nicecolorcategories(pctchange_volatility(reg),cmap,cutoffs,endsopen,'dontuseendcolors');

                g1=geoshow(lat,lon,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',facealpha);
                if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20;g2=geoshow(lat2,lon2,'DisplayType','polygon','FaceColor',thiscolor,'FaceAlpha',facealpha);end

                %Add hatching for regions where at least 2/3 of ensemble members DO NOT
                %agree on the sign of the change (reversed from the old ways)
                %Adding "hatches to patches"
                if pctchange_volatility(reg)>=0 && quantile(pctdiff_volatility_total(:,reg),0.33)>=0
                elseif pctchange_volatility(reg)<=0 && quantile(pctdiff_volatility_total(:,reg),0.67)<=0
                else %insignificant, so YES add hatching
                    hatchfill2(g1,'single','HatchDensity',50,'HatchColor','k','HatchLineWidth',0.8);
                    if reg==1 || reg==5 || reg==6 || reg==9 || reg==10 || reg==20
                        hatchfill2(g2,'single','HatchDensity',50,'HatchColor','k','HatchLineWidth',0.8);
                    end
                end
            end

            h=findall(gca);
            for i=1:size(h,1)
                if strcmp(class(h(i)),'matlab.graphics.primitive.Patch') && h(i).FaceAlpha==facealpha %all colored patches
                    h(i).EdgeColor=h(i).FaceColor;h(i).EdgeAlpha=0;h(i).LineWidth=0.01;h(i).LineStyle=':';
                end
            end
            dontclear=1;plotBlankMap(figc,'worldnorthof60s',0,'ghost white',0,{'stateboundaries';0}); %so all borders look the same 

            %Colorbar and its label
            cbleftpos=0.73;cbwidth=0.01;cbboxheight=0.03;cbbottomstart=0.16-size(cutoffs,1)/2*cbboxheight;
            textbottomstart=0.19;textspacing=cbboxheight*2.48;
            for intervalcount=1:size(intervals_displayonfigure,1)
                if intervalcount==1
                    if endsopen==1
                        thistextdescrip=strcat(['<',num2str(cutoffs(1)),'%']);
                    else
                        thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                    end
                elseif intervalcount==size(intervals_displayonfigure,1)
                    if endsopen==1
                        thistextdescrip=strcat(['>',num2str(cutoffs(end-1)),'%']);
                    else
                        thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                    end
                else
                    thistextdescrip=strcat([num2str(cutoffs(intervalcount)),'% to ',num2str(cutoffs(intervalcount+1)),'%']);
                end
                if intervals_displayonfigure(intervalcount)==1
                    annotation('rectangle',[cbleftpos cbbottomstart+(intervalcount-1)*cbboxheight cbwidth cbboxheight],...
                        'FaceColor',cmap(round(startat+cmapintervalsize*(intervalcount-1)),:),...
                        'EdgeColor',cmap(round(startat+cmapintervalsize*(intervalcount-1)),:),'FaceAlpha',facealpha);
                    t=text(1.03,textbottomstart+(intervalcount+0.5)*textspacing,thistextdescrip,'units','normalized');
                    set(t,'fontsize',11,'fontweight','bold','fontname','arial');
                end
            end

            t=text(-0.1,0.9,'c)','units','normalized');set(t,'fontweight','bold','fontname','arial','fontsize',16);
        end

        figname='volatilitychange_boxplotandmap';curpart=2;highqualityfiguresetup;
    end
end



