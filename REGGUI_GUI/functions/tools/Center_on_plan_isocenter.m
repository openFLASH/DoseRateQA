%% Center_on_plan_isocenter
% Set the new view point at the coordinate of the plan isocentre. The displayed image will be recentered on the isocentre.
%
%% Syntax
% |handles = Center_on_plan_isocenter(handles,plan_name)|
%
%
%% Description
% |handles = Center_on_plan_isocenter(handles,plan_name)| Define the new view point
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.origin| : Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.plans| - _STRUCTURE_ Description of the treamtent plan. Contains the descrition of the beams geometry
% * ---- |handles.plans.name{i}| - _CELL VECTOR of STRING_ Name of the ith treatment plan
% * ---- |handles.plans.data{i}{j}.isocenter| - _CELL VECTOR of SCALAR VECTOR_ - IOsocentre (in CT scan coordinate) of the jth beam of the ith plan
%
% |plan_name| - _STRING_ Name of the treatment plan in |handles.plans|
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated :
%
% * |handles.view_point| - _INTEGER VECTOR_ Coordinate (in pixel, origin at 1st voxel) of the isocentre in the image
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Center_on_plan_isocenter(handles,plan_name,modify_origin)
if(nargin<3)
    modify_origin = 0;
end
% get isocenter from treatment plan
for i=1:length(handles.plans.name)
    if(strcmp(handles.plans.name{i},plan_name))
        myBeamData = handles.plans.data{i};
    end
end
iso_dcm = myBeamData{1}.isocenter;
% set the workspace origin so that isocenter is at 0,0,0 and modify the iso of all plans
if(modify_origin)
    handles.origin = handles.origin - iso_dcm;
    for i=2:length(handles.images.name)
        handles.images.info{i}.ImagePositionPatient = handles.origin;
    end
    for i=2:length(handles.fields.name)
        handles.fields.info{i}.ImagePositionPatient = handles.origin;
    end
    for i=2:length(handles.plans.name)
        for j=1:length(handles.plans.data{i})
            handles.plans.data{i}{j}.isocenter = handles.plans.data{i}{j}.isocenter - iso_dcm;
        end
    end
end
% set viewpoint to isocenter
iso_voxel = round((iso_dcm-handles.origin)./handles.spacing);
if((iso_voxel(1)>0 && iso_voxel(1)<handles.size(1)) && (iso_voxel(2)>0 && iso_voxel(2)<handles.size(2)) && (iso_voxel(3)>0 && iso_voxel(3)<handles.size(3)))
    handles.view_point = iso_voxel;    
end
