%% Initialize_reggui_handles
% Initialize the REGGUI data handles.
%
%% Syntax
% |handles = Initialize_reggui_handles()|
%
% |handles = Initialize_reggui_handles(handles)|
%
% |handles = Initialize_reggui_handles(handles,param1,val1,...)|
%
%
%% Description
% |handles = Initialize_reggui_handles()| Initialize the data handles using default values
%
% |handles = Initialize_reggui_handles(handles)| Reset existing data handle with the defaults values
%
% |handles = Initialize_reggui_handles(handles,param1,val1,...)| Reset existing data handle with the defaults values and append to handles the specified list of parameters with the given values. There can be a list of parameters and values
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed.
%
% |param1| - _STRING_ -  Name of the field to be added to |handles|
%
% |val1| - _ANY_ -  Value of the field 
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Initialize_reggui_handles(handles,varargin)

if(nargin<1)
    handles = struct;
    temp = mfilename('fullpath');
    handles.path = fileparts(fileparts(fileparts(temp)));
end
if(not(isstruct(handles)))
    handles = struct;
    temp = mfilename('fullpath');
    handles.path = fileparts(fileparts(fileparts(temp)));
end

% set default modes
handles.auto_mode = 1;
handles.error_mode = 0;
handles.backup_mode = 0;
handles.roi_mode = 0;
handles.beam_mode = 0;

% initialize data structure with empty data
handles.current_roi = cell(0);
handles.instructions = cell(0);
handles.instruction_history = cell(0);
handles.images = struct('name',[],'data',[],'info',[]);
handles.images.name{1} = 'none';
handles.images.data{1} = [];
handles.images.info{1} = struct;
handles.fields = struct('name',[],'data',[],'info',[]);
handles.fields.name{1} = 'none';
handles.fields.data{1} = [];
handles.fields.info{1} = struct;
handles.mydata = struct('name',[],'data',[],'info',[]);
handles.mydata.name{1} = 'none';
handles.mydata.data{1} = [];
handles.mydata.info{1} = struct;
handles.plans = struct('name',[],'data',[],'info',[]);
handles.plans.name{1} = 'none';
handles.plans.data{1} = [];
handles.plans.info{1} = struct;
handles.meshes = struct('name',[],'data',[],'info',[]);
handles.meshes.name{1} = 'none';
handles.meshes.data{1} = [];
handles.meshes.info{1} = struct;
handles.registrations = struct('name',[],'data',[]);
handles.registrations.name{1} = 'none';
handles.registrations.data{1} = [];
handles.indicators = struct('name',[],'data',[],'info',[]);
handles.indicators.name{1} = 'none';
handles.indicators.data{1} = [];
handles.indicators.info{1} = struct;
handles.rendering_frames = cell(0);
handles.dvhs = [];

% set default spatial properties
handles.size = [0;0;0];
handles.spacing = [1;1;1];
handles.origin = [0;0;0];
handles.spatialpropsettled = 0;

% set default display parameters
handles.view_point = [1;1;1];
handles.minscale = 0;
handles.maxscale = 1;
handles.minscaleF = 0;
handles.maxscaleF = 1;
handles.scale_prctile = 0.1;
handles.field_color = [1 0 0];
handles.fielddensity = 8;
handles.colormap = gray(64);
handles.second_colormap = [0,0,0;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;...
    0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;...
    0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;...
    0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,0.9375;0.125,1,0.875;0.1875,1,0.8125;...
    0.25,1,0.75;0.3125,1,0.6875;0.375,1,0.625;0.4375,1,0.5625;0.5,1,0.5;...
    0.5625,1,0.4375;0.625,1,0.375;0.6875,1,0.3125;0.75,1,0.25;0.8125,1,0.1875;...
    0.8750,1,0.125;0.9375,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;...
    1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;...
    1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;...
    0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0;0.5,0,0];% jet with 0 as lowest value

% set default logging info
handles.error_count = 0;
handles.log_filename = fullfile(handles.path,'reggui_logs.txt');

% read optional inputs
if(nargin>2)
    for i=1:2:length(varargin)
        if(ischar(varargin{i}))
            try
                handles.(varargin{i})= varargin{i+1};
            catch
                disp(['Cannot create handles field: ',varargin{i}]);
            end
        end
    end
end
