%% contour_distance_3D
% Compute the distance between the GTV and the lung contour. The distance is computed along the DICOM axis in the AP/PA, LR/RL, IS/SI directions
% NOTE : The coordinates of input masks must be DICOM: (xDICOM,yDICOM,zDICOM)
%
%% Syntax
% |[min_distance] = contour_distance_3D(GTVmask,Lung_mask)|
%
%
%% Description
% |[min_distance] = contour_distance_3D(GTVmask,Lung_mask)| Computes the distance between the GTV and the lung contour.
%
%
%% Input arguments
% |GTVmask| - _SCALAR MATRIX_ -  |GTVmask(x,y,z)=1| if the pixel at position (x,y,z) belongs to the GTV. 0, otherwise 
%
% |Lung_mask| - _SCALAR MATRIX_ -  |Lung_mask(x,y,z)=1| if the pixel at position (x,y,z) belongs to the corresponding lung (R or L) where the tumor (GTV) is located. 0, otherwise 
%
%
%% Output arguments
%
% |min_distance| - _SCALAR MATRIX_ - Returns the minimum distance (in pixels) between the GTV and the lung contour:
%
% * |min_distance(1,:) = [min_xRL min_xLR]| - _SCALAR VECTOR_ - The minimum distance along the X DICOM axis in the right to left and inversly
% * |min_distance(1,:) = [min_yAP min_yPA]| - _SCALAR VECTOR_ - The minimum distance along the Y DICOM axis in the anterior to posterior direction and inversly
% * |min_distance(1,:) = [min_zIS min_zSI]| - _SCALAR VECTOR_ - The minimum distance along the Z DICOM axis in the inferior to superior direction and inversly
%
%% Contributors
% Author: Ana M. Barragan Montero (open.reggui@gmail.com)
% created on 30/01/2016
% last modification 03/02/2016


function [min_distance] = contour_distance_3D(GTVmask,Lung_mask)


% INPUT : GTV mask and 


% Substract GTVmask to Lung_mask
Lung_mask = Lung_mask - GTVmask;
Lung_mask = (Lung_mask > 0); % avoid negatives values when the GTV goes outside the lung


% find borders for GTV ( we assume that the GTV is ROI_index_2)

tmp = squeeze(sum(GTVmask,3));
tmp = squeeze(sum(tmp,2));
idx = find(tmp);
min_idx_GTV = min(idx);
max_idx_GTV = max(idx);
center_idx_GTV = round((max_idx_GTV - min_idx_GTV)/2)+min_idx_GTV;

tmp = squeeze(sum(GTVmask,3));
tmp = squeeze(sum(tmp,1));
idy = find(tmp);
min_idy_GTV = min(idy);
max_idy_GTV = max(idy);
center_idy_GTV = round((max_idy_GTV - min_idy_GTV)/2)+min_idy_GTV;

tmp = squeeze(sum(GTVmask,1));
tmp = squeeze(sum(tmp,1));
idz = find(tmp);
min_idz_GTV =  min(idz);
max_idz_GTV = max(idz);
center_idz_GTV = round((max_idz_GTV - min_idz_GTV)/2)+min_idz_GTV;

% Find minimum distance for xDICOM,yDICOM and zDICOM

% xDICOM RL and LR
tmp = Lung_mask(center_idx_GTV:end,idy,idz);
tmp = squeeze(sum(tmp,1));
min_xRL = min(tmp(:));

tmp = Lung_mask(1:center_idx_GTV,idy,idz);
tmp = squeeze(sum(tmp,1));
min_xLR = min(tmp(:));


% yDICOM AP and PA
tmp = Lung_mask(idx,center_idy_GTV:end,idz);
tmp = squeeze(sum(tmp,2));
min_yAP = min(tmp(:));

tmp = Lung_mask(idx,1:center_idy_GTV,idz);
tmp = squeeze(sum(tmp,2));
min_yPA = min(tmp(:));

% zDICOM IS and SI 
tmp = Lung_mask(idx, idy,center_idz_GTV:end);
tmp = squeeze(sum(tmp,3));
min_zIS = min(tmp(:));

tmp = Lung_mask(idx,idy,1:center_idz_GTV);
tmp = squeeze(sum(tmp,3));
min_zSI = min(tmp(:));



% fill in vector
min_distance = [min_xRL min_xLR; min_yAP min_yPA; min_zIS min_zSI];


end



