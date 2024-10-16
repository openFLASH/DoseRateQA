%% field_convert
% Convert the deformation field between the two possible data formats:
% Either from _CELL VECTOR_ to _SCALAR MATRIX_
% Or from _SCALAR MATRIX_ to _CELL VECTOR_
%
%% Syntax
% |field = field_convert(input_field = _CELL VECTOR_,dims)|
%
% |field = field_convert(input_field = _SCALAR MATRIX_,dims)|
%
% |field = field_convert(input_field)|
%
%
%% Description
% |field = field_convert(input_field = _CELL VECTOR_,dims)| converts the deformation field from _CELL VECTOR_ to _SCALAR MATRIX_
%
% |field = field_convert(input_field = _SCALAR MATRIX_,dims)| converts the deformation field from _SCALAR MATRIX_ to _CELL VECTOR_
%
% |field = field_convert(input_field)| Converts data format of the deformation field and computes the dimension of the deformation field from the size of |input_field|
%
%
%% Input arguments
% |input_field| - There are two possible types of input: 
%
% * _CELL VECTOR of MATRICES_ |input_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
% * _MATRIX of SCALAR_ |input_field(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |input_field(2,x,y,z)| and |input_field(3,x,y,z)|.
%
% |dims| - _INTEGER_ -  Dimension of the deformation field |input_field|.
%
%
%% Output arguments
%
% |field| - There are two possible types of ouput. The output type is the opposite of the input  type: 
%
% * _MATRIX of SCALAR_ |input_field(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |input_field(2,x,y,z)| and |input_field(3,x,y,z)|.
% * _CELL VECTOR of MATRICES_ |input_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function field = field_convert(input_field,dims)

if(iscell(input_field))
    if(nargin<2)
        dims = length(input_field);
    end

    if(dims==2)

        field = zeros([2,size(cell2mat(input_field(1)))],'single');
        field(1,:,:) = cell2mat(input_field(2));
        field(2,:,:) = cell2mat(input_field(1));

    elseif(dims==3)

        field = zeros([3,size(cell2mat(input_field(1)))],'single');
        field(1,:,:,:) = cell2mat(input_field(2));
        field(2,:,:,:) = cell2mat(input_field(1));
        field(3,:,:,:) = cell2mat(input_field(3));

    end

else
    field = cell(0);
    if(nargin<2)
        dims = ndims(input_field)-1;
    end

    if(dims==2)

        field{1} = squeeze(input_field(2,:,:));
        field{2} = squeeze(input_field(1,:,:));

    elseif(dims==3)

        field{1} = squeeze(input_field(2,:,:,:));
        field{2} = squeeze(input_field(1,:,:,:));
        field{3} = squeeze(input_field(3,:,:,:));

    end


end
