%% Resample_beam
% Rotate all the images contained in |handles.images| so that their pixel axes are aligned with the beam's eye view of the beam number |beam_index| defined in the plan |plan_name|. Z corresponds to be beam axis after transformation.
% Delete all the data in |handles.mydata| and |handles.fields|.
% The deformation field between the original DICOM CS and the beam coordinate is stored in |handles.mydata| in data element 'beam_align_transform_data'.
%
%% Syntax
% |handles = Resample_beam(plan_name,beam_index,handles)|
%
%
%% Description
% |handles = Resample_beam(plan_name,beam_index,handles)| Description
%
%
%% Input arguments
% |plan_name| - _STRING_ -  Name of the plan contained in |handles.plans| to use to realign the images axes
%
% |beam_index| - _INTEGER_ - Index of the beam contained in |handles.plans.data{beam_index}| to use to realign the images axes
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.plans| - _STRUCTURE_ Information about the i-th treatment plan
% * |handles.plans.data{i}{f}| - _STRUCTURE_ Information about the beam/field f of the i-th treatment plan. See parameter |beam| of function |get_beam_params| for more information.
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated 
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.mydata| will be deleted
% * |handles.fields| will be deleted
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Resample_beam(plan_name,beam_index,handles)
handles = Automatic(handles);
% clear all fields and data
handles = Remove_all_fields(handles);
handles = Remove_all_data(handles);
% resample to isotropic voxel size
handles = Resample_all(handles,[],[],min(handles.spacing)*ones(3,1));
% get plan
for i=1:length(handles.plans.name)
    if(strcmp(handles.plans.name{i},plan_name))
        myBeamData = handles.plans.data{i};
    end
end
% compute transformation
handles = Compute_beam_align_transform(myBeamData{beam_index},'beam_align_transform',handles);
% copy transformation in data
handles = Field2data('beam_align_transform',[],[],[],'beam_align_transform_data',handles);
handles = Remove_all_fields(handles);
% convert all images to data
nb_images = length(handles.images.name)-1;
for i=2:nb_images+1
    handles = Image2data(handles.images.name{i},[],[],[],[handles.images.name{i},'_data'],handles);
end
% clear workspace
handles = Remove_all_images(handles);
% apply transformation to all data
for i=3:nb_images+2
    handles = Data_deformation(handles.mydata.name{i},'beam_align_transform_data',handles.mydata.name{i}(1:end-5),handles,0);
end
% remove old images
for i=3:nb_images+2
    handles = Remove_data(handles.mydata.name{2},handles);
end
% transfer all transformed images into workspace
for i=3:nb_images+2
    handles = Data2image(handles.mydata.name{i},handles.mydata.name{i},handles);
end
% clear all data
handles = Remove_all_data(handles);

