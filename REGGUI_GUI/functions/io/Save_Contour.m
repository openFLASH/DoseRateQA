%% Save_Contour
% Write on disk several DICOM RT structures into a DICOM file using binary masks stored in |handles.images.data|. If |format = 'pacs'|, the contours are saved to the Orthanc PACS instead of the local disk.
% The surface of the binary mask is identified in order to define the contours in each slice of the CT scan. Several binary masks can be used in roder to create several RT structures in the exported DICOM file.
% Optionally, the contours can be smoothed before saving to remove 'stair effects'.
%
%% Syntax
% |infoRS = Save_Contour(selection,infoImage,outname,handles)|
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours)|
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags)|
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags,inname)|
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags,inname,new_contour_names)|
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags,inname,new_contour_names,format)|
%
%% Description
% |infoRS = Save_Contour(selection,infoImage,outname,handles)| Save the RT struct with no smoothing of contours
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours)| Save the RT struct with defined smoothing
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags)| Save the RT struct with defined smoothing and additional DICOM tags
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags,inname)| Save the RT struct by appending to new data to existing file using the defined smoothing and provided additional DICOM tags
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags,inname,new_contour_names)| Use new contour names in the export
%
% |infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags,inname,new_contour_names,format)| Define the format of exported data
%
%% Input arguments
% |selection| - _INTEGER VECTOR_ - |selection(i)| Index of the i-th structure stored in |handles.images.data{selection(i)}| shall be included in the exported DICOM RT structure
%
% |infoImage| - _STRUCTURE_ DICOM Information about the contours to be saved in the DICOM file
%
% * |infoImage.OriginalHeader.StudyID| - _STRING_ -
% * |infoImage.OriginalHeader.StudyDescription| - _STRING_ -
% * |infoImage.OriginalHeader.StudyDate| - _STRING_ -
% * |infoImage.OriginalHeader.StudyInstanceUID| - _STRING_ -
% * |infoImage.OriginalHeader.PatientName| - _STRING_ -
% * |infoImage.OriginalHeader.PatientID| - _STRING_ -
% * |infoImage.OriginalHeader.PatientBirthDate| - _STRING_ -
% * |infoImage.OriginalHeader.PatientSex| - _STRING_ -
% * |infoImage.FrameOfReferenceUID| - _STRING_ -
% * |infoImage.SeriesInstanceUID| - _STRING_ -
% * |infoImage.ImagePositionPatient| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |infoImage.Spacing| - _SCALAR VECTOR_ - Pixel size (|mm|)
% * |infoImage.SOPClassUID| - _STRING_ -
% * |infoImage.SOPInstanceUID(i).SOPInstanceUID| - _STRING_ - SOPInstanceUID of the contour in the i-th slice
%
% |outname| - _STRING_ -  [OPTIONAL] Name of the new file that will contain the DICOM RT-struct. If absent, the new file name is [inname '_ext']
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed.
%
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| 1= the pixel at (x,y,z) belongs to the i-th structure. 1= the pixel at (x,y,z) does not belong to the i-th structure.
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |smooth_contours| - _INTEGER_ - [OPTIONAL. Default : 0] |0<=smooth_contours<=100|. Apply a gaussian filtering to the contour to remove remove 'stair effects'. |smooth_contours| is proportional to the sigma of the Gaussian. Set |smooth_contours=0| not to apply any smoothing.
%
% |input_dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the RT struct file
%
% * |input_dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |input_dicom_tags{i,2}| - _ANY_ Value of the tag
%
% |inname| - _STRING_ - [OPTIONAL] Name of the file of DICOM RT-struct to which the new contours will be appended. If absent, a new file is created.
%
% |new_contours_names| - _CELL VECTOR of STRING_ - |new_contours_names{i}| Replaces the name of i-th contour to be exported
%
% |format| - _STRING_ -   [OPTIONAL. Default : 'dcm'] Format to use to save the file. The options are: 
%
% * 'pacs' : Send the image to Orthanc PACS
% * 'dcm' : DICOM File
%
%% Output arguments
%
% |infoRS| - _STRUCTURE_ - Structure with the DICOM data that has been saved on disk
%
%
%% Contributors
% Script written by John Lee (UCL/MD/MINT/IMRE) for the IMREViewer
% Adapted by (UCL/EPL/ELEC/TELE) to be used in REGGUIC by G. Janssens (open.reggui@gmail.com)

function infoRS = Save_Contour(selection,infoImage,outname,handles,smooth_contours,input_dicom_tags,inname,new_contours_names,format)

if(nargin<5)
    smooth_contours = 0;
end
if(nargin<6)
    input_dicom_tags = {};
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

% current time
Date = datestr(now,'yyyymmdd');
Time = datestr(now,'HHMMSS');

% general info
infoRS.Filename = ''; % will be filled in by Matlab IPT
infoRS.FileModDate = ''; % will be filled in by Matlab IPT
infoRS.FileSize = 0; % will be filled in by Matlab IPT
infoRS.Format = 'DICOM';
infoRS.FormatVersion = 3;
infoRS.Width = [];
infoRS.Height = [];
infoRS.BitDepth = [];
infoRS.ColorType = '';
infoRS.SelectedFrames = []; % instead of: infoCT.SelectedFrames;
infoRS.FileStruct.Location = ''; % will be filled in by Matlab IPT
infoRS.FileStruct.Messages = {''}; % will be filled in by Matlab IPT
infoRS.FileStruct.Current_Message = 0; % will be filled in by Matlab IPT
infoRS.FileStruct.FID = 0; % will be filled in by Matlab IPT
infoRS.FileStruct.Current_Endian = ''; % will be filled in by Matlab IPT
infoRS.FileStruct.Pixel_Endian = ''; % will be filled in by Matlab IPT
infoRS.FileStruct.Current_VR = ''; % will be filled in by Matlab IPT
infoRS.FileStruct.Warn.Current = 0; % will be filled in by Matlab IPT
infoRS.FileStruct.Warn.Max = Inf; % will be filled in by Matlab IPT
infoRS.StartOfPixelData = 0; % will be filled in by Matlab IPT
infoRS.FileMetaInformationGroupLength = 0; % will be filled in by Matlab IPT
infoRS.FileMetaInformationVersion = 0; % will be filled in by Matlab IPT
infoRS.Modality = 'RTSTRUCT'; % RTSTRUCT file
infoRS.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.481.3'; % RTSTRUCT file
infoRS.MediaStorageSOPInstanceUID = dicomuid;
infoRS.TransferSyntaxUID = '1.2.840.10008.1.2';
infoRS.ImplementationClassUID = '1.2.250.1.59.3.0.3.5.0';
infoRS.InstanceCreationDate = Date;
infoRS.InstanceCreationTime = Time;
infoRS.SOPClassUID = '1.2.840.10008.5.1.4.1.1.481.3'; %RTSTRUCT file
infoRS.SOPInstanceUID = infoRS.MediaStorageSOPInstanceUID; % instead of: dicomuid;
infoRS.AccessionNumber = ''; % instead of: infoCT.AccessionNumber;
% study info
if(isfield(infoImage.OriginalHeader,'StudyID'))
    infoRS.StudyID = infoImage.OriginalHeader.StudyID;
else
    infoRS.StudyID = '';
end
if(isfield(infoImage.OriginalHeader,'StudyDescription'))
    infoRS.StudyDescription = infoImage.OriginalHeader.StudyDescription;
else
    infoRS.StudyDescription = '';
end
if(isfield(infoImage.OriginalHeader,'StudyDate'))
    infoRS.StudyDate = infoImage.OriginalHeader.StudyDate;
else
    infoRS.StudyDate = '';
end
if(isfield(infoImage.OriginalHeader,'StudyDate'))
    infoRS.StudyTime = infoImage.OriginalHeader.StudyTime;
else
    infoRS.StudyDate = '';
end
if(isfield(infoImage.OriginalHeader,'StudyInstanceUID'))
    infoRS.StudyInstanceUID = infoImage.OriginalHeader.StudyInstanceUID; % instead of: dicomuid
else
    infoRS.StudyInstanceUID = '';
end
infoRS.SeriesDescription = 'REGGUI RT Structure Set';
infoRS.SeriesInstanceUID = dicomuid;
infoRS.SeriesNumber = '';
% reset content info
infoRS.ContentLabel = '';
infoRS.ContentDescription = '';
% patient info
if(isfield(infoImage.OriginalHeader,'PatientName'))
    infoRS.PatientName = infoImage.OriginalHeader.PatientName;
else
    infoRS.PatientName = '';
end
if(isfield(infoImage.OriginalHeader,'PatientID'))
    infoRS.PatientID = infoImage.OriginalHeader.PatientID;
else
    infoRS.PatientID = '';
end
if(isfield(infoImage.OriginalHeader,'PatientBirthDate'))
    infoRS.PatientBirthDate = infoImage.OriginalHeader.PatientBirthDate;
else
    infoRS.PatientBirthDate = '';
end
if(isfield(infoImage.OriginalHeader,'PatientSex'))
    infoRS.PatientSex = infoImage.OriginalHeader.PatientSex;
else
    infoRS.PatientSex = '';
end
%----------- ReferencedFrameOfReferenceSequence ----------%
% frame of reference taken from CT scan
infoRS.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID = infoImage.FrameOfReferenceUID;
infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPClassUID = '1.2.840.10008.3.1.2.3.1'; % Study Management Detached
infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID = infoRS.StudyInstanceUID;
infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = infoImage.SeriesInstanceUID;
% if exported contours as complement of an existing rt-struct
adapt_uids = 0;
add_to_existing_file = exist(inname,'file');
if(add_to_existing_file)
    input_RT = read_dicomrtstruct(inname,infoImage);
    if(strcmp(input_RT.DicomHeader.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID,infoImage.SeriesInstanceUID))
        disp('Same SeriesInstanceUIDs in image and RTStruct to be extended. Continue...')
    else
        disp('Different SeriesInstanceUIDs in image and RTStruct to be extended.')
        disp(['   Output image: ',infoImage.SeriesInstanceUID]);
        disp(['   Input RTStruct: ',input_RT.DicomHeader.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID]);
        disp('   UIDs will be modified...')
        adapt_uids = 1;
    end
    infoRS = input_RT.DicomHeader;
    infoRS.InstanceCreationDate = Date;
    infoRS.InstanceCreationTime = Time;
    onum = input_RT.StructNum;
    if(isempty(outname))
        outname = [inname(1:end-4) '_ext'];
    end
else
    onum = 0;
end
% correct uids in input RTStruct
if(add_to_existing_file && adapt_uids)
    % frame of reference taken from CT scan
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID = infoImage.FrameOfReferenceUID;
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID = infoRS.StudyInstanceUID;
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = infoImage.SeriesInstanceUID;
    for StructCur=1:onum
        StructCurItem   =   ['Item_',num2str(StructCur)];
        infoRS.StructureSetROISequence.(StructCurItem).ReferencedFrameOfReferenceUID = infoImage.FrameOfReferenceUID;
        SliceCur        =   1;
        SliceCurItem    =   'Item_1';
        if(~isfield(infoRS.ROIContourSequence.(StructCurItem), 'ContourSequence'))
            continue
        end
        while isfield(infoRS.ROIContourSequence.(StructCurItem).ContourSequence,SliceCurItem)
            Z = infoRS.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(3:3:end);
            slice_index = (Z(1)-infoImage.ImagePositionPatient(3))/infoImage.Spacing(3) + 1;
            infoRS.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourImageSequence.Item_1.ReferencedSOPInstanceUID = infoImage.SOPInstanceUID(slice_index).SOPInstanceUID;
            SliceCur        =   SliceCur+1;
            SliceCurItem    =   ['Item_',num2str(SliceCur)];
        end
    end
end
% structure set info
infoRS.StructureSetLabel = 'REGGUI';
infoRS.StructureSetDate = Date;
infoRS.StructureSetTime = Time;
% for each slice
nslis = handles.size(3);%datasets.array(setindex).ddim(3);
nlins = size(selection,2);%length(datasets.array(setindex).lines.array);
for isli = 1:nslis
    % Item_<isli> string
    Item_isli = ['Item_', sprintf('%i',nslis-isli+1)];
    % refer to CT SOP
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(Item_isli).ReferencedSOPClassUID = infoImage.SOPClassUID; % normally '1.2.840.10008.5.1.4.1.1.2' for CT
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(Item_isli).ReferencedSOPInstanceUID = infoImage.SOPInstanceUID(isli).SOPInstanceUID;
end
%---------------- StructureSetROISequence ----------------%
%------------------- ROIContourSequence ------------------%
%--------------- RTROIObservationsSequence ---------------%
for ilin = 1:nlins
    % clear structure
    clear ConSeq
    outdata = handles.images.data{selection(ilin)};
    data_max = max(max(max(outdata)));
    outdata = outdata>=data_max/2;
    % encode non-empty cells of line array into ContourSequence structure (ConSeq)
    item = 0;
    if(smooth_contours>0)
        disp('Smoothing will be applied on polylines...')
    end
    for isli = nslis:-1:1
        Item_isli = ['Item_', sprintf('%i',isli)];
        % find region of interest
        current_slice = outdata(:,:,end-isli+1);
        bb = [2;2;2];
        [i,j] = find(current_slice);
        if (~isempty(i))
            minimum = [max(1,min(i)-bb(1));max(1,min(j)-bb(2))];
            maximum = [min(handles.size(1),max(i)+bb(1));min(handles.size(2),max(j)+bb(2))];
            current_slice = current_slice(minimum(1):maximum(1),minimum(2):maximum(2));
            % Oversampling
            if(smooth_contours<0)% old method (slow)
                current_slice_oversampled = zeros(3*size(current_slice));
                current_slice_oversampled(1:3:end-2,1:3:end-2) = current_slice;
                current_slice_oversampled(1:3:end-2,2:3:end-1) = current_slice;
                current_slice_oversampled(1:3:end-2,3:3:end) = current_slice;
                current_slice_oversampled(2:3:end-1,1:3:end-2) = current_slice;
                current_slice_oversampled(2:3:end-1,2:3:end-1) = current_slice;
                current_slice_oversampled(2:3:end-1,3:3:end) = current_slice;
                current_slice_oversampled(3:3:end,1:3:end-2) = current_slice;
                current_slice_oversampled(3:3:end,2:3:end-1) = current_slice;
                current_slice_oversampled(3:3:end,3:3:end) = current_slice;
                [boundCell_temp,~,~] = bwboundaries(current_slice_oversampled);
                current_slice_oversampled = imdilate(current_slice_oversampled,[0 1 0; 1 1 1; 0 1 0]);
                current_slice_oversampled(isinf(current_slice_oversampled)) = 0;
                [boundCell,~,N] = bwboundaries(current_slice_oversampled);
            else
                current_slice = imresize(current_slice,3,'nearest');
                [boundCell,~,N] = bwboundaries(current_slice);
                boundCell_temp = boundCell;
            end
            for ireg = 1:size(boundCell,1)
                if(ireg>N)
                    bound = cell2mat(boundCell_temp(ireg,1));
                else
                    bound = cell2mat(boundCell(ireg,1));
                end
                if(smooth_contours>0)
                    % Smoothing of the contour to remove 'stair effects' (for physicians !)
                    sigma = smooth_contours/100*2;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    smoother = gaussian_kernel(fsz, sigma);
                    smoother = smoother/sum(smoother);
                    min_curv = smooth_contours/500;
                    if(ceil(fsz/2)<size(bound,1))
                        bound_temp = [bound(end-ceil(fsz/2)+1:end,:);bound;bound(1:ceil(fsz/2),:)];
                        bound_temp = [conv(bound_temp(:,1),smoother) conv(bound_temp(:,2),smoother)];
                        %Removing low-curvature points
                        dx = conv(bound_temp(:,1),[-1 0 1])/2;
                        dy = conv(bound_temp(:,2),[-1 0 1])/2;
                        ddx = conv(bound_temp(:,1),[1 -2 1]);
                        ddy = conv(bound_temp(:,2),[1 -2 1]);
                        curvature = abs(dx.*ddy-dy.*ddx)./(dx.^2+dy.^2+eps).^(3/2);
                        curvature = curvature(fsz+2:end-fsz-1);
                        curvature(1:ceil((smooth_contours+1)/5):end)=min_curv+1;
                        bound = bound_temp(fsz+1:end-fsz,:);
                        bound = bound(find(curvature>min_curv),:);
                    end
                end
                bound = (bound+1)/3;
                bound(:,1) = bound(:,1)+minimum(1)-1;
                bound(:,2) = bound(:,2)+minimum(2)-1;
                %Removing low-curvature points
                dx = conv(bound(:,1),[-1 0 1])/2;
                dy = conv(bound(:,2),[-1 0 1])/2;
                ddx = conv(bound(:,1),[1 -2 1]);
                ddy = conv(bound(:,2),[1 -2 1]);
                curvature = abs(dx.*ddy-dy.*ddx)./(dx.^2+dy.^2+eps).^(3/2);
                curvature = curvature(2:end-1);
                %curvature(1:20:end)=1;
                bound = bound(1:end,:);
                bound = bound(find(curvature>eps),:);
                % number of vertices in current line
                nvers = size(bound,1) - 1;
                % if line has two vertices at least
                if 1<nvers
                    % new item
                    item = item + 1;
                    % Item_<item> string
                    Item_item = ['Item_', sprintf('%i',item)];
                    %------------------- ROIContourSequence ------------------%
                    % image associated to contour (only one in this case)
                    ConSeq.(Item_item).ContourImageSequence.Item_1.ReferencedSOPClassUID = infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(Item_isli).ReferencedSOPClassUID; % see above
                    ConSeq.(Item_item).ContourImageSequence.Item_1.ReferencedSOPInstanceUID = infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(Item_isli).ReferencedSOPInstanceUID; % see above
                    % contour type and size
                    ConSeq.(Item_item).ContourGeometricType = 'CLOSED_PLANAR';
                    ConSeq.(Item_item).NumberOfContourPoints = nvers;
                    ConSeq.(Item_item).ContourNumber = item;
                    % offsets
                    X = (bound(:,1)-1)*handles.spacing(1)+handles.origin(1);
                    Y = (bound(:,2)-1)*handles.spacing(2)+handles.origin(2);
                    Z = (nslis-isli)*ones(nvers,1)*handles.spacing(3)+handles.origin(3);
                    X = X(1:end-1);
                    Y = Y(1:end-1);
                    ContourData = [X,Y,Z];
                    ContourData = reshape(ContourData',1,3*nvers);
                    ConSeq.(Item_item).ContourData = ContourData;
                end
            end
        end
    end
    if item==0, continue; else onum = onum + 1; end % if empty, skip
    Item_onum = ['Item_', sprintf('%i',onum)];
    if(add_to_existing_file)
        Prev_onum = ['Item_', sprintf('%i',onum-1)];
    end
    %---------------- StructureSetROISequence ----------------%
    if(add_to_existing_file)
        infoRS.StructureSetROISequence.(Item_onum).ROINumber = infoRS.StructureSetROISequence.(Prev_onum).ROINumber + 1;
        infoRS.StructureSetROISequence.(Item_onum).ReferencedFrameOfReferenceUID = infoRS.StructureSetROISequence.(Prev_onum).ReferencedFrameOfReferenceUID;
    else
        infoRS.StructureSetROISequence.(Item_onum).ROINumber = onum-1;
        infoRS.StructureSetROISequence.(Item_onum).ReferencedFrameOfReferenceUID = infoImage.FrameOfReferenceUID;
    end
    if(isempty(new_contours_names))      
        if(isfield(handles.images.info{selection(ilin)},'Contour_name'))
            infoRS.StructureSetROISequence.(Item_onum).ROIName = handles.images.info{selection(ilin)}.Contour_name;
        else
            infoRS.StructureSetROISequence.(Item_onum).ROIName = strrep(handles.images.name{selection(ilin)},'_',' ');
        end
    else
        infoRS.StructureSetROISequence.(Item_onum).ROIName = new_contours_names{ilin};
    end
    infoRS.StructureSetROISequence.(Item_onum).ROIGenerationAlgorithm = '';
    %------------------- ROIContourSequence ------------------%
    infoRS.ROIContourSequence.(Item_onum).ROIDisplayColor = round(255*rand(3,1));
    infoRS.ROIContourSequence.(Item_onum).ContourSequence = ConSeq;
    infoRS.ROIContourSequence.(Item_onum).ReferencedROINumber = infoRS.StructureSetROISequence.(Item_onum).ROINumber;
    %--------------- RTROIObservationsSequence ---------------%
    infoRS.RTROIObservationsSequence.(Item_onum).ObservationNumber = onum-1;
    infoRS.RTROIObservationsSequence.(Item_onum).ReferencedROINumber = infoRS.StructureSetROISequence.(Item_onum).ROINumber;
    infoRS.RTROIObservationsSequence.(Item_onum).ROIObservationLabel = infoRS.StructureSetROISequence.(Item_onum).ROIName(1:min(end,15));
    infoRS.RTROIObservationsSequence.(Item_onum).RTROIInterpretedType = '';
    infoRS.RTROIObservationsSequence.(Item_onum).ROIInterpreter.FamilyName = '';
    infoRS.RTROIObservationsSequence.(Item_onum).ROIInterpreter.GivenName  = '';
    infoRS.RTROIObservationsSequence.(Item_onum).ROIInterpreter.MiddleName = '';
    infoRS.RTROIObservationsSequence.(Item_onum).ROIInterpreter.NamePrefix = '';
    infoRS.RTROIObservationsSequence.(Item_onum).ROIInterpreter.NameSuffix = '';
end
% input dicom data
if(not(isempty(input_dicom_tags)))
    for i=1:size(input_dicom_tags,1)
        try
            infoRS.(input_dicom_tags{i,1}) = input_dicom_tags{i,2};
            disp(['Dicom tag ',input_dicom_tags{i,1},' = ',input_dicom_tags{i,2}])
        catch
            disp(['Cannot set dicom tag ',input_dicom_tags{i,1},' to ',input_dicom_tags{i,2}])
        end
    end
end

if(strcmp(format,'pacs'))
    [~,reggui_config_dir] = get_reggui_path();
    dirname = fullfile(reggui_config_dir,'temp_dcm_data');
    if(not(exist(dirname,'dir')))
        mkdir(dirname);
    end
    exported_file = fullfile(dirname,outname);
else
    exported_file = outname;
end
if(isempty(strfind(exported_file,'.dcm')))
    exported_file = [exported_file,'.dcm'];
end

% export dicom file to disk
dicomwrite([],exported_file,infoRS,'CreateMode','Copy');

% send to PACS if needed
if(strcmp(format,'pacs'))
    disp('Sending dicom file to PACS...')
    orthanc_import_from_disk('instances',exported_file);
    try
        delete(exported_file);
    catch
        disp(['Warning: cannot delete folder ',exported_file]);
    end
end
