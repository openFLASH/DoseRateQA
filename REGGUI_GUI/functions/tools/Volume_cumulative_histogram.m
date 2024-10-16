%% Volume_cumulative_histogram
% Computes the cumulative intensity historgram of an image: plot of the number of voxels (Y-axis) with a intensity (X-axis) smaller or equal to that of the range (bin). There are 1024 bins in the histogram.
% The mask |im2| defines the part of |im1| that is included in the histogram computation. The voxels outside this mask are not included in the histogram computation.
%
%% Syntax
% |[res h_out] = Volume_cumulative_histogram(im1,im2,handles)| 
%
% |[res h_out] = Volume_cumulative_histogram(im1,im2,handles,interval)| 
%
% |[res h_out] = Volume_cumulative_histogram(im1,im2,handles,interval,fig_number,color)| 
%
% |[res h_out] = Volume_cumulative_histogram(im1,im2,handles,interval,fig_number,color,normalizeFlag)| 
%
%
%% Description
% |[res h_out] = Volume_cumulative_histogram(im1,im2,handles)| Computes the un-normalised intensity cumulative histogram of the image. The X-axis boundaries are the minimum and maximum intensity of the image. Display the histogram in figure 1 in red.
%
% |[res h_out] = Volume_cumulative_histogram(im1,im2,handles,interval)| Computes the un-normalised  intensity cumulative histogram of the image within the defined intensity |interval|. Display the histogram in figure 1  in red.
%
% |[res h_out] = Volume_cumulative_histogram(im1,im2,handles,interval,fig_number,color)| Computes the  un-normalised intensity cumulative histogram of the image within the defined intensity |interval|. 
%
% |[res h_out] = Volume_cumulative_histogram(im1,im2,handles,interval,fig_number,color,normalizeFlag)| Computes the intensity cumulative histogram of the image within the defined intensity |interval|. 
%
%
%% Input arguments
% |im1| - _STRING_ - Name of the image image for distribution computation
%
% |im2| - _STRING_ - Name of the mask defining the volume (i.e. segmentation mask)
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
% |interval| - _SCALAR VECTOR_ - [OPTIONAL] |interval = [min, max]| Lower and higher boundaries of the X-axis (intensity) of the histogram. If absent, then uses the minimum and maximum intensity of the image.
%
% |fig_number| - _INTEGER_ -  [OPTIONAL] Display the cumulative histogram in the specified figure. If |fig_number=0|, then no figure is displayed. By default, the figure 1 is diisplayed.
%
% |color| - _STRING_ -  Define the colour of the displayed cumulative histogram. Default is 'r'.
%
% |normalizeFlag| - _BOOLEAN_ - If true, then the cumulative histogram Y-axis is normalised between 0 and 100%
%
%
%% Output arguments
%
% |res| - _SCALAR VECTOR_ - Compute the statistical parameters of the image. |res = [min(myIm1) max(myIm1) mean(myIm1) median(myIm1)]| : minimum and maximum intensity of the image, average intensity and median intensity of the image
%
% |h_out| - _SCALAR VECTOR_ - Intensity cumulative histogram |h_out(i)| is the number of voxel with an intensity less or equal to the ith inteisty bin.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [res h_out] = Volume_cumulative_histogram(im1,im2,handles,interval,fig_number,color,normalizeFlag)

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im1))
        myIm1 = handles.mydata.data{i};
    end
    if(strcmp(handles.mydata.name{i},im2))
        myIm2 = handles.mydata.data{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm1 = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},im2))
        myIm2 = handles.images.data{i};
    end
end
h_out = [];
try
    number_of_bins = 4096;
    add_begin = 0;
    add_end = 0;
    myIm1(find(myIm2<max(max(max(myIm2)))/2)) = NaN;
    if(nargin>3)
        if(not(isempty(interval)))
            bin_size = (interval(2)-interval(1))/number_of_bins;
            add_begin = floor((min(min(min(myIm1)))-interval(1))/bin_size);
            add_end = floor((interval(2)-max(max(max(myIm1))))/bin_size);
            number_of_bins = floor( (max(max(max(myIm1)))-min(min(min(myIm1)))) /bin_size);
            myIm1(find(myIm1<interval(1)))=NaN;
            myIm1(find(myIm1>interval(2)))=NaN;
            h_out = zeros(1,4096);
        else
            interval = [min(min(min(myIm1))),max(max(max(myIm1)))];
        end
    else
        interval = [min(min(min(myIm1))),max(max(max(myIm1)))];
    end
    myIm1 = reshape(myIm1,size(myIm1,1)*size(myIm1,2)*size(myIm1,3),1,1);
    myIm1 = myIm1(find(not(isnan(myIm1))));
    h = hist(myIm1,number_of_bins);
    h = h(end:-1:1);
    h = cumsum(h);
    h = h(end:-1:1);
    h = [ones(1,add_begin)*max(h),h,zeros(1,add_end)];
    myIm1(find(myIm1<1)) = 1;%for gedu computation
    geud = (mean(myIm1.^(-10)))^(-1/10);
    if(nargin<5)
        fig_number = 1;
    end
    if(nargin<6)
        color = 'r';
    end
    if(nargin<7)
        normalizeFlag = 0;
    end
    if(normalizeFlag)
        h = h./(max(h))*100;
    end
    res = [min(myIm1) max(myIm1) mean(myIm1) median(myIm1) geud];
    if(fig_number)
        figure(fig_number)
        plot(linspace(interval(1),interval(2),length(h)),h,color,'LineWidth',2,'MarkerSize',1);
        if(isempty(h_out) && round(interval(1))>0)
            h_out = zeros([1,interval(2)+1])+100;
            h_out(1,[round(interval(1)):end]) = h(1,round(linspace(1,4096,length(h_out)-round(interval(1))+1))');
        else
            h_out = h;
        end
    end
catch
    disp('Error!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
