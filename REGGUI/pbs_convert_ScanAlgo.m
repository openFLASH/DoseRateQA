%% pbs_convert_ScanAlgo
% Send a Pencil Beam Scanning (PBS) treatment plan to the "scanalgo" gateway interface. The treatment plan is converted first into a sequence of text strings (using |convert_Plan_PBS|) to send to scanalgo.
% Scanalgo predicts the timing of the delivery of the spots and returns the reply in several text strings.
% This reply is processed and packaged into a Matlab structure (using |convert_PBS_timing|).
%
% Note that the scanning magnets labels are defined in the PHYSICS CS. PHYSICS CS is derived from the Y-IEC GANTRY by exchanging X<->Y axes. So the X-magnet scans along the Y-IEC-GANTRY axis and vice-versa.
%
%% Syntax
% |delivery = pbs_convert_ScanAlgo(plan)|
%
% |delivery = pbs_convert_ScanAlgo(plan,options)|
%
%
%% Description
% |delivery = pbs_convert_ScanAlgo(plan)| Get the spot timing for the default room, spot and snout IDs and the number of repainting defined in |plan|
%
% |delivery = pbs_convert_ScanAlgo(plan,options)| Provide optional parameters
%
%% Input arguments
% |plan| - _STRUCTURE_ - Description of the treatment plan
%
% * |plan{f}.gantry_angle|  - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
% * |plan{f}.table_angle| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
% * |plan{f}.isocenter| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
% * |plan{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).nb_paintings| - _INTEGER_ - Number of painting for the j-th energy layer
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer. The coordinate system is IEC GANTRY.
% * ----|spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer
%
% |options| - _CELL_ - List of optional parameters (name of the parameter, followed by the value of the parameter). Such as:
%
% * |nb_paintings| - _INTEGER_ - [OPTIONAL] Number of paintings to apply to all layers. If empty (or missing), the number of painting is read from plan{f}.spots(j).nb_paintings
%
% * |gateway_IP| - _STRING_ - [OPTIONAL. Default  = '127.0.0.1:8080'] IP address where to connect to the scanalgo gateway
%
% * |room_id| - _STRING_ -  [OPTIONAL. default = ''] Name of the treatment room in which the plan will be delivered
%
% * |spot_tune_id| - _STRING_ - [OPTIONAL. Default  = ''] Name of the spot ID to use to deliver the plan
%
% * |snout_id| - _STRING_ - [OPTIONAL. Default  = ''] Name of the snout to use to deliver the plan
% * |energy_switching_time| -_SCALAR_- [OPTIONAL. Default  = ''] If provided, the energy layer switching time used by scanAlgo is ignored. The value provided in |energy_switching_time| is used instead.
%
% |verbose| -_BOOL_- [OPTIONAL: default = true] If true, the function display messages in console. If false, the function is silent
%
%
%% Output arguments
%
% |plan| - _STRUCTURE_ Description of the timing of the PBS spot delivery.
%
% * |plan{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).xy_current(s,:)| - _SCALAR VECTOR_ -  Magnet Setpoint (x,y) (in mm) of the s-th spot in the j-th energy layer. The magnets labels are defined in the PHYSICS CS. The PHYSICS CS is derived from the Y-IEC GANTRY by exchanging X<->Y axes. So the X-magnet scans along the Y-IEC-GANTRY axis and vice-versa.
% * ----|spots(j).time(s)| - _SCALAR_ - Time stamp (s) of the start  of the s-th spot in the j-th energy layer
% * ----|spots(j).duration(s)| - _SCALAR_ - Duration (s)  of the s-th spot in the j-th energy layer
% * ----|spots(j).charge(s)| - _SCALAR_ - Electric charge of the s-th spot in the j-th energy layer
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function delivery = pbs_convert_ScanAlgo(plan,options , verbose)

if nargin < 3
  verbose = true;
end

try_older_format = 0;

% Default config file
[~,reggui_data_path] = get_reggui_path;
config_file = fullfile(reggui_data_path,'reggui_scanalgo_config.txt');
if(nargin>1)
    for i=1:2:length(options)
        if(strcmp(options{i},'config_file'))
            if(exist(options{i+1},'file'))
                config_file = options{i+1};
            else
                if verbose
                  disp('Cannot find input scanalgo config file. Use default config file.');
                end
            end
        end
    end
end

% Default parameters
gateway_IP = '';
room_id = '';
spot_tune_id = '';
snout_id = '';
sort_spots = 'true';
energy_switching_time = [];
burst_switching_time = [];
try
    % try reading the default parameters from the reggui userdata folder
    fid = fopen(config_file);
    while(1)
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        eval(tline);
    end
    fclose(fid);
catch
    if verbose
      disp('Could not read default scanalgo parameters.')
    end
end
nb_paintings = 1;
output_filename = '';

% Input parameters
if(nargin>1)
    for i=1:2:length(options)
        if(ischar(options{i}))
            try
                eval([options{i},' = options{i+1};']);
            catch
                if verbose
                  disp(['Cannot create variable: ',options{i}]);
                end
            end
        end
    end
end

% Correct parameters
if(isempty(gateway_IP))
    gateway_IP = '127.0.0.1:8080';
end

if(not(try_older_format))

    format = 'json';
    url = ['http://',gateway_IP,'/rest/scanalgo-gateway/'];
    gateway_header = struct;
    gateway_header.name='Content-Type';
    gateway_header.value='application/json';
    gateway_header(2).name='Accept';
    gateway_header(2).value='application/json';
    try
        gateway_body = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id,snout_id,sort_spots);
        if(exist('user','var') && exist('password','var'))
            disp(['Connecting to ',url])
            options = weboptions('RequestMethod','post','Username',user,'Password',password,'ContentType','json','MediaType','application/json');
            for f=1:length(gateway_body)
                temp = webwrite(url,gateway_body{f},options);
                start_time = 0;
                for j=1:length(temp.layers)
                    delivery{1,f}.spots(j).energy = temp.layers(j).energy;
                    start_time = start_time + temp.layers(j).switchingTime;
                    layer_time = 0;
                    if(isfield(temp.layers(j),'bursts'))
                        nb_spots_previous_bursts = 0;
                        for b = 1:length(temp.layers(j).bursts)
                            for s = 1:length(temp.layers(j).bursts(b).spots)
                                spot_index = s + nb_spots_previous_bursts;
                                delivery{1,f}.spots(j).xy_current(spot_index,1) = temp.layers(j).bursts(b).spots(s).currentSetpointX;
                                delivery{1,f}.spots(j).xy_current(spot_index,2) = temp.layers(j).bursts(b).spots(s).currentSetpointY;
                                delivery{1,f}.spots(j).xy(spot_index,1) = temp.layers(j).bursts(b).spots(s).clinicalX;
                                delivery{1,f}.spots(j).xy(spot_index,2) = temp.layers(j).bursts(b).spots(s).clinicalY;
                                delivery{1,f}.spots(j).duration(spot_index,1) = temp.layers(j).bursts(b).spots(s).duration;
                                delivery{1,f}.spots(j).charge(spot_index,1) = temp.layers(j).bursts(b).spots(s).targetCharge;
                                delivery{1,f}.spots(j).element_id(spot_index,1) = temp.layers(j).bursts(b).spots(s).elementId;
                                delivery{1,f}.spots(j).spot_id(spot_index,1) = temp.layers(j).bursts(b).spots(s).spotId;
                                if(isfield(temp.layers(j).bursts(b).spots(s),'angle'))
                                    delivery{1,f}.spots(j).gantry_angle(spot_index,1) = temp.layers(j).bursts(b).spots(s).angle;
                                end
                                if(isfield(temp.layers(j).bursts(b).spots(s),'timeFromStart'))
                                    delivery{1,f}.spots(j).time(spot_index,1) = temp.layers(j).bursts(b).spots(s).timeFromStart*1e3;
                                else
                                    delivery{1,f}.spots(j).time(spot_index,1) = temp.layers(j).bursts(b).spots(s).startTime + start_time + layer_time;
                                end
                            end
                            burst_time = temp.layers(j).bursts(b).spots(s).startTime + temp.layers(j).bursts(b).spots(s).duration;
                            layer_time = layer_time + burst_time;
                            nb_spots_previous_bursts = nb_spots_previous_bursts + length(temp.layers(j).bursts(b).spots);
                        end
                    else
                        for s = 1:length(temp.layers(j).spots)
                            delivery{1,f}.spots(j).xy_current(s,1) = temp.layers(j).spots{s}.currentSetpointX;
                            delivery{1,f}.spots(j).xy_current(s,2) = temp.layers(j).spots{s}.currentSetpointY;
                            delivery{1,f}.spots(j).xy(s,1) = temp.layers(j).spots{s}.clinicalX;
                            delivery{1,f}.spots(j).xy(s,2) = temp.layers(j).spots{s}.clinicalY;
                            delivery{1,f}.spots(j).duration(s,1) = temp.layers(j).spots{s}.duration;
                            delivery{1,f}.spots(j).charge(s,1) = temp.layers(j).spots{s}.targetCharge;
                            delivery{1,f}.spots(j).element_id(s,1) = temp.layers(j).spots{s}.elementId;
                            delivery{1,f}.spots(j).spot_id(s,1) = temp.layers(j).spots{s}.spotId;
                            if(isfield(temp.layers(j).bursts(b).spots(s),'angle'))
                                delivery{1,f}.spots(j).gantry_angle(spot_index,1) = temp.layers(j).bursts(b).spots(s).angle;
                            end
                            if(isfield(temp.layers(j).bursts(b).spots(s),'timeFromStart'))
                                delivery{1,f}.spots(j).time(spot_index,1) = temp.layers(j).bursts(b).spots(s).timeFromStart;
                            else
                                delivery{1,f}.spots(j).time(s,1) = temp.layers(j).spots{s}.startTime + start_time;
                            end
                        end
                        layer_time = layer_time + burstemp.layers{j}.spots{s}.startTime + temp.layers(j).spots{s}.duration;
                    end
                    if(layer_time>temp.layers(j).duration)
                        disp('Warning: sum of burst duration exceeds layer duration');
                    end
                    start_time = start_time + temp.layers(j).duration;
                end
            end
        else
            response = cell(length(gateway_body),1);
            for f=1:length(gateway_body)
                response{f} = urlread2(url,'POST',gateway_body{f},gateway_header);
                if(contains(response{f},'"status":500'))
                    disp(gateway_body{f});
                    disp(response{f});
                end
                if(not(isempty(output_filename)))
                    fid=fopen([output_filename,'_',num2str(f),'.json'],'w');
                    fprintf(fid,response{f});
                    fclose(fid);
                end
            end
            delivery = convert_PBS_timing(response,format);
        end
    catch
        try_older_format = 1;
    end

end

if(try_older_format)
    if verbose
      disp('Warning: failed when using this scanalgo format. Trying with older scanalgo format...')
    end
    try_older_format = 0;
    format = 'json-1';
    url = ['http://',gateway_IP,'/rest/scanalgo-gateway/'];
    gateway_header = struct;
    gateway_header.name='Content-Type';
    gateway_header.value='application/json';
    gateway_header(2).name='Accept';
    gateway_header(2).value='application/json';

    try
        gateway_body = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id,snout_id,sort_spots);
        if(exist('user','var') && exist('password','var'))
            options = weboptions('RequestMethod','post','Username',user,'Password',password,'ContentType','json','MediaType','application/json');
            for f=1:length(gateway_body)
                temp = webwrite(url,gateway_body{f},options);
                start_time = 0;
                for j=1:length(temp.layers)
                    delivery{1,f}.spots(j).energy = temp.layers(j).energy;
                    start_time = start_time + temp.layers(j).switchingTime;
                    layer_time = 0;
                    if(isfield(temp.layers(j),'bursts'))
                        nb_spots_previous_bursts = 0;
                        for b = 1:length(temp.layers(j).bursts)
                            for s = 1:length(temp.layers(j).bursts(b).spots)
                                spot_index = s + nb_spots_previous_bursts;
                                delivery{1,f}.spots(j).xy_current(spot_index,1) = temp.layers(j).bursts(b).spots(s).currentSetpointX;
                                delivery{1,f}.spots(j).xy_current(spot_index,2) = temp.layers(j).bursts(b).spots(s).currentSetpointY;
                                delivery{1,f}.spots(j).xy(spot_index,1) = temp.layers(j).bursts(b).spots(s).clinicalX;
                                delivery{1,f}.spots(j).xy(spot_index,2) = temp.layers(j).bursts(b).spots(s).clinicalY;
                                delivery{1,f}.spots(j).time(spot_index,1) = temp.layers(j).bursts(b).spots(s).startTime + start_time + layer_time;
                                delivery{1,f}.spots(j).duration(spot_index,1) = temp.layers(j).bursts(b).spots(s).duration;
                                delivery{1,f}.spots(j).charge(spot_index,1) = temp.layers(j).bursts(b).spots(s).targetCharge;
                                delivery{1,f}.spots(j).element_id(spot_index,1) = temp.layers(j).bursts(b).spots(s).elementId;
                                delivery{1,f}.spots(j).spot_id(spot_index,1) = temp.layers(j).bursts(b).spots(s).spotId;
                                delivery{1,f}.spots(j).energy = temp.layers(j).energy;
                            end
                            burst_time = temp.layers(j).bursts(b).spots(s).startTime + temp.layers(j).bursts(b).spots(s).duration;
                            layer_time = layer_time + burst_time;
                            nb_spots_previous_bursts = nb_spots_previous_bursts + length(temp.layers(j).bursts(b).spots);
                        end
                    else
                        for s = 1:length(temp.layers(j).spots)
                            delivery{1,f}.spots(j).xy_current(s,1) = temp.layers(j).spots{s}.currentSetpointX;
                            delivery{1,f}.spots(j).xy_current(s,2) = temp.layers(j).spots{s}.currentSetpointY;
                            delivery{1,f}.spots(j).xy(s,1) = temp.layers(j).spots{s}.clinicalX;
                            delivery{1,f}.spots(j).xy(s,2) = temp.layers(j).spots{s}.clinicalY;
                            delivery{1,f}.spots(j).time(s,1) = temp.layers(j).spots{s}.startTime + start_time;
                            delivery{1,f}.spots(j).duration(s,1) = temp.layers(j).spots{s}.duration;
                            delivery{1,f}.spots(j).charge(s,1) = temp.layers(j).spots{s}.targetCharge;
                            delivery{1,f}.spots(j).element_id(s,1) = temp.layers(j).spots{s}.elementId;
                            delivery{1,f}.spots(j).spot_id(s,1) = temp.layers(j).spots{s}.spotId;
                        end
                        layer_time = layer_time + burstemp.layers{j}.spots{s}.startTime + temp.layers(j).spots{s}.duration;
                    end
                    if(layer_time>temp.layers(j).duration)
                        disp('Warning: sum of burst duration exceeds layer duration');
                    end
                    start_time = start_time + temp.layers(j).duration;
                end
            end
        else
            response = cell(length(gateway_body),1);
            for f=1:length(gateway_body)
                response{f} = urlread2(url,'POST',gateway_body{f},gateway_header);
                if(contains(response{f},'"status":500'))
                    disp(gateway_body{f});
                    disp(response{f});
                end
                if(not(isempty(output_filename)))
                    fid=fopen([output_filename,'_',num2str(f),'.json'],'w');
                    fprintf(fid,response{f});
                    fclose(fid);
                end
            end
            delivery = convert_PBS_timing(response,format);
        end
    catch
        try_older_format = 1;
    end
end

if(try_older_format)
    disp('Warning: failed when using this scanalgo format. Trying with older scanalgo format...')
    try_older_format = 0;
    format = 'json-2';
    url = ['http://',gateway_IP,'/rest/scanalgo-gateway/'];
    gateway_header = struct;
    gateway_header.name='Content-Type';
    gateway_header.value='application/json';
    gateway_header(2).name='Accept';
    gateway_header(2).value='application/json';
    try
        gateway_body = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id,snout_id);
        response = cell(length(gateway_body),1);
        for f=1:length(gateway_body)
            response{f} = urlread2(url,'POST',gateway_body{f},gateway_header);
            if(contains(response{f},{'"status":500','java.io.IOException'}))
                if verbose
                  disp(gateway_body{f});
                  disp(response{f});
                end
            end
            if(not(isempty(output_filename)))
                fid=fopen([output_filename,'_',num2str(f),'.json'],'w');
                fprintf(fid,response{f});
                fclose(fid);
            end
        end
        delivery = convert_PBS_timing(response,format);

        % Convert setpoint into xy position
        if(not(isfield(delivery{1}.spots(1),'xy')))
            for f=1:length(delivery)
                for i=1:length(delivery{f}.spots)
                    % find correspondance between xy and xy_current
                    xy_proxy = delivery{f}.spots(i).xy_current(:,[2,1]);
                    xy_proxy(:,1) = xy_proxy(:,1)*max(plan{f}.spots(i).xy(:,1))/max(unique(roundsd(xy_proxy(:,1),4)));
                    xy_proxy(:,2) = xy_proxy(:,2)*max(plan{f}.spots(i).xy(:,2))/max(unique(roundsd(xy_proxy(:,2),4)));
                    delivery{f}.spots(i).xy = xy_proxy*NaN;
                    D = sum(xy_proxy.^2,2)*ones(1,size(plan{f}.spots(i).xy,1)) + ones(size(xy_proxy,1),1)*sum(plan{f}.spots(i).xy.^2,2)'-2.*xy_proxy*plan{f}.spots(i).xy';
                    for j=1:size(xy_proxy,1)
                        [~,index] = min(D(j,:));
                        delivery{f}.spots(i).xy(j,:) = plan{f}.spots(i).xy(index,:);
                    end
                end % loop on layers
            end % loop on fields
        end

    catch
        try_older_format = 1;
    end
end

if(try_older_format)
    if verbose
      disp('Warning: failed when using this scanalgo format. Trying with older scanalgo format...')
    end
    try_older_format = 0;
    format = 'json-3';
    url = ['http://',gateway_IP,'/rest/scanalgo-gateway/'];
    gateway_header = struct;
    gateway_header.name='Content-Type';
    gateway_header.value='application/json';
    gateway_header(2).name='Accept';
    gateway_header(2).value='application/json';
    try
        gateway_body = convert_Plan_PBS(plan,format,nb_paintings,room_id,spot_tune_id,snout_id);
        response = cell(length(gateway_body),1);
        for f=1:length(gateway_body)
            response{f} = urlread2(url,'POST',gateway_body{f},gateway_header);
            if(not(isempty(output_filename)))
                fid=fopen([output_filename,'_',num2str(f),'.json'],'w');
                fprintf(fid,response{f});
                fclose(fid);
            end
        end
        delivery = convert_PBS_timing(response,format);

        % Convert setpoint into xy position
        for f=1:length(delivery)
            for i=1:length(delivery{f}.spots)
                % find correspondance between xy and xy_current
                xy_proxy = delivery{f}.spots(i).xy_current(:,[2,1]);
                xy_proxy(:,1) = xy_proxy(:,1)*max(plan{f}.spots(i).xy(:,1))/max(unique(roundsd(xy_proxy(:,1),4)));
                xy_proxy(:,2) = xy_proxy(:,2)*max(plan{f}.spots(i).xy(:,2))/max(unique(roundsd(xy_proxy(:,2),4)));
                delivery{f}.spots(i).xy = xy_proxy*NaN;
                D = sum(xy_proxy.^2,2)*ones(1,size(plan{f}.spots(i).xy,1)) + ones(size(xy_proxy,1),1)*sum(plan{f}.spots(i).xy.^2,2)'-2.*xy_proxy*plan{f}.spots(i).xy';
                for j=1:size(xy_proxy,1)
                    [~,index] = min(D(j,:));
                    delivery{f}.spots(i).xy(j,:) = plan{f}.spots(i).xy(index,:);
                end
            end % loop on layers
        end % loop on fields

    catch
        disp('ERROR: could not convert plan using ScanAlgo gateway!');
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
end

% Convert time in [s]
for f=1:length(delivery)
    for i=1:length(delivery{f}.spots)
        delivery{f}.spots(i).time = delivery{f}.spots(i).time/1e3;
    end
end

% Convert charge to MUs
for f=1:length(delivery)
    % Get weights from plan and charges from delivery
    layer_index = 1;
    for i=1:length(plan{f}.spots)
        weight_plan = sum(plan{f}.spots(i).weight);
        weight_delivery = sum(delivery{f}.spots(layer_index).charge);
        split = 0; % splitted layers
        if(layer_index+1<length(delivery{f}.spots))
            while(delivery{f}.spots(layer_index).energy == delivery{f}.spots(layer_index+split+1).energy)
                weight_delivery = weight_delivery + sum(delivery{f}.spots(layer_index+split+1).charge);
                split = split+1;
                if(layer_index+split+1>length(delivery{f}.spots))
                    break
                end
            end
        end
        weight_ratio(layer_index:layer_index+split) = weight_plan/weight_delivery;
        layer_index = layer_index + split + 1;
    end
    % Convert charge to weight
    for i=1:length(delivery{f}.spots)
        delivery{f}.spots(i).weight = delivery{f}.spots(i).charge*weight_ratio(i);
    end
end

% If energy switching time is specified, correct scanalgo outputs
if(not(isempty(energy_switching_time)))
    scanalgo_switching_time = delivery{1}.spots(1).time(1);
    for f=1:length(delivery)
        for i=1:length(delivery{f}.spots)
            delivery{f}.spots(i).time = delivery{f}.spots(i).time + i*(energy_switching_time - scanalgo_switching_time);
        end
    end
end

% If burst switching time is specified, correct scanalgo outputs
if(not(isempty(burst_switching_time)))
    for f=1:length(delivery)
        time_change = 0;
        for i=1:length(delivery{f}.spots)
            scanalgo_switching_time = 0;
            burst_switchings = find_burst_switchings(delivery{f}.spots(i));
            for j=2:length(burst_switchings)
                scanalgo_switching_time(j) = delivery{f}.spots(i).time(burst_switchings(j)) - delivery{f}.spots(i).time(burst_switchings(j)-1);
            end
            burst_switchings(end+1) = length(delivery{f}.spots(i).time)+1;
            for j=1:length(burst_switchings)-1
                time_change = time_change + burst_switching_time - scanalgo_switching_time(j);
                delivery{f}.spots(i).time(burst_switchings(j):burst_switchings(j+1)-1) = delivery{f}.spots(i).time(burst_switchings(j):burst_switchings(j+1)-1) + time_change;
            end
        end
    end
end

% Include energy and number of paintings
if(isempty(nb_paintings))
    nb_paintings = 1;
end
for f=1:length(delivery)
    if(length(delivery{f}.spots)==length(plan{f}.spots))
        for i=1:length(delivery{f}.spots)
            delivery{f}.spots(i).energy = plan{f}.spots(i).energy;
        end
    end
    for i=1:length(delivery{f}.spots)
        delivery{f}.spots(i).nb_paintings = nb_paintings;
    end
end

% Include info from the plan
for f=1:length(delivery)
    fields = fieldnames(plan{f});
    for j=1:length(fields)
        if(not(strcmp(fields{j},'spots')))
            delivery{f}.(fields{j}) = plan{f}.(fields{j});
        end
    end
end

%-------------------------------------------------------------
function delivery = mergeLayers(delivery)
  for f=1:length(delivery)
    s = 2;
    while (s <= length(delivery{f}.spots))
      if (delivery{f}.spots(s).energy == delivery{f}.spots(s-1).energy)
        fprintf('Merging 2 layers with same energy \n')
        delivery{f}.spots(s-1).xy_current = [delivery{f}.spots(s-1).xy_current ; delivery{f}.spots(s).xy_current];
        delivery{f}.spots(s-1).duration = [delivery{f}.spots(s-1).duration ; delivery{f}.spots(s).duration];
        delivery{f}.spots(s-1).time = [delivery{f}.spots(s-1).time ; delivery{f}.spots(s).time];
        delivery{f}.spots(s-1).charge = [delivery{f}.spots(s-1).charge ; delivery{f}.spots(s).charge];
        delivery{f}.spots(s) = [];
      else
        s = s +1;
    end
  end

end
