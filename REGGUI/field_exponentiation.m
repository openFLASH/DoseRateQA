%% field_exponentiation
% Compute the exponential of a deformation field.
% See section  "2.2.1 Field exponential" of reference [1] for more information
%
%% Syntax
% |est_field = field_exponentiation(est_field)|
%
%
%% Description
% |est_field = field_exponentiation(est_field)| describes the function
%
%
%% Input arguments
% |est_field| - The deformation field. There are two possible types of input: 
%
% * _CELL VECTOR of MATRICES_ |input_field{1}(x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in cell components {2} and {3}. 
% * _MATRIX of SCALAR_ |input_field(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |input_field(2,x,y,z)| and |input_field(3,x,y,z)|.
%
%
%% Output arguments
%
% |est_field| - _Same as input type_ - The exponentiated field.
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function est_field = field_exponentiation(est_field)

convert = 0;

if(not(iscell(est_field)))
    est_field = field_convert(est_field);
    convert = 1;
end

est_field_sqr = est_field{1}.^2;
for n=2:length(est_field)
    est_field_sqr = est_field_sqr+est_field{n}.^2;
end

N = ceil(2 + log2(max(max(max(sqrt(est_field_sqr)))))/2) +1;
if(N<1)
    N=1;
end

for n = 1:length(est_field)
    est_field{n} = est_field{n}*2^(-N);
end
for r=1:N
    for n = 1:length(est_field)
        new_field{n} = linear_deformation(est_field{n},'',est_field,[]);
        new_field{n} = new_field{n}+est_field{n};
    end
    est_field = new_field;
end

if(convert)
    est_field = field_convert(est_field);
end
