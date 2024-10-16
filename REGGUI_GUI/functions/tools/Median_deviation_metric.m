%% Median_deviation_metric
% Compute the median of the difference between the vectors of the two deformation fields
%
%% Syntax
% |res = Median_deviation_metric(im1,im2,handles)|
%
%
%% Description
% |res = Median_deviation_metric(im1,im2,handles)| Compute the median of the difference between the vectors of the two deformation fields
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
% * |handles.roi_mode| _SCALAR_ - |handles.roi_mode=1| The mean norm difference is computed only for the field contained inside the ROI.|handles.roi_mode=0| The mean norm difference is computed for the whole field.
% * |handles.current_roi{1}| - Index of the image in |handles.images.name| that should be used as the ROI
% * |handles.current_roi{2}| - Name of the image in  |handles.images.name| that should be used as the ROI
%
%
%% Output arguments
%
% |res| - _SCALAR_ - Median of the difference between the vectors of the two deformation fields
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Median_deviation_metric(im1,im2,handles)

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
    if(use_roi_mode)
        for n=1:3
            m(n,:) = abs(myIm1(n,find(handles.images.data{use_roi_mode})) - myIm2(n,find(handles.images.data{use_roi_mode})));
            m(n,:) = abs(m(n,:) - median(m(n,:)));
        end
        res = median(reshape(m,1,n*length(m)));
        disp(['Median deviation (on ROI) = ' num2str(res)])
    else
        for n=1:3
            m(n,:) = reshape(squeeze(abs(myIm1(n,:,:,:)-myIm2(n,:,:,:))),1,size(myIm1,2)*size(myIm1,3)*size(myIm1,4));
            m(n,:) = abs(m(n,:) - median(m(n,:)));
        end
        res = median(reshape(m,1,n*length(m)));
        disp(['Median deviation = ' num2str(res)]);
    end
catch ME
    reggui_logger.info(['Error : fields not found or uncorrect size. ',ME.message],handles.log_filename);
    rethrow(ME);
end
