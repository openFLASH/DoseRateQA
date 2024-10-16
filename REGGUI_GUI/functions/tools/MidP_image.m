%% MidP_image
% Compute the mid position of chosen images
%
%% Syntax
% |handles = MidP_image(input_image_names,output_image_name,handles,body_name,thorax_name,ref_image_name,output_df_names,output_vf_names)|
%
%% Description
% |handles = MidP_image(input_image_names,output_image_name,handles,body_name,thorax_name,ref_image_name,output_df_names,output_vf_names)| computes the mid position of the selected images
%
%% Input arguments
% |input_image_names| - _CELL VECTOR of STRING_ -  |input_image_names{i}| Name of the ith image in |handles.images| that is included in the mid position
%
% |output_image_name| - _STRING_ -  Name of the mid position image in |handles.images|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _STRING_ - Name of the ith image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data will be updated (where XXX is either 'images', 'fields' or "mydata"; depending on where the input data is located):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the resulting image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| resulting intensity at voxel (x,y,z)
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Created with Create_default_info.m
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = MidP_image(input_image_names,output_image_name,handles,body_name,thorax_name,ref_image_name,output_df_names,output_vf_names,options)

if(nargin<4)
    body_name = '';
end
if(nargin<5)
    thorax_name = 'none';
elseif(isempty(thorax_name))
    thorax_name = 'none';
end
if(nargin<6)
    ref_image_name = input_image_names{1};
end
if(nargin<7)
    for phase=1:length(input_image_names)
        output_df_names{phase} = ['df_phase',num2str(phase),'_to_midp'];
    end
end
if(nargin<8)
    for phase=1:length(input_image_names)
        output_vf_names{phase} = ['df_phase',num2str(phase),'_to_midp_log'];
    end
end

initial_handles = handles;
handles = Automatic(handles,1);

% Registration parameters
reg_resolution = 2.5;
reg_nb_levels = 8;
reg_nb_iterations = [2,5,10,10,10,10,10,10];
regul = 1.25;

% Optional parameters
if(nargin<9)
    options = {};
end
try
    for i=1:size(options,1)
        if(ischar(options{i,2}))
            eval([options{i,1},' = ',options{i,2},';']);
        else
            eval([options{i,1},' = ',num2str(options{i,2}),';']);
        end
    end
catch
end

% Resample
disp('Resampling images...')
if(not(isempty(body_name)))
    handles = Resample_all(handles,body_name,[10],[],'from_mask');% 1cm margin around body
end
handles = Resample_all(handles,[],[],[reg_resolution;reg_resolution;reg_resolution]);

% Register
disp('Registering images...')
for phase=1:length(input_image_names)
    df_names{phase} = ['df_ref_to_phase',num2str(phase)];
    vf_names{phase} = ['df_ref_to_phase',num2str(phase),'_log'];
    if(not(strcmp(input_image_names{phase},ref_image_name)))
        disp(['Registering ',ref_image_name,' to ',input_image_names{phase}])
        handles = Registration_modules(1,input_image_names(phase),{ref_image_name},thorax_name,reg_nb_levels,reg_nb_iterations,{4},{1},{[]},{1},1,[],6,3,ones(1,reg_nb_levels)*regul,'def_ct',df_names{phase},'',0,handles,1);
    else
        handles = Empty_field(vf_names{phase},handles);
    end
end

% Compute average velocity field
disp('Computing average deformation...')
handles = Average_image(vf_names,'df_average_log',handles,2);

% Compute velocity fields to MidP
for phase=1:length(input_image_names)
    deformed_image_names{phase} = [input_image_names{phase},'_def'];
    [~,vf_info] = Get_reggui_data(handles,'df_average_log','fields');
    initial_handles = Set_reggui_data(initial_handles,output_df_names{phase}, field_exponentiation(Get_reggui_data(handles,'df_average_log','fields')-Get_reggui_data(handles,vf_names{phase},'fields')) ,vf_info,'mydata');
    if(nargin>7)
        initial_handles = Set_reggui_data(initial_handles,output_vf_names{phase}, Get_reggui_data(handles,'df_average_log','fields')-Get_reggui_data(handles,vf_names{phase},'fields') ,vf_info,'mydata');
    end
end

% Reset handles to previous workspace
handles = initial_handles;
clear initial_handles

% Deform images to mid position
disp('Deforming images...')
for phase=1:length(input_image_names)
    handles = Data2field(output_df_names{phase},output_df_names{phase},handles);
    handles = Remove_data(output_df_names{phase},handles);
    handles = Deformation(input_image_names{phase},output_df_names{phase},deformed_image_names{phase},handles);
    if(nargin<7)
        handles = Remove_field(output_df_names{phase},handles);
    end
    if(nargin>7)
        handles = Data2field(output_vf_names{phase},output_vf_names{phase},handles);
        handles = Remove_data(output_vf_names{phase},handles);
    end
end

% Compute median image
disp('Computing median image...')
handles = Median_image(deformed_image_names,output_image_name,handles,1);                                                                                                                                                                                                                                                                                                               

