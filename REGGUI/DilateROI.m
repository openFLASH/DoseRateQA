%% DilateROI
% This function expands the target volume (with a user-defined margin) in 
% order to generate a volume to place the spots, which ensures that there
% are enough spots to cover the target in all possible situations. This 
% margin should be big enough to account for lateral penumbra and possible
% error scenarios. 
%%

%% Syntax
% |[ RTVonCT ] = DilateROI( TVonCT,margins,VoxelSize)|

%% Description
% |[ RTVonCT ] = DilateROI( TVonCT,margins,VoxelSize)| performs a dilation
% of the target volume binary mask |TVonCT|, using the user-defined margin
% (|margins|) (in mm), which is previously converted in voxel units by
% dividing by the voxel size (|VoxelSize|).
% 

%% Input arguments
% |TVonCT| - _array_ - 3D binary mask for the target volume (TV), i. e.,
% voxels inside the target are equal to one, while those outside are equal
% to zero.
%
% |margins| - _array_ - Row (1x3) vector containing the dilation value 
% on x, y, and z DICOM axis (in mm).
%
% |VoxelSize| - _array_ - Column (3x1) vector containing the resolution of
% the CT for the x, y and z DICOM coordinates (in mm).
% 

%% Output arguments
% |RTVonCT| - _array_ - 3D binary mask for the dilated or robust target 
% volume (RTV), i. e., voxels inside the target are equal to one, while 
% those outside are equal to zero. 

%% Contributors
% Authors : Ana Barragan, Lucian Hotoiu


function [ RTVonCT ] = DilateROI( TVonCT,margins,VoxelSize)

RTVonCT = zeros(size(TVonCT));

% translate margins from mm into CT voxels
margins = round(margins ./ [VoxelSize(1),VoxelSize(2),VoxelSize(3)]); % in voxels
wzero = find(margins == 0);
margins(wzero)=1; %If margin is less than a voxel, then force it to be one voxel

sCT = size(TVonCT);
temp = find(squeeze(sum(sum(TVonCT,2),3)));
ilb = max(     1,min(temp)-margins(1));
iub = min(sCT(1),max(temp)+margins(1));
temp = find(squeeze(sum(sum(TVonCT,1),3)));
jlb = max(     1,min(temp)-margins(2));
jub = min(sCT(2),max(temp)+margins(2));
temp = find(squeeze(sum(sum(TVonCT,1),2)));
klb = max(     1,min(temp)-margins(3));
kub = min(sCT(3),max(temp)+margins(3));

% Dilatation
maxmar = max(margins);
if maxmar>0
    % dilate if necessary
    % build structuring element (3D ellipsoid, flat)
    [XX,YY,ZZ] = meshgrid(-max(margins):max(margins));
    SE = (XX.^2./margins(1)^2 + YY.^2./margins(2)^2 + ZZ.^2./margins(3)^2)<=1;
    
    % dilated mask (robust target volume : RTVonCT)
    RTVonCT(ilb:iub,jlb:jub,klb:kub) = imdilate(TVonCT(ilb:iub,jlb:jub,klb:kub),SE);
end

end
