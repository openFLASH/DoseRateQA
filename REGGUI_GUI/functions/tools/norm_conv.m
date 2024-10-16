%% norm_conv
% Perform a normalised convolution [1] of an image with a kernel:
% F = (a.c * k) / (c * k)
% where a.c is a element to element product and * is the convolution operator
%
% For details see chapter 5 of reference [2].
%
%% Syntax
% |res = norm_conv(a,k,c)|
%
%
%% Description
% |res = norm_conv(a,k,c)| Perform a normalised convolution
%
%
%% Input arguments
% |a| - _SCALAR MATRIX_ - |a(x,y,z)| Intensity at voxel (x,y,z) of the image
%
% |c| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the |a| image.
%
% |k| - _SCALAR MATRIX_ |k(x,y,z)| Intensity of the voxel (x,y,z) of the convolution kernel
%
%
%% Output arguments
%
% |res| - _SCALAR MATRIX_ - |res(x,y,z)| Intensity at voxel (x,y,z) of the image
%
% References
%
% [1] Knutsson, H. and Westin, C-F.: Normalized and differential convolution: Methods for Interpolation and Filtering of incomplete and uncertain data.Proc. of the IEEE Conf. on Computer Vision and Pattern Recognition, 1993, 515-523. 
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = norm_conv(a,k,c)

if(nargin<3)
    c = ones(size(a));
end

res = conv(a.*c,k,'same')./(conv(c,k,'same')+eps);
