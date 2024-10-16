%% On_region_of_interest
% Select the current region of interest (ROI) from the list of images stored in |handles.images| and activate or desactivate the ROI.
%
%% Syntax
% |handles = On_region_of_interest(handles)|
%
% |handles = On_region_of_interest(handles,on_off)|
%
% |handles = On_region_of_interest(handles,on_off,name)|
%
%
%% Description
% |handles = On_region_of_interest(handles)| Desactivate the current ROI selection
%
% |handles = On_region_of_interest(handles,on_off)| Desactivate the current ROI selection
%
% |handles = On_region_of_interest(handles,on_off,name)| Select an image as the current ROI and activate or desactivate the ROI
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure. The ROI data will be added to this structure
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
%
% |on_off| - _INTEGER_ - 0 = current ROI is not active. 1 = current ROI is active
%
% |name| - _STRING_ -  Name of the image contained in |handles.mydata| that will be selected as the current ROI
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.current_roi| - _CELL VECTOR_ Definition of the current region of interest
% * -----|handles.current_roi{1}| - _STRING_ - Name of the image in |handles.images{i}| that is defined as the current ROI
% * -----|handles.current_roi{2}| - _INTEGER_ - Index |i| of the image in |handles.images{i}| that is defined as the current ROI
% * |handles.roi_mode| - _INTEGER_ - 0 = Current ROI is not active. 1 = current ROI is active
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = On_region_of_interest(handles,on_off,name)

% Authors : G.Janssens

if(nargin<3)
    handles.roi_mode = 0;
else
    handles.roi_mode = on_off;
    if(handles.roi_mode)
        handles.current_roi = cell(0);
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},name))
                handles.current_roi{1} = name;
                handles.current_roi{2} = i;
            end
        end
        if(handles.current_roi{2}>1)
            disp('Region of Interest mode ON')
        else
            handles.roi_mode = 0;
            handles.current_roi = cell(0);
        end
    end
end

