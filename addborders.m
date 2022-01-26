%Add borders & coasts
%This is a helper script for plotBlankMap and plotModelData


%options for cont are a continent's full name, e.g. 'North America', or 'all'

%note: North America includes Caribbean; Asia includes Middle East; Oceania
%includes the Maritime Continent


%If desired, add provincial boundaries for certain countries
hold on;
addprovboundaries=0;
if addprovboundaries==1
    load china.province.mat;plotm(lat,long,'color',colors('gray'));
    S=shaperead('IndiaStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('RussiaStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('AustraliaStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('BrazilStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('CanadaProvinces.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
    S=shaperead('MexicoStates.shp','UseGeoCoords',true);geoshow(S,'FaceColor',co,'edgecolor',colors('gray'),'FaceAlpha',0);
end

exist lw;if ans==0;lw=1;end



%load coast;
exist stateboundaries;
if ans==0
%    states=shaperead('usastatelo', 'UseGeoCoords', true);
%    geoshow(states, 'DisplayType', 'polygon','facecolor',co,'edgecolor',colors('gray'),'FaceAlpha',0,'linewidth',lw);
else
    if stateboundaries==1
        states=shaperead('usastatelo', 'UseGeoCoords', true);
        geoshow(states, 'DisplayType', 'polygon','facecolor',co,'edgecolor',colors('gray'),'FaceAlpha',0,'linewidth',lw);
    end
end
%[Gray vs black US state borders]
%geoshow(states, 'DisplayType', 'polygon','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
%geoshow(states, 'DisplayType', 'polygon','facecolor',co,'edgecolor',colors('gray'),'FaceAlpha',0.3,'linewidth',lw);

exist provincialbordersonly;
if ans==1
    if provincialbordersonly==1;return;end
end


if strcmp(conttoplot,'North America') || strcmp(conttoplot,'all')
    borders('Canada','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Mexico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Cuba','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bahamas','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('United States','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Greenland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Puerto Rico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Jamaica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Haiti','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Dominican Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Russia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Guatemala','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Honduras','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('El Salvador','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Nicaragua','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Costa Rica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Panama','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Belize','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Dominica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('British Virgin Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bermuda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saint Martin','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Antigua and Barbuda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Barbados','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Grenada','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saint Kitts and Nevis','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saint Lucia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saint Vincent and the Grenadines','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Trinidad and Tobago','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
end

if strcmp(conttoplot,'South America') || strcmp(conttoplot,'all')
    borders('Saint Martin','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Antigua and Barbuda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Barbados','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Grenada','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saint Kitts and Nevis','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saint Lucia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saint Vincent and the Grenadines','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Trinidad and Tobago','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('British Virgin Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Nicaragua','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Costa Rica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Panama','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Colombia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Venezuela','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Suriname','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Guyana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Brazil','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Ecuador','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Peru','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bolivia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Chile','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Paraguay','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Argentina','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Uruguay','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Antarctica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
end

if strcmp(conttoplot,'Europe') || strcmp(conttoplot,'all')
    borders('Azerbaijan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Georgia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Armenia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Turkey','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Egypt','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Libyan Arab Jamahiriya','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Algeria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Tunisia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Morocco','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Cyprus','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Ukraine','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Russia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Romania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bulgaria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Greece','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Albania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Montenegro','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Croatia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Serbia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bosnia and Herzegovina','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Hungary','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Slovakia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Belarus','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Lithuania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Latvia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Estonia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Finland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Sweden','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Norway','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Poland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Czech Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Austria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Italy','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Switzerland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('France','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Germany','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Denmark','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Netherlands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Belgium','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('United Kingdom','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Ireland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Spain','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Portugal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Iceland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Luxembourg','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Liechtenstein','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Monaco','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('San Marino','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Andorra','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Malta','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
end

if strcmp(conttoplot,'Asia') || strcmp(conttoplot,'all')
    borders('Japan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Korea, Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Syrian Arab Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Korea, Democratic People''s Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('China','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Mongolia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Russia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Nepal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('India','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bangladesh','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bhutan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Kazakhstan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Tajikistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Turkmenistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Uzbekistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Kyrgyzstan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Afghanistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Pakistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Iran Islamic Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Iraq','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Kuwait','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Yemen','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saudi Arabia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Ethiopia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Somalia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Oman','k','FaceColor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Sudan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Lebanon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Israel','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Jordan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Qatar','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('United Arab Emirates','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bahrain','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Sri Lanka','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Thailand','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Burma','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Cambodia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Djibouti','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Eritrea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Viet Nam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Philippines','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Malaysia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Taiwan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Indonesia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Singapore','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Lao People''s Democratic Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
end

if strcmp(conttoplot,'Africa') || strcmp(conttoplot,'all')
    borders('Guinea-Bissau','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Equatorial Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Chad','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Senegal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Mali','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Mauritania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Niger','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Nigeria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Ghana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Togo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Benin','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Liberia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Cameroon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Congo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Gabon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Democratic Republic of the Congo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Angola','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Namibia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Botswana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('South Africa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Swaziland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Madagascar','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Mozambique','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Malawi','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Gambia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Zambia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Zimbabwe','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Kenya','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('United Republic of Tanzania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Uganda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Rwanda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Burundi','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Ethiopia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Somalia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Oman','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Sudan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Central African Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Western Sahara','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Yemen','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Saudi Arabia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Cote d''Ivoire','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Cape Verde','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Sierra Leone','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Burkina Faso','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Djibouti','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Eritrea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Comoros','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Lesotho','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
end

if strcmp(conttoplot,'Oceania') || strcmp(conttoplot,'all')
    borders('Papua New Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Indonesia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Australia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('New Zealand','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Antarctica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Solomon Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Fiji','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Micronesia, Federated States of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Vanuatu','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Tonga','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Tuvalu','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Bangladesh','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Brunei Darussalam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Samoa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('American Samoa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('New Caledonia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('British Indian Ocean Territory','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Reunion','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Seychelles','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Palau','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Nauru','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Kiribati','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Guam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('South Georgia South Sandwich Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Marshall Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Sao Tome and Principe','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('French Southern and Antarctic Lands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Cocos Keeling Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
    borders('Commonwealth of the Northern Mariana Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0,'linewidth',lw);
end




