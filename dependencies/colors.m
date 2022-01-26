function rgbcode = colors(colorinput)
%Get select decimal RGB triplets from color names as surveyed by Randall Munroe
%Color list can obviously be expanded as desired (from rgb.txt file)

%dark blue to dark red color recommendations:
%darkest blue, very dark blue, somewhat dark blue, moderate dark blue, medium blue,
%fairly light blue, 'very pale blue', 'very pale red', 'fairly light red',
%'medium red', 'moderate dark red', 'somewhat dark red', 'very dark red', 'darkest red'

%general recommendations: medium green, moderate dark blue

%https://www.ncl.ucar.edu/Document/Graphics/ColorTables/nrl_sirkes_nowhite.shtml


colorlist={'warm purple';'sea green';'dark green blue';'teal';'dark red';'pale blue';...
    'neon green';'rose';'light pink';'indigo';'lime';'olive green';'peach';'light brown';...
    'hot pink';'black';'lilac';'navy blue';'beige';'salmon';'maroon';'bright green';...
    'forest green';'aqua';'cyan';'tan';'dark blue';'lavender';'turquoise';'violet';...
    'light purple';'lime green';'gray';'grey';'sky blue';'yellow';'magenta';'light green';...
    'orange';'light blue';'red';'brown';'pink';'blue';'green';'purple';'dark orange';
    'gold';'mint';'light orange';'dark brown';'light red';'crimson';'fuchsia';'dark magenta';
    'bright red';'dark turquoise';'chocolate';'orange red';'emerald';'jade';'auburn';'ruby';
    'dark green';'white';'light grey';'light gray';'ochre';'dark yellow';'sand';'khaki';'burgundy';
    'light pink';'very light gray';'ghost white';'histogram blue';'darkest blue';'very dark blue';
    'somewhat dark blue';'moderate dark blue';'medium blue';'fairly light blue';'very pale blue';
    'very pale red';'fairly light red';'medium red';'moderate dark red';'somewhat dark red';
    'very dark red';'darkest red';'meteoswiss_very dark red';'meteoswiss_dark red';...
    'meteoswiss_light red';'meteoswiss_pale orange';'meteoswiss_very pale blue';...
    'meteoswiss_light blue';'meteoswiss_dark blue';'meteoswiss_very dark blue';...
    'sirkes_dark red';'sirkes_light red';'sirkes_orange';'sirkes_gold';...
    'sirkes_pale blue';'sirkes_medium blue';'sirkes_dark blue';'sirkes_very dark blue';...
    'dodger blue';'ultramarine blue';...
    'meteoswiss_very dark green';'meteoswiss_dark green';'meteoswiss_light green';...
    'meteoswiss_very pale green';...
    'dark gray';'medium green';'medium-dark green';'medium-bright green';...
    'light sky blue';...
    'bright pink'};
rgblist={'952e8f';'53fca1';'1f6357';'029386';'840000';'d0fefe';
    '0cff0c';'cf6275';'ffd1df';'380282';'aaff32';'677a04';'ffb07c';'ad8150';
    'ff028d';'000000';'cea2fd';'001146';'e6daa6';'ff796c';'650021';'01ff07';
    '06470c';'13eac9';'00ffff';'d1b26f';'00035b';'c79fef';'06c2ac';'9a0eea';
    'bf77f6';'89fe05';'929591';'929591';'75bbfd';'ffff14';'c20078';'96f97b';
    'f97306';'95d0fc';'e50000';'653700';'ff81c0';'0343df';'15b01a';'7e1e9c';'c65102';
    'dbb40c';'9ffeb0';'fdaa48';'341c02';'ff474c';'8c000f';'ed0dd9';'960056';
    'ff000d';'045c5a';'3d1c02';'fd411e';'01a049';'1fa774';'9a3001';'ca0147';
    '033500';'ffffff';'d8dcd6';'d8dcd6';'bf9005';'d5b60a';'e2ca76';'aaa662';'610023';
    'ffd1df';'faebd7';'f8f8ff';'xxxxxx';'0f1b5b';'113391';
    '142fb9';'2f4bd4';'5670f2';'7c91f9';'adb9f3';
    'f3bdad';'f58a6a';'fa4040';'e62121';'ca3636';
    'af1717';'790505';'xxxxxx';'xxxxxx';...
    'xxxxxx';'xxxxxx';'xxxxxx';...
    'xxxxxx';'xxxxxx';'xxxxxx';...
    'xxxxxx';'xxxxxx';'xxxxxx';'xxxxxx';...
    'xxxxxx';'xxxxxx';'xxxxxx';'xxxxxx';...
    '3399ff';'3355ff';...
    'xxxxxx';'xxxxxx';'xxxxxx';...
    'xxxxxx';...
    '696969';'24b25e';'209851';'28dc73';...
    '75d2fd';...
    'xxxxxx'};



matchfound=0;
%disp(colorinput);
for rr=1:length(colorlist)
    if strcmp(colorinput,colorlist(rr))
        %disp('Match found');
        matchfound=1;
        rgbcode=rgblist(rr);
    end
end
if matchfound==0
    disp('Sorry, no matches');
else
    if strcmp(colorinput,'histogram blue')
        rgbcode=[0.37 0.67 0.83];
    elseif strcmp(colorinput,'meteoswiss_very dark red')
        rgbcode=[110./255 10./255 15./255];
    elseif strcmp(colorinput,'meteoswiss_dark red')
        rgbcode=[166./255 15./255 20./255];
    elseif strcmp(colorinput,'meteoswiss_light red')
        rgbcode=[240./255 60./255 43./255];
    elseif strcmp(colorinput,'meteoswiss_pale orange')
        rgbcode=[252./255 146./255 114./255];
    elseif strcmp(colorinput,'meteoswiss_very pale blue')
        rgbcode=[120./255 191./255 214./255];
    elseif strcmp(colorinput,'meteoswiss_light blue')
        rgbcode=[66./255 146./255 199./255];
    elseif strcmp(colorinput,'meteoswiss_dark blue')
        rgbcode=[8./255 87./255 156./255];
    elseif strcmp(colorinput,'meteoswiss_very dark blue')
        rgbcode=[7./255 30./255 70./255];
    elseif strcmp(colorinput,'meteoswiss_very pale green')
        rgbcode=[94./255 224./255 116./255];
    elseif strcmp(colorinput,'meteoswiss_light green')
        rgbcode=[0./255 201./255 50./255];
    elseif strcmp(colorinput,'meteoswiss_dark green')
        rgbcode=[0./255 128./255 0./255];
    elseif strcmp(colorinput,'meteoswiss_very dark green')
        rgbcode=[0./255 92./255 0./255];
    elseif strcmp(colorinput,'sirkes_dark red')
        rgbcode=[191./255 0./255 0./255];
    elseif strcmp(colorinput,'sirkes_light red')
        rgbcode=[252./255 33./255 0./255];
    elseif strcmp(colorinput,'sirkes_orange')
        rgbcode=[252./255 97./255 0./255];
    elseif strcmp(colorinput,'sirkes_gold')
        rgbcode=[252./255 191./255 0./255];
    elseif strcmp(colorinput,'sirkes_pale blue')
        rgbcode=[0./255 225./255 255./255];
    elseif strcmp(colorinput,'sirkes_medium blue')
        rgbcode=[0./255 180./255 210./255];
    elseif strcmp(colorinput,'sirkes_dark blue')
        rgbcode=[0./255 128./255 161./255];
    elseif strcmp(colorinput,'sirkes_very dark blue')
        rgbcode=[0./255 97./255 128./255];
    elseif strcmp(colorinput,'bright pink')
        rgbcode=[252./255 104./255 235./255];
    else
        rgbcode=hex2rgb(rgbcode)/255; %on a 0-to-1 scale as required by Matlab
    end
end
    

end

