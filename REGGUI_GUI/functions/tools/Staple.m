%% Staple
% Staple function is based on ITK implementation.
% The function implements the Simultaneous Truth and Performance Level Estimation algorithm for generating ground truth volumes from a set of binary expert segmentations. The  algorithm  considers a  collection  of  segmentations  and computes a probabilistic estimate of the hidden, implicit, true segmentation and a measure of the performance  level  achieved  by  each  segmentation. 
%
%% Syntax
% |handles = Staple(segmentationNames,outname,handles)|
%
% |handles = Staple(segmentationNames,outname,handles,datatype)|
%
%
%% Description
% |handles = Staple(segmentationNames,outname,handles)| Compute the probaility of the true segmentation using default datatype
%
% |handles = Staple(segmentationNames,outname,handles,datatype)| Compute the probaility of the true segmentation using the specified datatype
%
%% Input arguments
% |segmentationNames| - _CELL VECTOR_ -  |segmentationNames{i}| Name of the i-th training segmentation image stored in |handles.XXX| (where XXX is either "images" or "mydata" depending on |datatype|)
%
% |outname| - _STRING_ -  Name of the new image created in |handles.XXX| (where XXX is either "images" or "mydata" depending on |datatype|)
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either "images" or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.size| - _SCALAR VECTOR_ Dimension (x,y,z) (in pixels) of the image in GUI
%
% |datatype| - _INTEGER_ - [OPTIONAL. Defaul = 1] Define where the data is located:
%
% * |datatype =1| : data is in |handles.images|
% * |datatype =2|  : data is in |handles.mydata|
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated in the destimation image |i| (where XXX is either "images" or "mydata" depending on |datatype|):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the new image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Default information structure
%
%% References
% [1] http://crl.med.harvard.edu/software/TutorialIntroductionToSTAPLE.pdf
% [2] https://itk.org/Doxygen/html/classitk_1_1STAPLEImageFilter.html
% 
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Staple(segmentationNames,outname,handles,datatype)

if nargin<4
    datatype = 1;
    disp('As no datatype was selected, default type ''image'' was chosen');
end

if datatype ==1
    seg = zeros(length(segmentationNames),handles.size(1),handles.size(2),handles.size(3),'single');
    for j =1:length(segmentationNames)
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},segmentationNames{j}))
                seg(j,:,:,:) = handles.images.data{i};
            end
        end
    end
else
    for j =1:length(segmentationNames)
        for i=1:length(handles.mydata.name)
            if(strcmp(handles.mydata.name{i},segmentationNames{j}))
                try
                    seg(j,:,:,:) = handles.mydata.data{i};
                catch
                    disp('The segmentation types do not seem coherent')
                end
            end
        end
    end
end

maxNumberIterations = 20;
minRMSError = 1e-10;
number_of_seg = length(segmentationNames);

%create sensitivity and specificity
p = zeros(number_of_seg,1);
q = zeros(number_of_seg,1);

last_p = -10*ones(number_of_seg,1);
last_q = -10*ones(number_of_seg,1);

%confidence_weight = 1.0;

temp_seg = mean(seg,1);
gamma = mean(seg(:));

for iter = 1:maxNumberIterations
    % Now iterate on estimating specificity and sensitivity 
    
    p_denom = sum(temp_seg(:));
    q_denom = sum(1-temp_seg(:));
    
    a1 = ones(size(temp_seg));
    b1 = ones(size(temp_seg));
    
    for i = 1:number_of_seg
        p(i) = sum(temp_seg(logical(seg(i,:)>=0.5)))/p_denom;
        q(i)= sum(1-temp_seg(logical(seg(i,:)<0.5)))/q_denom;
        
        a1(logical(seg(i,:)>=0.5)) = a1(logical(seg(i,:)>=0.5))*p(i);
        b1(logical(seg(i,:)>=0.5)) = b1(logical(seg(i,:)>=0.5))*(1-q(i));
        
        a1(logical(seg(i,:)<0.5)) = a1(logical(seg(i,:)<0.5))*(1-p(i));
        b1(logical(seg(i,:)<0.5)) = b1(logical(seg(i,:)<0.5))*q(i);
        
    end
    temp_seg = gamma*a1./ (gamma*a1+(1-gamma)*b1);
    convergence_flag = true;
    
    if find(((p-last_p).*(p-last_p)) > minRMSError)
        convergence_flag = false;
    end
    if find(((q-last_q).*(q-last_q)) > minRMSError)
        convergence_flag = false;
    end
        
    if convergence_flag
        break
    end
    
    last_p = p;
    last_q = q;
end

if(datatype==1)
    outname = check_existing_names(outname,handles.images.name);
    handles.images.name{length(handles.images.name)+1} = outname;
    handles.images.data{length(handles.images.data)+1} = squeeze(temp_seg);
    handles.images.info{length(handles.images.info)+1} = Create_default_info('image',handles);
else
    outname = check_existing_names(outname,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = outname;
    handles.mydata.data{length(handles.mydata.data)+1} = squeeze(temp_seg);
    handles.mydata.info{length(handles.mydata.info)+1} = Create_default_info('image',handles);
end
