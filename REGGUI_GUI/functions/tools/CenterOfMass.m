%% CenterOfMass
% Compute the centre of mass of an image: R = sum(R.I) ./ sum(R) where R is the coordinate of the voxel and I is the intensity of the voxel. The sum is over all voxels.
% The view point of the displayed image is recentered on the centre of mass.
%
%% Syntax
% |[CoM,CoM_realspace] = CenterOfMass(im1,handles)|
%
% |[CoM,CoM_realspace,handles] = CenterOfMass(im1,handles)|
%
%
%% Description
% |[CoM,CoM_realspace] = CenterOfMass(im1,handles)| Compute the coordinates of the centre of mass
%
% |[CoM,CoM_realspace,handles] = CenterOfMass(im1,handles)|  Compute the coordinates of the centre of mass and recentre the point of view
%
%
%% Input arguments
% |im1| - _STRING_ -  Name of the image contained in |handles.XXX.name| to be processed
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either "images" or "mydata" or "fields"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |CoM| - _SCALAR VECTOR_ - Coordinate of the centre of mass (in pixels) of the centre of mass
%
% |CoM_realspace| - _SCALAR VECTOR_ - Coordinate of the centre of mass (in mm) of the centre of mass
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated :
%
% * |handles.view_point| - _INTEGER VECTOR_ Coordinate (in pixel, origin at 1st voxel) of the isocentre in the image
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [CoM,CoM_realspace,handles] = CenterOfMass(im1,handles)

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im1))
        myIm = handles.mydata.data{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm = handles.images.data{i};
    end
end
try
    [X,Y,Z] = meshgrid(1:size(myIm,2),1:size(myIm,1),1:size(myIm,3));
    CoM = [sum(sum(sum(Y.*myIm)));sum(sum(sum(X.*myIm)));sum(sum(sum(Z.*myIm)))]'/sum(sum(sum(myIm)));
    CoM_realspace = ((CoM-1)'.*handles.spacing + handles.origin)';
    disp(['The center of mass  = [ ', num2str(CoM),' ] (pixels)   =  [ ', num2str(CoM_realspace),' ] (mm)']);    
    if(nargout>2)
       handles.view_point = round(CoM'); 
    end
catch
    disp('Error : images not found or uncorrect size!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
