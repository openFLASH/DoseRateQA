%% gauss_leg_cube
% The function returns the coordinates and the weights associated to the points for an integration on a tetrahedra. 
%
%% Syntax
% |[Coord, Weights] = gauss_leg_cube(order)|
%
%
%% Description
% |[Coord, Weights] = gauss_leg_cube(order)| returns the coordinates and weight of the integration points in tetrahedral coordinate system
%
%
%% Input arguments
% |order| - _INTEGER_ -  Order of the integration precision (allowed values: 1, 2 or 3)
%
%
%% Output arguments
%
% |Coord| - _SCALAR MATRIX_ - |Coord(i,:)| Coordinates (e1,e2,e3,e4) of the point |i| in tetrahedral coordinate system (see [1]).
%
% |Weights| - _SCALAR VECTOR_ - |Weights(i)| Weight of the point |i| in the tetrahedral integration
%
%% Reference
% [1] http://www.colorado.edu/engineering/CAS/courses.d/AFEM.d/AFEM.Ch09.d/AFEM.Ch09.pdf
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [Coord, Weights] = gauss_leg_cube(order)

switch order;
    case 1
        Coord = [1 0 0 0];
        Weights = 1;
    case 2
        val = sqrt(3)/3;
        Coord = [1 val val val;1 -val val val;1 -val -val val;1 val -val val;1 val val -val;1 -val val -val;1 -val -val -val;1 val -val -val];
        Weights = ones(1,8)/8;
    case 3
        val = 0.774596669241483;
        Coord = [1 0 0 0;1 val val val;1 -val val val;1 -val -val val;1 val -val val;1 val val -val;1 -val val -val;1 -val -val -val;1 val -val -val];
        Weights = [4*8/9 ones(1,8)*5/9]/8;
    otherwise
        disp('The order you asked for is not available')
end
