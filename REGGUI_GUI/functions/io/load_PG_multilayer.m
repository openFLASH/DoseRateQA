%% load_PG_multilayer
% Read the text file containing the measurement logs of the prompt gamma camera (PG) for the spots delivered in several layers.
%
%% Syntax
% |layers = load_PG_multilayer(filename)|
%
% |layers = load_PG_multilayer(filename,uniformity_correction)|
%
% |layers = load_PG_multilayer(filename,uniformity_correction,output_row)|
%
% |layers = load_PG_multilayer(filename,uniformity_correction,output_row,inverse_profiles)|
%
%
%% Description
% |layers = load_PG_multilayer(filename)| Load the measurement logs with no gain calibration, using both detector rows and no inversion
%
% |layers = load_PG_multilayer(filename,uniformity_correction)| Load the measurement logs with gain calibration, using both detector rows and no inversion
%
% |layers = load_PG_multilayer(filename,uniformity_correction,output_row)|  Load the measurement logs with no gain calibration, using specified detector and no inversion
%
% |layers = load_PG_multilayer(filename,uniformity_correction,output_row,inverse_profiles)| Load the measurement logs with no gain calibration, using specified detector and specified inversion
%
%
%% Input arguments
% |filename| - _STRING_ - Name of the file (including path) with the log of PG measurements
%
% |uniformity_correction| - _SCALAR VECTOR_ - [OPTIOANL. Default = empty] Gain calibration curve of the detectors
%
% |output_row| - _STRING_ - [OPTIONAL. Default  = 'both'] Select from which row of detector the data should be read
%
% * 'lower_row' : only the lower row
% * 'upper_row' : only the higher row
% * 'both' : the sum of both row
%
% |inverse_profiles| - _INTEGER_ - [OPTIONAL. Default =0] 1 = Inverse the order of the detector channels. O = Do not inverse
%
%
%% Output arguments
%
% |layers| - _STRUCTURE_ -  Description
%
% * |layers{l,2}.nb_protons(s)| - _SCALAR_ - Number of proton in the s-th spot of the l-th energy layer 
% * |layers{l,2}.layer.xy(s,:)| - _SCALAR VECTOR_ - Average spot position (x,y) over the delivery of the s-th spot of the l-th energy layer. The coordinate system is IEC-GANTRY.  
% * |layers{l,2}.layer.measure{s}(b)| - _SCALAR VECTOR_ - Prompt gamma intensity in the b-th measurement bin
% * |layers{l,2}.layer.delivery_time(s)| - _SCALAR_ - Time (s) to deliver the  s-th spot of the layer    
% * |layers{l,1} = layer_indices(l)| - _INTEGER_ Index of the l-th layer 
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function layers = load_PG_multilayer(filename,uniformity_correction,output_row,inverse_profiles)

layers = cell(0);

if(nargin<4)
    inverse_profiles = 0;
end
if(nargin<3)
    output_row = 'both';
end
if(nargin<2)
    uniformity_correction = [];
else
    nb_lines = 0;
    nb_profiles = 0;
    try
        fid=fopen(filename);
        while 1
            tline = fgets(fid);
            if ~ischar(tline), break, end
            nb_lines = nb_lines+1;
            nb_profiles = nb_profiles + not(isempty(strfind(tline,'Profile')));
        end
        fclose(fid);
    catch ME
        disp('Failed to read file... ');
        fclose(fid);
        rethrow(ME);
    end
    if(nb_profiles>floor(nb_lines/9))
        uniformity_correction = [];
    end
end

try
    fid=fopen(filename);
    profiles=zeros(0,0);
    spots=zeros(0,0);
    fseek(fid,0,'eof');
    maxi=ftell(fid);
    fseek(fid,0,'bof');
    % skip initial 2 lines (TIH)
    fgets(fid);
    temp = fgets(fid);
    diff_only = 0;
    if(not(isempty(strfind(temp,'[]'))))
        diff_only = 1;
    end
    % read profiles
    current_line = fgetl(fid);
    while(ftell(fid)<maxi)
        eval(['Spot = ',current_line(strfind(current_line,':')+1:end),''';']);%[Layer, Spot, Irradiation time, X, Y, Protons]
        spots = [spots,Spot];
        Tdiff=fscanf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,',20); % both rows
        if(not(diff_only))
            URLT=fscanf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,',20);
            URUT=fscanf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,',20);
            LRLT=fscanf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,',20);
            LRUT=fscanf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,',20);            
            if(not(isempty(uniformity_correction)))
                %disp('Applying uniformity correction...')
                URdiff = (URLT-URUT)./uniformity_correction(1,:)';
                LRdiff = (LRLT-LRUT)./uniformity_correction(2,:)';
            else
                URdiff = (URLT-URUT);
                LRdiff = (LRLT-LRUT);
            end
            Tdiff = URdiff+LRdiff;
            if(inverse_profiles)
                Tdiff = Tdiff(end:-1:1);
                URdiff = URdiff(end:-1:1);
                LRdiff = LRdiff(end:-1:1);
            end
        else
            if(inverse_profiles)
                Tdiff = Tdiff(end:-1:1);
            end
        end
        switch output_row
            case 'lower_row'
                profiles=[profiles,LRdiff];
            case 'upper_row'
                profiles=[profiles,URdiff];
            otherwise
                profiles=[profiles,Tdiff];
        end
        % skip useless lines
        current_line = fgetl(fid);
        while(isempty(strfind(current_line,'[')) && ftell(fid)<maxi)
            current_line = fgetl(fid);
        end
    end
    fclose(fid);
catch ME
    disp('Failed to read file... ');
    fclose(fid);
    rethrow(ME);
end

[~,layer_order] = sort(spots(1,:));
spots = spots(:,layer_order);
profiles = profiles(:,layer_order);
profiles = profiles';
layer_indices = unique(spots(1,:));
nLayers = length(layer_indices);

for i=1:nLayers
    layer = struct;
    % find spots and profiles from current layer
    spots_current_layer = spots(:,spots(1,:)==layer_indices(i));
    profiles_current_layer = profiles(spots(1,:)==layer_indices(i),:);
    % read delivery time
    delivery_timing = spots_current_layer(3,:)';
    % read number of protons
    norm_factor = spots_current_layer(6,:)';
    % read and normalize profiles
    
    for s=1:size(profiles_current_layer,1)
        layer.nb_protons(s) = norm_factor(s);
        if(norm_factor(s)~=0)
            layer.xy(s,:) = spots_current_layer(4:5,s)';
            layer.measure{s} = profiles_current_layer(s,:)/norm_factor(s);
        end
        layer.delivery_time(s) = delivery_timing(s);
    end
    layers{i,1} = layer_indices(i);
    layers{i,2} = layer;
end
