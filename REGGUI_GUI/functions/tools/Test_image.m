%% Test_image
% Return an image with the size defined in |handles.size|. The image contains the specified frequencies at the different scales.
% If no frequency are provided, the function returns a null field.
%
%% Syntax
% |handles = Test_image(im_dest,handles)|
%
% |handles = Test_image(im_dest,handles,scales)|
%
%
%% Description
% |handles = Test_image(im_dest,handles)| Returns a null image
%
% |handles = Test_image(im_dest,handles,scales)| Return an image with the spatial frequency atthe specified scales
%
%
%% Input arguments
% |im_dest| - _STRING_ -  Name of the new image created in |handles.images| 
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI 
%
% |scales| - _SCALAR VECTOR_ - |scales1(i)| Spatial frequencies in the image at scale i
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. 
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Test_image(im_dest,handles,scales)
if(handles.size(1) && handles.size(2) && handles.size(3))
    if(nargin>2)
        s = zeros(handles.size(1),handles.size(2),handles.size(3),'single');
        s(1,1,1) = 2^7;
        % for the highest frequency, only one value in the spectrum (and doubled)
        freqX = round((handles.size(1)-1)/2^(1/2+1/2));
        freqY = round((handles.size(2)-1)/2^(1/2+1/2));
        freqZ = round((handles.size(3)-1)/2^(1/2+1/2));
        s(1+freqX,1,1) = 2*2^((1/2+1/2)*8/sum(abs(scales)>0)-1)*scales(1);
        s(1,1+freqY,1) = 2*2^((1/2+1/2)*8/sum(abs(scales)>0)-1)*scales(1);
        s(1,1,1+freqZ) = 2*2^((1/2+1/2)*8/sum(abs(scales)>0)-1)*scales(1);
        if(length(scales)>(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1)
            disp('Warning: vector of frequencies too long for the size of the image. Vector limited to continuous component');
            s(1,1,1) = max(scales(floor(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1:end));
            scales = scales(1:floor(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1);
        end
        for k=2:length(scales)
            % The image will be a sum of cosines whose periods (in voxels)
            % are 2^(1/2+k/2). The first component (k=1, highest frequency)
            % always has a period of 2 voxels.
            freqX = round((handles.size(1)-1)/2^(1/2+k/2));
            freqY = round((handles.size(2)-1)/2^(1/2+k/2));
            freqZ = round((handles.size(3)-1)/2^(1/2+k/2));
            % Component of the Fourier transform have amplitudes that are
            % geometrically increasing (from high frequencies to low
            % frequencies) with an increasing factor of 2^(4/N) where N is
            % the number of non-zero component in the scales vector.
            s(1+freqX,1,1) = 2^((1/2+(sum(abs(scales(1:k))>0))/2)*8/sum(abs(scales)>0)-1)*scales(k);
            s(mod(end-freqX,end)+1,1,1) = s(1+freqX,1,1);
            s(1,1+freqY,1) = 2^((1/2+(sum(abs(scales(1:k))>0))/2)*8/sum(abs(scales)>0)-1)*scales(k);
            s(1,mod(end-freqY,end)+1,1) = s(1,1+freqY,1);
            s(1,1,1+freqZ) = 2^((1/2+(sum(abs(scales(1:k))>0))/2)*8/sum(abs(scales)>0)-1)*scales(k);
            s(1,1,mod(end-freqZ,end)+1) = s(1,1,1+freqZ);
        end
        imTest = real(ifftn(s));
        imTest = imTest - min(min(min(imTest)));
        imTest = imTest/(max(max(max(imTest)))+eps)*256;
        im_dest = check_existing_names(im_dest,handles.images.name);
        handles.images.name{length(handles.images.name)+1} = im_dest;
        handles.images.data{length(handles.images.data)+1} = imTest;
        handles.images.info{length(handles.images.info)+1} = Create_default_info('image',handles);
    else
        imEmpty = zeros(handles.size(1),handles.size(2),handles.size(3),'single');
        im_dest = check_existing_names(im_dest,handles.images.name);
        handles.images.name{length(handles.images.name)+1} = im_dest;
        handles.images.data{length(handles.images.data)+1} = imEmpty;
        handles.images.info{length(handles.images.info)+1} = Create_default_info('image',handles);
    end
else
    disp('Error : you have to load an image first (to set dimensions) !')
end
