%% Cylindrical_phantom_generation
% Create a CT scan of a numerical phantom. The phantom is a cylinder of PMMA (HU = 75) with a diameter of 75mm containing a stack of slabs (with radius 25mm) of different materials (with various HU) that simulate different anatomical regions. Outside of the PMMA cylinder, there is air (HU = -1024).
% If the phantom CT has different size from the images currently stored in |handles.images|, then the |handles.images| is reset and the new CT is added to |handles.images|.
%
%% Syntax
% |res = Cylindrical_phantom_generation(handles,image_name,phantom_case)|
%
%
%% Description
% |res = Cylindrical_phantom_generation(handles,image_name,phantom_case)| Description
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure where the new image will be created.
%
% |image_name| - _STRING_ - Name of the new numerical phantom to be added to |handles.images| 
%
% |phantom_case| - _INTEGER_ - Type of numerical phantom to create:
%
% *  phantom_case = 1 : homogeneous lung
% *  phantom_case = 2 : homogeneous adipose
% *  phantom_case = 3 : homogeneous water
% *  phantom_case = 4 : homogeneous muscle
% *  phantom_case = 5 : homogeneous pmma
% *  phantom_case = 6 : homogeneous bone
% *  phantom_case = 7 : brain        
% *  phantom_case = 8 : head - empty cavity
% *  phantom_case = 9 : head - filled cavity
% *  phantom_case = 10 : lung
% *  phantom_case = 11 : lung with rib
% *  phantom_case = 12 : lung with thick rib
% *  phantom_case = 77 : TEST
% *  phantom_case = otherwise : homogeneous water
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
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

% TODO Use function compute_cylindrical_ray to generate the ray bundle. Avoid duplicating similar code
% TODO compute_orthogonal_points and this function use similar code to compute the start and stop coodinate of the ray bundle. Create a function doing that thawt will then be called by ray_tracing_curved and compute_orthogonal_points
% TODO define radius and length as input parameters of the function, not as hard coded parameters

function res = Cylindrical_phantom_generation(handles,image_name,phantom_case)

% dimension of the image
big_r = 75; % radius of the phantom (in mm)
small_r = 25; % radius of the central slabs (in mm)
cylinder_length = 400;

% HU definition
HU_phantom = 75; % pmma

% ------------------------------------------------------------
% M(H>-950 & H<=-200) = 1;% lung (-500)
% M(H>-200 & H<=-10) = 2;% adipose (-100)
% M(H>-10 & H<=10) = 3;% water (0)
% M(H>10 & H<=50) = 4;% muscle (30)
% M(H>50 & H<=100) = 5;% pmma (75)
% M(H>100) = 6;% bone (200)

HU_center = zeros(1,cylinder_length) -1024;
switch phantom_case
    case 1 % homogeneous lung
        slabs = [400,-500];
    case 2 % homogeneous adipose
        slabs = [400,-100];
    case 3 % homogeneous water
        slabs = [400,0];
    case 4 % homogeneous muscle
        slabs = [400,30];
    case 5 % homogeneous pmma
        slabs = [400,75];
    case 6 % homogeneous bone
        slabs = [400,200];
    case 7 % brain        
        slabs = [50,75; 5,-1024; 10,-100; 10,200; 5, 75; 200,0; 5, 75];% ranges: 90 mm (115.5 MeV) and 140 mm (145.5 MeV)       
    case 8 % head - empty cavity
        slabs = [50,75; 5,-1024; 10,-100; 10,200; 38,75; 10,-1024; 38,75; 50,75];% ranges: 130 mm (137.5 MeV) and 140 mm (144 MeV)
    case 9 % head - filled cavity
        slabs = [50,75; 5,-1024; 10,-100; 10,200; 38,75; 50,75; 50,75];
    case 10 % lung
        slabs = [20,-100; 50,30; 30,-500; 20,30; 30,-500; 100,30];% range: 112 mm (110 MeV)
    case 11 % lung with rib
        slabs = [20,-100; 40,30; 10,200; 30,-500; 20,30; 30,-500; 100,30];
    case 12 % lung with thick rib
        slabs = [20,-100; 30,30; 20,200; 30,-500; 20,30; 30,-500; 100,30];
    case 77 % TEST
        slabs = [25,1;25,-1;25,200;25,-1;25,1;25,200;25,1;25,-1;25,200;25,-1;25,1;25,200;25,1;25,-1;25,200];
    otherwise % homogeneous water
        slabs = [400,0];
end
i = 1;
for s=1:size(slabs,1)
    for j=1:slabs(s,1)
        HU_center(i) = slabs(s,2);
        i = i+1;
    end
end
% ------------------------------------------------------------

% % table0 - homogeneous
% depth = [200];
% HU = [1];

% % table1 - head
% depth = [10;12;17;27;162;172;177;179;189];
% HU = [50;-1024;-55;999;34;999;-55;-1024;50];

% % table2 - head, empty cavity
% depth = [10;12;32;42;82;92;122;162;167;169;179];
% HU = [50;-1024;-55;999;34;-1024;34;999;-55;-1024;50];

% % table2b - head, filled cavity
% depth = [10;12;32;42;82;92;122;162;167;169;179];
% HU = [50;-1024;-55;999;34;0;34;999;-55;-1024;50];

% % table3 - lung
% depth = [20;70;100;120;140;175;260;310;330];
% HU = [-55;40;-741;50;-741;100;-741;40;-55];

% % table4 - lung with rib
% depth = [20;60;70;100;120;140;175;260;310;330];
% HU = [-55;40;657;-741;50;-741;100;-741;40;-55];





% create 2D slice
d = zeros(2*(big_r+1)+1,2*(big_r+1)+1,'single');
[x,y]=meshgrid([1:size(d,1)],[1:size(d,2)]);
d=sqrt(((x-size(d,1)/2)).^2+((y-size(d,2)/2)).^2);
slice = zeros(size(d))-1024;
slice(d<=big_r) = HU_phantom;
if(small_r>0)
    slice(d<=small_r) = 0;
end

% create 3D volume
ct = repmat(slice,[1,1,cylinder_length+2]);
ct(:,:,1)=-1024;
ct(:,:,end)=-1024;
for i=1:cylinder_length;
    ct(:,:,i+1)=ct(:,:,i+1) + single(HU_center(i).*(d<=small_r));
end

% 'experiment-like' positioning
ct = permute(ct,[3 1 2]);

% clear workspace if image dimensions are different
if(not(handles.spatialpropsettled) || handles.size(1)~=size(ct,1) || handles.size(2)~=size(ct,2) || handles.size(3)~=size(ct,3))
    handles.images = struct('name',[],'data',[],'info',[]);
    handles.images.name{1} = 'none';
    handles.images.data{1} = [];
    handles.images.info{1} = struct;
    handles.size(1) = size(ct,1);
    handles.size(2) = size(ct,2);
    handles.size(3) = size(ct,3);
    handles.spacing = [1;1;1];
    handles.origin = [0;0;0];
    handles.view_point = round(size(ct)/2)';
    handles.spatialpropsettled = 1;
end

% store
image_name = check_existing_names(image_name,handles.images.name);
handles.images.name{length(handles.images.name)+1} = image_name;
handles.images.data{length(handles.images.data)+1} = single(ct);
info = Create_default_info('image',handles);
info.OriginalHeader.Modality = 'CT';
handles.images.info{length(handles.images.info)+1} = info;

% set handles as output
res = handles;
