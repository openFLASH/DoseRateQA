%% get_image_scale
% Find the pixel intensity corresponding to the lower and higher percentile of the intensity histogram of an image.
% If several images are provided, the smallest / highest value of the percentile intensity for the list of image is returned.
% If minimum and maximum scales are provided, then the smalles / highest percentile value are capped by the scale
%
%% Syntax
% |[min_scale,max_scale] = get_image_scale(Image_list)|
%
% |[min_scale,max_scale] = get_image_scale(Image_list,prctile)|
%
% |[min_scale,max_scale,modif] = get_image_scale(Image_list,prctile,min_scale,max_scale)|
%
%
%% Description
% |[min_scale,max_scale,modif] = get_image_scale(Image_list)| Return the minimum and maximum pixel intensity for the whole list of images
%
% |[min_scale,max_scale,modif] = get_image_scale(Image_list,prctile)| Return the intensity corresponding to the lower and higher percentile of the intensity historgram
%
% |[min_scale,max_scale,modif] = get_image_scale(Image_list,prctile,min_scale,max_scale)| Return the intensity corresponding to the lower and higher percentile of the intensity historgram or the minimum / maximum scale intensity if the percentile is outside ofthe scale range.
%
%
%% Input arguments
% |Image_list| - _CELL VECTOR of SCALAR MATRIX_ - |Image_list{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
%
% |prctile| - _SCALAR_ -  Percentile at which the histogram is cut (0 <= prctile < 100). If prctile = 0, then the minimum and maximum intensity for the whole image list are returned
%
% |min_scale| - _SCALAR_ - Lowest boundary of the intensity scale. If the percentile is lower than this value, then the function return |min_scale| instead
%
% |max_scale| - _SCALAR_ - Higher boundary of the intensity scale. If the percentile is higher than this value, then the function return |max_scale| instead
%
%
%% Output arguments
%
% |min_scale| - _SCALAR_ - Pixel intensity of the lower percentile. The smallest value for the image list is returned. 
%
% |max_scale| - _SCALAR_ - Pixel intensity of the higher percentile. The largest value for the image list is returned.
%
% |modif| - _BOOL_ - If |min_scale| or |max_scale| were provided in input and have been modified, |modif=0|. |modif=0|otherwise
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [min_scale,max_scale,modif] = get_image_scale(Image_list,prctile,min_scale,max_scale)

if(nargin<2)
    prctile = 0;
end
if(nargin<3)
    min_scale = Inf;
    max_scale = -Inf;
end

if(nargout>2)
    min_scale_orig = min_scale;
    max_scale_orig = max_scale;
end

if(isempty(min_scale))
    min_scale = Inf;
end
if(isempty(max_scale))
    max_scale = -Inf;
end

for i=1:length(Image_list)
    if(not(isempty(Image_list{i})))
        if(prctile>0)
            im_sorted = sort(Image_list{i}(:));
            try
                min_scale = min(min_scale,im_sorted(ceil(prctile/100*length(im_sorted))));
                max_scale = max(max_scale,im_sorted(floor((1-prctile/100)*length(im_sorted))));
            catch
                min_scale = min(min_scale,min(Image_list{i}(:)));
                max_scale = max(max_scale,max(Image_list{i}(:)));
            end
        else
            min_scale = min(min_scale,min(Image_list{i}(:)));
            max_scale = max(max_scale,max(Image_list{i}(:)));
        end
    end
end

if(isinf(min_scale))
    min_scale = 0;
end
if(max_scale <= min_scale)
    max_scale = min_scale + 1e-6;
end

if(nargout>2)
    if((min_scale_orig==min_scale)&&(max_scale_orig==max_scale))
        modif = 0;
    else
        modif = 1;
    end
end
