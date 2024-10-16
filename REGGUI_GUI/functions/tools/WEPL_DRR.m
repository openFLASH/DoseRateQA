%% WEPL_DRR
% Compute the Water Equivalent Path Length (WEPL) (in mm) from the skin surface (defined as 50cm upstream from isocentre) down to surface of the 2D detector.  The WEPL is computed along the path of the selected proton beam, assuming that all rays are paralell (no divergence).
%
%% Syntax
% |handles = WEPL_DRR(handles,ct_name,drr_name,model,sad,gantry_angle,table_angle,isocenter,sdd,detect_size,detect_spacing)|
%
%
%% Description
% |handles = WEPL_DRR(handles,ct_name,drr_name,model,sad,gantry_angle,table_angle,isocenter,sdd,detect_size,detect_spacing)| Compute the Water Equivalent Path Length (WEPL)
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.origin| : Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |ct_name| - _STRING_ -  Name of the CT scan in |handles.images| from which the WEPL are computed
%
% |drr_name| - _STRING_ - Name of the image in |handles.mydata| that will contain the new image
%
% |model| - _STRUCTURE or STRING_ - Description of the conversion curve from HU to stopping power. See parameter |model| of the function |hu_to_we| for more information
%
% |sad| - _SCALAR_ - Proton source to axis (isocentre) distance (in mm)
%
% |gantry_angle| - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
%
% |table_angle| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
%
% |isocenter| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
%
% |sdd| - _SCALAR_ - Proton source to detector distance (in mm) 
%
% |detect_size| - _SCALAR VECTOR_ - Size (x,y,) (in mm) of the detector
%
% |detect_spacing| - _SCALAR_ - Pixel size (mm) of the detector. The pixels are square.

%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the new image = |data_dest|
% * |handles.mydata.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) = the resampled sub-volume of the image
% * |handles.mydata.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

% TODO Use better definition of skin surface. Do not hardcode the 500mm distance

function handles = WEPL_DRR(handles,ct_name,drr_name,model,sad,gantry_angle,table_angle,isocenter,sdd,detect_size,detect_spacing)

% usage: handles = WEPL_DRR(handles,'ct','drr',[-1000 0;-200 0.793;-120 0.957;-20 1.013;35 1.025;100 1.09;140 1.106;4500 3.387],2300,0,0,[0;70;-62.5],2800,[400,400],1);

% Get input image
ct = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},ct_name))
        ct = handles.images.data{i};
    end
end
if(isempty(ct))
    error('Error : input image not found in the current list !')
end

% create beam with input parameters
beam.gantry_angle = gantry_angle;
beam.table_angle = table_angle;
beam.isocenter = isocenter;
[~,pt_source] = compute_beam_isoplane([0;0],beam,sad);

% replace beam isocenter by detector isocenter
beam.isocenter = pt_source + sdd/sad*(isocenter-pt_source);

% define lines for ray-tracings
[x,y] = meshgrid([-detect_size(1)/2:detect_spacing:detect_size(1)/2],[-detect_size(2)/2:detect_spacing:detect_size(2)/2]); % detector pixel grid in 2D
pts_2D = [x(:)';y(:)'];
pts_detect = compute_beam_isoplane(pts_2D,beam,sdd);
pts_source = repmat(pt_source,[1,size(pts_detect,2)]);
vcts_rays = normalize_vcts(pts_detect-pts_source);
pts_in = pts_source + (sad-500)*vcts_rays;

% perform ray-tracing within target binary mask and compute WEPL
disp('start ray-tracings for 2D wepl computation...')
ct_profiles_detect = ray_tracing(ct,handles.origin,handles.spacing,pts_in,pts_detect,1,'linear',-1024);
wet_profiles_detect = hu_to_we(ct_profiles_detect,model);
wepl_detect = sum(wet_profiles_detect,2);

% re-order and display result
wepl_detect = reshape(wepl_detect,size(x));

figure
imshow(wepl_detect,[min(wepl_detect(:)) max(wepl_detect(:))])
axis xy

% store in reggui datastore
drr_name = check_existing_names(drr_name,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = drr_name;
handles.mydata.data{length(handles.mydata.data)+1} = wepl_detect;
handles.mydata.info{length(handles.mydata.info)+1} = Create_default_info('image',handles);
