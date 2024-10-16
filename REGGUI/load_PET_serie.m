%% load_PET_serie
% Load all the Positron emission tomography (PET) DICOM files contained in the specified folder in order to create a 3D image |myMat|. The function uses the DICOM information contained in the files to sort the slices in the correct order in |myMat|.
%
%% Syntax
% |[myMat myInfo] = load_PET_serie(dicom_filename = FILE)|
%
% |[myMat myInfo] = load_PET_serie(dicom_filename = FOLDER)|
%
%
%% Description
% |[myMat myInfo] = load_PET_serie(dicom_filename = FILE)|  Load all the files contained in the same folder as file |dicom_filename|.
%
% |[myMat myInfo] = load_PET_serie(dicom_filename = FOLDER)| Load all the files contained in the folder |dicom_filename|.
%
%
%% Input arguments
% |dicom_filename| - _STRING_ - Name of one of the file contained in the folder. Alternatively, it can also be the name of the folder.
%
%
%% Output arguments
%
% |myMat| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file.
%
%
%% Contributors
% Authors : L.Persoon, G.Janssens, J.Orban (open.reggui@gmail.com)

function [myMat myInfo] = load_PET_serie(dicom_filename)

Current_dir = pwd;

[myDir,my_Image,ext] = fileparts(dicom_filename);

disp(['Loading 3D PET serie (',dicom_filename,')'])

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

FilenamesIN = cell(0);
for slices=1:length(myFiles)
    FilenamesIN{slices} = fullfile(myDir,myFiles(slices).name);
end

SliceNum                =   uint16(length(FilenamesIN));
if ~(SliceNum == 2 && ~isempty(strfind(FilenamesIN{1},'\.')) && ...
        ~isempty(strfind(FilenamesIN{2},'\..')))
    
    sel_info = struct;
    try
        sel_info = dicominfo(fullfile(myDir,my_Image));
    catch
        disp('Selected file is not a DICOM file... try to find a dicom serie in the selected repository')
        sel_info = dicominfo(FilenamesIN{round(SliceNum/2)});
    end
    
    % Sort the DICOM files from low to high slice Y value, and store filenames
    % in structure
    dicom_waitbar = waitbar(0,{'Checking Dicom Files (Filenames, position, UIDs, ...)';' ';['in ',strrep(strrep(myDir,'\','\\'),'_','\_')]});
    numberOfExcluded = 0;
    for SliceCur=1:SliceNum
        try
            DicomHeader         =   dicominfo(FilenamesIN{SliceCur});
            % check UIDs
            if (~strcmp(DicomHeader.SeriesInstanceUID,sel_info.SeriesInstanceUID) || ...
                    ~strcmp(DicomHeader.StudyInstanceUID,sel_info.StudyInstanceUID) || ...
                    ~strcmp(DicomHeader.SOPClassUID,sel_info.SOPClassUID) )
                disp(['File ',myFiles(SliceCur).name,' has not the same UIDs! Skip...']);
                numberOfExcluded = numberOfExcluded + 1;
            else
                Yi(SliceCur-numberOfExcluded,:)      =   [double(SliceCur),...
                    DicomHeader.ImagePositionPatient(3)];
            end
        catch
            disp(['File ',myFiles(SliceCur).name,' is not in DICOM format! Skip...']);
            numberOfExcluded = numberOfExcluded + 1;
        end
        waitbar(double(SliceCur)/double(SliceNum),dicom_waitbar);
    end %for SliceCur
    SliceNum = SliceNum - numberOfExcluded;
    close(dicom_waitbar)
    
    SliceValueYSorted       =   sortrows(Yi,2);
    PETOUT.Filenames        =   FilenamesIN(SliceValueYSorted(:,1));
    PETOUT.SliceLocations   =   SliceValueYSorted;
    PETOUT.SliceLocations(:,2) = PETOUT.SliceLocations(:,2)/10;
    
    % Read the first Dicom header and store in structure
    PETOUT.DicomHeader      =   dicominfo(PETOUT.Filenames{1});
    myInfo                  =   dicominfo(PETOUT.Filenames{1});
    myInfo.OriginalHeader   =   myInfo;
    
    % Store information from the Dicom header in structure for later quick
    % access
    PETOUT.PixelSpacingXi   =   PETOUT.DicomHeader.PixelSpacing(1)/10;
    %/10 for mm to cm (IEC)
    PETOUT.PixelSpacingYi   =   PETOUT.SliceLocations(2,2)-...
        PETOUT.SliceLocations(1,2);
    %Because slicethickness is not equal to slicespacing
    % PETOUT.PixelSpacingYi   =   PETOUT.DicomHeader.SliceThickness/10;
    %                             %/10 for mm to cm (IEC)
    PETOUT.PixelSpacingZi   =   PETOUT.DicomHeader.PixelSpacing(2)/10;
    %/10 for mm to cm (IEC)
    PETOUT.PixelNumXi       =   double(PETOUT.DicomHeader.Width);
    PETOUT.PixelNumYi       =   double(length(PETOUT.Filenames));
    PETOUT.PixelNumZi       =   double(PETOUT.DicomHeader.Height);
%     if PETOUT.DicomHeader.ImageOrientationPatient == [ -1 ; 0 ; 0 ; 0 ; -1 ; 0 ]
%         PETOUT.PixelFirstXi     =(PETOUT.DicomHeader.ImagePositionPatient(1)/10)-...
%             (PETOUT.PixelSpacingXi*PETOUT.PixelNumXi);
%         %/10 for mm to cm (IEC)
%         PETOUT.PixelFirstYi     =(PETOUT.DicomHeader.ImagePositionPatient(3)/10);
%         %/10 for mm to cm (IEC)
%         PETOUT.PixelFirstZi     =-((PETOUT.DicomHeader.ImagePositionPatient(2)/10) -...
%             (PETOUT.PixelSpacingZi*(PETOUT.PixelNumZi-1)));
%     else
        PETOUT.PixelFirstXi     =PETOUT.DicomHeader.ImagePositionPatient(1)/10;
        %/10 for mm to cm (IEC)
        PETOUT.PixelFirstYi     =PETOUT.DicomHeader.ImagePositionPatient(3)/10;
        %/10 for mm to cm (IEC)
        PETOUT.PixelFirstZi     =(-PETOUT.DicomHeader.ImagePositionPatient(2)/10) -...
            (PETOUT.PixelSpacingZi*(PETOUT.PixelNumZi-1));
%     end
    
    try
    PETOUT.RescaleIntercept  =   PETOUT.DicomHeader.RescaleIntercept;
    PETOUT.RescaleSlope      =   PETOUT.DicomHeader.RescaleSlope;
    catch
    end
    try
    PETOUT.Model             =   PETOUT.DicomHeader.ManufacturerModelName;
    PETOUT.Manufacturer      =   PETOUT.DicomHeader.Manufacturer;
    catch
    end
    
    PETOUT.Institute = '';
    if isfield(PETOUT.DicomHeader,'InstitutionName');
        if strfind(PETOUT.DicomHeader.InstitutionName,'Maastro')
            PETOUT.Institute = 'Maastro';
        end
    end
    
    if isfield(PETOUT.DicomHeader,'TableHeight');
        PETOUT.TableHeight       =   PETOUT.DicomHeader.TableHeight;
    else
        PETOUT.TableHeight       =   0;
    end
    
    if isfield(PETOUT.DicomHeader,'Units');
        PETOUT.Units             =   PETOUT.DicomHeader.Units;
    else
        PETOUT.Units       =   '';
    end
    
    if isfield(PETOUT.DicomHeader,'PatientWeight');
        PETOUT.PatientWeight             =   PETOUT.DicomHeader.PatientWeight;
    else
        PETOUT.PatientWeight       =   0;
    end
    
    if isfield(PETOUT.DicomHeader,'DecayCorrection');
        PETOUT.DecayCorrection             =   PETOUT.DicomHeader.DecayCorrection;
    else
        PETOUT.DecayCorrection       =   '';
    end
    
    if isfield(PETOUT.DicomHeader,'SeriesType');
        PETOUT.SeriesType             =   PETOUT.DicomHeader.SeriesType;
    else
        PETOUT.SeriesType       =   '';
    end
    
    if isfield(PETOUT.DicomHeader,'FrameOfReferenceUID');
        PETOUT.FrameOfReference      =   PETOUT.DicomHeader.FrameOfReferenceUID;
    else
        PETOUT.FrameOfReference      =   '';
    end
    
    if isfield(PETOUT.DicomHeader,'SeriesInstanceUID');
        PETOUT.SeriesUID             =   PETOUT.DicomHeader.SeriesInstanceUID;
    else
        PETOUT.SeriesUID             =   '';
    end
    
    if isfield(PETOUT.DicomHeader,'StudyInstanceUID');
        PETOUT.StudyUID             =   PETOUT.DicomHeader.StudyInstanceUID;
    else
        PETOUT.StudyUID             =   '';
    end
    
    SOP = struct;
    if isfield(PETOUT.DicomHeader,'SOPInstanceUID');
        PETOUT.SOPInstanceUID             =   PETOUT.DicomHeader.SOPInstanceUID;
        for SliceCur=1:SliceNum
            hdr = dicominfo(PETOUT.Filenames{SliceCur});
            SOP(SliceCur).SOPInstanceUID = hdr.SOPInstanceUID;
        end
    else
        PETOUT.SOPInstanceUID             =   '';
    end
    
    
    % Important parameters for SUV calculation
    % Half Time is half life time ins econds
    % Total Dose is total dose in Bequerels to the patient
    % StartTime is the actual radiopharmaceutical administration time
    if isfield(PETOUT.DicomHeader,'RadiopharmaceuticalInformationSequence');
        if isfield(PETOUT.DicomHeader.RadiopharmaceuticalInformationSequence,'Item_1');
            if isfield(PETOUT.DicomHeader.RadiopharmaceuticalInformationSequence.Item_1,'RadiopharmaceuticalStartTime');
                PETOUT.RadioPharmaceuticalStartTime       =   PETOUT.DicomHeader.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime;
            else
                PETOUT.RadioPharmaceuticalStartTime      =   '000000.000000';
            end
            if isfield(PETOUT.DicomHeader.RadiopharmaceuticalInformationSequence.Item_1,'RadionuclideTotalDose');
                PETOUT.RadionuclideTotalDose              =   PETOUT.DicomHeader.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
            else
                PETOUT.RadionuclideTotalDose              =   0;
            end
            if isfield(PETOUT.DicomHeader.RadiopharmaceuticalInformationSequence.Item_1,'RadionuclideHalfLife');
                PETOUT.RadionuclideHalfLife               =   PETOUT.DicomHeader.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
            else
                PETOUT.RadionuclideHalfLife               =   0;
            end
            
        else
            PETOUT.RadioPharmaceuticalStartTime       =   '000000.000000';
            PETOUT.RadionuclideTotalDose              =   0;
            PETOUT.RadionuclideHalfLife               =   0;
        end
    else
        PETOUT.RadioPharmaceuticalStartTime      =   '000000.000000';
        PETOUT.RadionuclideTotalDose              =   0;
        PETOUT.RadionuclideHalfLife               =   0;
    end
    
    PETOUT.SuitableForSUV = 0;
    if PETOUT.RadionuclideHalfLife ~= 0 && PETOUT.RadionuclideTotalDose ~= 0 && ...
            ~strcmp(PETOUT.RadioPharmaceuticalStartTime,'000000.000000') && ...
            (isempty(PETOUT.SeriesType) || isempty(strfind(PETOUT.SeriesType,'DYNAMIC'))) && ...
            ~isempty(PETOUT.DecayCorrection) && PETOUT.PatientWeight ~= 0 && ...
            ~isempty(PETOUT.Units)
        
        PETOUT.SuitableForSUV = 1;
        
    end
    
    dicom_waitbar = waitbar(0,'Reading Dicom PET Serie...');
    
    % Read all slices in path, convert to Hounsfield
    % Units, apply IEC convention
    PETOUT.Image             =   uint16(zeros(PETOUT.PixelNumZi,...
        PETOUT.PixelNumXi,PETOUT.PixelNumYi));
    
    for SliceCur=1:SliceNum
        PETOUT.Image(:,:,SliceCur)    =   ...
            dicomread(PETOUT.Filenames{SliceCur});
        hdr = dicominfo(PETOUT.Filenames{SliceCur});        
        try
            PETOUT.AcquistionDates{SliceCur}   = hdr.AcquisitionDate;
            PETOUT.AcquistionTimes{SliceCur}   = hdr.AcquisitionTime;
            if strcmp(PETOUT.Manufacturer,'Philips Medical Systems')
                PETOUT.AcquistionDTValue(SliceCur) = datenum(datevec([hdr.AcquisitionDate ' ' hdr.AcquisitionTime,'.000'],'yyyymmdd HHMMSS.FFF'));
                PETOUT.StartTimeDTValue(SliceCur)  = datenum(datevec([hdr.AcquisitionDate ' ' PETOUT.RadioPharmaceuticalStartTime,'.000'],'yyyymmdd HHMMSS.FFF'));
            else
                PETOUT.AcquistionDTValue(SliceCur) = datenum(datevec([hdr.AcquisitionDate ' ' hdr.AcquisitionTime],'yyyymmdd HHMMSS.FFF'));
                PETOUT.StartTimeDTValue(SliceCur)  = datenum(datevec([hdr.AcquisitionDate ' ' PETOUT.RadioPharmaceuticalStartTime],'yyyymmdd HHMMSS.FFF'));
            end
            timediff = datevec(PETOUT.AcquistionDTValue(SliceCur) - PETOUT.StartTimeDTValue(SliceCur));
            PETOUT.TimeDifferences(SliceCur)   = timediff(6) + 60 * timediff(5) + 3600 * timediff(4);
        catch
            disp(['Warning: unable to find acquisition time information for slice ',num2str(SliceCur)]);
        end
        waitbar(double(SliceCur)/double(SliceNum),dicom_waitbar);
    end %for SliceCur
    close(dicom_waitbar)
    
    %Set PET in IEC format
    PETOUT.Image(:,:,:)            =   PETOUT.Image(end:-1:1,:,:);
    PETOUT.Image                   =   permute(PETOUT.Image,[ 2 1 3 ]);
    PETOUT.Image                   =   permute(PETOUT.Image,[ 1 3 2 ]);
end

temp    = (double(PETOUT.Image) .* PETOUT.RescaleSlope) + PETOUT.RescaleIntercept; 

% Remove rescale tags for avoiding future mistakes...
if(isfield(myInfo.OriginalHeader,'RescaleSlope'))
   myInfo.OriginalHeader.RescaleSlope = 1;
end
if(isfield(myInfo.OriginalHeader,'RescaleIntercept'))
   myInfo.OriginalHeader.RescaleIntercept = 0;
end

if(PETOUT.SuitableForSUV)    
    SuvPetDataOUT = PETOUT;
    PatientWeigth = PETOUT.PatientWeight * 1000; %PatientWeigth in grams           
    if strcmp(PETOUT.DecayCorrection,'START')
        if isempty(strfind(PETOUT.SeriesType,'DYNAMIC'))
            SuvBodyWeightCoef = ones(PETOUT.PixelNumYi,2);
            for i = 1:PETOUT.PixelNumYi
                AmountOfDecay             = PETOUT.TimeDifferences(i) / PETOUT.RadionuclideHalfLife;
                DecayCorrectedDose        = PETOUT.RadionuclideTotalDose * exp(-(AmountOfDecay)*log(2));
                SuvBodyWeightCoef(i,1)    = PETOUT.SliceLocations(i,2)*10;% from cm to mm
                SuvBodyWeightCoef(i,2)    = PatientWeigth / DecayCorrectedDose;
                temp(:,i,:)               = temp(:,i,:) .* SuvBodyWeightCoef(i,2);
            end
        end
        myInfo.SuvBodyWeightCoef = SuvBodyWeightCoef;
        myInfo.OriginalHeader.SuvBodyWeightCoef = SuvBodyWeightCoef;
    elseif strcmp(PETOUT.DecayCorrection,'ADMIN')
        DecayCorrectedDose = PETOUT.RadionuclideTotalDose;
        SuvBodyWeightCoef  = PatientWeigth / DecayCorrectedDose;
        temp  = temp .* SuvBodyWeightCoef;
        myInfo.SuvBodyWeightCoef = SuvBodyWeightCoef;
        myInfo.OriginalHeader.SuvBodyWeightCoef = SuvBodyWeightCoef;
    end
end

% TODO Bug in some PET files ???? TO BE CHECKED
if(isfield(myInfo.OriginalHeader,'RelatedSeriesSequence'))
   if(not(isstruct(myInfo.OriginalHeader.RelatedSeriesSequence)))
       myInfo.OriginalHeader = rmfield(myInfo.OriginalHeader,'RelatedSeriesSequence');
   end
end
if(isfield(myInfo.OriginalHeader,'RespiratoryTriggerSequence'))
   if(not(isstruct(myInfo.OriginalHeader.RespiratoryTriggerSequence)))
       myInfo.OriginalHeader = rmfield(myInfo.OriginalHeader,'RespiratoryTriggerSequence');
   end
end


% DICOMIm = dicomread(fullfile(myDir,myFiles(SliceValueYSorted(:,1)).name));
% myMat = zeros([size(DICOMIm,2),size(DICOMIm,1),size(SliceValueYSorted,2)],'single');
%
% disp([size(DICOMIm,2),size(DICOMIm,1),size(SliceValueYSorted,2)])
% disp(size(temp))
%
% for slices = 1:numberOfSlices
%     myMat(:,:,slices) = single(temp(1:size(DICOMIm,1),1:size(DICOMIm,3))');
% end

myMat = single(permute(temp,[1 3 2]));
myMat = myMat(:,end:-1:1,:);

% Reading dicom files
if(~isfield(myInfo,'ImagePositionPatient'))
    myInfo.ImagePositionPatient = [0;0;0];
    if(isfield(myInfo,'SpacingBetweenSlices'))
        myInfo.Spacing = [myInfo.PixelSpacing;myInfo.SpacingBetweenSlices];
    elseif(isfield(myInfo,'SliceThickness'))
        myInfo.Spacing = [myInfo.PixelSpacing;myInfo.SliceThickness];
    else
        myInfo.Spacing = [myInfo.PixelSpacing;1];
    end
else
    try
        myInfo2 = dicominfo(PETOUT.Filenames{2});
        position_diff = myInfo2.ImagePositionPatient-myInfo.ImagePositionPatient;
        if(length(find(position_diff))==1)
            myInfo.Spacing = [myInfo.PixelSpacing;max(abs(position_diff))];
        else
            orientationPlane = myInfo.ImageOrientationPatient;
            orientationVector = cross(orientationPlane(1:3),orientationPlane(4:6));
            spacing = position_diff./orientationVector;
            testSpacing = spacing-spacing(1);
            if sum(abs(testSpacing))<0.001
                myInfo.Spacing = [myInfo.PixelSpacing;spacing(1)];
            else
                error('Error : mismatch between ImagePositionPatient and ImageOrientationPatient tags !!')
            end
        end
    catch
        myInfo.Spacing = [myInfo.PixelSpacing;1];
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
    myInfo.Spacing = abs(myInfo.Spacing);
end

% INVERT X and Y
myInfo.Spacing = [myInfo.Spacing(2);myInfo.Spacing(1);myInfo.Spacing(3)];% TODO THIS HAS TO BE CHECKED !!!!!!!!!!!!!

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

myInfo.SOPInstanceUID = SOP;

cd(Current_dir);
