%% Deform_rtstruct
% Loads anatomical contours from the DICOM RT struct file |inname|. Then applies a deformation field |field_name| and an (optional) rigid transform |transform_name| to the anatomical contours. % The deformed contours are saved in a DICOM file.
%
%% Syntax
% |res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician)|
%
% |res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician,transform_name)|
%
% |res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician,transform_name,input_dicom_tags)|
%
% |res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician,transform_name,input_dicom_tags,orig_image)|
%
%
%% Description
% |res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician)| Apply the deformation field to the contours. Save the RT struct with defined smoothing
%
% |res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician,transform_name)| Apply the rigid deformation and the deformation field to the contours. Save the RT struct with defined smoothing
%
% |res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician,transform_name,input_dicom_tags)| Apply the rigid deformation and the deformation field to the contours. Save the RT struct with defined smoothing and additional DICOM tags
%
% |res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician,transform_name,input_dicom_tags,orig_image)| Apply the rigid deformation and the deformation field to the contours. Save the RT struct with defined smoothing and additional DICOM tags. Use pixel size and spacing from image file |orig_image|
%
%
%% Input arguments
% |inname| - _STRING_ -  - _STRING_ - Name of the file of DICOM RT-struct
%
% |ref_image_name| - _STRING_ -  Name of the CT scan (asociated to the contours) stored in |handles.images|. The size and spacing information from the image will be used 
%
% |field_name| - _STRING_ - Name of the deformation field (stored in |handles.fields| to apply to the contours
%
% |outname| - _STRING_ - Name of the DICOM file in the deformed contours will be stored
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure: 
%
% * |handles.images.name{i}| - _CELL VECTOR of STRING_ - Name of the ith image
% * |handles.images.data{i}| - _CELL VECTOR of SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.images.info{i}| - _STRUCTURE_ DICOM Information about the ith image
% * |handles.fields.name{i}| - _STRING_ - Name of the ith field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |data(1,x,y,z)| is X component of the deformation ith field at the voxel (x,y,z). The Y and Z components are defined in matrix components |data(2,x,y,z)| and |data(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the ith deformation field
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - [OPTIONAL] Matrix describing a RIGID transform to be applied before the deformation field (where XXX is |mydata| or |fields|)
% * ---|handles.XXX.data{i}(1,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in pixels) of the origin of the *image* C.S. (i.e. of the |handles.origin| C.S.)
% * ---|handles.XXX.data{i}(2,:)| - _SCALAR VECTOR_ Translation vector (x,y,z) (in mm) of the origin of the *patient* C.S. (i.e. of the DICOM |ImagePositionPatient| C.S.)
% * ---|handles.XXX.data{i}(3-5,:)| - _SCALAR VECTOR_ Rotation matrix 3x3 matrix
% * |handles.log_filename| - _STRING_ - Name of the file where REGGUI is storing the message log
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
% * |handles.origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
% |physician| - _INTEGER_ - [OPTIONAL. Default : 0] 0 = not physician. 1 = physician. Smoothing of the contour to remove 'stair effects' 
%
% |transform_name| - _STRING_ - Name of the RIGID transformation contained in |handles.mydata| or |handles.fields|
%
% |input_dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the RT struct file 
%
% * |input_dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |input_dicom_tags{i,2}| - _ANY_ Value of the tag
%
% |orig_image| - _STRING_ - [OPTIONAL] File name of the image to use to define the size and pixel spacing. If absent, uses the size and spacing from |handles|.
%
%
%% Output arguments
%
% |res = handles| - _STRUCTURE_ -  REGGUI data structure. No change to the input.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Deform_rtstruct(inname,ref_image_name,field_name,outname,handles,physician,transform_name,input_dicom_tags,orig_image)

for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},ref_image_name))
        infoImage = handles.images.info{i};
        imageSize = size(handles.images.data{i});
        spacing = handles.images.info{i}.Spacing;
        origin = handles.images.info{i}.ImagePositionPatient;
    end
end

use_orig_image = 0;
if(nargin>8)
    try
        [myOrigDir,myOrigFilename] = fileparts(orig_image);
        [origImage,origInfo] = load_Image(myOrigDir,myOrigFilename,'dcm');
        imageSize = size(origImage);
        spacing = origInfo.Spacing;
        origin = origInfo.ImagePositionPatient;
        use_orig_image = 1;
    catch
        disp('Could not open image.')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
    end
end    

myField = cell(0);
infoField = cell(0);
if(iscell(field_name)) % multiple transformations
    for j=1:length(myField)
        for i=1:length(handles.fields.name)
            if(strcmp(handles.fields.name{i},field_name{j}))
                infoField{j} = handles.fields.info{i};
                myField{j} = handles.fields.data{i};
            end
        end
    end
else % single transformation
    for i=1:length(handles.fields.name)
        if(strcmp(handles.fields.name{i},field_name))
            infoField{1} = handles.fields.info{i};
            myField{1} = handles.fields.data{i};
        end
    end
end

if(nargin>6)
    myTransform = [];
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},transform_name))
            infoTransform = handles.mydata.info{i};
            myTransform = handles.mydata.data{i};
        end
    end
    for i=1:length(handles.fields.name)
        if(strcmp(handles.fields.name{i},transform_name))
            infoTransform = handles.fields.info{i};
            myTransform = handles.fields.data{i};
        end
    end
end

try
    if(use_orig_image)
        input_RT = read_dicomrtstruct(inname,origInfo);
    else
        input_RT = read_dicomrtstruct(inname,infoImage);
    end
catch ME
    reggui_logger.info(['Not able to read the input RT struct using given reference image information. ',ME.message],handles.log_filename);
    rethrow(ME);
end

nlins = length(input_RT.Struct);

if(nargin<6)
    physician = 0;
elseif(physician>0)
    disp('Polylines will be smoothed...')
end

% Create a DICOM RTSTRUCT structure

% current time
Date = datestr(now,'yyyymmdd');
Time = datestr(now,'HHMMSS');

% general info
adapt_uids = 0;
if(strcmp(input_RT.DicomHeader.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID,infoImage.SeriesInstanceUID))
    disp('Same SeriesInstanceUIDs in image and RTStruct to be deformed. Continue...')
else
    disp('Different SeriesInstanceUIDs in image and RTStruct to be deformed.')
    disp(['   Output image: ',infoImage.SeriesInstanceUID]);
    disp(['   Input RTStruct: ',input_RT.DicomHeader.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID]);
    disp('   UIDs will be modified...')
    adapt_uids = 1;
end
infoRS = input_RT.DicomHeader;
infoRS.InstanceCreationDate = Date;
infoRS.InstanceCreationTime = Time;
infoRS.ContentLabel = '';
infoRS.ContentDescription = '';
onum = 0;
if(isempty(outname))
    outname = [inname(1:end-4) '_def'];
end

% correct uids in input RTStruct
if(adapt_uids)
    % copy study info from image
    if(isfield(infoImage.OriginalHeader,'StudyDescription'))
        infoRS.StudyID = infoImage.OriginalHeader.StudyID;
    else
        infoRS.StudyID = '';
    end
    if(isfield(infoImage.OriginalHeader,'StudyDescription'))
        infoRS.StudyDescription = infoImage.OriginalHeader.StudyDescription;
    else
        infoRS.StudyDescription = '';
    end
    infoRS.StudyDate = infoImage.OriginalHeader.StudyDate;
    infoRS.StudyTime = infoImage.OriginalHeader.StudyDate;
    infoRS.StudyInstanceUID = infoImage.OriginalHeader.StudyInstanceUID;
    % frame of reference taken from CT scan
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID = infoImage.FrameOfReferenceUID;
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPClassUID = '1.2.840.10008.3.1.2.3.1'; % Study Management Detached
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID = infoRS.StudyInstanceUID;
    infoRS.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = infoImage.SeriesInstanceUID;
    for StructCur=1:onum
        StructCurItem   =   ['Item_',num2str(StructCur)];
        infoRS.StructureSetROISequence.(StructCurItem).ReferencedFrameOfReferenceUID = infoImage.FrameOfReferenceUID;
        SliceCur        =   1;
        SliceCurItem    =   'Item_1';
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
if(length(infoImage.SOPInstanceUID)~=nslis)
    disp('Wrong number of SOPInstanceUIDs in image info (it might be due to resampling ?).')
end
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
def_waitbar = waitbar(0,{'Deforming volume structures...'});
% Correct for translation if rigid transform
translation = zeros(1,3);
if(nargin>6 && not(isempty(myTransform)) && not(use_orig_image))
    translation = sign(myTransform(2,:)).*floor(abs(myTransform(2,:))./infoImage.Spacing').*infoImage.Spacing';% extract the 'integer' translation
    myTransform(2,:) = sign(myTransform(2,:)).*mod(abs(myTransform(2,:)),infoImage.Spacing');% compute the remaining translation      
elseif(use_orig_image)
    data_translation = myTransform(2,:);
    myTransform(1:2,:) = 0;
end

for ilin = 1:nlins
    % clear structure
    clear ConSeq

    outdata = zeros(imageSize,'single');
    try
        points = input_RT.Struct(ilin).Slice;
    catch
        disp('Invalid number !');
    end

    for slices = 1:imageSize(3)
        coordX = [];
        coordY = [];
        myMat_temp = zeros(imageSize(1),imageSize(2));
        for contSlices = 1:size(points,2)
            if ( (points(contSlices).Z(1)-translation(3) >= (slices-1.5)*spacing(3)+origin(3)) && ...
                    (points(contSlices).Z(1)-translation(3) < (slices-0.5)*spacing(3)+origin(3)) );
                coordY = (points(contSlices).X-translation(1)-origin(1))/spacing(1)+1;
                coordX = (points(contSlices).Y-translation(2)-origin(2))/spacing(2)+1;
                coordX = [coordX; coordX(1)];
                coordY = [coordY; coordY(1)];
                myMat_temp = or(poly2mask(double(coordX),double(coordY),imageSize(1),imageSize(2)),myMat_temp);
            end
        end
        outdata(:,:,slices) = single(myMat_temp);
    end
    
    % Rigid transformation of the binary mask
    if(use_orig_image)        
        if(length(size(outdata))==2)
            outdata = rigid_deformation2D(outdata,myTransform,spacing,origin-data_translation');
        else
            outdata = rigid_deformation(outdata,myTransform,spacing,origin-data_translation');
        end
        data_origin = origin - data_translation';
        % If uses original image, resample to workspace
        orig = (- data_origin + handles.origin)./spacing +1;
        if(handles.spacing(1)>spacing(1))
            downfactor = handles.spacing(1)./spacing(1);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filterx = gaussian_kernel(fsz, sigma);
            filterx = filterx/sum(filterx);
            outdata = padarray(outdata, [length(filterx) 0 0], 'replicate');
            outdata = conv3f(outdata, single(filterx));
            outdata = outdata(length(filterx)+1:end-length(filterx), :, :);
        end
        if(handles.spacing(2)>spacing(2))
            downfactor = handles.spacing(2)./spacing(2);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filtery = gaussian_kernel(fsz, sigma);
            filtery = filtery'/sum(filtery);
            outdata = padarray(outdata, [0 length(filtery) 0], 'replicate');
            outdata = conv3f(outdata, single(filtery));
            outdata = outdata(:,length(filtery)+1:end-length(filtery), :);
        end
        if(handles.spacing(3)>spacing(3))
            downfactor = handles.spacing(3)./spacing(3);
            sigma = downfactor*.4;
            fsz = round(sigma * 5);
            fsz = fsz + (1-mod(fsz,2));
            filterz = gaussian_kernel(fsz, sigma);
            filterz = filterz/sum(filterz);
            outdata = padarray(outdata, [0 0 length(filterz)], 'replicate');
            outdata = conv3f(outdata, single(permute(filterz, [3 2 1])));
            outdata = outdata(:,:,length(filterz)+1:end-length(filterz));
        end
        lastpt = orig + (handles.size-1).*handles.spacing./spacing;
        outdata = resampler3(outdata,linspace(orig(1),lastpt(1),handles.size(1)),linspace(orig(2),lastpt(2),handles.size(2)),linspace(orig(3),lastpt(3),handles.size(3)));
        outdata(isnan(outdata))=0;  
    else
        if(nargin>6 && not(isempty(myTransform)))
            if(length(size(outdata))==2)
                outdata = rigid_deformation2D(outdata,myTransform,spacing,origin);
            else
                outdata = rigid_deformation(outdata,myTransform,spacing,origin);
            end
        end
    end
    
    % Deformation of the binary mask
    for j=1:length(myField)
        if(strcmp(infoField{j}.Type,'deformation_field'))
            outdata = linear_deformation(outdata, ' ', myField{j}, []);
        elseif(strcmp(infoField{j}.Type,'rigid_transform'))
            if(length(size(outdata))==2)
                outdata = rigid_deformation2D(outdata,myField{j},handles.spacing,handles.origin);
            else
                outdata = rigid_deformation(outdata,myField{j},handles.spacing,handles.origin);
            end
        else
            error('Not a valid type. Must be ''deformation_field'' or ''rigid_transform''')
        end
    end
    data_max = max(max(max(outdata)));
    outdata = outdata>data_max/2;
    % encode non-empty cells of line array into ContourSequence structure (ConSeq)
    item = 0;
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
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Oversampling
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
            current_slice_oversampled = imdilate(current_slice_oversampled,[0 1 0; 1 1 1; 0 1 0]);
            current_slice_oversampled(isinf(current_slice_oversampled)) = 0;
            boundCell = bwboundaries(current_slice_oversampled);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for ireg = 1:size(boundCell,1);
                bound = cell2mat(boundCell(ireg,1));
                if(physician)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Smoothing of the contour to remove 'stair effects' (for physicians !)
                    sigma = physician/100*2;
                    fsz = round(sigma * 5);
                    fsz = fsz + (1-mod(fsz,2));
                    smoother = gaussian_kernel(fsz, sigma);
                    smoother = smoother/sum(smoother);
                    min_curv = physician/500;
                    if(ceil(fsz/2)<size(bound,1))
                        bound_temp = [bound(end-ceil(fsz/2)+1:end,:);bound;bound(1:ceil(fsz/2),:)];
                        bound_temp = [conv(bound_temp(:,1),smoother) conv(bound_temp(:,2),smoother)];
                        %Removing low-curvature points
                        dx = conv(bound_temp(:,1),[-1 0 1])/2;
                        dy = conv(bound_temp(:,2),[-1 0 1])/2;
                        ddx = conv(bound_temp(:,1),[1 -2 1]);
                        ddy = conv(bound_temp(:,2),[1 -2 1]);
                        curvature = abs(dx.*ddy+dy.*ddx)./(dx.^2+dy.^2+eps).^(3/2);
                        curvature = curvature(fsz+2:end-fsz-1);
                        curvature(1:ceil((physician+1)/5):end)=min_curv+1;
                        bound = bound_temp(fsz+1:end-fsz,:);
                        bound = bound(find(curvature>min_curv),:);
                    end
                    bound = (bound+1.5)/3;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                else
                    %disp('Exporting contour without smoothing.')
                    bound = (bound+1.5)/3;
                end
                bound(:,1) = bound(:,1)+minimum(1)-1;
                bound(:,2) = bound(:,2)+minimum(2)-1;
                %Removing low-curvature points
                dx = conv(bound(:,1),[-1 0 1])/2;
                dy = conv(bound(:,2),[-1 0 1])/2;
                ddx = conv(bound(:,1),[1 -2 1]);
                ddy = conv(bound(:,2),[1 -2 1]);
                curvature = abs(dx.*ddy+dy.*ddx)./(dx.^2+dy.^2+eps).^(3/2);
                curvature = curvature(2:end-1);
                %curvature(1:20:end)=1;
                bound = bound(1:end,:);
                bound = bound(find(curvature>0),:);
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
    if(item==0)
        %continue; % if empty, skip
        onum = onum + 1; 
        ConSeq = [];
    else
        onum = onum + 1; 
    end 
    Item_onum = ['Item_', sprintf('%i',onum)];
    %---------------- StructureSetROISequence ----------------%
    infoRS.StructureSetROISequence.(Item_onum).ROINumber = onum-1;
    infoRS.StructureSetROISequence.(Item_onum).ReferencedFrameOfReferenceUID = infoImage.FrameOfReferenceUID;
    infoRS.ROIContourSequence.(Item_onum).ContourSequence = ConSeq;
    waitbar(ilin/(nlins+1),def_waitbar);
end
% input dicom data
if(nargin>7)
    for i=1:size(input_dicom_tags,1)
        try
            infoRS.(input_dicom_tags{i,1}) = input_dicom_tags{i,2};
            disp(['Dicom tag ',input_dicom_tags{i,1},' = ',input_dicom_tags{i,2}])
        catch
        end
    end
end
waitbar(nlins/(nlins+1),def_waitbar,'Exporting dicom structure...');
dicomwrite([],[outname '.dcm'],infoRS,'CreateMode','Copy');
close(def_waitbar)

res = handles;
