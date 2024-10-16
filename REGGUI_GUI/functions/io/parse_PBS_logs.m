%% parse_PBS_logs
% Imports PBS delivery logs and computes the xy coordinates of the delivered spots by finding the closest coordinates in the plan.
% Aggregate successive spots with identical coordinates
%
%% Syntax
% |beam_delivery = parse_PBS_logs(beam_planning,logFilename)|
%
% |beam_delivery = parse_PBS_logs(beam_planning,logFilename,xdr_converter)|
%
%
%% Description
% |beam_delivery = parse_PBS_logs(beam_planning,logFilename)| Read the PBS log using the default JAVA log converter and aggregate successive PBS spot
%
% |beam_delivery = parse_PBS_logs(beam_planning,logFilename,xdr_converter)| Read the PBS log using the specified JAVA log converter and aggregate successive PBS spot
%
%
%% Input arguments
% * |beam_planning{1}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer. The coordinate system is IEC-GANTRY.
%
% |logFilename| - _STRING_ - Name of the folder containing the logs
%
% |xdr_converter| - _STRING_ - File name (including path) of the JAVA executable used to convert the irradiation logs from XDR format to text format. If absent, uses the default convertion program.
%
%
%% Output arguments
%
% |beam_delivery| - _STRUCTURE_ - beam_delivery (structure) with xy
%
% * |beam_delivery{1}.spots(l).charge(s)| - _SCALAR_ - Electrical charge of the s-th spot of the l-th energy layer
% * |beam_delivery{1}.spots(l).timeStart(s)| - _SCALAR_ - Time at the begining of the delivery of the s-th spot of the l-th energy layer 
% * |beam_delivery{1}.spots(l).timeStop(s)| - _SCALAR_ - Time at the end of the delivery of the s-th spot of the l-th energy layer 
% * |beam_delivery{1}.spots(l).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer. This is the coordinate of the closest spot in the plan near xyIC(s,:). The coordinate system is IEC-GANTRY.
% * |beam_delivery{1}.spots(l).xyIC(s,:)| - _SCALAR VECTOR_ - Average spot position (x,y) over the delivery of the s-th spot of the l-th energy layer.  The coordinate system is IEC-GANTRY.   
% * |beam_delivery{1}.spots(l).nb_protons(s)| - _SCALAR_ - Number of proton in the s-th spot of the l-th energy layer 
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function beam_delivery = parse_PBS_logs(beam_planning,logFilename,xdr_converter)


% get plan and logs
if(nargin<3)
    beam_delivery = load_PBS_logs(logFilename,[],[]);
else
    beam_delivery = load_PBS_logs(logFilename,'',xdr_converter);
end

% get number of layers
nb_layers = length(beam_planning{1}.spots);

% parse spot information
for layer=1:nb_layers
    
    XY_planning = beam_planning{1}.spots(layer).xy;
    XY_delivery = beam_delivery{1}.spots(layer).xyConverted;
    
    % Replace XY coordinates of the delivered spots by closest coordinates in the plan
    D = sum(XY_delivery.^2,2)*ones(1,size(XY_planning,1)) + ones(size(XY_delivery,1),1)*sum(XY_planning.^2,2)'-2.*XY_delivery*XY_planning';
    for i=1:size(XY_delivery,1)
        [~,index] = min(D(i,:));
        XY_delivery(i,:) = XY_planning(index,:);
    end    
    
    % Update beam delivery structure
    beam_delivery{1}.spots(layer).xy = XY_delivery;
    
    % Aggregate successive spots with identical coordinates
    g = diff(beam_delivery{1}.spots(layer).xy(:,1)+1e6*beam_delivery{1}.spots(layer).xy(:,2)); % Replace the 2-dimensional (X,Y) coordinate of a spot by a LINEAR index (X+10^6.Y). Take the difference of linear index between sucessive measurements. Aggregate all the measurements for which the ndex difference is null (i.e. these measurements belong to the same spot ).
    index = find(g==0);
    index = index(end:-1:1);
    for i=1:length(index)
        beam_delivery{1}.spots(layer).timeStop(index(i)) = beam_delivery{1}.spots(layer).timeStop(index(i)+1);
        beam_delivery{1}.spots(layer).charge(index(i)) = beam_delivery{1}.spots(layer).charge(index(i)) + beam_delivery{1}.spots(layer).charge(index(i)+1);
        beam_delivery{1}.spots(layer).nb_protons(index(i)) = beam_delivery{1}.spots(layer).nb_protons(index(i)) + beam_delivery{1}.spots(layer).nb_protons(index(i)+1);
        % remove elements of the aggregated measurements
        beam_delivery{1}.spots(layer).xy = beam_delivery{1}.spots(layer).xy([1:index(i),index(i)+2:end],:);
        beam_delivery{1}.spots(layer).xyIC = beam_delivery{1}.spots(layer).xyIC([1:index(i),index(i)+2:end],:);
        beam_delivery{1}.spots(layer).timeStart = beam_delivery{1}.spots(layer).timeStart([1:index(i),index(i)+2:end]);
        beam_delivery{1}.spots(layer).timeStop = beam_delivery{1}.spots(layer).timeStop([1:index(i),index(i)+2:end]);
        beam_delivery{1}.spots(layer).charge = beam_delivery{1}.spots(layer).charge([1:index(i),index(i)+2:end]);
        beam_delivery{1}.spots(layer).nb_protons = beam_delivery{1}.spots(layer).nb_protons([1:index(i),index(i)+2:end]);
    end   
    
end
