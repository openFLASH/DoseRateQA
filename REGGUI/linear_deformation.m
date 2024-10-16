%% linear_deformation
% Deforms an 3D image or a (first) defomation field according to a given (second) deformation field.
% |linear_deformation| does not make use of the estimate certainty.
% The default method used is simple bi/trilinear interpolation
%%

%% Syntax
% |output = linear_deformation(indata, boundary, deformation_field = MATRIX, deformation_certainty, interpolation, logdomain)|
%
% |output = linear_deformation(indata, boundary, deformation_field = CELL VECTOR OF MATRICES, deformation_certainty, interpolation, logdomain)|
%
% |output = linear_deformation(indata, boundary, deformation_field, deformation_certainty)|
%
% |output = linear_deformation(indata, boundary, deformation_field, deformation_certainty, interpolation, logdomain)|

%% Description
% |output = linear_deformation(indata, boundary, deformation_field, deformation_certainty, interpolation, logdomain)| Deforms the image according to the deformation field
%
% |output = linear_deformation(indata, boundary, deformation_field, deformation_certainty)| Deforms the image according to the deformation field using linear interpolation and logdomain =0
%
% |output = linear_deformation(indata, boundary, deformation_field, deformation_certainty, interpolation)| Deforms the image according to the deformation field  using logdomain =0

%% Input arguments
% |indata| - _MATRIX of SCALAR_ -  |data(x,y,z)| represents the intensity of the voxel (x,y,z). Alternatively, |data(j,x,y,z)| represents the j-th component of the vector of a deformation field at voxel (x,y,z).
%
% |boundary| - _STRING_ -  The following options are possible:
%
% * 'zeros': Zero padding: The voxel of the deformated image coming from deformation vector pointing outside of the field of view of the image are set to zero
% * Otherwise : intensity constant padding : The voxel of the deformated image coming from deformation vector pointing outside of the field of view of the image are set equal to the intensity of the closest voxel on the border of the image
%
% |deformation_field| - There are two possible types of input: 
%
% * _CELL VECTOR of MATRICES_ |deformation_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
% * _MATRIX of SCALAR_ |deformation_field(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |deformation_field(2,x,y,z)| and |deformation_field(3,x,y,z)|.
%
% |deformation_certainty| - Not used.
%
% |interpolation| - _STRING_ -  Type of interpolation used. See |interp2| and |interp3| for the list of options.
%
% |logdomain| - _INTEGRER_ -  |logdomain=1|: Use the logarithmic diffeomorphic when accumulating the transforms. |logdomain=0| Directly accumulate the transform (i.e. in the exponential domain).
%
%
%% Output arguments
%
% |output| - _MATRIX of SCALAR_ -  |output(x,y,z)| represents the intensity of the voxel (x,y,z) of the deformed image. Alternatively, |output(j,x,y,z)| represents the j-th component of the vector of a deformation field at voxel (x,y,z).
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function output = linear_deformation(indata, boundary, deformation_field, deformation_certainty, interpolation, logdomain)

if(not(iscell(deformation_field)))
    deformation_field = field_convert(deformation_field);
end

if(not(isa(deformation_field{1},'single')))
    for n=1:length(deformation_field)
        deformation_field{n} = single(deformation_field{n});
    end
end

f_a = 1;
if(~(exist('field_application','file')==3))
    f_a = 0;
    disp('Warning : field_application not found ! You may need to compile the mex-file.')
end

if(nargin<5)
    interpolation = 'linear';
else
    f_a = 0;
end

if(nargin<6)
    logdomain = 0;
end
if(logdomain)
    deformation_field = field_exponentiation(deformation_field);
end

dims = length(size(indata));
sz = size(indata);

switch boundary
    case 'zeros'
        if (dims == 2)
            [X,Y] = meshgrid(1:sz(2), 1:sz(1));
            X = single(X);
            Y = single(Y);
            output = interp2(X, Y, indata, X+deformation_field{1}, Y+deformation_field{2}, interpolation);
        elseif (dims == 3)
            if(f_a)
                % modified by J.A.Lee October 2008
                output = field_application({deformation_field{2},deformation_field{1},deformation_field{3}},single([1;1;1]),indata,single([1;1;1]),single([0;0;0]),single(NaN));
            else
                [X,Y,Z] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3));
                X = single(X);
                Y = single(Y);
                Z = single(Z);
                output = interp3(indata, X+deformation_field{1}, Y+deformation_field{2}, Z+deformation_field{3}, interpolation);
            end
        end
        % Remove NaN:s
        z = isnan(output);
        output(z) = 0;

    otherwise
        if (dims == 2)
            [X,Y] = meshgrid(1:sz(2), 1:sz(1));
            X = single(X);
            Y = single(Y);
            %output = interp2(X, Y, indata, X+deformation_field{1}, Y+deformation_field{2}, 'linear');
            output = interp2(X, Y, indata, max(min(X+deformation_field{1},size(indata,2)),1), max(min(Y+deformation_field{2},size(indata,1)),1), interpolation);
            %z = (X+deformation_field{1}>size(indata,2) | X+deformation_field{1}<1 | Y+deformation_field{2}>size(indata,1) | Y+deformation_field{2}<1);
        elseif (dims == 3)
            if(f_a)
                % modified by J.A.Lee October 2008
                output = field_application({deformation_field{2},deformation_field{1},deformation_field{3}},single([1;1;1]),indata,single([1;1;1]));
            else
                [X,Y,Z] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3));
                X = single(X);
                Y = single(Y);
                Z = single(Z);
                %output = interp3(indata, X+deformation_field{1},Y+deformation_field{2}, Z+deformation_field{3}, 'linear');
                output = interp3(indata, max(min(X+deformation_field{1},size(indata,2)),1), max(min(Y+deformation_field{2},size(indata,1)),1), max(min(Z+deformation_field{3},size(indata,3)),1), interpolation);
                %z = (X+deformation_field{1}>size(indata,2) | X+deformation_field{1}<1 | Y+deformation_field{2}>size(indata,1) | Y+deformation_field{2}<1 | Z+deformation_field{3}>size(indata,3) | Z+deformation_field{3}<1);
            end
        end
end

