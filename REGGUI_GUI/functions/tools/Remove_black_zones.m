%% Remove_black_zones
% Identify a paralelipipedic box that enclose all volume of "zero" pixels in 1 to 4 images. The paralellipiped includes the union of the "zero" zones of the 4 images.
% the function returns the coordinates (in pixel) of top left corner (stored in data element |data_dest_start|) and the size (in pixel, stored in data element |data_dest_size|) of the paralellipiped. 
% The "zero" voxels are voxels whose intensity is smaller than 1% of the full range of intensities.
%
%% Syntax
% |res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name)|
%
% |res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name,image2_name)|
%
% |res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name,image2_name,image3_name)|
%
% |res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name,image2_name,image3_name,image4_name)|
%
%
%% Description
% |res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name)| Return dimensions of the paralellipiped including the "zero" area of 1 image
%
% |res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name,image2_name)| Return dimensions of the paralellipiped including the "zero" area of 2 images
%
% |res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name,image2_name,image3_name)| Return dimensions of the paralellipiped including the "zero" area of 3 images
%
% |res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name,image2_name,image3_name,image4_name)| Return dimensions of the paralellipiped including the "zero" area of 4 images
%
%
%% Input arguments
% |data_dest_start| - _STRING_ - Name of the data element in |handles.mydata| that will contain the coordinate of the first pixel of the paralellipied
%
% |data_dest_size| - _STRING_ -  Name  of the data element in |handles.mydata| that will contain the dimension ofthe paralellipiped
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |image1_name| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed
%
% |image2_name| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed 
%
% |image3_name| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed 
%
% |image4_name| - _STRING_ -  Name of the image contained in |handles.images.name| to be processed 
%
%
%% Output arguments
%
% |res=handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.mydata.name{i}| - _STRING_ - Name of the new image = |data_dest|
% * |handles.mydata.data{i}| - _SCALAR VECTOR_ - Data element |data_dest_start|: The (x,y,z) coordinates (in pixel) of the first pixel of the paralellipiped
% * |handles.mydata.data{i}| - _SCALAR VECTOR_ - Data element |data_dest_size|: Dimension (in pixel) along the (x,y,z) axis of the paralellipid
% * |handles.mydata.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Remove_black_zones(data_dest_start,data_dest_size,handles,image1_name,image2_name,image3_name,image4_name)

num_im = nargin - 3;
minimum = [1;1;1];
maximum = [1e6;1e6;1e6];

for i=1:num_im
    eval(['image_name = image',num2str(i),'_name;']);
    myImage = [];
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},image_name))
            myImage = handles.images.data{i};
        end
    end
    if(isempty(myImage))
        error('Error : input image not found in the current list !')
    end
    i_min = min(min(min(myImage)));
    i_intercept = max(max(max(myImage)))-i_min;
    [i j s] = find(myImage<(i_min+i_intercept/100));% "zero" voxels are voxels whose intensity is smaller than 1% of the full range of intensities.
    [j k] = ind2sub([handles.size(2) handles.size(3)],j);
    minimum = max([max(1,min(i));max(1,min(j));max(1,min(k))],minimum);
    maximum = min([min(handles.size(1),max(i));min(handles.size(2),max(j));min(handles.size(3),max(k))],maximum);
end

data_dest_start = check_existing_names(data_dest_start,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = data_dest_start;
handles.mydata.data{length(handles.mydata.data)+1} = minimum;
handles.mydata.info{length(handles.mydata.info)+1} = Create_default_info('box',handles);

data_dest_size = check_existing_names(data_dest_size,handles.mydata.name);
handles.mydata.name{length(handles.mydata.name)+1} = data_dest_size;
handles.mydata.data{length(handles.mydata.data)+1} = maximum-minimum+1;
handles.mydata.info{length(handles.mydata.info)+1} = Create_default_info('box',handles);

res = handles;
