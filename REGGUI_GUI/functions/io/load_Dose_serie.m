%% load_Dose_serie
% Load all the DICOM files (representing dose maps) contained in the specified folder in order to create a 3D dose map |myMat|. The function uses the DICOM information contained in the files to sort the slices in the correct order in |myMat|. If there are missing files in the folder (= missing slices in the dose map), the function will interpolate the missing slices.
%
%% Syntax
% |[myMat,myInfo] = load_Dose_serie(dicom_filename = FILE)|
%
% |[myMat,myInfo] = load_Dose_serie(dicom_filename = FOLDER)|
%
%
%% Description
% |[myMat,myInfo] = load_Dose_serie(dicom_filename = FILE)| Load all the files contained in the same folder as file |dicom_filename|.
%
% |[myMat,myInfo] = load_Dose_serie(dicom_filename = FOLDER)| Load all the files contained in the folder |dicom_filename|.
%
%
%% Input arguments
% |dicom_filename| - _STRING_ - Name of one of the file contained in the folder. Alternatively, it can also be the name of the folder.
%
%
%% Output arguments
%
% |myMat| - _SCALAR MATRIX_ - |myMat(x,y,z)| Dose (in Gy) at voxel (x,y,z).
%
% |myInfo| - _STRUCTURE_ -  Description
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [myMat,myInfo] = load_Dose_serie(dicom_filename)

myMat = [];

Current_dir = pwd;

[myDir,my_Image,ext] = fileparts(dicom_filename);

disp(['Loading Dose serie (',dicom_filename,')'])

sel_info = struct;
try
    sel_info = dicominfo(fullfile(myDir,my_Image));
catch
    disp('Selected file is not a DICOM file... try to find a dicom serie in the selected repository')
end

if(isempty(ext) && isdir(dicom_filename))
    myDir = dicom_filename;
end
if(strcmp(myDir(end),'/'))
    myDir = myDir(1:end-1);
end

if(strcmp(ext,'.dcm'))
    myFiles = dir_without_hidden([myDir '/*.dcm']);
else
    myFiles = dir_without_hidden([myDir '/*']);
end

if size(myFiles,1) == 0
    myFiles = dir_without_hidden(myDir);
end

try
    if(not(isfield(sel_info,'SeriesInstanceUID')))
        %     sel_info = dicominfo(fullfile(myDir,myFiles(1).name));
        sel_info = dicominfo(fullfile(myDir,myFiles(floor(length(myFiles)/2)).name));
    end
catch
    disp('Matlab is not able to read selected dicom info.')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end

numberOfSlices = length(myFiles);
SliceLocationSorted = [1:numberOfSlices;zeros(1,numberOfSlices)]';
SliceLocation = SliceLocationSorted;
try_numbering = 0;
try_slicelocation = 0;
try_translationvector = 0;
try_index = 0;
SOP = struct;
disp_warning_no_SOPInstanceUID = 0;


% Check for dicom files

% Try to sort dicom files using image position patient
try
    numberOfExcluded = 0;
    if(ispc)
        myDirName = strrep(myDir,'\','\\');
    else
        myDirName = myDir;
    end
    dicom_waitbar = waitbar(0,{'Checking Dicom Files (Position, UIDs, ...)';' ';['in ',strrep(myDirName,'_','\_')]});
    for slices = 1:numberOfSlices
        %disp(['checking file: ',fullfile(myDir,myFiles(slices).name)])
        try
            UnsortedDICOMHeader=dicominfo(fullfile(myDir,myFiles(slices).name));
            % check UIDs
            if (~strcmp(UnsortedDICOMHeader.SeriesInstanceUID,sel_info.SeriesInstanceUID) || ...
                    ~strcmp(UnsortedDICOMHeader.StudyInstanceUID,sel_info.StudyInstanceUID) || ...
                    ~strcmp(UnsortedDICOMHeader.SOPClassUID,sel_info.SOPClassUID) )
                disp(['File ',myFiles(slices).name,' has not the same UIDs! Skip...']);
                numberOfExcluded = numberOfExcluded + 1;
            elseif ~isDoseOrDoseRate(UnsortedDICOMHeader.Modality)
               %(~strcmp(UnsortedDICOMHeader.Modality,'RTDOSE'))
                disp(['File ',myFiles(slices).name,' is not from RTDOSE modality! Skip...']);
                numberOfExcluded = numberOfExcluded + 1;
            else
                SliceLocation(slices-numberOfExcluded,:)=[slices,UnsortedDICOMHeader.ImagePositionPatient(3)];
                try
                    SOP(slices).SOPInstanceUID = UnsortedDICOMHeader.SOPInstanceUID;
                catch
                    disp_warning_no_SOPInstanceUID = true;
                end
            end
        catch
            disp(['File ',myFiles(slices).name,' is not in DICOM format! Skip...']);
            numberOfExcluded = numberOfExcluded + 1;
        end
        waitbar(slices/numberOfSlices,dicom_waitbar);
    end
    close(dicom_waitbar)
    numberOfSlices=numberOfSlices-numberOfExcluded;
    SliceLocation = SliceLocation(1:numberOfSlices,:);
    SliceLocationSorted = SliceLocationSorted(1:numberOfSlices,:);

    if(length(unique(SliceLocation(:,2)))==size(SliceLocation,1))
        disp('Sorting dicom files according to patient position...')
        SliceLocationSorted(:,:)=sortrows(SliceLocation,2);
        if(disp_warning_no_SOPInstanceUID)
            disp('Warning: The dicom header does not contain SOPInstanceUIDs. It will not be possible to write appropriate DICOM_RTStructs based on this image.')
        else
            SOP = SOP(SliceLocationSorted(:,1));
        end
    else
        try_slicelocation = 1;
    end
catch
    disp('failed to sort according to patient position')
    close(dicom_waitbar)
    try_slicelocation = 1;
end

% Try to sort dicom files using slice location
if try_slicelocation
    numberOfSlices = length(myFiles);
    numberOfExcluded = 0;
    dicom_waitbar = waitbar(0,{'Checking Dicom Files (Slice location, UIDs, ...)';' ';['in ',strrep(myDirName,'_','\_')]});
    try
        for slices = 1:numberOfSlices
            try
                UnsortedDICOMHeader=dicominfo(fullfile(myDir,myFiles(slices).name));
                % check UIDs
                if (~strcmp(UnsortedDICOMHeader.SeriesInstanceUID,sel_info.SeriesInstanceUID) || ...
                        ~strcmp(UnsortedDICOMHeader.StudyInstanceUID,sel_info.StudyInstanceUID) || ...
                        ~strcmp(UnsortedDICOMHeader.SOPClassUID,sel_info.SOPClassUID) )
                    disp(['File ',myFiles(slices).name,' has not the same UIDs! Skip...']);
                    numberOfExcluded = numberOfExcluded + 1;
                else
                    SliceLocation(slices-numberOfExcluded,:)=[slices,UnsortedDICOMHeader.SliceLocation];
                    try
                        SOP(slices).SOPInstanceUID = UnsortedDICOMHeader.SOPInstanceUID;
                    catch
                        disp_warning_no_SOPInstanceUID = true;
                    end
                end
            catch
                disp(['File ',myFiles(slices).name,' is not in DICOM format! Skip...']);
                numberOfExcluded = numberOfExcluded + 1;
            end
            waitbar(slices/numberOfSlices,dicom_waitbar);
        end
        close(dicom_waitbar)
        numberOfSlices=numberOfSlices-numberOfExcluded;
        SliceLocation = SliceLocation(1:numberOfSlices,:);
        SliceLocationSorted = SliceLocationSorted(1:numberOfSlices,:);

        if(length(unique(SliceLocation(:,2)))==size(SliceLocation,1))
            disp('Sorting dicom files according to slice location...')
            SliceLocationSorted(:,:)=sortrows(SliceLocation,2);
            if (disp_warning_no_SOPInstanceUID)
                disp('Warning: The dicom header does not contain SOPInstanceUIDs. It will not be possible to write appropriate DICOM_RTStructs based on this image.')
            else
                SOP = SOP(SliceLocationSorted(:,1));
            end
        else
            try_index = 1;
        end
    catch
        disp('failed to sort according to slice location')
        close(dicom_waitbar)
        try_index = 1;
    end
end

% If previous failed, try to sort dicom files using image index
if try_index
    numberOfSlices = length(myFiles);
    numberOfExcluded = 0;
    dicom_waitbar = waitbar(0,{'Checking Dicom Files (Image index, UIDs, ...)';' ';['in ',strrep(myDirName,'_','\_')]});
    try
        for slices = 1:numberOfSlices
            try
                UnsortedDICOMHeader=dicominfo(fullfile(myDir,myFiles(slices).name));
                % check UIDs
                if (~strcmp(UnsortedDICOMHeader.SeriesInstanceUID,sel_info.SeriesInstanceUID) || ...
                        ~strcmp(UnsortedDICOMHeader.StudyInstanceUID,sel_info.StudyInstanceUID) || ...
                        ~strcmp(UnsortedDICOMHeader.SOPClassUID,sel_info.SOPClassUID) )
                    disp(['File ',myFiles(slices).name,' has not the same UIDs! Skip...']);
                    numberOfExcluded = numberOfExcluded + 1;
                else
                    SliceLocation(slices-numberOfExcluded,:)=[slices,UnsortedDICOMHeader.ImageIndex];
                    try
                        SOP(slices).SOPInstanceUID = UnsortedDICOMHeader.SOPInstanceUID;
                    catch
                        disp_warning_no_SOPInstanceUID = true;
                    end
                end
            catch
                disp(['File ',myFiles(slices).name,' is not in DICOM format! Skip...']);
                numberOfExcluded = numberOfExcluded + 1;
            end
            waitbar(slices/numberOfSlices,dicom_waitbar);
        end
        close(dicom_waitbar)
        numberOfSlices=numberOfSlices-numberOfExcluded;
        SliceLocation = SliceLocation(1:numberOfSlices,:);
        SliceLocationSorted = SliceLocationSorted(1:numberOfSlices,:);
        if(length(unique(SliceLocation(:,2)))==size(SliceLocation,1))
            disp('Sorting dicom files according to image index...')
            SliceLocationSorted(:,:)=sortrows(SliceLocation,2);
            if (disp_warning_no_SOPInstanceUID)
                disp('Warning: The dicom header does not contain SOPInstanceUIDs. It will not be possible to write appropriate DICOM_RTStructs based on this image.')
            else
                SOP = SOP(SliceLocationSorted(:,1));
            end
        else
            try_numbering = 1;
        end
    catch
        disp('failed to sort according to image index')
        close(dicom_waitbar)
        try_translationvector = 1;
    end
end

% Try to sort dicom files using translation vector
if try_translationvector
    numberOfSlices = length(myFiles);
    numberOfExcluded = 0;
    dicom_waitbar = waitbar(0,{'Checking Dicom Files (Translation vector, UIDs, ...)';' ';['in ',strrep(myDirName,'_','\_')]});
    try
        for slices = 1:numberOfSlices
            try
                UnsortedDICOMHeader=dicominfo(fullfile(myDir,myFiles(slices).name));
                SliceLocation(slices-numberOfExcluded,:)=[slices,UnsortedDICOMHeader.ImageTranslationVector(3)];
                try
                    SOP(slices).SOPInstanceUID = UnsortedDICOMHeader.SOPInstanceUID;
                catch
                    disp_warning_no_SOPInstanceUID = true;
                end
            catch
                disp(['File ',myFiles(slices).name,' is not in DICOM format! Skip...']);
                numberOfExcluded = numberOfExcluded + 1;
            end
            waitbar(slices/numberOfSlices,dicom_waitbar);
        end
        close(dicom_waitbar)
        numberOfSlices=numberOfSlices-numberOfExcluded;
        SliceLocation = SliceLocation(1:numberOfSlices,:);
        SliceLocationSorted = SliceLocationSorted(1:numberOfSlices,:);

        if(length(unique(SliceLocation(:,2)))==size(SliceLocation,1))
            disp('Sorting dicom files according to translation vector...')
            SliceLocationSorted(:,:)=sortrows(SliceLocation,2);
            if (disp_warning_no_SOPInstanceUID)
                disp('Warning: The dicom header does not contain SOPInstanceUIDs. It will not be possible to write appropriate DICOM_RTStructs based on this image.')
            else
                SOP = SOP(SliceLocationSorted(:,1));
            end
        else
            try_numbering = 1;
        end
    catch
        disp('failed to sort according to translation vector')
        close(dicom_waitbar)
        try_numbering = 1;
    end
end

% If previous failed, try to sort dicom files using file name numbering
if try_numbering
    numberOfSlices = length(myFiles);
    try
        maxLengthName = 0;
        for slices = 1:numberOfSlices
            maxLengthName = max(maxLengthName,length(myFiles(slices).name));
        end
        for slices = 1:numberOfSlices
            myFile = myFiles(slices).name;
            idNum = str2double(myFile(maxLengthName-2:end));
            if(isnan(idNum))
                idNum = str2double(myFile(maxLengthName-1:end));
            end
            if(isnan(idNum))
                idNum = str2double(myFile(end));
            end
            if(isnan(idNum))
                idNum = 1;
            end
            SliceLocation(slices,:) = [slices, idNum];
            %             SOP(slices).SOPInstanceUID = dicomuid;%'tag not initialized';
        end
        disp('Sorting dicom files according to file name...')
        disp('Warning: The dicom header does not contain SOPInstanceUIDs. It will not be possible to write appropriate DICOM_RTStructs based on this image.')
        SliceLocationSorted(:,:)=sortrows(SliceLocation,2);
    catch
    end
end

% Reading dicom files
myInfo = dicominfo(fullfile(myDir,myFiles(SliceLocationSorted(1,1)).name));
myInfo.OriginalHeader = myInfo;
if(not(isfield(myInfo,'PixelSpacing')) && isfield(myInfo,'PhysicalDeltaX') && isfield(myInfo,'PhysicalDeltaY'))
    myInfo.PixelSpacing = [myInfo.PhysicalDeltaX;myInfo.PhysicalDeltaX]*10;
    disp('Warning: PhysicalDelta considered as beeing expressed in cm. Might be wrong...');
elseif(not(isfield(myInfo,'PixelSpacing')) && isfield(myInfo,'PixelAspectRatio'))
    myInfo.PixelSpacing = myInfo.PixelAspectRatio;
end
if(isfield(myInfo,'ImagePositionPatient'))
    try
        myInfo2 = dicominfo(fullfile(myDir,myFiles(SliceLocationSorted(2,1)).name));
        position_diff = myInfo2.ImagePositionPatient-myInfo.ImagePositionPatient;
        if(sum(position_diff)==0)
            if(isfield(myInfo,'SpacingBetweenSlices'))
                myInfo.Spacing = [myInfo.PixelSpacing;myInfo.SpacingBetweenSlices];
            elseif(isfield(myInfo,'SliceThickness'))
                myInfo.Spacing = [myInfo.PixelSpacing;myInfo.SliceThickness];
            else
                myInfo.Spacing = [myInfo.PixelSpacing;1];
            end
        elseif(length(find(position_diff))==1)
            myInfo.Spacing = [myInfo.PixelSpacing;max(abs(position_diff))];
        else
            orientationPlane = myInfo.ImageOrientationPatient;
            orientationVector = cross(orientationPlane(1:3),orientationPlane(4:6));
            spacing = position_diff./orientationVector;
            testSpacing = spacing-spacing(1);
            if sum(abs(testSpacing))<0.001
                myInfo.Spacing = [myInfo.PixelSpacing;spacing(1)];
            else
                disp('Warning : mismatch between ImagePositionPatient and ImageOrientationPatient tags !!')
                myInfo.Spacing = [myInfo.PixelSpacing;spacing(1)];
            end
        end
    catch
        myInfo.Spacing = [myInfo.PixelSpacing;1];
    end
    myInfo.Spacing = abs(myInfo.Spacing);
elseif(isfield(myInfo,'ImageTranslationVector'))
    myInfo.ImagePositionPatient = myInfo.ImageTranslationVector;
    try
        myInfo2 = dicominfo(fullfile(myDir,myFiles(SliceLocationSorted(2,1)).name));
        position_diff = myInfo2.ImageTranslationVector-myInfo.ImageTranslationVector;
        if(length(find(position_diff))==1)
            myInfo.Spacing = [myInfo.PixelSpacing;max(abs(position_diff))];
        else
            disp('Warning : image orientation might be wrong !!')
        end
    catch
        myInfo.Spacing = [myInfo.PixelSpacing;1];
    end
    myInfo.Spacing = abs(myInfo.Spacing);
else
    myInfo.ImagePositionPatient = [0;0;0];
    if(isfield(myInfo,'SpacingBetweenSlices'))
        myInfo.Spacing = [myInfo.PixelSpacing;myInfo.SpacingBetweenSlices];
    elseif(isfield(myInfo,'SliceThickness'))
        myInfo.Spacing = [myInfo.PixelSpacing;myInfo.SliceThickness];
    else
        myInfo.Spacing = [myInfo.PixelSpacing;1];
    end
end

% INVERT X and Y
myInfo.Spacing = [myInfo.Spacing(2);myInfo.Spacing(1);myInfo.Spacing(3)];% THIS HAS TO BE CHECKED !!!!!!!!!!!!!

if(~isfield(myInfo,'SOPClassUID'))
    [imageType,OK] = listdlg('PromptString','This image was not recognized automatically, what type of image is it?',...
        'SelectionMode','single','ListString',{'CT','MR','RTDose','PET','Label (!unrecognised format)'});
    switch imageType
        case 1
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.2';
        case 2
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.4';
        case 3
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.481.2';
        case 4
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.128';
        case 5
            myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
    end
end
if(~isfield(myInfo,'SeriesInstanceUID'))
    myInfo.SeriesInstanceUID = dicomuid;
    disp('Warning: The dicom header does not contain a serieInstanceUID. One was just created.')
end
if(~isfield(myInfo,'FrameOfReferenceUID'))
    myInfo.FrameOfReferenceUID = 'tag not initialized';
    disp('Warning: The dicom header does not contain a FrameOfReferenceUID.')
end
if(~isfield(myInfo,'StudyInstanceUID'))
    myInfo.StudyInstanceUID = dicomuid;%[myInfo.PixelSpacing;myInfo.SliceThickness];
end
if(~isfield(myInfo,'PatientID'))
    myInfo.PatientID = 'noID';
end
if(~isfield(myInfo,'ImageOrientationPatient'))
    myInfo.ImageOrientationPatient = [1;0;0;0;1;0];
    disp('Warning: no orientation was found for this image');
end

DICOMIm = dicomread(fullfile(myDir,myFiles(SliceLocationSorted(1,1)).name));

% Check for missing slices in the scan
interslice = diff(SliceLocationSorted(:,2));
interslice_spacing = median(interslice);
if(interslice_spacing)
    missing_slices = round((interslice-interslice_spacing)/interslice_spacing);
else
    missing_slices = interslice*0;
end
nb_missing = sum(missing_slices);
if(nb_missing)
    disp(['WARNING: ',num2str(nb_missing),' missing slices !'])
end

% Creating the image matrix
myMat = zeros([size(DICOMIm,2),size(DICOMIm,1),numberOfSlices+nb_missing],'single');
dicom_waitbar = waitbar(0,'Reading Dicom Serie...');

SOP_all = struct;
SOP_all(1).SOPInstanceUID = '';

for slices = 1:numberOfSlices
    temp = dicomread(fullfile(myDir,myFiles(SliceLocationSorted(slices,1)).name));
    myMat(:,:,slices+sum(missing_slices(1:slices-1))) = single(temp(1:size(DICOMIm,1),1:size(DICOMIm,2))');
    SOP_all(slices+sum(missing_slices(1:slices-1))) = SOP(slices);
    waitbar(slices/numberOfSlices,dicom_waitbar);
end

if(nb_missing)
    disp(['Interpolating missing slices...'])
    for miss=1:nb_missing
        current = find(missing_slices);
        current = current(1)+miss-1;
        disp(['Slice ',num2str(current+1),' = slice ',num2str(current),' mult by ',num2str(missing_slices(current-miss+1)),'/',num2str(missing_slices(current-miss+1)+1),' added to slice ',num2str(current+missing_slices(current-miss+1)+1),' mult by 1/',num2str((missing_slices(current-miss+1)+1))])
        myMat(:,:,current+1) = myMat(:,:,current).*(missing_slices(current-miss+1)/(missing_slices(current-miss+1)+1)) + myMat(:,:,current+missing_slices(current-miss+1)+1).*(1/(missing_slices(current-miss+1)+1));
        missing_slices(current-miss+1) = missing_slices(current-miss+1)-1;
    end
end

close(dicom_waitbar)

if(isfield(myInfo.OriginalHeader,'RescaleSlope') && isfield(myInfo.OriginalHeader,'RescaleIntercept'))
    myMat = myMat * myInfo.OriginalHeader.RescaleSlope + myInfo.OriginalHeader.RescaleIntercept;
end

myMat = myMat*myInfo.DoseGridScaling;
myInfo.rescaled = 1;

myInfo.SOPInstanceUID = SOP_all;

cd(Current_dir);
