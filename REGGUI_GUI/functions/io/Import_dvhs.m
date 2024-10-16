%% Import_dvhs
% Import from a file a dove volume historgram and store it in |handles.dvhs|
%
%% Syntax
% |handles = Import_dvhs(myDVHDir, myDVHFilename, handles)|
%
%
%% Description
% |handles = Import_dvhs(myDVHDir, myDVHFilename, handles)| Import the DVH
%
%
%% Input arguments
% |myDVHDir| - _STRING_ - Name of the file containing the DVH
%
% |myDVHFilename| - _STRING_ - Directory where the file is stored
%
% |handles| - _STRUCTURE_ - REGGUI data structure.
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing imported data
%
%  |handles.dvhs| - _CELL VECTOR of STRUCTURE_ - Data strcture of the dose volume histogram. See |save_DVH| for more information.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Import_dvhs(myDVHDir, myDVHFilename, handles, format)

if(nargin<4)
    format = 'mat';
end

if(isnumeric(format))
    switch format
        case 1
            format = 'mat';
        case 2
            format = 'json';
        otherwise
            error('Invalid type number.')
    end
end

filename = fullfile(myDVHDir,myDVHFilename);

switch format
    case 'json'
        
        temp = loadjson(filename);
        temp = temp.dvh;
        
        % convert json into reggui structure
        dvhs = cell(0);
        for i=1:length(temp)            
            dvhs{i}.dose = temp{i}.dose_0x20_name;
            dvhs{i}.volume = temp{i}.volume_0x20_name;
            dvhs{i}.Dp = 0;
            dvhs{i}.color = [hex2dec(temp{i}.hexcolor(1:2));hex2dec(temp{i}.hexcolor(3:4));hex2dec(temp{i}.hexcolor(5:6))]/255;
            dvhs{i}.hexcolor = temp{i}.hexcolor;
            dvhs{i}.style = '-';
            dvhs{i}.dvh = temp{i}.curve.volume;
            dvhs{i}.dvh_X = temp{i}.curve.dose;
            dvhs{i}.dmin = temp{i}.dmin;
            dvhs{i}.dmax = temp{i}.dmax;
            dvhs{i}.dmean = temp{i}.dmean;
            dvhs{i}.dmedian = NaN;
            dvhs{i}.geud = NaN;            
        end
        
    otherwise % mat file
        
        temp = load(filename);
        dvhs = temp.dvhs;
        
end

if(isempty(handles.dvhs))
    handles.dvhs = dvhs;
else
    for i=1:length(dvhs)
        handles.dvhs{end+1} = dvhs{i};
    end
end
