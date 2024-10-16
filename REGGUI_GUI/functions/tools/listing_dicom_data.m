%% listing_dicom_data
% Parse the content of the directory and sub-directories to look for DICOM files. Alternatively if |patient| is not a directory, search the Orthanc PACS for the ID |patient|. For each DICOM file that is found (either in the folder or in the PACS), the value of the DICOM tags for this file are stored in the cell array |list_of_data|.
%
%% Syntax
% |list_of_data = listing_dicom_data()|
%
% |list_of_data = listing_dicom_data(patient)|
%
% |list_of_data = listing_dicom_data(patient,unique_patientID,input_list_of_data)|
%
%
%% Description
% |list_of_data = listing_dicom_data()| Parse data in current directory and sub-directory
%
% |list_of_data = listing_dicom_data(patient)| If |patient| is a folder, parse data in the directory |patient| and its sub-directory. If |patient| is an existing ID in the PACS, retrieve the associated data.
%
% |list_of_data = listing_dicom_data(patient,unique_patientID,input_list_of_data)| Add the data to the previous data list.
%
%
%% Input arguments
% |patient| - _STRING_ - [OPTIONAL. Defaul: current directory] Directory containing the DICOM file to parse or ID of the patient in the PACS
%
% |unique_patientID| - _INTEGER_ - [OPTIONAL. Default =0] 1= Read patient ID and only read the DICOM files for that patient. The check use either the patient ID defined in |list_of_data{1}{6}| if provided. Otherwise, it uses the patient ID in the first file in the directory.  0= read all file and do not check for patient ID
%
% |input_list_of_data| - _CELL MATRIX_ - [OPTIONAL] Previously filled list of DICOM data (|input_list_of_data{i}{1-16}| describes the content of the i-th file, with structure similar to |list_of_data|). This list is updated with the data read from disk. If this is not provided, the function attempts to read a file |reggui_patient_file.mat| that would be stored in |patient|. Otherwise, the function ignore previous data.
%
%
%% Output arguments
%
% |list_of_data| - _CELL ARRAY_ -  |list_of_data{i}{j}| DICOM tag read from the DICOM files #i stored on disk (or PACS) with 1<=i=<number of parsed files. The j-th DICOM tag is:
%
% * j = 1 : label
% * j = 2 : creation time
% * j = 3 : Modif time
% * j = 4 : Dirname
% * j = 5 : Filename
% * j = 6 : Patient ID
% * j = 7 : Patient name
% * j = 8 : Modality
% * j = 9 : StudyID
% * j = 10 : Study time
% * j = 11 : ImageType
% * j = 12 : Reference (SeriesInstanceUID or SOPInstanceUID)
% * j = 13 : 4D serie ID
% * j = 14 : Content description
% * j = 15 : Additional info (list of contours for RTSTRUCT, beam index for RT dose, list of beams for RT plan)
% * j = 16 : SOP instance UID
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function list_of_data = listing_dicom_data(patient,unique_patientID,input_list_of_data)

nb_items = 16;

current_dir = pwd;

list_of_data = cell(0);

if(nargin<1)
    patient_dir = current_dir;
else
    patient_dir = patient;
end
if(nargin<2)
    unique_patientID = 0;
end
update_mode = 0;
if(nargin<3)
    input_list_of_data = cell(0);
    if(nargout<1 && exist([patient_dir,'/reggui_patient_file.mat'],'file'))
        input = load(fullfile(patient_dir,'reggui_patient_file.mat'));
        if(size(input,2)>=nb_items)
            input_list_of_data = input.output;
            update_mode = 1;
        end
    end
elseif(size(input_list_of_data,2)<nb_items)
    input_list_of_data = cell(0);
end

% ------------------------------------------------------------------------
if(not(exist(patient_dir,'dir'))) % if patient is a patient ID, look into the PACS

    disp([patient_dir,' folder not found. Looking for ',patient_dir,' patient id in the PACS...']);
    patient_ids = {};
    patients = orthanc_get_info('patients');
    for i=1:length(patients)
        temp = orthanc_get_info(['patients/',patients{i}]);
        patient_ids{i} = temp.MainDicomTags.PatientID;
        patient_names{i} = temp.MainDicomTags.PatientName;
        studies{i} = temp.Studies;
    end
    temp = strcmp(patient_ids,patient_dir);
    if(sum(temp(:))>0)
        [~,index] = find(temp);
        patient_pacs_id = patients{index};
        Patient_ID = patient_ids{index};
        Patient_name = patient_names{index};
        studies_pacs_ids = studies{index};
    else
        disp([patient_dir,' not found in the PACS. Abort.']);
        return
    end
    dicom_data = cell(0);
    for i=1:length(studies_pacs_ids)
        temp_s = orthanc_get_info(['studies/',studies_pacs_ids{i}]);
        serie_id = temp_s.Series;
        for j=1:length(serie_id)
            temp = orthanc_get_info(['series/',serie_id{j}]);
            instance_id = temp.Instances{1};
            if(isfield(temp.MainDicomTags,'SeriesDescription'))
                if(not(isempty(temp.MainDicomTags.SeriesDescription)))
                    series_name = temp.MainDicomTags.SeriesDescription;
                else
                    series_name = temp.MainDicomTags.SeriesInstanceUID;
                end
            else
                series_name = temp.MainDicomTags.SeriesInstanceUID;
            end
            add_item = 1;
            if(not(isempty(list_of_data)))
                if(sum(strcmp(list_of_data(:,4),series_name)))
                    add_item = 0;
                end
            end
            if(add_item)
                dicom_data{end+1}.header = orthanc_get_info(['instances/',temp.Instances{1},'/simplified-tags']);
                dicom_data{end}.modif_date = temp.LastUpdate;
                dicom_data{end}.dicom_dirname = series_name;
                if(strcmp(dicom_data{end}.header.Modality,'RTSTRUCT') || strcmp(dicom_data{end}.header.Modality,'RTPLAN'))
                    dicom_data{end}.dicom_filename = instance_id;
                else
                    dicom_data{end}.dicom_filename = serie_id{j};
                end
            end
        end
    end

    if(not(isempty(input_list_of_data)))
        i = 1;
        while i<=size(input_list_of_data,1)
            entry_index = 0;
            for j=1:length(dicom_data)
                if(strcmp(dicom_data{j}.dicom_filename,input_list_of_data{i,5}))
                    entry_index = j;
                    break
                end
            end
            if(entry_index==0)
                input_list_of_data = input_list_of_data([1:i-1,i+1:end],:); % remove i-th entry from the input (data no longer exists in pacs)
            else
                dicom_data = dicom_data([1:entry_index-1,entry_index+1:end]); % remove j-th entry from the new data in pacs
                i = i+1;
            end
        end
    end

else %  if patient is a folder, parse dicom data saved on disk

    dicom_waitbar = waitbar(0,{'Parsing Dicom Files ... '});

    if((patient_dir(end)=='\')||(patient_dir(end)=='/'))
        patient_dir = patient_dir(1:end-1);
    end

    % List sub-directories
    remaining_dirs = cell(0);
    remaining_dirs{1} = patient_dir;
    all_dirs = cell(0);
    try
        while not(isempty(remaining_dirs))
            cd(remaining_dirs{end});
            subdirs = struct2cell(dir_without_hidden(remaining_dirs{end},'folders'));
            subdirs = subdirs(1,:);
            for i=1:length(subdirs)
                subdirs{i} = [strrep(remaining_dirs{end},'\','/'),'/',subdirs{i}];
            end
            all_dirs = [all_dirs;strrep(remaining_dirs{end},'\','/')];
            if(isempty(subdirs))
                remaining_dirs = remaining_dirs(1:end-1);
            else
                remaining_dirs(end:end+length(subdirs)-1,:) = subdirs;
            end
        end
    catch
        err = lasterror;
        disp([' ',err.message]);
        disp(err.stack(1));
    end
    cd(patient_dir);

    if(not(isempty(input_list_of_data)))
        % Remove missing files from input data list
        input_missing = [];
        for i=1:size(input_list_of_data,1)
            if(not(exist(fullfile(patient_dir,input_list_of_data{i,4},input_list_of_data{i,5}),'file')))
                disp(['Warning: file ',fullfile(patient_dir,input_list_of_data{i,4},input_list_of_data{i,5}),' cannot be found. Remove from the patient list.']);
                input_missing = [input_missing i];
            end
        end
        for i=1:length(input_missing)
            input_list_of_data = input_list_of_data([1:input_missing(i)-1,input_missing(i)+1:end],:);
            input_missing(find(input_missing>input_missing(i))) = input_missing(find(input_missing>input_missing(i)))-1;
        end
        for d=1:length(all_dirs)
            files = dir_without_hidden(all_dirs{d});
            latest_in_dir = 0;
            % find latest file change in directory
            for f=1:length(files)
                latest_in_dir = max(latest_in_dir,mydatenum(files(f).date));
            end
            % find latest file modif in input data from this directory
            latest_in_input = 0;
            input_in_dir = [];
            for i=1:size(input_list_of_data,1)
                if(strcmp(strrep(all_dirs{d},'\','/'),strrep(fullfile(patient_dir,input_list_of_data{i,4}),'\','/')))
                    input_in_dir = [input_in_dir i];
                    latest_in_input = max(latest_in_input,mydatenum(input_list_of_data{i,3}));
                end
            end
            if(abs(floor(latest_in_dir*1e3-latest_in_input*1e3))>0 || length(files)<=10) % If new data in directory or few number of data
                for i=1:length(input_in_dir)
                    input_list_of_data = input_list_of_data([1:input_in_dir(i)-1,input_in_dir(i)+1:end],:);
                    input_in_dir(find(input_in_dir>input_in_dir(i))) = input_in_dir(find(input_in_dir>input_in_dir(i)))-1;
                end

            else
                disp(['No new dicom data found in: ',strrep(all_dirs{d},'\','/'),' -> do not list again.']);
                all_dirs{d} = [];
            end
        end
    end

    % List dicom data
    dicom_data = cell(0);
    if(unique_patientID)
        if(isempty(input_list_of_data))
            d = length(all_dirs);
            myFiles = dir(all_dirs{d});
            i = 2;
            temp_info = struct;
            temp_info.PatientID = 0;
            while i>0
                try
                    i = i+1;
                    try
                        temp_info = dicominfo(fullfile(all_dirs{d},myFiles(i).name),'UseVRHeuristic',false); % Try not to use 'UseVRHeuristic' (only possible from 2015b)
                    catch
                        temp_info = dicominfo(fullfile(all_dirs{d},myFiles(i).name));
                    end
                    i = 0;
                catch
                    if(i>length(myFiles))
                        d = d-1;
                        if(d>0)
                            myFiles = dir(all_dirs{d});
                        end
                        i = 2;
                    end
                    if(d<1)
                        i = 0;
                    end
                end
            end
            patientID = temp_info.PatientID;
        else
            patientID = input_list_of_data{1,6};
        end
    end

    for d=1:length(all_dirs)
        if(not(isempty(all_dirs{d})))
            list_of_uids = cell(0);
            myFiles = dir_without_hidden(all_dirs{d});
            numberOfSlices = length(myFiles);
            for slices = 1:numberOfSlices
                try
                    try
                        UnsortedDICOMHeader=dicominfo(fullfile(all_dirs{d},myFiles(slices).name),'UseVRHeuristic',false); % Try not to use 'UseVRHeuristic' (only possible from 2015b)
                    catch
                        UnsortedDICOMHeader=dicominfo(fullfile(all_dirs{d},myFiles(slices).name));
                    end
                    if(unique_patientID && not(strcmp(UnsortedDICOMHeader.PatientID,patientID))) % check if patient ID is consistent
                        disp(['Warning : some data (',myFiles(slices).name,') that correspond to another patient (',UnsortedDICOMHeader.PatientID,') have been excluded from the list (',patientID,').'])
                    else
                        % check UIDs
                        if(not(isempty(list_of_uids)) && (strcmp(UnsortedDICOMHeader.Modality,'CT') || strcmp(UnsortedDICOMHeader.Modality,'PT') || (strcmp(UnsortedDICOMHeader.Modality,'RTDOSE')&&UnsortedDICOMHeader.NumberOfFrames==1)))
                            if(~sum(strcmp(UnsortedDICOMHeader.SeriesInstanceUID,list_of_uids(:,1))) || ...
                                    ~sum(strcmp(UnsortedDICOMHeader.StudyInstanceUID,list_of_uids(:,2))) || ...
                                    ~sum(strcmp(UnsortedDICOMHeader.SOPClassUID,list_of_uids(:,3))) )
                                list_of_uids = [list_of_uids;{UnsortedDICOMHeader.SeriesInstanceUID,UnsortedDICOMHeader.StudyInstanceUID,UnsortedDICOMHeader.SOPClassUID}];
                                new_data = struct;
                                new_data.filename = fullfile(all_dirs{d},myFiles(slices).name);
                                new_data.header = UnsortedDICOMHeader;
                                dicom_data{length(dicom_data)+1}=new_data;
                            end
                        else
                            list_of_uids = {UnsortedDICOMHeader.SeriesInstanceUID,UnsortedDICOMHeader.StudyInstanceUID,UnsortedDICOMHeader.SOPClassUID};
                            new_data = struct;
                            new_data.filename = fullfile(all_dirs{d},myFiles(slices).name);
                            new_data.header = UnsortedDICOMHeader;
                            dicom_data{length(dicom_data)+1}=new_data;
                        end
                    end
                    waitbar((d-1)/length(all_dirs)+slices/numberOfSlices/length(all_dirs)*0.9,dicom_waitbar);
                catch
                    %                 err = lasterror;
                    %                 disp(['    ',err.message]);
                    %                 disp(err.stack(1));
                end
            end
        else
            waitbar(d/length(all_dirs),dicom_waitbar);
        end
    end

    for d=1:length(dicom_data)
        % separate dirname and filename
        [dicom_dirname,dicom_filename,ext] = fileparts(dicom_data{d}.filename(length(patient_dir)+2:end));
        dicom_data{d}.dicom_filename = [dicom_filename ext];
        dicom_data{d}.dicom_dirname = strrep(dicom_dirname,'\','/');
        % extract modification date
        dicom_data{d}.modif_date = getfield( dir(dicom_data{d}.filename(length(patient_dir)+2:end)), 'date');
    end

    close(dicom_waitbar)

end

% ------------------------------------------------------------------------
% label - creation time - modif time - dirname - filename - Patient ID -
% Patient name - modality - StudyID - Study time - ImageType - Ref image -
% 4D serie ID - Content description - additional info - SOP instance UID
list_of_data = cell(length(dicom_data),nb_items);
previous_list_of_data = input_list_of_data;

for d=1:length(dicom_data)
    % fill in optional dicom info
    if(not(isfield(dicom_data{d}.header,'InstanceCreationDate')))
        if(isfield(dicom_data{d}.header,'AcquisitionDate'))
            dicom_data{d}.header.InstanceCreationDate = dicom_data{d}.header.AcquisitionDate;
        elseif(isfield(dicom_data{d}.header,'FileModDate'))
            dicom_data{d}.header.InstanceCreationDate = datestr(dicom_data{d}.header.FileModDate,'yyyymmdd');
        else
            dicom_data{d}.header.InstanceCreationDate = datestr(dicom_data{d}.modif_date,'yyyymmdd');
        end
    end
    if(not(isfield(dicom_data{d}.header,'InstanceCreationTime')))
        if(isfield(dicom_data{d}.header,'AcquisitionTime'))
            dicom_data{d}.header.InstanceCreationTime = dicom_data{d}.header.AcquisitionTime;
        elseif(isfield(dicom_data{d}.header,'FileModDate'))
            dicom_data{d}.header.InstanceCreationTime = datestr(dicom_data{d}.header.FileModDate,'HHMMSS');
        else
            dicom_data{d}.header.InstanceCreationTime = datestr(dicom_data{d}.modif_date,'HHMMSS');
        end
    end
    if(not(isfield(dicom_data{d}.header,'ContentLabel')))
        dicom_data{d}.header.ContentLabel = '';
    end
    if(not(isfield(dicom_data{d}.header,'ContentDescription')))
        dicom_data{d}.header.ContentDescription = '';
    end
    if(not(isfield(dicom_data{d}.header,'SeriesInstanceUID')))
        dicom_data{d}.header.SeriesInstanceUID = '';
    end
    if(not(isfield(dicom_data{d}.header,'StudyID')))
        dicom_data{d}.header.StudyID = '';
    end
    if(not(isfield(dicom_data{d}.header,'StudyDate')))
        dicom_data{d}.header.StudyDate = '';
    end
    if(not(isfield(dicom_data{d}.header,'StudyTime')))
        dicom_data{d}.header.StudyTime = '';
    end
    if(isfield(dicom_data{d}.header.PatientName,'FamilyName') && isfield(dicom_data{d}.header.PatientName,'GivenName'))
        dicom_data{d}.header.PatientName = [dicom_data{d}.header.PatientName.FamilyName,'^',dicom_data{d}.header.PatientName.GivenName];
    elseif(isfield(dicom_data{d}.header.PatientName,'FamilyName'))
        dicom_data{d}.header.PatientName = dicom_data{d}.header.PatientName.FamilyName;
    end
    % extract useful dicom info
    if(isfield(dicom_data{d}.header,'ImageType'))
        if(strcmp(dicom_data{d}.header.Modality,'CT') && isfield(dicom_data{d}.header,'AcquisitionTime'))
            list_of_data(d,:) = {dicom_data{d}.header.ContentLabel,[dicom_data{d}.header.InstanceCreationDate,dicom_data{d}.header.InstanceCreationTime],dicom_data{d}.modif_date,dicom_data{d}.dicom_dirname,dicom_data{d}.dicom_filename,dicom_data{d}.header.PatientID,dicom_data{d}.header.PatientName,dicom_data{d}.header.Modality,dicom_data{d}.header.StudyID,[dicom_data{d}.header.StudyDate,dicom_data{d}.header.StudyTime],dicom_data{d}.header.ImageType,dicom_data{d}.header.SeriesInstanceUID,str2double(strrep([dicom_data{d}.header.AcquisitionTime,dicom_data{d}.header.StudyDate(5:end),dicom_data{d}.header.StudyTime],'.','')),dicom_data{d}.header.ContentDescription,'',dicom_data{d}.header.SOPInstanceUID};
        else
            list_of_data(d,:) = {dicom_data{d}.header.ContentLabel,[dicom_data{d}.header.InstanceCreationDate,dicom_data{d}.header.InstanceCreationTime],dicom_data{d}.modif_date,dicom_data{d}.dicom_dirname,dicom_data{d}.dicom_filename,dicom_data{d}.header.PatientID,dicom_data{d}.header.PatientName,dicom_data{d}.header.Modality,dicom_data{d}.header.StudyID,[dicom_data{d}.header.StudyDate,dicom_data{d}.header.StudyTime],dicom_data{d}.header.ImageType,dicom_data{d}.header.SeriesInstanceUID,0,dicom_data{d}.header.ContentDescription,'',dicom_data{d}.header.SOPInstanceUID};
        end
    elseif(strcmp(dicom_data{d}.header.Modality,'REG'))
        list_of_data(d,:) = {dicom_data{d}.header.ContentLabel,[dicom_data{d}.header.InstanceCreationDate,dicom_data{d}.header.InstanceCreationTime],dicom_data{d}.modif_date,dicom_data{d}.dicom_dirname,dicom_data{d}.dicom_filename,dicom_data{d}.header.PatientID,dicom_data{d}.header.PatientName,dicom_data{d}.header.Modality,dicom_data{d}.header.StudyID,[dicom_data{d}.header.StudyDate,dicom_data{d}.header.StudyTime],'',dicom_data{d}.header.SeriesInstanceUID,0,dicom_data{d}.header.ContentDescription,'',dicom_data{d}.header.SOPInstanceUID};
    elseif(isDoseOrDoseRate(dicom_data{d}.header.Modality))
      %strcmp(dicom_data{d}.header.Modality,'RTDOSE'))
        beam_index = '';
        if(isfield(dicom_data{d}.header,'ReferencedRTPlanSequence'))
            if(isfield(dicom_data{d}.header.ReferencedRTPlanSequence,'Item_1'))
                if(isfield(dicom_data{d}.header.ReferencedRTPlanSequence.Item_1,'ReferencedFractionGroupSequence'))
                    if(isfield(dicom_data{d}.header.ReferencedRTPlanSequence.Item_1.ReferencedFractionGroupSequence.Item_1,'ReferencedBeamSequence'))
                        beam_index = ['beam ',num2str(dicom_data{d}.header.ReferencedRTPlanSequence.Item_1.ReferencedFractionGroupSequence.Item_1.ReferencedBeamSequence.Item_1.ReferencedBeamNumber)];
                    end
                end
            else
                if(isfield(dicom_data{d}.header.ReferencedRTPlanSequence{1},'ReferencedFractionGroupSequence'))
                    if(isfield(dicom_data{d}.header.ReferencedRTPlanSequence{1}.ReferencedFractionGroupSequence{1},'ReferencedBeamSequence'))
                        beam_index = ['beam ',num2str(dicom_data{d}.header.ReferencedRTPlanSequence{1}.ReferencedFractionGroupSequence{1}.ReferencedBeamSequence{1}.ReferencedBeamNumber)];
                    end
                end
            end
        end
        if(isfield(dicom_data{d}.header,'ReferencedRTPlanSequence'))
            if(isfield(dicom_data{d}.header.ReferencedRTPlanSequence,'Item_1'))
                ReferencedSOPInstanceUID = dicom_data{d}.header.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID;
            else
                ReferencedSOPInstanceUID = dicom_data{d}.header.ReferencedRTPlanSequence{1}.ReferencedSOPInstanceUID;
            end
        else
            ReferencedSOPInstanceUID = '';
        end
        list_of_data(d,:) = {dicom_data{d}.header.ContentLabel,[dicom_data{d}.header.InstanceCreationDate,dicom_data{d}.header.InstanceCreationTime],dicom_data{d}.modif_date,dicom_data{d}.dicom_dirname,dicom_data{d}.dicom_filename,dicom_data{d}.header.PatientID,dicom_data{d}.header.PatientName,dicom_data{d}.header.Modality,dicom_data{d}.header.StudyID,[dicom_data{d}.header.StudyDate,dicom_data{d}.header.StudyTime],'',ReferencedSOPInstanceUID,0,dicom_data{d}.header.ContentDescription,beam_index,dicom_data{d}.header.SOPInstanceUID};
    elseif(strcmp(dicom_data{d}.header.Modality,'RTSTRUCT'))
        try
            if(isfield(dicom_data{d}.header.StructureSetROISequence,'Item_1'))
                contourNames = ['{ ',dicom_data{d}.header.StructureSetROISequence.Item_1.ROIName];
                for StructCur=2:length(fieldnames(dicom_data{d}.header.ROIContourSequence))
                    StructCurItem   =   ['Item_',num2str(StructCur)];
                    contourNames    =   [contourNames,' , ',dicom_data{d}.header.StructureSetROISequence.(StructCurItem).ROIName];
                end
                contourNames    =   [contourNames,' }'];
                reference_frame = dicom_data{d}.header.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID;
            else
                contourNames = ['{ ',dicom_data{d}.header.StructureSetROISequence{1}.ROIName];
                for StructCur=2:length(dicom_data{d}.header.ROIContourSequence)
                    contourNames    =   [contourNames,' , ',dicom_data{d}.header.StructureSetROISequence{StructCur}.ROIName];
                end
                contourNames    =   [contourNames,' }'];
                reference_frame = dicom_data{d}.header.ReferencedFrameOfReferenceSequence{1}.RTReferencedStudySequence{1}.RTReferencedSeriesSequence{1}.SeriesInstanceUID;
            end
        catch
            contourNames    =   '{  }';
            disp([dicom_data{d}.dicom_filename,' is not a valid RT-Struct !!'])
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
        list_of_data(d,:) = {dicom_data{d}.header.ContentLabel,[dicom_data{d}.header.InstanceCreationDate,dicom_data{d}.header.InstanceCreationTime],dicom_data{d}.modif_date,dicom_data{d}.dicom_dirname,dicom_data{d}.dicom_filename,dicom_data{d}.header.PatientID,dicom_data{d}.header.PatientName,dicom_data{d}.header.Modality,dicom_data{d}.header.StudyID,[dicom_data{d}.header.StudyDate,dicom_data{d}.header.StudyTime],'',reference_frame,0,dicom_data{d}.header.ContentDescription,contourNames,dicom_data{d}.header.SOPInstanceUID};
    elseif(strcmp(dicom_data{d}.header.Modality,'RTPLAN'))
        try
            f_names = fieldnames(dicom_data{d}.header.IonBeamSequence);
            field_list = '';
            for f=1:length(f_names)
                if(strcmp(dicom_data{d}.header.IonBeamSequence.(f_names{f}).TreatmentDeliveryType,'TREATMENT'))
                    field_list = [field_list,' , ',dicom_data{d}.header.IonBeamSequence.(f_names{f}).BeamName];
                end
            end
            field_list = ['{ ',field_list(4:end),' }'];
        catch
            field_list = '';
        end
        if(isfield(dicom_data{d}.header.ReferencedStructureSetSequence,'Item_1'))
            reference_contours = dicom_data{d}.header.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID;
        else
            reference_contours = dicom_data{d}.header.ReferencedStructureSetSequence{1}.ReferencedSOPInstanceUID;
        end
        list_of_data(d,:) = {dicom_data{d}.header.ContentLabel,[dicom_data{d}.header.InstanceCreationDate,dicom_data{d}.header.InstanceCreationTime],dicom_data{d}.modif_date,dicom_data{d}.dicom_dirname,dicom_data{d}.dicom_filename,dicom_data{d}.header.PatientID,dicom_data{d}.header.PatientName,dicom_data{d}.header.Modality,dicom_data{d}.header.StudyID,[dicom_data{d}.header.StudyDate,dicom_data{d}.header.StudyTime],'',reference_contours,0,dicom_data{d}.header.RTPlanLabel,field_list,dicom_data{d}.header.SOPInstanceUID};
    else
        list_of_data(d,:) = {dicom_data{d}.header.ContentLabel,[dicom_data{d}.header.InstanceCreationDate,dicom_data{d}.header.InstanceCreationTime],dicom_data{d}.modif_date,dicom_data{d}.dicom_dirname,dicom_data{d}.dicom_filename,dicom_data{d}.header.PatientID,dicom_data{d}.header.PatientName,dicom_data{d}.header.Modality,dicom_data{d}.header.StudyID,[dicom_data{d}.header.StudyDate,dicom_data{d}.header.StudyTime],'',[],0,dicom_data{d}.header.ContentDescription,'',dicom_data{d}.header.SOPInstanceUID};
    end
end

if(nargin>2 || update_mode)
    if(size(input_list_of_data,2)<nb_items)
        input_list_of_data = [input_list_of_data,cell(size(input_list_of_data,1),nb_items-size(input_list_of_data,2))];
    end
    list_of_data = [input_list_of_data;list_of_data];
end

if(isempty(list_of_data))
    return
end

list_of_data = sortrows(list_of_data,3);
list_of_data = sortrows(list_of_data,4);
list_of_data = sortrows(list_of_data,2);

% Remove series of less than 2 images
series_ID = cell2mat(list_of_data(:,13));
IDs = unique(series_ID);
for i=1:length(IDs)
    if(sum(series_ID==IDs(i))==1)
        list_of_data{find(series_ID==IDs(i)),13} = 0;
    end
end
% Update 4D series IDs
current_serie_ID = max(cell2mat(list_of_data(:,13)))*1.1+1;
for i=1:size(list_of_data,1)
    if(list_of_data{i,13}==0)
        %list_of_data{i,13} = 0;
        if(sum(strcmp(list_of_data{i,8},{'CT','PT','REG'})))
            j=1;
            while j<i
                if(list_of_data{j,13}>=0 && strcmp(list_of_data{i,8},list_of_data{j,8}) && strcmp(list_of_data{i,9},list_of_data{j,9}) && strcmp(list_of_data{i,10},list_of_data{j,10}) && strcmp(list_of_data{i,11},list_of_data{j,11}))% HEURISTIC!!!! && strcmp(list_of_data{i,3}(1:11),list_of_data{j,3}(1:11))
                    if(list_of_data{j,13}>0)
                        list_of_data{i,13} = list_of_data{j,13};
                    else
                        list_of_data{j,13} = current_serie_ID;
                        list_of_data{i,13} = current_serie_ID;
                        current_serie_ID = current_serie_ID*1.1+1;
                    end
                    j=i;
                end
                j=j+1;
            end
        end
    end
end
% Remove series of less than 2 images
series_ID = cell2mat(list_of_data(:,13));
IDs = unique(series_ID);
for i=1:length(IDs)
    if(sum(series_ID==IDs(i))==1)
        list_of_data{find(series_ID==IDs(i)),13} = 0;
    end
end

% Re-attribute previous labels if removed during re-listing
current_labels = list_of_data(:,1);
missing_labels = cell(0);
corresponding_data = cell(0);
for i=1:size(previous_list_of_data,1)
    if(not(isempty(previous_list_of_data{i,1})))
        if(sum(strcmp(previous_list_of_data{i,1},current_labels))==0)
            missing_labels{length(missing_labels)+1} = previous_list_of_data{i,1};
            corresponding_data{length(missing_labels)} = i;
        end
    end
end
for i=1:length(missing_labels)
    f_name = strcmp(list_of_data(:,5),previous_list_of_data{corresponding_data{i},5});
    if(sum(f_name))
        indices = find(f_name);
        for j=1:length(indices)
            if(isempty(list_of_data{indices(j)}))
                list_of_data{indices(j),1} = missing_labels{i};
            end
        end
    end
end

if(update_mode)
    cd(patient_dir)
    output = list_of_data;
    save reggui_patient_file.mat output
end

cd(current_dir);
