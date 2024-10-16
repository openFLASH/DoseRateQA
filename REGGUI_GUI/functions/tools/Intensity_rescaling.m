%% Intensity_rescaling
% Linearly rescale the intensity of an image either using the scaling information in the DICOM header or by using a defined minimum and maximum intensity
%
%% Syntax
% |handles = Intensity_rescaling(im1,handles,params)|
%
% |handles = Intensity_rescaling(im1,handles,params)|
%
%
%% Description
% |handles = Intensity_rescaling(im1,handles)| Rescale the image intensity using the information of the DICOM header
%
% |handles = Intensity_rescaling(im1,handles,params)| Rescale the image intensity using provided minimum and maximum intensity
%
%
%% Input arguments
% |im1| - _STRING_ -  Name of the image in |handles.images| or |handles.mydata| to be processed
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images'or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * ----|handles.mydata.info.rescaled| - _INTEGER_ - 1 = the image will be rescaled using the DICOM information. If tag is absent or 0, image is rescaled using |params|
% * ----|handles.mydata.info.OriginalHeader.Modality| - _STRING_ - 'PT' = the PET image is rescaled with the |RescaleSlope| and |RescaleIntercept| defined in hader. 'DOSE' = the image is rescaled using the |DoseGridScaling| defined in header and the output is in mGy units.
%* ----|handles.mydata.info.OriginalHeader.RescaleSlope| - _SCALAR_ - Slope for rescaling PET images
%* ----|handles.mydata.info.OriginalHeader.RescaleIntercept| - _SCALAR_ - Intercep for rescaling PET images
%* ----|handles.mydata.info.OriginalHeader.DoseGridScaling| - _SCALAR_ Slope for rescaling DOSE images (in Gy)
% 
%
% |params| - _SCALAR VECTOR_ - [OPTIONAL. Used only is |myInfo.OriginalHeader.rescaled| is not =1] |params=[min,max]| Minimum and maximum intensity of the linearly rescaled intensity
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data will be updated (where XXX is either 'images'or "mydata"; depending on where the input data is located):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the resulting image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| resulting intensity at voxel (x,y,z)
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Created with Create_default_info.m
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Intensity_rescaling(im1,handles,params)


for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},im1))
        myIm = handles.mydata.data{i};
        myInfo = handles.mydata.info{i};
        myDataSet = [4,i];
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm = handles.images.data{i};
        myInfo = handles.images.info{i};
        myDataSet = [1,i];
    end
end
rescale_image = 0;
if(isfield(myInfo,'OriginalHeader'))
    if(isfield(myInfo.OriginalHeader,'Modality'))
        if(isfield(myInfo,'rescaled'))
            if(not(myInfo.rescaled))
                rescale_image = 1;
            end
        else
            rescale_image = 1;
        end
    end
end
if(nargin>2)
    myInfo.rescaled = 2;
end
if(rescale_image==1)
    switch myInfo.OriginalHeader.Modality
        case 'PT'
            disp(['Rescale PET image with : ', num2str(myInfo.OriginalHeader.RescaleSlope),' and ',num2str(myInfo.OriginalHeader.RescaleIntercept)]);
            myIm = (myIm .* myInfo.OriginalHeader.RescaleSlope) + myInfo.OriginalHeader.RescaleIntercept;
        case 'DOSE'
            myIm = myIm .* myInfo.OriginalHeader.DoseGridScaling*1e3;% Put the dose in mGy
        otherwise
            return
    end
    myInfo.rescaled = 1;
    switch myDataSet(1)
        case 1
            handles.images.data{myDataSet(2)}=myIm;
            handles.images.info{myDataSet(2)}=myInfo;
        case 4
            handles.mydata.data{myDataSet(2)}=myIm;
            handles.mydata.info{myDataSet(2)}=myInfo;
    end
elseif(rescale_image==2)
    myIm = myIm - min(min(min( myIm)));
    myIm = myIm / max(max(max( myIm )));
    myIm = myIm .* (params(2)-params(1)) + params(1);
    myInfo.rescaled = 1;
    switch myDataSet(1)
        case 1
            handles.images.data{myDataSet(2)}=myIm;
            handles.images.info{myDataSet(2)}=myInfo;
        case 4
            handles.mydata.data{myDataSet(2)}=myIm;
            handles.mydata.info{myDataSet(2)}=myInfo;
    end
end
