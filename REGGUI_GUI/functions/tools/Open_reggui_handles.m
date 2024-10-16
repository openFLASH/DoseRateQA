%% Open_reggui_handles
% Load previously saved REGGUI data workspace. The workspace is loaded into the |handles| variable.
%
%% Syntax
% |handles = Open_reggui_handles(handles,myProject_Name)|
%
%
%% Description
% |handles = Open_reggui_handles(handles,myProject_Name)| Load the workspace
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be updated.
%
% |myProject_Name| - _STRING_ -  Name (with path) of the file containing the saved workspace data
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Open_reggui_handles(handles,myProject_Name)

disp(['Opening project : ',myProject_Name]);

myProject = load(myProject_Name);
if(isfield(myProject,'myProject'))
    myProject = myProject.myProject;
end
if(isdir(myProject.handles.dataPath))
    handles.dataPath = myProject.handles.dataPath;
end
handles.images = myProject.handles.images;
for i=2:length(handles.images.name)
    if(~isa(handles.images.data{i},'single'))
        disp(['Image <<' handles.images.name{i} '>> casted to single']);
        handles.images.data{i} = single(handles.images.data{i});
    end
end
if(~isfield(handles.images,'info'))
    handles.images.info{1} = struct;
    for i=2:length(handles.images.name)
        disp('Warning: no header information. Create default.')
        handles.images.info{i} = Create_default_info('image',handles);
    end
end
handles.fields = myProject.handles.fields;
for i=2:length(handles.fields.name)
    if(~isa(handles.fields.data{i},'single'))
        disp(['Field <<' handles.fields.name{i} '>> casted to single']);
        handles.fields.data{i} = single(handles.fields.data{i});
    end
end
if(~isfield(handles.fields,'info'))
    handles.fields.info{1} = struct;
    for i=2:length(handles.fields.name)
        disp('Warning: no header information. Create default.')
        if(ndims(handles.fields.data{i})>2)
            handles.fields.info{i} = Create_default_info('deformation_field',handles);
        else
            handles.fields.info{i} = Create_default_info('rigid_transform',handles);
        end
    end
end
handles.mydata = myProject.handles.mydata;
if(~isfield(handles.mydata,'info'))
    handles.mydata.info{1} = struct;
    for i=1:length(handles.mydata.name)
        disp('Warning: no header information. Create default.')
        handles.mydata.info{i} = Create_default_info('data',handles);
    end
end
if(isfield(myProject.handles,'plans'))
    handles.plans = myProject.handles.plans;
end
if(isfield(myProject.handles,'meshes'))
    handles.meshes = myProject.handles.meshes;
end
if(isfield(myProject.handles,'registrations'))
    handles.registrations = myProject.handles.registrations;
end
if(isfield(myProject.handles,'indicators'))
    handles.indicators = myProject.handles.indicators;
end
field_list = {'instruction_history';...
    'error_count';...
    'size';...
    'spacing';...
    'origin';...
    'spatialpropsettled';...
    'minscale';...
    'maxscale';...
    'minscaleF';...
    'maxscaleF';...
    'scale_prctile';...
    'colormap';...
    'second_colormap';...
    'field_color';...
    'fielddensity';...
    'view_point';...
    'rendering_frames';...
    'dvhs';...
    'beam_mode'};
for i=1:length(field_list)
    if(isfield(myProject.handles,field_list{i}))
        handles.(field_list{i}) = myProject.handles.(field_list{i});
    else
        disp([field_list{i},' not found.'])
    end
end
% retro-compatibility
if(not(isfield(myProject.handles,'size')) && isfield(myProject.handles,'sizeX')&& isfield(myProject.handles,'sizeY')&& isfield(myProject.handles,'sizeZ'))
    handles.size = [myProject.handles.sizeX;myProject.handles.sizeY;myProject.handles.sizeZ];
end
try
  if(ischar(handles.colormap))
    handles.colormap = eval(handles.colormap);
  end
  if(ischar(handles.second_colormap))
    handles.second_colormap = eval(handles.second_colormap);
  end
end
