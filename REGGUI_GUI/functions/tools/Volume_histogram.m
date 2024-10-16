%% Volume_histogram
% Computes the intensity historgram of an image: plot of the number of voxels (Y-axis) with a intensity (X-axis) contained whithin a range (bin). There are 1024 bins in the histogram.
% The mask_name |mask_name| defines the part of |image_name| that is included in the histogram computation. The voxels outside this mask_name are not included in the histogram computation.
%
%% Syntax
% |[res h_out] = Volume_histogram(image_name,mask_name,handles)| 
%
% |[res h_out] = Volume_histogram(image_name,mask_name,handles,interval)| 
%
% |[res h_out] = Volume_histogram(image_name,mask_name,handles,interval,fig_number,color)| 
%
% |[res h_out] = Volume_histogram(image_name,mask_name,handles,interval,fig_number,color,normalizeFlag)| 
%
%
%% Description
% |[res h_out] = Volume_histogram(image_name,mask_name,handles)| Computes the un-normalised intensity histogram of the image. The X-axis boundaries are the minimum and maximum intensity of the image. Display the histogram in figure 1 in red.
%
% |[res h_out] = Volume_histogram(image_name,mask_name,handles,interval)| Computes the un-normalised  intensity histogram of the image within the defined intensity |interval|. Display the histogram in figure 1  in red.
%
% |[res h_out] = Volume_histogram(image_name,mask_name,handles,interval,fig_number,color)| Computes the  un-normalised intensity histogram of the image within the defined intensity |interval|. 
%
% |[res h_out] = Volume_histogram(image_name,mask_name,handles,interval,fig_number,color,normalizeFlag)| Computes the intensity histogram of the image within the defined intensity |interval|. 
%
%
%% Input arguments
% |image_name| - _STRING_ - Name of the image in |handles.XXX| for distribution computation (where XXX is either 'images' of "mydata")
%
% |mask_name| - _STRING_ - Name of the mask_name defining the volume (i.e. segmentation mask_name)
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |interval| - _SCALAR VECTOR_ - [OPTIONAL] |interval = [min, max]| Lower and higher boundaries of the X-axis (intensity) of the histogram. If absent, then uses the minimum and maximum intensity of the image.
%
% |fig_number| - _INTEGER_ -  [OPTIONAL] Display the histogram in the specified figure. If |fig_number=0|, then no figure is displayed. By default, the figure 1 is diisplayed.
%
% |color| - _STRING_ -  Define the colour of the displayed histogram. Default is 'r'.
%
% |normalizeFlag| - _BOOLEAN_ - If true, then the histogram Y-axis is normalised between 0 and 100%
%
%
%% Output arguments
%
% |res| - _SCALAR VECTOR_ - Compute the statistical parameters of the image. |res = [min(im) max(im) mean(im) median(im) mean(abs(im)) compute_prctile(im,5) compute_prctile(im,95)]| : minimum and maximum intensity of the image, average, median, average absolute and percentiles 5 and 95.
%
% |h| - _SCALAR VECTOR_ - Intensity histogram |h(i)| is the number of voxel with an intensity contained in the ith intensity bin.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [res,h] = Volume_histogram(image_name,mask_name,handles,interval,fig_number,color,normalizeFlag,number_of_bins,smoothing)

% default parameters
if(nargin<4)
    interval = [];
end
if(nargin<5)
    fig_number = 1;
end
if(nargin<6)
    color = 'r';
end
if(nargin<7)
    normalizeFlag = 0;
end
if(nargin<8)
    number_of_bins = 100;
end
if(nargin<9)
    smoothing = 0;
end

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},image_name))
        im = handles.mydata.data{i};
    end
    if(strcmp(handles.mydata.name{i},mask_name))
        mask = handles.mydata.data{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image_name))
        im = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},mask_name))
        mask = handles.images.data{i};
    end
end
try    
    im = im(mask>=(max(mask(:))/2));
    if(isempty(interval))
        interval = [min(im),max(im)];
    end
    x = linspace(interval(1),interval(2),number_of_bins);
    h = hist(im,x); 
    if(normalizeFlag)
        h = h./(max(h))*100;
    end
    res = [min(im) max(im) mean(im) median(im) mean(abs(im)) compute_prctile(im,5) compute_prctile(im,95)];
    if(fig_number)
        if(smoothing>0)
            h = gauss_smoothing(h,smoothing).*single(h>0);
        end
        figure(fig_number)
        use_area = strfind(color,'_area');
        if(not(isempty(use_area)))
            color = strrep(color,'_area','');
            area(x,h,'FaceColor',color,'FaceAlpha',0.3,'EdgeColor','none');
        else
            plot(x,h,color,'LineWidth',2,'MarkerSize',1);
        end
    end
catch
    disp('Error!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
