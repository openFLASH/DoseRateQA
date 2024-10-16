%% Cross_correlation
% Compute the cross correlation function between 2 images.
% See section "2.4.1 Energy functionals", sub section "b) Image metrics" of reference [1] for more details
%
%% Syntax
% |res = Cross_correlation(im1,im2,handles)|
%
%
%% Description
% |res = Cross_correlation(im1,im2,handles)| Compute the cross correlation function between 2 images
%
%
%% Input arguments
% |im1| - _STRING_ - Name of the first image in |handles.XXX| (where XXX is either 'images' of "mydata")
%
% |im2| - _STRING_ - Name of the second image in |handles.XXX| (where XXX is either 'images' of "mydata")
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.roi_mode| _SCALAR_ - |handles.roi_mode=1| The metric is computed only for the image contained inside the ROI.|handles.roi_mode=0| The metric is computed for the whole image.
% * |handles.current_roi{1}| - Index of the image in |handles.images.name| that should be used as the ROI
% * |handles.current_roi{2}| - Name of the image in  |handles.images.name| that should be used as the ROI
%
%
%% Output arguments
%
% |res| - _SCALAR_ - The cross correlation coeffficient
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Cross_correlation(im1,im2,handles)

% Authors : G.Janssens

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
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm1 = handles.images.data{i};
        myType1 = 1;
    end
    if(strcmp(handles.images.name{i},im2))
        myIm2 = handles.images.data{i};
        myType2 = 1;
    end
end
% If region of interest defined in REGGUI
use_roi_mode = 0;
if(handles.roi_mode==1 && myType1==1 && myType2==1)
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
        res = sum(sum(sum( (myIm1.*myIm2).*handles.images.data{use_roi_mode} )))/sqrt( sum(sum(sum((myIm1.^2).*handles.images.data{use_roi_mode})))*sum(sum(sum((myIm2.^2).*handles.images.data{use_roi_mode}))) );
        disp(['Cross-correlation (within ROI) = ' num2str(res)])
    else
        res = sum(sum(sum( myIm1.*myIm2 )))/sqrt( sum(sum(sum(myIm1.^2)))*sum(sum(sum(myIm2.^2))) );
        disp(['Cross-correlation = ' num2str(res)])
    end

catch ME
    reggui_logger.info(['Error : images not found or uncorrect size. ',ME.message],handles.log_filename);
    rethrow(ME);
end
