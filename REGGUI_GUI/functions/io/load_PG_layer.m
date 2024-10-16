%% load_PG_layer
% Read the text file containing the measurement logs of the prompt gamma camera (PG) for the spots delivered in one layer.
%
%% Syntax
% |layer = load_PG_layer(filename)|
%
%
%% Description
% |layer = load_PG_layer(filename)| Load the PG measurement logs for one layer
%
%
%% Input arguments
% |filename| - _STRING_ - Name of the file (including path) with the log of PG measurements
%
%
%% Output arguments
%
% |layer| - _STRUCTURE_ -  Description
%
% * layer.nb_protons(s) - _SCALAR_ - Number of protons in the s-th spot of the layer      
% * layer.xy(s,:) - _SCALAR VECTOR_ Position (x,y) (mm) of the s-th spot of the layer. The coordinate system is IEC-GANTRY. 
% * layer.measure{s}(b) - _SCALAR VECTOR_ - Prompt gamma intensity in the b-th measurement bin
% * layer.delivery_time(s) - _SCALAR_ - Time (s) to deliver the  s-th spot of the layer      
%
%
%% Contributors
% % Authors : G.Janssens, E. Clementel (open.reggui@gmail.com)

function layer = load_PG_layer(filename)

layer = struct;

try
    fid=fopen(filename);
    profiles=zeros(0,0);
    spots=zeros(0,0);
    fseek(fid,0,'eof');
    maxi=ftell(fid);
    fseek(fid,0,'bof');    
    % skip initial 5 lines
    for i=1:1:4
        fgets(fid);
    end
    % while !EOF
    while (ftell(fid)<maxi)
        spotstr = fgetl(fid);
        eval(['Spot = ',spotstr(strfind(spotstr,':')+1:end),''';']);
        spots = [spots Spot];
        temp=fscanf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f',20);
        
        % temp = temp(end:-1:1);
        
        profiles=[profiles temp];
        % skip useless lines
        for j=1:1:8
            fgets(fid);
        end
    end
    fclose(fid);
catch ME
    disp('Failed to read file... ');
    fclose(fid);
    rethrow(ME);
end

% read delivery time
delivery_timing = spots(4,:)';
% read number of protons
norm_factor = spots(3,:)';
% read and normalize profiles
profiles = profiles';
for s=1:size(profiles,1)
    layer.nb_protons(s) = norm_factor(s);    
    if(norm_factor(s)~=0)
        layer.xy(s,:) = spots(1:2,s)';
        layer.measure{s} = profiles(s,:)/norm_factor(s);
    end
    layer.delivery_time(s) = delivery_timing(s);   
end

