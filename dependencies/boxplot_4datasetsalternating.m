%Make boxes of each set of four a different color
%The boxplots have to be reconstructed using patches because there is not any other easy way to manipulate the widths of individual boxes
%Boxplots 3 & 4 of each set are half the width and also pale
%Call this immediately after boxplot(x,g)

box_h=findobj(gca,'Tag','Box');medianline=findobj(gca,'Tag','Median');
upperwhisker=findobj(gca,'Tag','Upper Whisker');lowerwhisker=findobj(gca,'Tag','Lower Whisker');
upperadjacentvalue=findobj(gca,'Tag','Upper Adjacent Value');loweradjacentvalue=findobj(gca,'Tag','Lower Adjacent Value');
outliers=findobj(gca,'Tag','Outliers');

leftboxleftedge=0.7;leftcenterboxleftedge=1.6;rightcenterboxleftedge=2.5;rightboxleftedge=3;
wideboxwidth=0.7;narrowboxwidth=0.3;

for i=max(g):-1:1 %because boxplot data is arranged backwards, for some reason
    box_xdata=[box_h(i).XData];medianline_xdata=[medianline(i).XData];
    upperwhisker_xdata=[upperwhisker(i).XData];lowerwhisker_xdata=[lowerwhisker(i).XData];
    upperadjacentvalue_xdata=[upperadjacentvalue(i).XData];loweradjacentvalue_xdata=[loweradjacentvalue(i).XData];
    outliers_xdata=[outliers(i).XData];
    if rem(i,4)==0 %because things are backwards, this is #1, #5, etc.
        stilllooking=1;
        for minii=4:4:max(g)
            if min(box_xdata)<minii && stilllooking==1
                setcountfromleft=minii/4;truexleft=setcountfromleft*4-(4-leftboxleftedge);stilllooking=0;
            end
        end
        thisboxwidth=wideboxwidth;thiscolor=color1;
    elseif rem(i,4)==3 %this is #2, #6, etc
        stilllooking=1;
        for minii=4:4:max(g)
            if min(box_xdata)<minii && stilllooking==1
                setcountfromleft=minii/4;truexleft=setcountfromleft*4-(4-leftcenterboxleftedge);stilllooking=0;
            end
        end
        thisboxwidth=wideboxwidth;thiscolor=color2;
    elseif rem(i,4)==2 %#3, #7, etc.
        stilllooking=1;
        for minii=4:4:max(g)
            if min(box_xdata)<minii && stilllooking==1
                setcountfromleft=minii/4;truexleft=setcountfromleft*4-(4-rightcenterboxleftedge);stilllooking=0;
            end
        end
        thisboxwidth=narrowboxwidth;
        temp=max(max(color3))-color3;thiscolor=color3+0.3*temp;
    elseif rem(i,4)==1
        stilllooking=1;
        for minii=4:4:max(g)
            if min(box_xdata)<minii && stilllooking==1
                setcountfromleft=minii/4;truexleft=setcountfromleft*4-(4-rightboxleftedge);stilllooking=0;
            end
        end
        thisboxwidth=narrowboxwidth;
        temp=max(max(color4))-color4;thiscolor=color4+0.3*temp;
    end
    mins=box_xdata==min(box_xdata);maxs=box_xdata==max(box_xdata);box_xdata(mins)=truexleft;box_xdata(maxs)=truexleft+thisboxwidth;
    patch(box_xdata,[box_h(i).YData],'w','FaceAlpha',0.2,'EdgeColor',thiscolor,'linewidth',2);

    mins=medianline_xdata==min(medianline_xdata);maxs=medianline_xdata==max(medianline_xdata);
    medianline_xdata(mins)=truexleft;medianline_xdata(maxs)=truexleft+thisboxwidth;
    maxs=upperwhisker_xdata==max(upperwhisker_xdata);
    upperwhisker_xdata(maxs)=truexleft+thisboxwidth/2;
    maxs=lowerwhisker_xdata==max(lowerwhisker_xdata);
    lowerwhisker_xdata(maxs)=truexleft+thisboxwidth/2;
    mins=upperadjacentvalue_xdata==min(upperadjacentvalue_xdata);maxs=upperadjacentvalue_xdata==max(upperadjacentvalue_xdata);
    upperadjacentvalue_xdata(mins)=truexleft;upperadjacentvalue_xdata(maxs)=truexleft+thisboxwidth;
    mins=loweradjacentvalue_xdata==min(loweradjacentvalue_xdata);maxs=loweradjacentvalue_xdata==max(loweradjacentvalue_xdata);
    loweradjacentvalue_xdata(mins)=truexleft;loweradjacentvalue_xdata(maxs)=truexleft+thisboxwidth;
    maxs=outliers_xdata==max(outliers_xdata);
    outliers_xdata(maxs)=truexleft+thisboxwidth/2;

    plot(medianline_xdata,[medianline(i).YData],'color',thiscolor,'linewidth',2);
    plot(upperwhisker_xdata,[upperwhisker(i).YData],'color',thiscolor,'linewidth',2);
    plot(lowerwhisker_xdata,[lowerwhisker(i).YData],'color',thiscolor,'linewidth',2);
    plot(upperadjacentvalue_xdata,[upperadjacentvalue(i).YData],'color',thiscolor,'linewidth',2);
    plot(loweradjacentvalue_xdata,[loweradjacentvalue(i).YData],'color',thiscolor,'linewidth',2);
    scatter(outliers_xdata,[outliers(i).YData],25,thiscolor,'+');
    
    %To ensure lack of cancelling-out between boxplot and patches
    set(box_h(i),'visible','off');
    set(medianline(i),'visible','off');
    set(upperwhisker(i),'visible','off');
    set(lowerwhisker(i),'visible','off');
    set(upperadjacentvalue(i),'visible','off');
    set(loweradjacentvalue(i),'visible','off');
    set(outliers(i),'visible','off');
        
    %disp(i);disp(truexleft);
end


