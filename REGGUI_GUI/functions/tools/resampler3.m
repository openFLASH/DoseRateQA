%% resampler3
% Resample an image in 3 dimension. The image is resampled at the points defined along the coordinates 3 axes.
%
%% Syntax
% |resampledImage = resampler3(initialImage, xCoord, yCoord, zCoord)|
%
% |resampledImage = resampler3(initialImage, xCoord, yCoord, zCoord, padding)|
%
%
%% Description
% |resampledImage = resampler3(initialImage, xCoord, yCoord, zCoord)| Resample the image image at the specified points using default padding intensity
%
% |resampledImage = resampler3(initialImage, xCoord, yCoord, zCoord, padding)| Resample the image image at the specified points using specified padding intensity
%
%
%% Input arguments
% |initialImage| - _SCALAR MATRIX_ - Input image to be resampled. |initialImage(x,y,z)| Intensity at voxel (x,y,z).
%
% |xCoord| - _INTEGER VECTOR_ - Vectors containing the X-coordinates (in pixel) of the points were the resampling is needed along the X-axis.
%
% |yCoord| - _INTEGER VECTOR_ - Vectors containing the X-coordinates of the points were the resampling is needed along the Y-axis.
%
% |zCoord| - _INTEGER VECTOR_ - Vectors containing the X-coordinates of the points were the resampling is needed along the Z-axis.
%
% |padding| - _SCALLAR_ - [OPTIOANL. Default = minimum intensity of |initialImage| (if negative) or 0] Intensity level to use for the pixels that are padded around the initial image. Padding involves putting extra columns, rows, slices and frames in an image, to create an image that has a greater number of pixels than it had originally.
%
%
%% Output arguments
%
% |resampledImage| - _SCALAR MATRIX_ - Resampled image. |resampledImage(x,y,z)| Intensity at voxel (x,y,z).
%
%
%% Contributors
% Authors : G.Janssens, J.Orban (open.reggui@gmail.com)

function resampledImage = resampler3(initialImage, xCoord, yCoord, zCoord, padding)

if(nargin<5)
    min_intensity = min(initialImage(:));
    if(min_intensity<0)
        padding = min_intensity;
    else
        padding = 0;
    end
end

% Pad the initial image with zeros and choose appropriate box
initialImagePadded = zeros(ceil(xCoord(end)-xCoord(1)+2),ceil(yCoord(end)-yCoord(1)+2),ceil(zCoord(end)-zCoord(1)+2),'single') + padding;
initialImagePadded(max(1,2-floor(xCoord(1))):min(ceil(xCoord(end)),size(initialImage,1))-floor(xCoord(1))+1,...
                   max(1,2-floor(yCoord(1))):min(ceil(yCoord(end)),size(initialImage,2))-floor(yCoord(1))+1,...
                   max(1,2-floor(zCoord(1))):min(ceil(zCoord(end)),size(initialImage,3))-floor(zCoord(1))+1) =...
      initialImage(max(1,floor(xCoord(1))):min(ceil(xCoord(end)),size(initialImage,1)),...
                   max(1,floor(yCoord(1))):min(ceil(yCoord(end)),size(initialImage,2)),...
                   max(1,floor(zCoord(1))):min(ceil(zCoord(end)),size(initialImage,3)));
xCoord = xCoord - floor(xCoord(1)) +1;
yCoord = yCoord - floor(yCoord(1)) +1;
zCoord = zCoord - floor(zCoord(1)) +1;

%Minimize memory
clear initialImage

%X resampling
out2x = zeros(length(xCoord),size(initialImagePadded,2),size(initialImagePadded,3),'single');
for x = 1:length(xCoord)-1
    xFloor = floor(xCoord(x));
    out2x(x,:,:) = initialImagePadded(xFloor,:,:)*(1-(xCoord(x)-xFloor))+initialImagePadded(xFloor+1,:,:)*(xCoord(x)-xFloor);
end
xCeil = ceil(xCoord(end));
out2x(length(xCoord),:,:) = initialImagePadded(max(1,xCeil-1),:,:)*(xCeil-xCoord(end))+initialImagePadded(xCeil,:,:)*(1-(xCeil-xCoord(end)));

%Y resampling
out2y = zeros(length(xCoord),length(yCoord),size(initialImagePadded,3),'single');
for y = 1:length(yCoord)-1
    yFloor = floor(yCoord(y));
    out2y(:,y,:) = out2x(:,yFloor,:)*(1-(yCoord(y)-yFloor))+out2x(:,yFloor+1,:)*(yCoord(y)-yFloor);
end
yCeil = ceil(yCoord(end));
out2y(:,length(yCoord),:) = out2x(:,max(1,yCeil-1),:)*(yCeil-yCoord(end))+out2x(:,yCeil,:)*(1-(yCeil-yCoord(end)));

%Minimize memory
clear out2x

%Z resampling
resampledImage = zeros(length(xCoord),length(yCoord),length(zCoord),'single');
for z = 1:length(zCoord)-1
    zFloor = floor(zCoord(z));
    resampledImage(:,:,z) = out2y(:,:,zFloor)*(1-(zCoord(z)-zFloor))+out2y(:,:,zFloor+1)*(zCoord(z)-zFloor);
end
zCeil = ceil(zCoord(end));
resampledImage(:,:,length(zCoord)) = out2y(:,:,max(1,zCeil-1))*(zCeil-zCoord(end))+out2y(:,:,zCeil)*(1-(zCeil-zCoord(end)));
