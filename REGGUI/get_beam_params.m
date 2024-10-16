%% get_beam_params
% Return the beam geometry parameter from a beam structure
%
%% Syntax
% |[res,res2,res3] = get_beam_params(beam)|
%
% |[res,res2,res3] = get_beam_params(data{2})|
%
% |[res,res2,res3] = get_beam_params(geom{3})|
%
% |res = get_beam_params(beam,param)|
%
% |res = get_beam_params(data{2},param)|
%
% |res = get_beam_params(geom{3},param)|
%
%% Description
% |[res,res2,res3] = get_beam_params(beam)| Return all the parameters of the beam geometry from a beam structure
%
% |[res,res2,res3] = get_beam_params(data{2})| Return all the parameters of the beam geometry from a cell vector with 2 elements
%
% |[res,res2,res3] = get_beam_params(geom{3})| Return all the parameters of the bema geometry from a cell vector with 3 elements
%
% |res = get_beam_params(beam,param)| Return the specified parameter of the beam geometry from a beam structure
%
% |res = get_beam_params(data{2},param)| Return the specified parameter of  the beam geometry from a cell vector with 2 elements
%
% |res = get_beam_params(geom{3},param)| Return the specified parameter of  the bema geometry from a cell vector with 3 elements
%
%
%% Input arguments
% |beam| - _STRUCTURE_ -  Description of the proton beam geometry
%
% * |beam.gantry_angle| - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
% * |beam.table_angle| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
% * |beam.isocenter| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
%
% |data| - _CELL VECTOR_ The data is a cell vector with two elements:
%
% * |data{1}| - _CELL VECTOR_ Cell vector of structure describing the beam
% * |data{2} = index| - _INTEGER_ Index so that data{1}{index} is the |beam| structure
%
% |geom| - _CELL VECTOR_ The data is a cell vector with three elements:
%
% * |geom{1}| - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
% * |geom{2}| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
% * |geom{3}| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
% 
% |param| - _STRING_ -  specify which geometric parameter shall be read from the beam geometry
%
% * 'gantry_angle'
% * 'table_angle'
% * 'isocenter'
%
%
%% Output arguments
%
% |res| - _SCALAR_ - The specified geometric parameter. By default: gantry angle (degree)
%
% |res2| - _SCALAR_ - Table yaw (degree)
%
% |res3| - _SCALAR VECTOR_ - (x,y,z) Coordiantes (in mm) of the isocentre in the DICOM CS ofthe CT scan
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [res,res2,res3] = get_beam_params(beam,param)

% Authors : G.Janssens (open.reggui@gmail.com)

% get beam
if(isstruct(beam)) % beam data
    gantry_angle = beam.gantry_angle;
    table_angle = beam.table_angle;
    isocenter = beam.isocenter;
elseif(length(beam)<3) % plan + beam_index
    myBeamData = beam{1};
    if(length(beam)>1)
        beam_index = beam{2};
    else
        beam_index = 1;
    end  
    gantry_angle = myBeamData{beam_index}.gantry_angle;
    table_angle = myBeamData{beam_index}.table_angle;
    isocenter = myBeamData{beam_index}.isocenter;
else % geometrical parameters in a cell   
    gantry_angle = beam{1};
    table_angle = beam{2};
    isocenter = beam{3};
end

if(nargin>1 && nargout==1)
    switch param
        case 'gantry_angle'
            res = gantry_angle;
        case 'table_angle'
            res = table_angle;
        case 'isocenter'
            res = isocenter;
        otherwise
            res = gantry_angle;
            res2 = table_angle;
            res3 = isocenter;
    end
else
    res = gantry_angle;
    res2 = table_angle;
    res3 = isocenter;
end
