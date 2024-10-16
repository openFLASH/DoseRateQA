%% newimage
% Create a new meta ('*.mha') image data structure. The image can has up to 5 dimensions (x,y,z,t,J). (x,y,z) are 3 spatial dimension. t is the time. The last dimensions can be used to can be used to store the 3 components of the vectors of a vector field (J=1 for X composnent of the vector, J=2 for Y component, etc.) 
%
%% Syntax
% |image = newimage(datasize)| Create a new image of default modality and specified size and with all elements equal to zero
%
% |image = newimage(datasize,data)| Create a new image of default modality and specified size and use |data| to fill the image
%
% |image = newimage(datasize,data,modality)| Create a new image of specified modality and specified size and use |data| to fill the image
%
%
%% Description
% |image = newimage(datasize)|
%
% |image = newimage(datasize,data)|
%
% |image = newimage(datasize,data,modality)|
%
%
%% Input arguments
% |datasize| - _SCALAR VECTOR_ - Size of each dimension of the image
%
% |data| - _SINGLE MATRIX_ - [OPTIONAL.] |data(x,y,z,t,J)| is the image to be stored in |image.dval|. If absent, a matrix of size |datasize| is created and filled with zeros
%
% |modality| - _STRING_ - [OPTIONAL. Default = 'OT'] Define the colour modality of the image. See function |newcolors| for more information
%
%
%% Output arguments
%
% |image| - _STRUCTURE_ - 'Meta' image data structure
%
% * |image.dval| - _SCALAR MATRIX_ - |data(x,y,z,t,J)| representing the image.
% * |image.name| - _STRING_ - Image name = 'New image'
% * |image.patient| - _STRUCTURE_ - Patient structure (see function |newpatient|)
% * |img.ddim| - _SCALAR VECTOR_ - |ddim(x,y,z,t)| Size of each dimension
% * |image.dmod| - _STRING_ - Define the colour modality of the image (see function |newcolors|)
% * |img.dext| - _SCALAR MATRIX_ - |dext(t,J,1)| minimum intensity at time t and vector component J. |dext(t,J,2)| Maximum intensity at time t and vector component J. 
% * |img.dspa| - _SCALAR VECTOR_ - (x,y,z) Pixel size (mm) = spaccing
% * |img.zoff| - _SCALAR VECTOR_ Coordinates (x,y,z) (in mm) of the first voxel of the image
% * |img.dpcx| - _SCALAR VECTOR_ - |img.dpcx(i)| Absices (mm) of the i-th voxels along the X axis
% * |img.dpcy| - _SCALAR VECTOR_ - |img.dpcy(i)| Absices (mm) of the i-th voxels along the Y axis
% * |img.dpcz| - _SCALAR VECTOR_ - |img.dpcz(i)| Absices (mm) of the i-th voxels along the Z axis
% * |img.dfra| - _SCALAR MATRIX_  |fras(t,2)| Frame start times and lengths
% * |image.colors| - _STRUCTURE_ - Image color (see function |newcolors(modality)|)
% * |image.units| - _STRUCTURE_ - See function |newunits|
% * |img.type| - _STRING_ - Type of image = 'none'
% * |image.boxes| - _STRUCTURE_ - See function |newboxes(datasize)|
% * |image.masks| - _STRUCTURE_ - See function |newmasks(datasize)|
% * |image.lines| - _STRUCTURE_ - See function |newlines(datasize)|
% * |image.regis| - _STRUCTURE_ - See function |newregis(datasize)|
% * |image.file| - _STRING_ - Name of the header file '*.mha
% * |image.path| - _STRING_ - Name of the folder containing the image
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function image = newimage(datasize,data,modality)


% check arg
if nargin<3, modality = 'OT'; end;
if nargin<2,
    data = repmat(single(0),[datasize(1),datasize(2),datasize(3),datasize(4),datasize(5)]);
elseif size(data,1)==datasize(1) && size(data,2)==datasize(2) && size(data,3)==datasize(3) && size(data,4)==datasize(4) && size(data,5)==datasize(5),
    if ~strcmp(class(data),'single'),
        data = single(data);
    end;
else
    error('size mismatch!');
end;

image = struct(...
    'lock',false,...
    'fdad',0,...
    'fson',0,...
    'name','New image',...
    'dval',data,...
    'ddim',reshape(datasize(1:4),4,1),...
    'dext',double([reshape(min(min(min(data,[],1),[],2),[],3),datasize(4),[]),reshape(max(max(max(data,[],1),[],2),[],3),datasize(4),[])]),...
    'dspa',[1;1;1],...
    'dpcx',[1:datasize(1)]',...
    'dpcy',[1:datasize(2)]',...
    'dpcz',[1:datasize(3)]',...
    'dfra',zeros(datasize(4),2),...
    'dmod',modality,...
    'zfac',1,...
    'zoff',[0;0;0],...
    'poscur',[1;1;1;1],...
    'type','none',...
    'file','',...
    'path','',...
    'colors',newcolors(modality),...
    'units',newunits,...
    'boxes',newboxes(datasize),...
    'masks',newmasks(datasize),...
    'lines',newlines(datasize),...
    'regis',newregis(datasize),...
    'dicom',cell(1),... %'header',cell(datasize(4),1),...
    'patient',newpatient);
