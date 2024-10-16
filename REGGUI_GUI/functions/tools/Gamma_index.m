%% Gamma_index
% Compute the gamma index between two images
%
%% Syntax
% |[handles,gamma,passing_rate] = Gamma_index(im0,im1,mask,im_dest,handles)|
%
% |[handles,gamma,passing_rate] = Gamma_index(im0,im1,mask,im_dest,handles,options)|
%
%
%% Description
% |handles = Gamma_index(im0,im1,mask,im_dest,handles)| Compute gamma index with default options
%
% |handles = Gamma_index(im0,im1,mask,im_dest,handles,options)| Compute gamma index with selected options
%
%
%% Input arguments
% |im0| - _STRING_ -  Name of the first image in |handles.images| or |handles.mydata| (if absent in |handles.images|) to be compared
%
% |im1| - _STRING_ -  Name of the second image in |handles.images| or |handles.mydata| (if absent in |handles.images|) to be compared
%
% |mask| - _STRING_ -  Name of the mask in |handles.images| or |handles.mydata| (if absent in |handles.images|). The gamma index computation takes place only for the pixels contained inside the mask
%
% |im_dest| - _STRING_ -  Name of the new image in |handles.images| or |handles.mydata| (same location as |im0|) where result will be stored
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |options| - _SCALAR VECTOR_ -  [OPTIONAL] dd DD (Default dd=1 DD=1)
%
% * |options(1)| - _SCALAR_ Distance tolerance in mm (Default = 1mm)
% * |options(2)| - _SCALAR_ Dose tolerance in % (Default = 1%)
% * |options(3)| - _INTEGER_ - [OPTIONAL] Number of points for "bad" dose interpolation (default = 5)
% * |options(4)| - _BOOLEAN_ - [OPTIONAL] specify whether local (0) or global (default) dose difference will be used
% * |options(5)| - _SCALAR_ - [OPTIONAL] specify a dose threshold (in % of the reference dose) under which the gamma is not computed
% * |options(6)| - _SCALAR_ - [OPTIONAL] specify a reference dose (e.g. prescription) to be used for global dose computation and thresholding instead of the max dose
%
% |method| - _STRING_ - [OPTIONAL] specify which method is to be used among '3D_fast' (default), '2D' (default for 2D input data) and '3D_slow'
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data will be updated (where XXX is either 'images' of "mydata"; depending on where the input data is located):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of gamma index map = |couch_name|
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Value of the gamma index for voxel (x,y,z)
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file.Created from Create_default_info.m
%
% |gamma| - _SCALAR MATRIX_ - |gamma(x,y,z)| Value of the gamma index for voxel (x,y,z). Ignored voxels are set to -1. gamma has the same voxel
% grid as im0
%
% |passing_rate| - _SCALAR VECTOR_ - passing rate over the whole calculation region and over each individual structure (optionnally) provided as input
%
%% Contributors
% Authors : J. Hubeau, G.Janssens
%
%% Reference
% [1] 1. Winiecki, J., Ś, T. M., Majewska, K. & Drzewiecka, B. The gamma evaluation method as a routine QA procedure of IMRT. REP Pr. ONCOL RADIOTHER 162–168 (2009). doi:10.1016/S1507-1367(10)60031-4

function [handles,gamma,passing_rate,average_gamma] = Gamma_index(im0,im1,mask,im_dest,handles,options,method)

% Default parameters
if(nargin<6)
    options = [];
end
if(nargin<7)
    method = '';
end
if(isnumeric(options))
    options_num = options;
    options = struct;
    if(length(options_num)>0)
        options.dd = options_num(1);
    else
        options.dd = 1;
    end
    if(length(options_num)>1)
        options.DD = options_num(2);
    else
        options.DD = 1;
    end
    if(length(options_num)>2)
        options.FI = options_num(3);
    else
        options.FI = 5;
    end
    if(length(options_num)>3)
        options.global_ref = options_num(4);
    else
        options.global_ref = 1;
    end
    if(length(options_num)>4)
        options.threshold = options_num(5);
    else
        options.threshold = 0;
    end
    if(length(options_num)>5)
        options.prescription = options_num(6);
    end
end

% Get input data
[myIm0,info0,type0] = Get_reggui_data(handles,im0);
[myIm1,info1] = Get_reggui_data(handles,im1);
if(not(isempty(mask)))
    if(not(iscell(mask)))
        mask = {mask};
    end
    myMask = zeros(size(myIm0));
    myMasks = {};
    for i=1:length(mask)
        [temp,temp_info] = Get_reggui_data(handles,mask{i});
        if(sum(size(myIm0)~=size(myMask)) || sum(round(info0.Spacing,4)~=round(temp_info.Spacing,4)))
            disp('Reference dose and mask must have the same size and spacing. Skip.');
            myMasks{i} = [];
        else
            myMask = (temp>=max(temp(:))/2) | myMask;
            myMasks{i} = single(temp>=max(temp(:))/2);
        end
    end
else
    myMask = [];
    myMasks = {};
end

if(isempty(myMask) || sum(myMask(:))==0)
    disp('Warning: mask empty, not found or not specified. Computing gamma on the non-zero reference dose region.');
    myMask = myIm0>0;
end
myMask = single(myMask);

% Select method by default if none specified
if(isempty(method))
    if(size(myIm0,3)==1)
        method = '2D';
    elseif(not(isfield(options,'FI')))
        method = '3D_slow';
    elseif(options.FI<0)
        method = '3D_slow';
    else
        method = '3D_fast';
    end
end

% Compute gamma with selected method
switch method
    case '2D' % direct method in 2D
        [gamma,myMask] = gamma_2D(myIm0,info0,myIm1,info1,myMask,options);
        
    case '3D_slow' % direct method in 3D (slow and memory-consuming)
        [gamma,myMask] = gamma_3D_slow(myIm0,info0,myIm1,info1,myMask,options);
        
    otherwise % optimized method
        [gamma,myMask] = gamma_3D_fast(myIm0,info0,myIm1,info1,myMask,options);
        
end

% convert output into single precision
gamma = single(gamma);

% add ouput image to the list
handles = Set_reggui_data(handles,im_dest,gamma,info0,type0,0);

% compute passing rate
passing_rate = length(gamma(gamma<1 & myMask>=0.5))/length(gamma(myMask>=0.5)); % global passing rate (union of masks + threshold)
average_gamma = mean(gamma(myMask>=0.5), 'omitnan'); % average gamma (union of masks + threshold)
disp(['Average gamma: ',num2str(round(average_gamma,2))])
disp(['General passing rate: ',num2str(round(passing_rate*100,2)),'%'])
for i=1:length(myMasks)
    if(not(isempty(myMasks{i})))
        myMasks{i} = myMasks{i}>=0.5 & myMask >=0.5; % take intersection of structure (myMasks{i}) and calculation region (myMask)
        if(sum(myMasks{i}(:)))
            passing_rate(i+1) = length(gamma(gamma<1 & myMasks{i}))/length(gamma(myMasks{i})); % passing rate in structure
            average_gamma(i+1) = mean(gamma(myMasks{i}>=0.5)); % average gamma in structure
            try
                disp(['Passing rate in ',mask{i},': ',num2str(round(passing_rate(i+1)*100,2)),'%']);
            catch
            end
        else
            disp(['Passing rate cannot be computed in ',mask{i},' (contour empty or out of the ROI)']);
            passing_rate(i+1) = NaN;
            average_gamma(i+1) = NaN;
        end
    else
        disp(['Passing rate cannot be computed in ',mask{i},' (empty contour)']);
        passing_rate(i+1) = NaN;
        average_gamma(i+1) = NaN;
    end
end
