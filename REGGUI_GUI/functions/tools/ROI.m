%% ROI
% Define a region of interest in an image. If required, a dialog box is displayed with |image| to let the user outline the ROI directly onto the image.
%
%% Syntax
% |handles = ROI(image,params,im_dest,handles)|
%
%
%% Description
% |handles = ROI(image,params,im_dest,handles)| Define the region of interest
%
%
%% Input arguments
% |image| - _STRING_ -  Name of the image contained in |handles.images.name| to use to define the ROI
%
% |params| - _CELL VECTOR_ -  Parameters for the deifnition of the ROI. The parameter depends on the type of ROI to be defined:
%
% * |params{1} ='box'| Defines a ROi with paralelipipedid shape. User can manuall adapt the box size.
% * --------|params{2}| - _STRING_ Name of a previsouly defined mask in |handles.images| that is used to start the manual deifnition of ROI. If absent, then start manual definition with an empty
%
% * |params{1} ='sphere'| Defines a spherical ROI
% * % * --------|params{2}| - _SCALAR VECTOR_ (x,y,z) Radius (in mm) of the ellipsoidal ROI laong the 3 coordinate axes
% * % * --------|params{3}| - _SCALAR VECTOR_ (x,y,z) Coordinate (in pixel) of the centre of the ROI. If absent, a dialog box as for manual clicking at the position of the centre on the image.
%
% * |params{1} ='cylinder_z'| Defines a cylindrical ROI. The cylinder axis is paralell to the Z-axis and has the full length of the CT scan
% * % * --------|params{2}| - _SCALAR_ Radius (in mm) of the cylinder
% * % * --------|params{3}| - _SCALAR VECTOR_ (x,y,z) Coordinate (in pixel) of the centre of the ROI. If absent, a dialog box as for manual clicking at the position of the centre on the image.
%
%
% |im_dest|| - _STRING_ -  Name of the new image created in |handles.images| with the ROI
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.view_point| - _INTEGER VECTOR_ Coordinate (in pixel, origin at 1st voxel) of the isocentre in the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i|:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info|
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = ROI(image,params,im_dest,handles)

% Authors : G.Janssens

myImage = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image))
        myImage = handles.images.data{i};
        myInfo = handles.images.info{i};
    end
end
if(isempty(myImage))
    error('Error : input image not found in the current list !')
end
if(ndims(myImage)==2)
    error('Not implemented for 2D images')
else
    ROI_shape = params{1};
    im_res = zeros(size(myImage),'single');
    switch ROI_shape
        case 'box'
            if(length(params)>1)
                myMask = [];
                for i=1:length(handles.images.name)
                    if(strcmp(handles.images.name{i},params{2}))
                        myMask = handles.images.data{i};
                    end
                end
                myMask = myMask>max(max(max(myMask)))/2;
                im_res = image_viewer(myImage,myInfo,'box',handles.view_point,myMask);
            else
                im_res = image_viewer(myImage,myInfo,'box',handles.view_point);
            end
        case 'sphere'
            eval(['ROI_size = ' params{2} ';']);
            if(size(ROI_size)==1)
                ROI_size = [ROI_size;ROI_size;ROI_size];
            end
            if(length(params)<3)
                params{3} = image_viewer(myImage,myInfo,'point',handles.view_point);
            end
            eval(['ROI_center = ' params{3} ';']);
            [Y,X,Z] = meshgrid(-ceil(ROI_size(2)/handles.spacing(2)):ceil(ROI_size(2)/handles.spacing(2)),...
                -ceil(ROI_size(1)/handles.spacing(1)):ceil(ROI_size(1)/handles.spacing(1)),...
                -ceil(ROI_size(3)/handles.spacing(3)):ceil(ROI_size(3)/handles.spacing(3)));
            X = X.*handles.spacing(1);Y = Y.*handles.spacing(2);Z = Z.*handles.spacing(3);
            mask = single((X.^2/ROI_size(1).^2+Y.^2/ROI_size(2).^2+Z.^2/ROI_size(3).^2)<1);
            im_res = myImage*0;
            im_res(ROI_center(1)-ceil(ROI_size(1)/handles.spacing(1)):ROI_center(1)+ceil(ROI_size(1)/handles.spacing(1)),...
                ROI_center(2)-ceil(ROI_size(2)/handles.spacing(2)):ROI_center(2)+ceil(ROI_size(2)/handles.spacing(2)),...
                ROI_center(3)-ceil(ROI_size(3)/handles.spacing(3)):ROI_center(3)+ceil(ROI_size(3)/handles.spacing(3))) = mask;
        case 'cylinder_z'
            eval(['ROI_radius = ' params{2} ';']);
            if(length(params)<3)
                params{3} = image_viewer(myImage,myInfo,'point',handles.view_point);
            end
            eval(['ROI_center = ' params{3} ';']);
            % create 2D slice
            [y,x]=meshgrid([1:handles.size(2)],[1:handles.size(1)]);
            slice=sqrt(((x*handles.spacing(1)-ROI_center(1)+handles.origin(1))).^2+((y*handles.spacing(2)-ROI_center(2)+handles.origin(2))).^2)<ROI_radius;
            % create 3D volume
            im_res = repmat(slice,[1,1,handles.size(3)]);
        otherwise
            disp(['ROI with shape ''' ROI_shape ''' is not implemented.'])
    end
    
    im_dest = check_existing_names(im_dest,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = im_dest;
    handles.images.data{length(handles.images.data)+1} = single(im_res);
    info = Create_default_info('image',handles);
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    handles.images.info{length(handles.images.info)+1} = info;
end
