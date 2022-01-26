function [thiscolor,startat,interval] = nicecolorcategories(valuetoeval,cmap,cutoffs,endsopen,whethertouseendcolors)
%Makes an even number of color categories, centered on 0, using an inputted colormap
%Originally written for regionalcalcs.m (in ERL_Tipping_Points project)
%Whethertouseendcolors dictates whether the first and last colors should be the very edges of the colormap, or 1/2 an interval in

if endsopen==1
    numcolors=size(cutoffs,1)+1;
else
    numcolors=size(cutoffs,1)-1;
end


if strcmp(whethertouseendcolors,'dontuseendcolors') %the original and default
    interval=(size(cmap,1)-1)/(numcolors);startat=interval/2;
    foundstg=0;
    for i=2:size(cutoffs,1)-1
        if valuetoeval<cutoffs(i) && foundstg==0
            %disp(startat+interval*(i-2));
            thiscolor=cmap(round(startat+interval*(i-2)),:);foundstg=1;
        end
    end
elseif strcmp(whethertouseendcolors,'useendcolors')
    interval=(size(cmap,1)-1)/(numcolors-1);startat=1;
    foundstg=0;
    for i=2:size(cutoffs,1)
        if valuetoeval<cutoffs(i) && foundstg==0
            %disp(startat+interval*(i-1));
            thiscolor=cmap(round(startat+interval*(i-2)),:);foundstg=1;
        end
    end
end



if foundstg==0
    thiscolor=cmap(round(startat+interval*(i-1)),:);
end


end

