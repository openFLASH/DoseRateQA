%% compute_orthogonal_points
% Compute the coordinates of 2 points (|pts_in| and |pts_out|) belonging to each one of the rays composing a bundle of *paralell* rays.
% The position of the rays in a bundle is defined by the 2D-coordinate |pts_2D| of the rays in a plane perpendicular to the bundle axis
% All the rays of the bundle start from the same plan (containing |pt_in|) and end in the same plane (containing |pt_out|).
%
%% Syntax
% |[pts_in,pts_out] = compute_orthogonal_points(pt_in,pt_out,pts_2D)|
%
%
%% Description
% |[pts_in,pts_out] = compute_orthogonal_points(pt_in,pt_out,pts_2D)| Compute the coordiantes of the rays in the bundle
%
%
%% Input arguments
% |pt_in| - _SCALAR VECTOR_ - pt_in(x,y,z) Coordinates (in |mm|) of the source point on the beam axis 
%
% |pt_out| - _SCALAR VECTOR_ - pt_out(x,y,z) Coordinates (in |mm|) of the end point on the beam axis
%
% |pts_2D|- _MATRIX of DOUBLE_ - |pts_in(:,i)=[x,y]| Coordinates (in |mm|)
%
%
%% Output arguments
%
% |pts_in|- _MATRIX of DOUBLE_ - |pts_in(:,i)=[x,y,z]| Coordinates (in |mm|) of the source point of the i-th ray in the bundle
%
% |pts_out|- _MATRIX of DOUBLE_ - |pts_out(:,i)=[x,y,z]| Coordinates (in |mm|) of the end point of the i-th ray in the bundle
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [pts_in,pts_out] = compute_orthogonal_points(pt_in,pt_out,pts_2D)

v = pt_out-pt_in;
v = v/norm(v);
v_bis = -v([3;1;2]);
if(sum(not(v==-v_bis))==0)
    v_bis(3) = v_bis(3)+1;
end
ortho_x = cross(v_bis,v);
ortho_y = cross(ortho_x,v);

% Normalize
ortho_x = ortho_x/norm(ortho_x);
ortho_y = ortho_y/norm(ortho_y);

% Compute 3D isoplane points
pts_in = repmat(pt_in,[1,size(pts_2D,2)]) + repmat(pts_2D(1,:),[3,1]).*repmat(ortho_x,[1,size(pts_2D,2)]) + repmat(pts_2D(2,:),[3,1]).*repmat(ortho_y,[1,size(pts_2D,2)]);
pts_out = repmat(pt_out,[1,size(pts_2D,2)]) + repmat(pts_2D(1,:),[3,1]).*repmat(ortho_x,[1,size(pts_2D,2)]) + repmat(pts_2D(2,:),[3,1]).*repmat(ortho_y,[1,size(pts_2D,2)]);

