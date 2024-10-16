%% WEPL_computation
% Compute the Water Equivalent Path Length (WEPL) between the plane of the proton source and the voxels of a 3D CT scan. The WEPL is computed along the path of rays *paralell* to the beam axis (beam divergence is ignored).
%
% When the beam axis is paralell to the pixel rows of the CT scan (0, 90, 180, 270° and SAD = Inf), the function returns a 3D image where the value of each voxel represents the WEPL (mm) from the plane of the source up to that voxel. The computation is done for all the pixels in the CT scan.
%
% When the beam axis is NOT paralell to the pixel rows of the CT scan,  the function returns a 3D image where the value of each voxel represents the WEPL (mm) from the source up to that voxel. However, in this case, for computational efficiency, the WEPL is no longer computed for the whole CT scan but only for the voxels contained inside a specified region of interest (ROI) .
%
% If the coordinate of a single voxel is provided as a ROI, then the function will return the results as text displayed in the console.
%
%% Syntax
% |handles = WEPL_computation(image,params{4},im_dest,handles)|
%
% |handles = WEPL_computation(image,params{5},im_dest,handles)|
%
% |handles = WEPL_computation(image,params,im_dest,handles,roi=STRING)|
%
% |handles = WEPL_computation(image,params,im_dest,handles,roi=SCALAR VECTOR)|
%
%% Description
% |handles = WEPL_computation(image,params{4},im_dest,handles)| Computes the WEPL using a beam in |handles.plans| to define beam geometry
%
% |handles = WEPL_computation(image,params{5},im_dest,handles)| Computes the WEPL using the beam geometry defined by the provided parameters
%
% |handles = WEPL_computation(image,params,im_dest,handles,roi=STRING)| Computes WEPL for non orthogonal beam geometries. The WEPL is computed only for the voxels defined in the ROI
%
% |handles = WEPL_computation(image,params,im_dest,handles,roi=SCALAR VECTOR)| Computes the WEPL from the plane of the source to one specified voxel. Displays the result in the console and stops the execution of the program by throwing an error.
%
%% Input arguments
% |image| - _STRING_ -  Name of the CT scan contained in "handles.images" on which the WEPL is to be computed
%
% |params| - _CELL VECTOR_ - Definition of beam geometry. Different syntaxes are possible:
%
% * params = {model , SAD , plan_name , beam_index}
% * params = {model , SAD , isocenter , gantry_angle , table_angle}
%
% with:
%
% * |model| - _STRING_ -  Name of the file containing the HU to SPR calibration curve. The hounsfield unit (HU) of the CT scan are converted to water equivalent length using the function |hu_to_we.m|. The file is searched in the directory defined in 'handles.path'.
% * |SAD| - _FLOAT_ -  Source to axis distance (mm). Can be 'Inf' for "paralell" beamlets (For non orthogonal geometries, SAD=Inf is converted in to SAD = 3000mm)
% * |plan_name| - _STRING_ -  Name of the plan in "handles.plans" to use to select the beam parameters
% * |beam_index| - _INTEGER_ -  Index of the beam in the plan to use to compute the WEPL. The gantry angle, PPS table yaw angle and isocentre coordinate of the beam are used.
% * |isocenter| - _VECTOR of INTEGERS_ - [x,y,z] coordinate of the isocentre |mm|
% * |gantry_angle| - _SCALAR_ -  Gantry angle |degree|
% * |table_angle| - _SCALAR_ -  Yaw angle of the PPS table |degree|
%
% |im_dest| - _STRING_ -  Name of the image in |handles.images| where the WEPL map will be stored
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the i-th image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z)  in DICOM CS in the i-th image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the i-th image
% * |handles.plans| - _STRUCTURE_ Description of the treamtent plan. Contains the descrition of the beams geometry. Required if using param with usage (1)
% * ---- |handles.plans.name{i}| - _CELL VECTOR of STRING_ Name of the ith treatment plan
% * ---- |handles.plans.data{i}{j}| - _CELL VECTOR of STRUCTURE_ - Data related to the j-th beam of the ith plan
% * |handles.path| - _STRING_ - Define the path to the CSDA_range_in_XXX.txt files
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm| in DICOM CS) of the displayed images in GUI
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels in DICOM CS) of the displayed images in GUI
% * |handles.origin| : Coordinate (in |mm| in DICOM CS) of the first pixel of the image in the coordinate system of the image
%
% |roi| - _STRING_ - Region of interest where the WEPL is computed. In CASE ORTHOGONAL GEOMETRY and PARALELL beams, this parameter is ignored. In CASE NON ORTHOGONAL GEOMETRY, there are 2 possible uses:
%
% * CASE 1: _SCALAR VECTOR_ - Coordinates (x,y,z) (in mm) of one point where the ray tracing ends. The WEPL will be displayed in the console and an error will be thrown
% * CASE 2: - _STRING_ - Name of the image in (handles.images) defining the ROI. The ray tracing is done towards all the voxels contained inside the ROI
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.images.name{i}| - _STRING_ - Name of WEPL map
% * |handles.images.data{i}| - _SCALAR MATRIX_ - The WEPL map is stored in the 'handles' structure under the name defined in variable |im_dest|. This is the WEPL computed (in |mm|) along the beam path reaching this voxel. The distance is integrated from 400mm upstream from the voxel down to the voxel
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.Created from Create_default_info.m
%
%% NOTE
%
% * The function uses function hu_to_we.m to convert the HU into Water equivalent length by using: % (a) energy = 100MeV The CSDA approximation assume that we can use this constant energy to get the density and range value throughout the Bragg peak curve (b) density = F(HU) defined in hu_to_density for the model defined by params{1} (c) Range = F(energy) defined in hu_to_density for the model defined by params{1} with the function tabulated in the files "CSDA_range_in_XXX.txt"
% * In case of ORTHOGONAL geometry and PARALELL beams, the function makes the ray tracing with the function Matlab function 'cumsum'. The WEPL is computed on the whole image and the ROI is ignored.
% * In case of NON ORTHOGONAL geometry or NON paralell beam, the function makes ray tracing with the function 'ray_tracing'. The assumption is that the distance between the point where the WEPL is computed and the skin surface is less than 40cm. The paralell beam geometry is approximated by a SAD of 3000mm.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)
%



%TODO
%------
% 1) Adapt the function for other initial energies than 100MeV
% 2) pt_in(:,current) = pt_target(:,current) - current_axis*400;% 40 cm only (to be changed !)
%	The assumption is that the distance between the point where the WEPL is computed and the skin surface is less than 40cm
% 3) Manage paralell beamlet for non orthogonal geometries instead of assuming 30cm SAD. This could be done by adapting the line
%	current_axis = pt_target(:,current) - pt_source; in to current_axis = beam_axis;
% 4) Take into account differnet SAD in X and Y
% 5) Update HU_to_range and hu_to_density to include TPS calibration curves
% 6) out of memory error with ray tracing for large ROI volumes
%
%

%=============
function [handles,myImage] = WEPL_computation(image,params,im_dest,handles,roi)

myImage = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
if(isempty(myImage))
    error('Error : input image not found in the current list !')
end

model = params{1};

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

% Compute WEPL
myImage = hu_to_we(myImage,model);
orthogonal_computation = isinf(sad) && (table_angle==0  || table_angle==180 ) && (gantry_angle==0 || gantry_angle==90 || gantry_angle==180 || gantry_angle==270);

if(orthogonal_computation)
    % conversion from DICOM to FRS
    myImage = permute(myImage,[1,3,2]);
    myImage = myImage(:,:,end:-1:1);
    switch table_angle
        case 0
            switch gantry_angle
                case 0
                    myImage = myImage(:,:,end:-1:1);
                    myImage = cumsum(myImage,3)*handles.spacing(2);% spacing(2) because dicom (-y) to frs (z)
                    myImage = myImage(:,:,end:-1:1);
                case 90
                    myImage = myImage(end:-1:1,:,:);
                    myImage = cumsum(myImage,1)*handles.spacing(1);
                    myImage = myImage(end:-1:1,:,:);
                case 180
                    myImage = cumsum(myImage,3)*handles.spacing(2);
                case 270
                    myImage = cumsum(myImage,1)*handles.spacing(1);
                otherwise
                    non_orthogonal_computation = 1;
            end
        case 180
            switch gantry_angle
                case 0
                    myImage = myImage(:,:,end:-1:1);
                    myImage = cumsum(myImage,3)*handles.spacing(2);
                    myImage = myImage(:,:,end:-1:1);
                case 90
                    myImage = cumsum(myImage,1)*handles.spacing(1);
                case 180
                    myImage = cumsum(myImage,3)*handles.spacing(2);
                case 270
                    myImage = myImage(end:-1:1,:,:);
                    myImage = cumsum(myImage,1)*handles.spacing(1);
                    myImage = myImage(end:-1:1,:,:);
                otherwise
                    non_orthogonal_computation = 1;
            end
        otherwise
            non_orthogonal_computation = 1;
    end
    % conversion from FRS to DICOM
    myImage = myImage(:,:,end:-1:1);
    myImage = permute(myImage,[1,3,2]);
    
elseif(nargin>4) % ray-tracings for ROI voxels (in DICOM CS)
    
    myROI = [];

    if(ischar(roi))
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},roi))
                myROI = handles.images.data{i};
            end
        end
        if(isempty(myROI))
            error('Error : roi image not found in the current list !')
        elseif(sum(myROI>max(myROI(:))/2)>2e5)
            error('ROI is too large')
        end
        
        % restrict the loops on the roi bounding-box
        myROI = single(myROI>(max(myROI(:))/2));
        [i,j,s] = find(myROI);
        [j,k] = ind2sub([handles.size(2) handles.size(3)],j);
        indices = find(myROI);
        bb_low = [min(i);min(j);min(k)];
        bb_top = [max(i);max(j);max(k)];
        beam_axis = compute_beam_axis(gantry_angle,table_angle);
        if(not(isinf(sad)))
            pt_source = isocenter - sad*beam_axis;
        else
            pt_source = isocenter - 3e3*beam_axis;
        end
        
        current = 1;
        pt_target = zeros(3,length(indices));
        pt_in = zeros(3,length(indices));
        for k=bb_low(3):bb_top(3)
            for j=bb_low(2):bb_top(2)
                for i=bb_low(1):bb_top(1)
                    if(myROI(i,j,k))
                        pt_target(:,current) = [i*handles.spacing(1)+handles.origin(1);j*handles.spacing(2)+handles.origin(2);k*handles.spacing(3)+handles.origin(3)];
                        if(isinf(sad))
                            current_axis = beam_axis;
                        else
                            current_axis = pt_target(:,current) - pt_source;
                            current_axis = current_axis /norm(current_axis);
                        end
                        pt_in(:,current) = pt_target(:,current) - current_axis*400;% 40 cm only (to be changed !)
                        current = current+1;
                    end
                end
            end
        end
        
        disp('start ray-tracing')
        myROI(indices) = sum(ray_tracing(myImage,handles.origin,handles.spacing,pt_in,pt_target,min(handles.spacing),'linear',0),2)*min(handles.spacing);
        myImage = myROI;
        
    elseif(length(roi)==3)         
        beam_axis = compute_beam_axis(gantry_angle,table_angle);
        if(not(isinf(sad)))
            pt_source = isocenter - sad*beam_axis;
        else
            pt_source = isocenter - 3e3*beam_axis;
        end
        pt_target = [roi(1);roi(2);roi(3)];
        wepl = sum(ray_tracing(myImage,handles.origin,handles.spacing,pt_source,pt_target,min(handles.spacing),'linear',0))*min(handles.spacing);
        error(['WEPL to (',num2str(pt_target(1)),' ',num2str(pt_target(2)),' ',num2str(pt_target(3)),') [mm] is ',num2str(wepl/10),' [cm]'])
        
    end  
 
else    
    error('Please provide ROI for non-orthogonal WEPL calculation')    
end

% convert output into single precision
myImage = single(myImage);

% add output to the list
im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = myImage;
info = Create_default_info('image',handles);
if(isfield(myInfo,'OriginalHeader'))
    info.OriginalHeader = myInfo.OriginalHeader;
end
handles.images.info{length(handles.images.info)+1} = info;
