%% AbsoluteRelativeThreshold
% Threshold an image using statistical parameters computed from the image intensity as minimum and maximum boundaries. A mask can be defined, so that only the voxels contained inside the mask are processed. 
% The cumulative historgram of intensity range between the minimum and maximum boundaries is divided in |nbr_thrs| boundary levels |B(N)|. For the image |i| in the series (whith |1<= i <=nbr_thrs|), the maximum intensity boundary |thr_intensity(i)| is chosen so that there is a percentate |thr_percent = 100.*(1-(i./nbr_thrs).^power_factor)| pixels in the cumulative histograms with an intensity equal or lower to |thr_intensity(i)|. A series of images is generated, each with voxels in the intensity |I| range |bounds{1} <= I <= thr_intensity(N)|.
%
%% Syntax
% |[handles,thr_intensity,thr_percent] = AbsoluteRelativeThreshold(image,seg,im_dest,handles)| Threshold the image using the minimum and maximum intneisty as boundary.
%
% |[handles,thr_intensity,thr_percent] = AbsoluteRelativeThreshold(image,seg,im_dest,handles,nbr_thrs)| Threshold the image using the minimum and maximum intneisty as boundary.
%
% |[handles,thr_intensity,thr_percent] = AbsoluteRelativeThreshold(image,seg,im_dest,handles,nbr_thrs,bounds)| Threshold the image using specified statistical parameters.
%
% |[handles,thr_intensity,thr_percent] = AbsoluteRelativeThreshold(image,seg,im_dest,handles,nbr_thrs,bounds,power_factor)| Threshold the image using specified statistical parameters.
%
%
%% Description
% |[handles,thr_intensity,thr_percent] = AbsoluteRelativeThreshold(image,seg,im_dest,handles,nbr_thrs,bounds,power_factor)| describes the function
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image contained in |handles.images.name| to be thresholded
%
% |seg| - _STRING_ -  Name of the image contained in |handles.images.name| defining a mask. the thresholding will be done only inside this mask.
%
% |im_dest| - _STRING_ -  Name of the new series of images created in |handles.images|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image.
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image.
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |nbr_thrs| - _INTEGER_ - Number of boundary level to use to segment the cumulative intensity histogram 
%
% |bounds| - _CELL VECTOR of STRING_ -  String defining the statistical parameters to use for the minimum boundary |bounds{1}| and the maximum boundary |bounds{2}| for the thresholded structure. The possible strings are:
%
% * 'mean' : Use the mean intensity of the image as the boundary
% * 'median' : Use the median intensity of the image as the boundary
% * Otherwise : If any other string is entered, the the minimum or maximum intensity is used as the boundary
%
% |power_factor| - _SCALAR_ -  Exponent in the definition of the boundary levels of the image series
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation images |i|:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image. The |nbr_thrs| images have the name |im_dest_N|, with whith |1<=i<=nbr_thrs|.
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Image mask. Voxel (x,y,z)=1 if its intensity is between |bound{1}<=data{i}(x,y,z)<=thr_intensity(i)|  
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info.OriginalHeader|
%
% |thr_intensity| - _SCALAR VECTOR_ - |thr_intensity(i)| Higher boundary used for the ith image.
%
% |thr_percent| - _SCALAR VECTOR_ - |thr_percent(i)| Percentage of voxels in the cumulative histogram with an intensity lower or equal to |thr_intensity(i)|
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [handles,thr_intensity,thr_percent] = AbsoluteRelativeThreshold(image,seg,im_dest,handles,nbr_thrs,bounds,power_factor)

% Authors : G.Janssens

if(nargin<5)
    nbr_thrs = 10;
end

if(nargin<6)
    bounds = {'min','max'};
end

if(nargin<7)
    power_factor = 2;
end

myImage = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},seg))
        mySeg = handles.images.data{i};
    end
end
if(isempty(myImage))
    error('Error : input image not found in the current list !')
end

% Computing threshold values
myValues = myImage(mySeg>=max(mySeg(:)/2));
switch bounds{1}
    case 'mean'
        min_acti = mean(myValues);
    case 'median'
        min_acti = median(myValues);
    otherwise
        min_acti = min(myValues);
end
switch bounds{2}
    case 'mean'
        max_acti = mean(myValues);
    case 'median'
        max_acti = median(myValues);
    otherwise
        max_acti = max(myValues);
end
myValues = myValues((myValues>min_acti)&(myValues<=max_acti));
max_acti = max(max_acti,min_acti+nbr_thrs*eps);
thrs = 1 - linspace(1,1/(nbr_thrs),nbr_thrs).^power_factor; % modified by JAL to match IMREviewer code, June 14, 2013.
tmp = sort(myValues); thr_intensity = tmp(1+floor(numel(tmp)*thrs(:))); % thr_intensity = thrs*(max_acti-min_acti)+min_acti;
thr_percent = 100*(thr_intensity - min_acti) ./ (max_acti - min_acti);
disp(['Threshold values: ',num2str(thr_percent')])
myImage(mySeg<max(mySeg(:)/2)) = min_acti;

% Generating iso-contours
for i=1:nbr_thrs
    current_im_dest = check_existing_names([im_dest,'_',num2str(i)],handles.images.name);
    handles.images.name{length(handles.images.name)+1} = current_im_dest;
    handles.images.data{length(handles.images.data)+1} = single((myImage>=thr_intensity(i)) & (mySeg>=max(mySeg(:)/2)));
    info = Create_default_info('image',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.images.info{length(handles.images.info)+1} = info;
end

thr_intensity = thr_intensity';
thr_percent = thr_percent';
