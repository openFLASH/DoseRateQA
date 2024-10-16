%% Mutual_info
% Compute the mutual information metric between two images
%
%% Syntax
% |res = Mutual_info(im1,im2,handles)|
%
%
%% Description
% |res = Mutual_info(im1,im2,handles)| Compute the mutual information metric between two images
%
%
%% Input arguments
% |im1| - _STRING_ - Name of the first image in |handles.XXX| (where XXX is either 'images' of "mydata")
%
% |im2| - _STRING_ - Name of the second image in |handles.XXX| (where XXX is either 'images' of "mydata")
%
%
% |handles| - _STRUCTURE_ - REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images' of "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.roi_mode| _SCALAR_ - |handles.roi_mode=1| The metric is computed only for the image contained inside the ROI.|handles.roi_mode=0| The metric is computed for the whole image.
% * |handles.current_roi{1}| - Index of the image in |handles.images.name| that should be used as the ROI
% * |handles.current_roi{2}| - Name of the image in  |handles.images.name| that should be used as the ROI
%
%
%% Output arguments
%
% |res| - _SCALAR_ - Mutual information metric between two images
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Mutual_info(im1,im2,handles)


for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im1))
        myIm1 = handles.mydata.data{i};
        myType1 = 4;
    end
    if(strcmp(handles.mydata.name{i},im2))
        myIm2 = handles.mydata.data{i};
        myType2 = 4;
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm1 = handles.images.data{i};
        myType1 = 1;
    end
    if(strcmp(handles.images.name{i},im2))
        myIm2 = handles.images.data{i};
        myType2 = 1;
    end
end
% If region of interest defined in REGGUI
use_roi_mode = 0;
if(handles.roi_mode==1 && myType1==1 && myType2==1)
    try
        if(strcmp(handles.images.name{handles.current_roi{2}},handles.current_roi{1}))
            use_roi_mode = handles.current_roi{2};
        else
            handles.roi_mode = 0;
            handles.current_roi = cell(0);
        end
    catch
        handles.roi_mode = 0;
        handles.current_roi = cell(0);
    end
end
try

    myIm1 = floor((myIm1-min(myIm1(:)))/(max(myIm1(:)+eps)-min(myIm1(:)))*255);
    myIm2 = floor((myIm2-min(myIm2(:)))/(max(myIm2(:)+eps)-min(myIm2(:)))*255);

    rows=size(myIm1,1);
    cols=size(myIm1,2);
    humm=size(myIm1,3);

    N=256;
    a=zeros(N,N);
    b=a;

    if(use_roi_mode)
        for i=1:rows; % col
            for j=1:cols; % rows
                for k=1:humm;
                    if(handles.images.data{use_roi_mode}(i,j,k))
                        a(myIm1(i,j,k)+1,myIm2(i,j,k)+1)= a(myIm1(i,j,k)+1,myIm2(i,j,k)+1)+1;
                    end
                end
            end
        end
    else
        for i=1:rows; % col
            for j=1:cols; % rows
                for k=1:humm;
                    a(myIm1(i,j,k)+1,myIm2(i,j,k)+1)= a(myIm1(i,j,k)+1,myIm2(i,j,k)+1)+1;
                end
            end
        end
    end

    a = a/rows/cols/humm;

    b= a./N^2; % normalized joint histogram
    y_marg=sum(b); %sum of the rows of normalized joint histogram
    x_marg=sum(b');%sum of columns of normalized joint histogran

    Hy=0;
    for i=1:N;    %col
        if( y_marg(i)==0 )
            %do nothing
        else
            Hy = Hy + -(y_marg(i)*(log(y_marg(i)))); %marginal entropy for image 1
        end
    end

    Hx=0;
    for i=1:N;    %rows
        if( x_marg(i)==0 )
            %do nothing
        else
            Hx = Hx + -(x_marg(i)*(log(x_marg(i)))); %marginal entropy for image 2
        end
    end
    h_xy = -sum(sum(b.*(log(b+(b==0))))); % joint entropy

    res = (Hx + Hy - h_xy)/max(Hx,Hy);

    if(use_roi_mode)
        disp(['Mutual information (on ROI) = ' num2str(res)])
    else
        disp(['Mutual information = ' num2str(res)])
    end

catch ME
    reggui_logger.info(['Error : images not found or uncorrect size. ',ME.message],handles.log_filename);
    rethrow(ME);
end
