%% Mean_norm_metric
% Compute the mean norm of the difference between the vectors of the two deformation fields
%
%% Syntax
% |res = Mean_norm_metric(im1,im2,handles)|
%
%
%% Description
% |res = Mean_norm_metric(im1,im2,handles)| Compute the mean norm of the difference between two deformation fields
%
%
%% Input arguments
% |im1| - _STRING_ - Name of the first deformation field in |handles.XXX| (where XXX is either 'fields' of "mydata")
%
% |im2| - _STRING_ - Name of the second deformation field in |handles.XXX| (where XXX is either 'fields' of "mydata")
%
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'fields' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith field
% * |handles.XXX.data{i}| - _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.roi_mode| _SCALAR_ - |handles.roi_mode=1| The metric is computed only for the field contained inside the ROI.|handles.roi_mode=0| The metric is computed for the whole field.
% * |handles.current_roi{1}| - Index of the image in |handles.images.name| that should be used as the ROI
% * |handles.current_roi{2}| - Name of the image in  |handles.images.name| that should be used as the ROI
%
%
%% Output arguments
%
% |res| - _SCALAR_ - Mean norm of the difference between the vectors of the two deformation fields
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Mean_norm_metric(im1,im2,handles)


for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im1))
        myIm1 = handles.mydata.data{i};
        myType1 = 4;
    end
    if(strcmp(handles.mydata.name{i},im2))
        myIm2 = handles.mydata.data{i};
        myType2 = 4;
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},im1))
        myIm1 = handles.fields.data{i};
        myType1 = 2;
    end
    if(strcmp(handles.fields.name{i},im2))
        myIm2 = handles.fields.data{i};
        myType2 = 2;
    end
end
% If region of interest defined in REGGUI
use_roi_mode = 0;
if(handles.roi_mode==1 && myType1==2 && myType2==2)
    try
        if(strcmp(handles.images.name{handles.current_roi{2}},handles.current_roi{1}))
            use_roi_mode = handles.current_roi{2};
        else
            handles.roi_mode = 0;
            handles.current_roi = cell(0);
        end
    catch
        handles.roi_mode = 0;
        handles.current_roi = cell(0);
    end
end
try
    root_square_diff = sqrt(squeeze(sum((myIm1-myIm2).^2,1)));
    if(use_roi_mode)        
        res = sum(sum(sum( root_square_diff.*handles.images.data{use_roi_mode} ))) /sum(sum(sum(handles.images.data{use_roi_mode})));
        disp(['Mean norm (on ROI) = ' num2str(res)])
    else
        res = sum(sum(sum( root_square_diff ))) /size(myIm1,2)/size(myIm1,3)/size(myIm1,4);
        disp(['Mean norm = ' num2str(res)]);
    end

catch ME
    reggui_logger.info(['Error : fields not found or uncorrect size. ',ME.message],handles.log_filename);
    rethrow(ME);
end
