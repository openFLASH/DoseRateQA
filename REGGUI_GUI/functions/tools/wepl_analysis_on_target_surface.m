%% wepl_analysis_on_target_surface
% Compute the Water Equivalent Path Length error |WET_pCT - WET_vCT| between the nominal WEPL map |WET_vCT| and the WEPL map of the day |WET_pCT|. The results are two maps. The non zero values of the over-range (resp. under-range) map indicate positive (resp. negative) range errors (mm). For the under-range map, a dilation filter can be applied on |WET_pCT| to reduce the sharp WEPL gradient on the edges of the structure. 
%
%% Syntax
% |[res,WET_underranges] = wepl_analysis_on_target_surface(WET_pCT,WET_vCT)|
%
% |[res,WET_underranges] = wepl_analysis_on_target_surface(WET_pCT,WET_vCT,smearing_size)|
%
% |[res,WET_underranges] = wepl_analysis_on_target_surface(WET_pCT,WET_vCT,smearing_size,visu)|
%
%
%% Description
% |[res,WET_underranges] = wepl_analysis_on_target_surface(WET_pCT,WET_vCT)|
%
% |[res,WET_underranges] = wepl_analysis_on_target_surface(WET_pCT,WET_vCT,smearing_size)|
%
% |[res,WET_underranges] = wepl_analysis_on_target_surface(WET_pCT,WET_vCT,smearing_size,visu)|
%
%
%% Input arguments
% |WET_pCT| - _SCALAR MATRIX_ -  |WET_pCT(x,y)| WEPL (mm) to the voxel (x,y) of the planning CT
%
% |WET_vCT| - _SCALAR MATRIX_ -  |WET_pCT(x,y)| WEPL (mm) to the voxel (x,y) of the repeat CT or virtual CT. It must be in the same coordinate space as |WET_pCT|
%
% |smearing_size| - _TYPE_ -  Radius of the disk structuring element used for the dilation of the |WET_pCT|
%
% |visu| - _INTEGER_ - Flag to display or not the results. 1 = display plots. 0 = do not display plots
%
%
%% Output arguments
%
% |res| - _SCALAR MATRIX_ -  Over range map. |res(x,y)| WEPL (mm) indicate the magnitude of the over-range that will occur at voxel (x,y). If under-range occurs, then the value is 0.
%
% |WET_underranges| - _SCALAR MATRIX_ -  Over range map. |res(x,y)| WEPL (mm) indicate the magnitude of the under-range that will occur at voxel (x,y). If over-range occurs, then the value is 0.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [res,WET_underranges] = wepl_analysis_on_target_surface(WET_pCT,WET_vCT,smearing_size,visu)

% Authors : G.Janssens

current_dir = pwd;

% ------------------
% Default parameters
% ------------------

if(nargin<3)
    smearing_size = 0;
elseif(isempty(smearing_size))
    smearing_size = 0;
end

if(nargin<4)
    visu = 0;
end

% -----------------------------
% Over/under-ranges computation
% -----------------------------

WET_diff = WET_pCT - WET_vCT;

WET_temp = WET_pCT;
WET_temp(isnan(WET_pCT)) = min(WET_pCT(:));
if(smearing_size>0)
    s = strel('disk',smearing_size);
    WET_pCT_dilated = imdilate(WET_temp,s);
    WET_pCT_dilated(isnan(WET_pCT)) = NaN;
else
    WET_pCT_dilated = WET_temp;
end

WET_underranges = WET_pCT_dilated - WET_vCT;
WET_underranges(WET_underranges>0) = 0;
WET_underranges(isnan(WET_pCT)) = NaN;

WET_overranges = WET_diff;
WET_overranges(WET_overranges<0) = 0;
WET_overranges(isnan(WET_pCT)) = NaN;

res = WET_overranges;

% display ---------------------------

if(visu)
       
    roi = not(isnan(WET_pCT));
    [i,j] = find(roi);
    bx = [min(i),max(i)];
    by = [min(j),max(j)];    
       
    figure   
    colormap1 = colormap('jet');
    colormap1(1,:) = [1,1,1];
    colormap2 = [[1,1,1];[linspace(0,1,50)';ones(50,1)]*0.95,sqrt([linspace(0,1,40)';ones(20,1);linspace(1,0,40)'])*0.95,[ones(50,1);linspace(1,0,50)']*0.95];
    min_scale = min(min(WET_pCT(:)),min(WET_vCT(:)));
    max_scale = max(max(WET_pCT(:)),max(WET_vCT(:)));
    min_scale = min_scale - (max_scale-min_scale)/size(colormap1,1);
    
    subplot(1,3,1);
    im = WET_pCT([bx(1):bx(2)],[by(1):by(2)]);
    im(isnan(im)) = min_scale;
    imshow(im,[min_scale max_scale]);colorbar;
    colormap(gca,colormap1);
    xlabel('WET from pCT')
    
    subplot(1,3,2);
    im = WET_vCT([bx(1):bx(2)],[by(1):by(2)]);
    im(isnan(im)) = min_scale;
    imshow(im,[min_scale max_scale]);colorbar;
    colormap(gca,colormap1);
    xlabel('WET from vCT')
    
    subplot(1,3,3);
    im = WET_underranges([bx(1):bx(2)],[by(1):by(2)]) + WET_overranges([bx(1):bx(2)],[by(1):by(2)]);
    im(isnan(im)) = min(im(:)) - (max(im(:))-min(im(:)))/100;
    imshow(im,[min(im(:)) max(im(:))]);colorbar;
    colormap(gca,colormap2);
    xlabel('over/under-ranges')
        
end

cd(current_dir)
