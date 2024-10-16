%% Resample_image
% Resample an image from the |handles.images| into the |handles.mydata| structure.

%% Syntax
% |handles = Resample_image(image_name,grid,output_name,handles)|

%% Description
% |handles = Resample_image(image_name,output_name,handles)|  resample and copy the image from |handles.mydata| to the |handles.images| structure.

%% Input arguments
% |image_name| - _STRING_ -  Name of the image contained in |handles.mydata| to be copied
%
% |grid| - _STRING_ or _STRUCT_ - spatial properties for the output image (must contain grid.spacing, grid.size, grid.origin), or another image in mydata for the spatial properties to be copied from
%
% |output_name| - _STRING_ -  Name of the new image created in |handles.images|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:

%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com), J.Orban

function [handles,output_name] = Resample_image(image_name,grid,output_name,handles)

[myImage,myInfo] = Get_reggui_data(handles,image_name,'images');

if(not(isstruct(grid)))
    [temp,gridInfo] = Get_reggui_data(handles,grid,'mydata');
    grid = struct;
    grid.spacing = gridInfo.Spacing(:);
    grid.origin = gridInfo.ImagePositionPatient(:);
    grid.size = size(temp)';
end

if(not(isfield(grid,'spacing')&&isfield(grid,'origin')&&isfield(grid,'size')))
   disp('Target spatial properties not found. Abort.')
   return
end

for i=1:3
    if(round(myInfo.Spacing(i)*1e3)==round(grid.spacing(i)*1e3))
        myInfo.Spacing(i) = grid.spacing(i);
    end
end
orig = (- myInfo.ImagePositionPatient + grid.origin)./myInfo.Spacing +1;

if(grid.spacing(1)>myInfo.Spacing(1))
    downfactor = grid.spacing(1)./myInfo.Spacing(1);
    sigma = downfactor*.4;
    fsz = round(sigma * 5);
    fsz = fsz + (1-mod(fsz,2));
    filterx = gaussian_kernel(fsz, sigma);
    filterx = filterx/sum(filterx);
    myImage = padarray(myImage, [length(filterx) 0 0], 'replicate');
    myImage = conv3f(myImage, single(filterx));
    myImage = myImage(length(filterx)+1:end-length(filterx), :, :);
end
if(grid.spacing(2)>myInfo.Spacing(2))
    downfactor = grid.spacing(2)./myInfo.Spacing(2);
    sigma = downfactor*.4;
    fsz = round(sigma * 5);
    fsz = fsz + (1-mod(fsz,2));
    filtery = gaussian_kernel(fsz, sigma);
    filtery = filtery'/sum(filtery);
    myImage = padarray(myImage, [0 length(filtery) 0], 'replicate');
    myImage = conv3f(myImage, single(filtery));
    myImage = myImage(:,length(filtery)+1:end-length(filtery), :);
end
if(grid.spacing(3)>myInfo.Spacing(3))
    downfactor = grid.spacing(3)./myInfo.Spacing(3);
    sigma = downfactor*.4;
    fsz = round(sigma * 5);
    fsz = fsz + (1-mod(fsz,2));
    filterz = gaussian_kernel(fsz, sigma);
    filterz = filterz/sum(filterz);
    myImage = padarray(myImage, [0 0 length(filterz)], 'replicate');
    myImage = conv3f(myImage, single(permute(filterz, [3 2 1])));
    myImage = myImage(:,:,length(filterz)+1:end-length(filterz));
end
lastpt = orig + (grid.size-1).*grid.spacing./myInfo.Spacing;
image = resampler3(myImage,linspace(orig(1),lastpt(1),grid.size(1)),linspace(orig(2),lastpt(2),grid.size(2)),linspace(orig(3),lastpt(3),grid.size(3)));
image(isnan(image))=0;

% Replace spatial properties in info
myInfo.Spacing = grid.spacing;
myInfo.ImagePositionPatient = grid.origin;

% Save result
[handles,output_name] = Set_reggui_data(handles,output_name,image,myInfo,'mydata',0);
