%% WE_contour_distance
% Compute the moments statistical distribution of the *water equivalent length distances* between two structures defined in |mask1_name| and |mask2_name|.
%
%% Syntax
% |[res,WE_dist_2D_map] = WE_contour_distance(ct_name,mask1_name,mask2_name,params{4},handles)|
%
% |[res,WE_dist_2D_map] = WE_contour_distance(ct_name,mask1_name,mask2_name,params{5},handles)|
%
% |[res,WE_dist_2D_map] = WE_contour_distance(ct_name,mask1_name,mask2_name,params{5},handles,body_name)|
%
%
%% Description
% |[res,WE_dist_2D_map] = WE_contour_distance(ct_name,mask1_name,mask2_name,params,handles)| Compute the WE-distance between the 2 structures by computing WEPL from the edges of the CT scan.
%
% |[res,WE_dist_2D_map] = WE_contour_distance(ct_name,mask1_name,mask2_name,params,handles,body_name)| Compute the WE-distance between the 2 structures by computing WEPL from the body contour.
%

%
%% Input arguments
% |ct_name| - _STRING_ -  Name of the CT scan in |handles.images| from which the WEPL are computed
%
% |mask1_name| - _STRING_ -  Name of the binary mask in |handles.images| of the first structure
%
% |mask2_name| - _STRING_ -  Name of the binary mask in |handles.images| of the second structure
%
% |params| - _CELL VECTOR_ - Definition of the beam parameters depends on the number of elements in the vector:
%
% * |params{1}| - _STRUCTURE or STRING_ Define the Hounsfield unit to stopping power conversion model. See hu_to_we.m for description of the parameter
% * |params{2}| - _SCALAR_ - Proton source to axis (isocentre) distance (in mm)
% * If |params= {4}| has 4 elements:
% * -----|params{3}| - _STRING_ Name of the treatment plan in |handles.plans|
% * -----|params{4}| - _INTEGER_ - Index j of the beam in |handles.plans.data{i}{j}|
% * If |params= {5}| has 5 elements:
% * -----|params{3}| - _VECTOR of INTEGERS_ - [x,y,z] coordinate of the isocentre |mm|
% * -----|params{4}| - _SCALAR_ -  Gantry angle |mm|
% * -----|params= {5}| - _SCALAR_ -  Yaw angle of the PPS table |degree|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.plans| - _STRUCTURE_ Description of the treamtent plan. Contains the descrition of the beams geometry
% * ---- |handles.plans.name{i}| - _CELL VECTOR of STRING_ Name of the ith treatment plan
% * ---- |handles.plans.data{i}{j}| - _CELL VECTOR of STRUCTURE_ - Data related to the jth beam of the ith plan
% * |handles.origin| : Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |body_name| - _STRING_ -  [OPTIONAL] Name of the RT struct in |handles.images| defining the skin surface. The WEPL will be computed along the beam path, starting from the surface of this structure. If this parmeter is omitted, the WEPL are computed from theedges of the CT scan instead.
%
%
%% Output arguments
%
% |res| - _SCALAR VECTOR_ - Statistical moments of the water equivalent distance (mm) between structure |res = [minimal distance ,  mean distance,  maximum distance, standard deviation of the distance distribution, median distance]|
% 								!!!!!mask2_distal_or_proximal
%
% |WE_dist_2D_map| - _SCALAR MATRIX_ -  2D map (in a plane perpenticular otthe proton beam) of water equivalent distance between the 2 structures. |WE_dist_2D_map(x,y)| is the WE distance (in mm) along the beamlet going through pixel (x,y). The map is centered on the isocentre.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [res,WE_dist_2D_map] = WE_contour_distance(ct_name,mask1_name,mask2_name,params,handles,body_name)

% Get input images (CT and masks)
ct = [];
mask1 = [];
mask2 = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},ct_name))
        ct = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},mask1_name))
        mask1 = handles.images.data{i};
        mask1 = single(mask1>(max(mask1(:))/2));
    end
    if(strcmp(handles.images.name{i},mask2_name))
        mask2 = handles.images.data{i};
        mask2 = single(mask2>(max(mask2(:))/2));
    end
end
if(isempty(ct) || isempty(mask1) || isempty(mask2))
    error('Error : input image not found in the current list !')
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

try
    
    model = params{1};
    
    % Retrieve beam information
    beam = [];
    if(length(params)<5)
        sad = params{2};
        plan_name = params{3};
        beam_index = params{4};
        for i=1:length(handles.plans.name)
            if(strcmp(handles.plans.name{i},plan_name))
                plan = handles.plans.data{i};
                beam = plan{beam_index};
                break
            end
        end
        if(isempty(beam))
            error('Error : beam not found !')
        end
    else
        sad = params{2};
        beam.isocenter = params{3};
        beam.gantry_angle = params{4};
        beam.table_angle = params{5};        
    end
            
    % define lines for ray-tracings
    [x,y] = meshgrid([-100:100],[-100:100]);
    pts_2D = [x(:)';y(:)'];
    [pts_iso,pt_source] = compute_beam_isoplane(pts_2D,beam,sad);
    pts_source = repmat(pt_source,[1,size(pts_iso,2)]);
    vcts_rays = normalize_vcts(pts_iso-pts_source);
    pts_in = pts_iso - 400*vcts_rays;
    pts_out = pts_iso + 100*vcts_rays;
    
    % perform ray-tracing within target binary mask
    disp('start ray-tracings for 2D wepl computation...')
    mask1_profiles = ray_tracing(mask1,handles.origin,handles.spacing,pts_in,pts_out,1,'nearest',0);
    mask2_profiles = ray_tracing(mask2,handles.origin,handles.spacing,pts_in,pts_out,1,'nearest',0);
    
    % select rays intersecting both masks
    crossing_target = find(sum(mask1_profiles,2) & sum(mask2_profiles,2));
    
    % inititalize 2D map
    WE_dist_2D_map = NaN(size(x(:)));
    
    if(not(isempty(crossing_target)))
        pts_in = pts_in(:,crossing_target);
        vcts_rays = vcts_rays(:,crossing_target);
        mask1_profiles = mask1_profiles(crossing_target,:);
        mask2_profiles = mask2_profiles(crossing_target,:);
        pts_out = pts_out(:,crossing_target);
        
        % computing WET along the rays
        ct_profiles = ray_tracing(((ct+1024).*body)-1024,handles.origin,handles.spacing,pts_in,pts_out,1,'linear',-1024);
        wet_profiles = cumsum(hu_to_we(ct_profiles,model),2);
        if(size(wet_profiles,2)==1)
            wet_profiles = wet_profiles';
        end
        
        % find first and last points inside masks
        distances_2_from_1 = NaN(length(crossing_target),1);
        distances_1_from_2 = NaN(length(crossing_target),1);
        for i=1:length(crossing_target)
            mask1_entrance_index = length(mask1_profiles(i,:)) - find(mask1_profiles(i,end:-1:1),1,'last');
            mask2_entrance_index = length(mask2_profiles(i,:)) - find(mask2_profiles(i,end:-1:1),1,'last');
            mask1_exit_index = find(mask1_profiles(i,:),1,'last');
            mask2_exit_index = find(mask2_profiles(i,:),1,'last');
            distances_2_from_1(i,1) = wet_profiles(i,mask2_entrance_index) - wet_profiles(i,mask1_exit_index);
            distances_1_from_2(i,1) = wet_profiles(i,mask1_entrance_index) - wet_profiles(i,mask2_exit_index);
        end
        if(sum(abs(distances_1_from_2))<=sum(abs(distances_2_from_1)))
            disp(['Distances [mm] between ',mask1_name,' (distal) and ',mask2_name,' (proximal):'])
            is_mask2_distal = 0;
            distances = distances_1_from_2;
        else
            disp(['Distances [mm] between ',mask2_name,' (distal) and ',mask1_name,' (proximal):'])
            is_mask2_distal = 1;
            distances = distances_2_from_1;
        end     
        
        WE_dist_2D_map(crossing_target) = distances_2_from_1;
        WE_dist_2D_map = reshape(WE_dist_2D_map,size(x));
        
        res = [min(distances) mean(distances) max(distances) std(distances) median(distances) is_mask2_distal];
        disp(['minimum = ',num2str(res(1))])
        disp(['mean = ',num2str(res(2))])
        disp(['maximum = ',num2str(res(3))])
        disp(['std = ',num2str(res(4))])
        disp(['median = ',num2str(res(5))])
        
    else
        
        disp('No overlap between structures in the beam-eye-view.')
        res = [NaN NaN NaN NaN NaN 0];
        
    end
    
catch
    disp('Error : images not found or uncorrect size!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end

