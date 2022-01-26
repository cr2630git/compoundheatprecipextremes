%Make lefthand boxes of each pair a certain color, and righthand two sets of boxes another (each color corresponds to a particular dataset)
%The boxplots have to be reconstructed using patches because there is not any other easy way to manipulate the widths of individual boxes
%Call this immediately after boxplot(x,g)

box_h=findobj(gca,'Tag','Box');medianline=findobj(gca,'Tag','Median');
upperwhisker=findobj(gca,'Tag','Upper Whisker');lowerwhisker=findobj(gca,'Tag','Lower Whisker');
upperadjacentvalue=findobj(gca,'Tag','Upper Adjacent Value');loweradjacentvalue=findobj(gca,'Tag','Lower Adjacent Value');
outliers=findobj(gca,'Tag','Outliers');

for i=1:max(g)
    box_xdata=[box_h(i).XData];medianline_xdata=[medianline(i).XData];
    upperwhisker_xdata=[upperwhisker(i).XData];lowerwhisker_xdata=[lowerwhisker(i).XData];
    upperadjacentvalue_xdata=[upperadjacentvalue(i).XData];loweradjacentvalue_xdata=[loweradjacentvalue(i).XData];
    outliers_xdata=[outliers(i).XData];
    if rem(i,3)==0
        patch(box_xdata,[box_h(i).YData],'w','FaceAlpha',0.2,'EdgeColor',color1,'linewidth',2);
        plot(medianline_xdata,[medianline(i).YData],'color',color1,'linewidth',2);
        plot(upperwhisker_xdata,[upperwhisker(i).YData],'color',color1,'linewidth',2);
        plot(lowerwhisker_xdata,[lowerwhisker(i).YData],'color',color1,'linewidth',2);
        plot(upperadjacentvalue_xdata,[upperadjacentvalue(i).YData],'color',color1,'linewidth',2);
        plot(loweradjacentvalue_xdata,[loweradjacentvalue(i).YData],'color',color1,'linewidth',2);
        scatter(outliers_xdata,[outliers(i).YData],25,color1,'+');
    elseif rem(i,3)==1
        originalmidpoint=0.5*min(box_xdata)+0.5*max(box_xdata);
        originalquarterpoint=0.75*min(box_xdata)+0.25*max(box_xdata);

        if shrinkrighthandboxes==1;tochange=box_xdata>originalmidpoint;box_xdata(tochange)=originalmidpoint;end
        patch(box_xdata,[box_h(i).YData],'w','FaceAlpha',0.2,'EdgeColor',color2,'linewidth',2);set(box_h(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=medianline_xdata>originalmidpoint;medianline_xdata(tochange)=originalmidpoint;end
        plot(medianline_xdata,[medianline(i).YData],'color',color2,'linewidth',2);set(medianline(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=upperwhisker_xdata>originalquarterpoint;upperwhisker_xdata(tochange)=originalquarterpoint;end
        plot(upperwhisker_xdata,[upperwhisker(i).YData],'color',color2,'linewidth',2);set(upperwhisker(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=lowerwhisker_xdata>originalquarterpoint;lowerwhisker_xdata(tochange)=originalquarterpoint;end
        plot(lowerwhisker_xdata,[lowerwhisker(i).YData],'color',color2,'linewidth',2);set(lowerwhisker(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=upperadjacentvalue_xdata>originalquarterpoint;upperadjacentvalue_xdata(tochange)=originalquarterpoint;end
        plot(upperadjacentvalue_xdata,[upperadjacentvalue(i).YData],'color',color2,'linewidth',2);set(upperadjacentvalue(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=loweradjacentvalue_xdata>originalquarterpoint;loweradjacentvalue_xdata(tochange)=originalquarterpoint;end
        plot(loweradjacentvalue_xdata,[loweradjacentvalue(i).YData],'color',color2,'linewidth',2);set(loweradjacentvalue(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=outliers_xdata>originalquarterpoint;outliers_xdata(tochange)=originalquarterpoint;end
        scatter(outliers_xdata,[outliers(i).YData],25,color2,'+');set(outliers(i),'visible','off');
    else
        originalmidpoint=0.5*min(box_xdata)+0.5*max(box_xdata);
        originalquarterpoint=0.75*min(box_xdata)+0.25*max(box_xdata);

        if shrinkrighthandboxes==1;tochange=box_xdata>originalmidpoint;box_xdata(tochange)=originalmidpoint;end
        patch(box_xdata,[box_h(i).YData],'w','FaceAlpha',0.2,'EdgeColor',color3,'linewidth',2);set(box_h(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=medianline_xdata>originalmidpoint;medianline_xdata(tochange)=originalmidpoint;end
        plot(medianline_xdata,[medianline(i).YData],'color',color3,'linewidth',2);set(medianline(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=upperwhisker_xdata>originalquarterpoint;upperwhisker_xdata(tochange)=originalquarterpoint;end
        plot(upperwhisker_xdata,[upperwhisker(i).YData],'color',color3,'linewidth',2);set(upperwhisker(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=lowerwhisker_xdata>originalquarterpoint;lowerwhisker_xdata(tochange)=originalquarterpoint;end
        plot(lowerwhisker_xdata,[lowerwhisker(i).YData],'color',color3,'linewidth',2);set(lowerwhisker(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=upperadjacentvalue_xdata>originalquarterpoint;upperadjacentvalue_xdata(tochange)=originalquarterpoint;end
        plot(upperadjacentvalue_xdata,[upperadjacentvalue(i).YData],'color',color3,'linewidth',2);set(upperadjacentvalue(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=loweradjacentvalue_xdata>originalquarterpoint;loweradjacentvalue_xdata(tochange)=originalquarterpoint;end
        plot(loweradjacentvalue_xdata,[loweradjacentvalue(i).YData],'color',color3,'linewidth',2);set(loweradjacentvalue(i),'visible','off');

        if shrinkrighthandboxes==1;tochange=outliers_xdata>originalquarterpoint;outliers_xdata(tochange)=originalquarterpoint;end
        scatter(outliers_xdata,[outliers(i).YData],25,color3,'+');set(outliers(i),'visible','off');
    end
end


