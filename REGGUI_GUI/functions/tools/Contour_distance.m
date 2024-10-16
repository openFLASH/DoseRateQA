%% Contour_distance
% Compute the moments statistical distribution of the physical distances between two structures.
%
%% Syntax
% |res = Contour_distance(im1,im2,handles)|
%
%
%% Description
% |res = Contour_distance(im1,im2,handles)| describes the function
%
%
%% Input arguments
% |im1| - _STRING_ -  Name of the binary mask in |handles.images| of the first structure
%
% |im2| - _STRING_ -  Name of the binary mask in |handles.images| of the second structure
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name| - _STRING_ - Name of the image
% * |handles.images.data| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |res| - _SCALAR VECTOR_ - Statistical moments of the distance between structure |res = [minimal distance ,  mean distance,  maximum distance, standard deviation of the distance distribution, median distance]|
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


function [res, distances, distances3D] = Contour_distance(im1,im2,handles,isotropic_spacing)

% Authors : G.Janssens

% output : min mean max std median

if(nargin<4)
    isotropic_spacing = 1;
end

for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm1 = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},im2))
        myIm2 = handles.images.data{i};
    end
end
try
    
    % Crop around masks and resample with 1 mm3 voxel size
    [i,j,~] = find(myIm1|myIm2);
    [j,k] = ind2sub([handles.size(2) handles.size(3)],j);
    orig = [max(1,min(i)-1);max(1,min(j)-1);max(1,min(k)-1)];
    maximum = [min(handles.size(1),max(i)+1);min(handles.size(2),max(j)+1);min(handles.size(3),max(k)+1)];
    imsize = round((maximum-orig+1).*handles.spacing/isotropic_spacing);
    lastpt = orig + (imsize-1)./handles.spacing*isotropic_spacing;
    
    myIm1 = resampler3(myIm1,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)));
    myIm2 = resampler3(myIm2,linspace(orig(1),lastpt(1),imsize(1)),linspace(orig(2),lastpt(2),imsize(2)),linspace(orig(3),lastpt(3),imsize(3)));

    myIm1 = double(myIm1 >= max(max(max(myIm1)))/2);
    myIm2 = double(myIm2 >= max(max(max(myIm2)))/2);
    
    distmap = compute_distmap(myIm1)*isotropic_spacing;
    
    myIm2 = extract_binary_surface_from_volume(myIm2);
    
    distances = distmap(find(myIm2));
    distances3D = distmap .*myIm2;

    res = [min(abs(distances)-isotropic_spacing/2) mean(abs(distances)-isotropic_spacing/2) max(abs(distances)-isotropic_spacing/2) std(abs(distances)-isotropic_spacing/2) median(abs(distances)-isotropic_spacing/2)];
    
    disp(['Distances [mm] between ',im1,' and ',im2,' :'])    
    disp(['minimum = ',num2str(res(1))])
    disp(['mean = ',num2str(res(2))])
    disp(['maximum = ',num2str(res(3))])
    disp(['std = ',num2str(res(4))])
    disp(['median = ',num2str(res(5))])
    
catch
    disp('Error : images not found or uncorrect size!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
