%% WEPL_based_warping
% Deforms the planning dose map |dose_name|, in the direction paralell to proton beam axis, in order to account for the water equivalent path length modification between the planning CT scan |pCT_name| and the repeat CT scan |rCT_name| acquired on treatment day. The dose is redistributed to the voxel of the rCT with same WEPL as the pCT. The result is saved in the image |im_dest| in |handles.images|.
%
%% Syntax
% |handles = WEPL_based_warping(dose_name,pCT_name,rCT_name,params{4},im_dest,handles)|
%
% |handles = WEPL_based_warping(dose_name,pCT_name,rCT_name,params{5},im_dest,handles)|
%
% |handles = WEPL_based_warping(dose_name,pCT_name,rCT_name,params,im_dest,handles,transverse_resolution)|
%
%
%% Description
% |handles = WEPL_based_warping(dose_name,pCT_name,rCT_name,params,im_dest,handles)| Deforms the dose map in the direction of propagation of the proton beam according to the modification to the WEPL along the beam path. The resolution in the plane orthogonal to proton beam axis is 1mm.
%
% |handles = WEPL_based_warping(dose_name,pCT_name,rCT_name,params,im_dest,handles,transverse_resolution)|  Deforms the dose map in the direction of propagation of the proton beam according to the modification to the WEPL along the beam path. The resolution in the plane orthogonal to proton beam axis is down scaled to the size |transverse_resolution|.
%
%
%
%% Input arguments
% |dose_name| - _STRING_ - Name of the planning dose map in  |handles.images| that needs to be deformed
%
% |pCT_name| - _STRING_ -  Name of the planning CT scan in |handles.images| used to compute the planning WEPL
%
% |rCT_name| - _STRING_ -  Name of the repeat CT scan in |handles.images| used to compute the WEPL at the treatment day
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
% |im_dest| - _STRING_ -  Name of the image in |handles.images| where the WEPL corrected dose map will be stored
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.origin| : Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |transverse_resolution| - _SCALAR_ -  [OPTIONAL] Size (in mm) of the new downsampled pixel in the plane perpendicular to the proton beam axis 
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) of the new image
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.images.info|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = WEPL_based_warping(dose_name,pCT_name,rCT_name,params,im_dest,handles,transverse_resolution)

% Authors : G.Janssens (open.reggui@gmail.com)
 


% Retrieve images
pD = [];
pCT = [];
rCT = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},dose_name))
        pD = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},pCT_name))
        pCT = handles.images.data{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},rCT_name))
        rCT = handles.images.data{i};
    end
end
if(isempty(pD) || isempty(pCT) || isempty(rCT))
    error('Error : one of the input images not found in the current list !')
end

% Parameters
model = params{1};
if(iscell(model) && length(model)==2) % if different HU conversions for the 2 CTs
   model_pCT = model{1}; 
   model_vCT = model{2};
else
   model_pCT = model; 
   model_vCT = model;
end
coarse_spacing = 20;
coarse_size = coarse_spacing*100;
fine_spacing = 1;
if(nargin<7)
    transverse_resolution = fine_spacing;
end

% Retrieve beam information
if(length(params)<3)
    sad = Inf;
    isocenter = [];
elseif(length(params)<5)
    sad = params{2};
    plan_name = params{3};
    beam_index = params{4};
    for i=1:length(handles.plans.name)
        if(strcmp(handles.plans.name{i},plan_name))
            myBeamData = handles.plans.data{i};
        end
    end
    isocenter = myBeamData{beam_index}.isocenter;
    gantry_angle = myBeamData{beam_index}.gantry_angle;
    table_angle = myBeamData{beam_index}.table_angle;
else
    sad = params{2};
    isocenter = params{3};
    gantry_angle = params{4};
    table_angle = params{5};
end

% Compute beam axis
beam_axis = compute_beam_axis(gantry_angle,table_angle);
if(not(isinf(sad)))
    pt_source = isocenter - sad*beam_axis;
else
    pt_source = isocenter - 3e3*beam_axis;
end

% Compute original (dicom) grid
[Y,X,Z] = meshgrid(([1:size(pD,2)]-1)*handles.spacing(2)+handles.origin(2)-isocenter(2),([1:size(pD,1)]-1)*handles.spacing(1)+handles.origin(1)-isocenter(1),([1:size(pD,3)]-1)*handles.spacing(3)+handles.origin(3)-isocenter(3));

% Compute rotation matrix
z_axis = [0;0;-1];
c = cross(z_axis,beam_axis);
c = c/norm(c);
d = acos(dot(z_axis,beam_axis))/pi*180;
r = spin_calc('EVtoDCM',[c(:)' d],eps,0)*spin_calc('EVtoDCM',[0 0 1 90],0,0); % rotation matrix
r_inv = inv(r); % inverse rotation matrix

% Compute coarse beam grid
[Ytemp,Xtemp,Ztemp] = meshgrid(-coarse_size:coarse_spacing:coarse_size,-coarse_size:coarse_spacing:coarse_size,-coarse_size:coarse_spacing:coarse_size);
Xb = r(1,1)*Xtemp+r(1,2)*Ytemp+r(1,3)*Ztemp;
Yb = r(2,1)*Xtemp+r(2,2)*Ytemp+r(2,3)*Ztemp;
Zb = r(3,1)*Xtemp+r(3,2)*Ytemp+r(3,3)*Ztemp;
clear Ytemp Xtemp Ztemp

% Define ROI based on dose
pD_bs = interp3(Y,X,Z,pD,Yb,Xb,Zb); % plan dose in beam space
pD_bs(isnan(pD_bs))=0;
pD_bs(pD_bs<0)=0;
i_min = min(min(min(pD_bs)));
i_intercept = max(max(max(pD_bs)))-i_min;
if(i_intercept<=0)
   error('Empty dose. Abort')
end
[i,j,~] = find(pD_bs>(i_min+i_intercept/100)); % "zero-dose" voxels are voxels whose intensity is smaller than 1% of the full range of intensities.
[j,k] = ind2sub([size(pD_bs,2),size(pD_bs,3)],j);
minimum = ([max(1,min(j));max(1,min(i));max(1,min(k))]-2)*coarse_spacing - coarse_size;
maximum = ([min(size(pD_bs,1),max(j));min(size(pD_bs,2),max(i));min(size(pD_bs,3),max(k))]+2)*coarse_spacing - coarse_size;

% Resample images orthogonal to beam
[Ytemp,Xtemp,Ztemp] = meshgrid(minimum(1):fine_spacing:maximum(1),minimum(2):fine_spacing:maximum(2),minimum(3):fine_spacing:maximum(3));
Xb = r(1,1)*Xtemp+r(1,2)*Ytemp+r(1,3)*Ztemp;
Yb = r(2,1)*Xtemp+r(2,2)*Ytemp+r(2,3)*Ztemp;
Zb = r(3,1)*Xtemp+r(3,2)*Ytemp+r(3,3)*Ztemp;
clear Ytemp Xtemp Ztemp
pD = interp3(Y,X,Z,pD,Yb,Xb,Zb);pD(isnan(pD))=0;
pCT = interp3(Y,X,Z,pCT,Yb,Xb,Zb);pCT(isnan(pCT))=0;
rCT = interp3(Y,X,Z,rCT,Yb,Xb,Zb);rCT(isnan(rCT))=0;

% Resample images using sad
[Yb,Xb,Zb] = meshgrid(minimum(1):fine_spacing:maximum(1),minimum(2):fine_spacing:maximum(2),minimum(3):fine_spacing:maximum(3));
zoom_matrix = (permute(repmat(minimum(3):fine_spacing:maximum(3),[size(Xb,1) 1 size(Xb,2)]),[1 3 2])+sad)/sad;
pD = interp3(Yb,Xb,Zb,pD,Yb.*zoom_matrix,Xb.*zoom_matrix,Zb);pD(isnan(pD))=0;
pCT = interp3(Yb,Xb,Zb,pCT,Yb.*zoom_matrix,Xb.*zoom_matrix,Zb);pCT(isnan(pCT))=0;
rCT = interp3(Yb,Xb,Zb,rCT,Yb.*zoom_matrix,Xb.*zoom_matrix,Zb);rCT(isnan(rCT))=0;

% Smooth in transverse dimension
if(transverse_resolution > fine_spacing)
    downfactor = transverse_resolution/fine_spacing;
    sigma = downfactor;
    fsz = round(sigma * 5);
    fsz = fsz + (1-mod(fsz,2));
    filterx = gaussian_kernel(fsz, sigma);
    filterx = filterx/sum(filterx);
    pCT = padarray(pCT, [length(filterx) 0 0], 'replicate');
    pCT = conv3f(pCT, single(filterx));
    pCT = pCT(length(filterx)+1:end-length(filterx), :, :);
    rCT = padarray(rCT, [length(filterx) 0 0], 'replicate');
    rCT = conv3f(rCT, single(filterx));
    rCT = rCT(length(filterx)+1:end-length(filterx), :, :);
    filtery = gaussian_kernel(fsz, sigma);
    filtery = filtery'/sum(filtery);
    pCT = padarray(pCT, [0 length(filtery) 0], 'replicate');
    pCT = conv3f(pCT, single(filtery));
    pCT = pCT(:,length(filtery)+1:end-length(filtery), :);
    rCT = padarray(rCT, [0 length(filtery) 0], 'replicate');
    rCT = conv3f(rCT, single(filtery));
    rCT = rCT(:,length(filtery)+1:end-length(filtery), :);
end

% Compute wepl maps
pCT = single(hu_to_we(pCT,model_pCT));pCT(pCT<1e-3) = 1e-3;pCT = cumsum(pCT,3); %pCT is now a WEPL map, no longer a CT. Reuse the variable name to decrease memory usage
rCT = single(hu_to_we(rCT,model_vCT));rCT(rCT<1e-3) = 1e-3;rCT = cumsum(rCT,3); %rCT is now a WEPL map, no longer a CT. Reuse the variable name to decrease memory usage

% Warp dose
%[Yb,Xb,Zb] = meshgrid(minimum(1):fine_spacing:maximum(1),minimum(2):fine_spacing:maximum(2),minimum(3):fine_spacing:maximum(3)); % This line is redundant with l183
Zw = Zb;
for i=1:size(pD,1)
    for j=1:size(pD,2)
        Zw(i,j,:) = interp1(squeeze(pCT(i,j,:)),squeeze(Zb(i,j,:)),squeeze(rCT(i,j,:)));
    end
end 
pD = interp3(Yb,Xb,Zb,pD,Yb,Xb,Zw);

% Correct for r2 beam broadening effect
if(not(isinf(sad)))
    pD = pD.*((Zw+sad)./(Zb+sad)).^2;
end

% Resample warped dose in dicom coordinate system
pD = interp3(Yb,Xb,Zb,pD,Yb./zoom_matrix,Xb./zoom_matrix,Zb); % for sad
Xd = r_inv(1,1)*X+r_inv(1,2)*Y+r_inv(1,3)*Z;
Yd = r_inv(2,1)*X+r_inv(2,2)*Y+r_inv(2,3)*Z;
Zd = r_inv(3,1)*X+r_inv(3,2)*Y+r_inv(3,3)*Z;
clear Y X Z
pD = interp3(Yb,Xb,Zb,pD,Yd,Xd,Zd);
pD(isnan(pD)) = 0;

% Store output
im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = single(pD);
info = Create_default_info('dose_name',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;
