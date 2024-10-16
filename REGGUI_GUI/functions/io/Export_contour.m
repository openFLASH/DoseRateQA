%% Export_contour
% Save anatomical contours into a DICOM file on disk. The anatomical contours are generated from the surface of binary masks stored in |handles|. Information about coordinate system are extracted from a CT scan (stored in |handles.images| or |handles.mydata|).
% Optionally, the contours can be smoothed before saving to remove 'stair effects'. If some data is missing, dialog box are displayed to ask the user to manually select the correct masks.
%
%% Syntax
% |handles = Export_contour(contours_names,ref_image_name,outname,handles)|
%
% |handles = Export_contour(contours_names,ref_image_name,outname,handles,smooth_contours)|
%
% |handles = Export_contour(contours_names,ref_image_name,outname,handles,smooth_contours,dicom_tags)|
%
% |handles = Export_contour(contours_names,ref_image_name,outname,handles,smooth_contours,dicom_tags,inname)|
%
%
%% Description
% |handles = Export_contour(contours_names,ref_image_name,outname,handles)| Save the RT struct with no smoothing of contours
%
% |handles = Export_contour(contours_names,ref_image_name,outname,handles,smooth_contours)| Save the RT struct with defined smoothing
%
% |handles = Export_contour(contours_names,ref_image_name,outname,handles,smooth_contours,dicom_tags)| Save the RT struct with defined smoothing and additional DICOM tags
%
% |handles = Export_contour(contours_names,ref_image_name,outname,handles,smooth_contours,dicom_tags,inname)| Save the RT struct by appending to new data to existing file using the defined smoothing and provided additional DICOM tags
%
% |handles = Export_contour(contours_names,ref_image_name,outname,handles,smooth_contours,dicom_tags,inname,new_contours_names)| Save the RT struct with names specified in new_contour_names
%
%% Input arguments
% |contours_names| - _CELL VECTOR of STRING_ - |contours_names{i}| Name of the i-th contours dataset stored in |handles.images| to be exported
%
% |ref_image_name| - _STRING_ -  Name of the CT scan (asociated to the contours) stored in |handles.images| or |handles.mydata|
%
% |outname| - _STRING_ -  Name 
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either "images" or "mydata"):
%
% * |handles.images.name{i}| - _STRING_ - Name of the i-th image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the i-th image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the i-th image
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
% * |handles.dataPath| - _STRING_ - Directory in which REGGUI is saving its data
% * |handles.auto_mode| - _INTEGER_ - 0 = auto mode is not active. 1 = auto mode is active
%
% |smooth_contours| - _INTEGER_ - [OPTIONAL. Default : 0] |0<=smooth_contours<=100|. Apply a gaussian filtering to the contour to remove remove 'stair effects'. |smooth_contours| is proportional to the sigma of the Gaussian. Set |smooth_contours=0| not to apply any smoothing.
%
% |dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the RT struct file 
%
% * |dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |dicom_tags{i,2}| - _ANY_ Value of the tag
%
% |inname| - _STRING_ - [OPTIONAL] Name of the file of DICOM RT-struct to which the new contours will be appended. If absent, a new file is created.
%
% |new_contours_names| - _CELL VECTOR of STRING_ - |new_contours_names{i}| Replaces the name of i-th contour to be exported
%
%% Output arguments
%
% |res = handles| - _STRUCTURE_ -  REGGUI data structure. No change to the input.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Export_contour(contours_names,ref_image_name,outname,handles,smooth_contours,dicom_tags,inname,new_contours_names,format)

% default parameters
if(nargin<5)
    smooth_contours = [];
end
if(nargin<6)
    dicom_tags = {};
end
if(nargin<7)
    inname = '';
end
if(nargin<8)
    new_contours_names = {};
end
if(nargin<9)
    format = 'dcm';
end
if(isempty(smooth_contours))
    if(~handles.auto_mode)
        smooth_contours = are_you_physician();
    else
        smooth_contours = 0;
    end
end

% current time
Date = datestr(now,'yyyymmdd');
Time = datestr(now,'HHMMSS');

% get contour masks
selection = [];
for n=1:length(contours_names)
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},contours_names(n)) && ~isempty(handles.images.data{i}))
            selection = [selection,i];
        end
    end
end
imageChoiceIsOK = 0;
while(~imageChoiceIsOK)
    type1 = 0;
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},ref_image_name))
            infoImage = handles.mydata.info{i};
            type1 = 3;
        end
    end
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},ref_image_name))
            infoImage = handles.images.info{i};
            type1 = 1;
        end
    end    
    try
        imageChoiceIsOK=not( (length(infoImage.SOPInstanceUID)~=handles.size(3)) || isempty(infoImage.FrameOfReferenceUID));
    catch
        imageChoiceIsOK=0;
    end    
    if(not(imageChoiceIsOK))
        if(handles.auto_mode)
            Choice = 'Yes';
        else
            Choice = questdlg('All slices of the reference image must be in correct dicomformat in order to export rtstructs. Do you want to export the image as dicom serie first?', ...
                'Choose', ...
                'Yes','Choose another image','Cancel','Yes');
        end
        if(strcmp(Choice,'Cancel'))
            return
        elseif(strcmp(Choice,'Choose another image'))
            [ref_image_name,type1] = Image_list(handles,'To which image do you want the contours header to correspond ?',1);
            if (type1~=1&&type1~=3)
                error('Wrong type of data!');
            end
        elseif(strcmp(Choice,'Yes'))
            try
                [outP,outF] = fileparts(outname);
            catch
                outP = handles.dataPath;
                outF = 'rtstruct';
            end
            if(type1==1)
                for i=1:length(handles.images.name)
                    if(strcmp(handles.images.name{i},ref_image_name))
                        image = handles.images.data{i};
                        imageNumber = i;
                    end
                end
                default_name = cell(0);
                default_name{1} = [outP,'/reggui_',ref_image_name];
                if(handles.auto_mode)
                    outname1 = default_name{1};
                else
                    try
                        outname1 = char(inputdlg({'Choose a name to export (without file extension)'},' ',1,default_name));
                    catch
                        error('Wrong name!');
                    end
                end
                disp(['Exporting reference image in ',outname1])
                handles = Export_image(ref_image_name,outname1,'dcm',handles);
                infoImage = handles.images.info{imageNumber};
                outname = [outname1,'/',outF];
                if(not(isfield(infoImage,'OriginalHeader')))
                    infoImage.OriginalHeader = infoImage;
                    infoImage.OriginalHeader.StudyDescription = 'REGGUI simulation';
                    infoImage.OriginalHeader.StudyDate = Date;
                    infoImage.OriginalHeader.StudyTime = Time;
                end
                handles.images.info{imageNumber} = infoImage;
                imageChoiceIsOK=1;
            elseif(type1==3)
                for i=1:length(handles.mydata.name)
                    if(strcmp(handles.mydata.name{i},ref_image_name))
                        image = handles.mydata.data{i};
                        imageNumber = i;
                    end
                end
                default_name = cell(0);
                default_name{1} = [outP,'/reggui_',ref_image_name];
                if(handles.auto_mode)
                    outname1 = default_name{1};
                else
                    try
                        outname1 = char(inputdlg({'Choose a name to export (without file extension)'},' ',1,default_name));
                    catch
                        error('Wrong name!');
                    end
                end
                disp(['Exporting reference image in ',outname1])
                infoImage = Export_image(ref_image_name,outname1,'dcm',handles);
                outname = [outname1,'/',outF];
                if(not(isfield(infoImage,'OriginalHeader')))
                    infoImage.OriginalHeader = infoImage;
                    infoImage.OriginalHeader.StudyDescription = 'REGGUI simulation';
                    infoImage.OriginalHeader.StudyDate = Date;
                    infoImage.OriginalHeader.StudyTime = Time;
                else
                    infoImage.SeriesInstanceUID = infoImage.OriginalHeader.SeriesInstanceUID;
                end
                handles.mydata.info{imageNumber} = infoImage;
                imageChoiceIsOK=1;
            end
        end
    end
end

Save_Contour(selection,infoImage,outname,handles,smooth_contours,dicom_tags,inname,new_contours_names,format);
