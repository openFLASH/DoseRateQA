%% Project_on_isoplane
% Paralell projection (by summing) of the voxels of the 3D-image |target| along lines parallel to the beam axis defined in |beam|. The projection takes place on a 2D beam's eye view plane that is perpendicular to the |beam| axis.
%
%% Syntax
% |proj = Project_on_isoplane(handles,target,beam,sad,bev_size)|
%
%
%% Description
% |proj = Project_on_isoplane(handles,target,beam,sad,bev_size)| Project |target| onto the beam's eye view plane
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
%
% |target| - _MATRIX of DOUBLE_ - |im(x,y,z)| 3D image from which the ray trace are extracted
%
% |beam| - _STRUCTURE or CELL_ -  Description of the proton beam geometry. See parameter |beam| or |data| or |geom| of function |get_beam_params| for more information.
%
% |sad|- _SCALAR_ - Proton source to isocentre distance (in mm)
%
% |bev_size| - _SCALAR_ - Size (in mm) of the edges of the square beam's eye view projection plane
%
% |pxlSpacing| -_SCALAR_- [OTPIONAL. Default = 1mm] Pixel size (mm)
%
%% Output arguments
%
% |proj| - _SCALAR MATRIX_ - |proj(x,y)| Value of the paralell projection of the |target| on a a surface perpendicular to the |beam| axis. The surface is centered on |beam| axis. It is a square with size equal to |bev_size|*|bev_size|
%
% |bev_v| -_SCALAR VECTOR_- |bev_v(i)| is the X or Y coordinate (mm in IC gantry) of the elements |proj(i,:)| or |proj(:,i)|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [proj , bev_v , pts_iso] = Project_on_isoplane(handles,target,beam,sad,bev_size, pxlSpacing)

    if nargin < 6
      NbPxl = bev_size;
    else
      NbPxl = round(bev_size ./ pxlSpacing);
    end

    % define lines for ray-tracings
    bev_v = linspace(-bev_size/2,bev_size/2,NbPxl);
    [x,y] = meshgrid(bev_v,bev_v);
    pts_2D = [x(:)';y(:)'];
    [pts_iso,pt_source] = compute_beam_isoplane(pts_2D,beam,sad);

    pts_source = repmat(pt_source,[1,size(pts_iso,2)]);
    vcts_rays = normalize_vcts(pts_iso-pts_source);
    pts_in = pts_iso - 400*vcts_rays;
    pts_out = pts_iso + 100*vcts_rays;

    % perform ray-tracing within target binary mask
    [mask_profiles , pt]= ray_tracing(target,handles.origin,handles.spacing,pts_in,pts_out,1,'linear',0);

    % compute projection
    proj = sum(mask_profiles,2);
    proj = reshape(proj,[length(bev_v),length(bev_v)]);

end
