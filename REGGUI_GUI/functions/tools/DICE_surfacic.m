%% DICE_surfacic
% Compute the DICE_surfacic coefficient between two binary masks.
%
%% Syntax
% |res = DICE_surfacic(mask_ref,mask_eval,handles,tolerance)|
%
%
%% Description
% |res = DICE_surfacic(mask_ref,mask_eval,handles,tolerance)| Compute the DICE_surfacic coefficient
%
%
%% Input arguments
% |mask_ref| - _STRING_ -  Name of the first image in |handles.images| or |handles.mydata|
%
% |mask_eval| - _STRING_ -  Name of the second image in |handles.images| or |handles.mydata|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed.
%
% |tolerance| - _DOUBLE_ - Acceptable deviation for the surfaces to be considered as the same
%
%
%% Output arguments
%
% |res| - _SCALAR VECTOR_ - The results:
%
% * |res(1)| = Surface DICE coefficient between the 2 masks
% * |res(2)| = Added Path Length in evaluated mask surface compared to the reference mask
%
%% References
%
% https://phiro.science/article/S2405-6316(19)30063-6/fulltext
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = DICE_surfacic(mask_ref,mask_eval,handles,tolerance,unit)

if(nargin<4)
    tolerance = 0;
end
if(nargin<5)
    unit = 'mm';
end

[mask1,info1] = Get_reggui_data(handles,mask_ref);
[mask2,info2] = Get_reggui_data(handles,mask_eval);


if(not(sum(info1.Spacing==info2.Spacing)==length(info1.Spacing)) || not(sum(size(mask1)==size(mask2))==length(size(mask1))))
    disp('Different voxel grids. Cannot compute DICE. Abort.')
    res = [];
    return
end

if strcmp(unit,'mm2') % resample to isotropic voxel grid using smallest voxel spacing from input masks
    spacing = min(info1.Spacing)*ones(3,1);
    imsize = round(size(mask1)'.*info1.Spacing./spacing);
    lastpt = 1 + (imsize-1).*spacing./info1.Spacing;
    mask1 = resampler3(mask1,linspace(1,lastpt(1),imsize(1)),linspace(1,lastpt(2),imsize(2)),linspace(1,lastpt(3),imsize(3)));
    mask2 = resampler3(mask2,linspace(1,lastpt(1),imsize(1)),linspace(1,lastpt(2),imsize(2)),linspace(1,lastpt(3),imsize(3)));
end

% extract surface
surf1 = extract_binary_surface_from_volume(mask1>= 0.5);
surf2 = extract_binary_surface_from_volume(mask2>= 0.5);
intersection = single(surf1 & surf2);

% compute DICE and APL
if(tolerance == 0)
    dice_coef = sum(intersection(:))/(sum(surf1(:))+sum(surf2(:)))*2;
    added_path_length = surf1-intersection;
else
    disp('Not yet implemented')
    res = [];
end

if strcmp(unit,'mm2')
    added_path_length = round(sum(added_path_length(:))*spacing(1)^2);
elseif strcmp(unit,'mm')
    added_path_length = round(sum(added_path_length(:))*info1.Spacing(1));
else
    added_path_length = sum(added_path_length(:));
end

res = [dice_coef,added_path_length];
disp(['Surface DICE coefficient between ', mask_ref, ' and ', mask_eval, '  =  ', num2str(dice_coef)]);
if strcmp(unit,'mm2')
    disp(['Added path length between ', mask_ref, ' and ', mask_eval, '  =  ', num2str(added_path_length),' mm2']);
elseif strcmp(unit,'mm')
    disp(['Added path length between ', mask_ref, ' and ', mask_eval, '  =  ', num2str(added_path_length),' mm']);
else
    disp(['Added path length between ', mask_ref, ' and ', mask_eval, '  =  ', num2str(added_path_length),' voxels']);
end

