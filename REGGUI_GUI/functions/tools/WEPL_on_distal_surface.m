%% WEPL_on_distal_surface
% Compute the Water Equivalent Path Length (WEPL) (in mm) from the skin surface (defined as 40cm upstream from isocentre) down to the distal surface of the selected sturcture. The WEPL is computed along the path of the selected proton beam, assuming that all rays are paralell (no divergence). The result is a projection map of the distal surface of the structure. The map is centered on the projection of the isocentre. The axes are the IEC gantry CS.
%
%% Syntax
% |[res,wepl_target_ante] = WEPL_on_distal_surface(handles,ct_name,params,target_name,body_name)|
%
%
%% Description
% |[res,wepl_target_ante] = WEPL_on_distal_surface(handles,ct_name,params,target_name,body_name)| Compute the WEPL to the distal surface ofthe structure
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.plans| - _STRUCTURE_ Description of the treamtent plan. Contains the descrition of the beams geometry
% * ---- |handles.plans.name{i}| - _CELL VECTOR of STRING_ Name of the ith treatment plan
% * ---- |handles.plans.data{i}{j}| - _CELL VECTOR of STRUCTURE_ - Data related to the jth beam of the ith plan
% * ---- |handles.plans.data{i}{j}.energy| - _SCALAR_ Energy of the jth beam of the ith plan
% * |handles.origin| : Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |ct_name| - _STRING_ -  Name of the CT scan in |handles.images| from which the WEPL are computed
%
% |params| - _CELL VECTOR_ - Definition of the beam parameters:
%
% * |params{1}| - _STRUCTURE or STRING_ Define the Hounsfield unit to stopping power conversion model. See hu_to_we.m for description of the parameter
% * |params{2}| - _SCALAR_ - Proton source to axis (isocentre) distance (in mm)
% * |params{3}| - _STRING_ Name of the treatment plan in |handles.plans|
% * |params{4}| - _INTEGER_ - Index j of the beam in |handles.plans.data{i}{j}|
%
% |target_name| - _STRING_ -  Name of the RT struct in |handles.images| defining the target. The WEPL will be computed along the beam path up to the distal surface of this structure
%
% |body_name| - _STRING_ -  Name of the RT struct in |handles.images| defining the skin surface. The WEPL will be computed along the beam path, starting from the surface of this structure
%
%
%% Output arguments
%
% |res| - _SCALAR MATRIX_ -  2D projection map (along the beam path) of DISTAL surface of the structure |target_name|. |res(x,y)| is the WEPL (in mm) to the pixel (x,y). The map is centered on the isocentre projection.
%
%
% |wepl_target_ante| - _SCALAR MATRIX_ -  2D projection map (along the beam path) of PROXIMAL surface of the structure |target_name|. |wepl_target_ante(x,y)| is the WEPL (in mm) to the pixel (x,y). The map is centered on the isocentre projection. This parameter is computed only if the proximal surface is located downstream from the isocentre (e.g. typically for an organ at risk located downstream from the isocentre).
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

% TODO This function uses hu_to_we.m which has been declared as DEPRECATED
% TODO Use better definition of skin surface. Do not hardcode the 400mm distance

function [res,wepl_target_ante] = WEPL_on_distal_surface(handles,ct_name,params,target_name,body_name)

current_dir = pwd;

res = handles; %TODO Why this line ? It is overwritten by line 169

% Get input images (CT and masks)
ct = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},ct_name))
        ct = handles.images.data{i};
    end
end
if(isempty(ct))
    error('Error : input image not found in the current list !')
end

target = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},target_name))
        target = handles.images.data{i};
    end
end
if(isempty(target))
    error('Error : target_name image not found in the current list !')
else
    target = single(target>(max(target(:))/2));
end

if(nargin>5)
    body = [];
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},body_name))
            body = handles.images.data{i};
        end
    end
    body = single(body>(max(body(:))/2));
else
    body = ones(size(ct));
end

model = params{1};
sad = params{2};
plan_name = params{3};
beam_index = params{4};

beam = [];
for i=1:length(handles.plans.name)
    if(strcmp(handles.plans.name{i},plan_name))
        plan = handles.plans.data{i};
        beam = plan{beam_index};
        if(isfield(beam,'energy'))
           energy = beam.energy{1}; 
        end
        break
    end
end
if(isempty(beam))
    error('Error : beam not found !')
end

% define lines for ray-tracings
[x,y] = meshgrid([-100:100],[-100:100]); %Define points in a plane orthogonal to proton beam. Axes are IEC gantry CS
pts_2D = [x(:)';y(:)'];
[pts_iso,pt_source] = compute_beam_isoplane(pts_2D,beam,sad); %Convert coordinate of the rays into the DICOM patient CS
pts_source = repmat(pt_source,[1,size(pts_iso,2)]);
vcts_rays = normalize_vcts(pts_iso-pts_source);
pts_in = pts_iso - 400*vcts_rays;
pts_target_post = pts_iso + 100*vcts_rays;
pts_target_ante = pts_iso + 100*vcts_rays;

% perform ray-tracing within target binary mask
disp('start ray-tracings for 2D wepl computation...')
mask_profiles = ray_tracing(target,handles.origin,handles.spacing,pts_in,pts_target_post,1,'nearest',0);

% select rays intersecting target
crossing_target = find(sum(mask_profiles,2));
pts_in = pts_in(:,crossing_target);
vcts_rays = vcts_rays(:,crossing_target);
mask_profiles = mask_profiles(crossing_target,:);
pts_target_post = pts_target_post(:,crossing_target);
pts_target_ante = pts_target_ante(:,crossing_target);

% computing the intersection point in 3D
body_profiles = ray_tracing(body,handles.origin,handles.spacing,pts_in,pts_target_post,1,'nearest',0);
for i=1:size(mask_profiles,1)
    body_entrance_index = find(body_profiles(i,end:-1:1),1,'last')+1/2;
    pts_in(:,i) = pts_target_post(:,i) - body_entrance_index*vcts_rays(:,i);
    target_post_index = find(mask_profiles(i,end:-1:1),1,'first')-1;
    pts_target_post(:,i) = pts_target_post(:,i) - target_post_index*vcts_rays(:,i);
    target_ante_index = find(mask_profiles(i,end:-1:1),1,'last')-1;
    pts_target_ante(:,i) = pts_target_ante(:,i) - target_ante_index*vcts_rays(:,i);
end

% compute WET and WEPL
% target ante
ct_profiles_target_ante = ray_tracing(((ct+1024).*body)-1024,handles.origin,handles.spacing,pts_in,pts_target_ante,1,'linear',-1024);
wet_profiles_target_ante = hu_to_we(ct_profiles_target_ante,model);
wepl_target_ante_roi = sum(wet_profiles_target_ante,2);
% target post
ct_profiles_target_post = ray_tracing(((ct+1024).*body)-1024,handles.origin,handles.spacing,pts_in,pts_target_post,1,'linear',-1024);
wet_profiles_target_post = hu_to_we(ct_profiles_target_post,model);
wepl_target_post_roi = sum(wet_profiles_target_post,2);

% re-order and display result
wepl_target_ante = NaN(size(x(:)));
wepl_target_post = NaN(size(x(:)));
wepl_target_ante(crossing_target) = wepl_target_ante_roi;
wepl_target_post(crossing_target) = wepl_target_post_roi;
wepl_target_ante = reshape(wepl_target_ante,size(x));
wepl_target_post = reshape(wepl_target_post,size(x));

% figure
% subplot(1,2,1)
% imshow(wepl_target_ante,[min(wepl_target_ante(:)) max(wepl_target_ante(:))])
% subplot(1,2,2)
% imshow(wepl_target_post,[min(wepl_target_post(:)) max(wepl_target_post(:))])

% set output
res = wepl_target_post;

cd(current_dir)
