%% Import_contour
% Import RT contours from Dicom RTstruct into REGGUI's internal data.
% Import observation point from Dicom RTstruct into REGGUI's internal data.
% The image can be stored as a DICOM file on the local disk or on the Orthanc PACS if |contours| specifies the UID of the instance stored on the PACS instead of a file name.
% structure. The name of the field of |handles| that will contain the contours is automatically created by combaning the name |image| with the name of the contour.
% The contours are stored in an image either in |handles.images| or in |handles.mydata|. This image has the same size, |spacing| and |origin| as the specified associated |image| (typically the CT scan that was used to generate the contours).
%
% Make sure that there is the same number of slices in the asociated image and the DICOM RTstruc file. Otherwise, if the inter-slice distance is smaller for the contours, several contours will be allocated to the same image slice, leading to 'holes' in the ContourSequence
% If the interslice distance of the contours is larger than that of the image, there will be slices with missing contours.
%
% The voxels belonging to the RTstruct have a value set to 1. The voxels located outside of the RTstruct have a value equal to 0.
% The observation point becomes a structure with one single voxel set to 1.
%
%
%% Syntax
% |handles = Import_contour(contours,selectedContours,image,type,handles)|
%
% |handles = Import_contour(contours,selectedContours,image,type,handles,contour_names)|

%% Description
% |handles = Import_contour(contours,selectedContours,image,type,handles)|
% Imports into REGGUI user selected contours from a Dicom RTstruct file
% with default assigned contour names.
%
% |handles = Import_contour(contours,selectedContours,image,type,handles,contour_names)|
% Imports into REGGUI user selected contours from a Dicom RTstruct file with
% user specified contour names.

%% Input arguments
% |contours| - _STRING_ - If |contours| is the name of a file on disk, and |contours| is the name of the RT structure Dicom file to load. If not, then the |contours| is the UID of the instance stored on the PACS.
%
% |selectedContours| - _VECTOR of INTEGER_ - Indices of selected contours within the RTStruct. Alternatively, it can be a list of names (_CELL of STRING_), or the string 'all' (if all elements in the RT-STRUCT must be imported).
%
% |image| - _STRING_ - Name of image in |handles.mydata| or |handles.images| to which the contours are associated. The value of |spacing|, |origin| and |imageSize| are reteived from this associated image.
%
% |type| - _INTEGER_ - Defines where the contour import is performed:
%
% * if |type = 1| the contours are imported in |handles.images|
% * if |type = 3| the contours are imported in |handles.mydata|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure.
%
% |contour_names| - _CELL of STRINGS_ - optional parameter that imposes
% given contour names over default names.

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI data structure containing imported
% contours.

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [handles,contour_names] = Import_contour(contours,selectedContours,image,type,handles,contour_names,exclude_empty)

if(nargin<7)
   exclude_empty = 0;   
end

% ------------------------------------------------------------------------
% if PACS, import dicom from orthanc and save it locally
if(ischar(contours))
    if(not(exist(contours,'file')))
        [~,reggui_config_dir] = get_reggui_path();
        temp_dir = fullfile(reggui_config_dir,'temp_dcm_data');
        if(not(exist(temp_dir,'dir')))
            mkdir(temp_dir);
        end
        image_dir = fullfile(temp_dir,contours);
        if(exist(image_dir,'dir'))
            try
                rmdir(image_dir,'s');
            catch
                disp(['Warning: cannot delete folder ',image_dir]);
            end
        end
        mkdir(image_dir);
        orthanc_save_to_disk(['instances/',contours,'/file'],fullfile(image_dir,'rtstruct.dcm')); % contours gives the UID of the instance
        if(nargin>5)
            handles = Import_contour(fullfile(image_dir,'rtstruct.dcm'),selectedContours,image,type,handles,contour_names);
        else
            handles = Import_contour(fullfile(image_dir,'rtstruct.dcm'),selectedContours,image,type,handles);
        end
        try
            rmdir(image_dir,'s');
        catch
        end
        return
    end
end
% ------------------------------------------------------------------------

if(type==1)
    myInfo = [];
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},image))
            spacing = handles.images.info{i}.Spacing;
            origin = handles.images.info{i}.ImagePositionPatient;
            imageSize = size(handles.images.data{i});
            myInfo = handles.images.info{i};
        end
    end
    if(isempty(myInfo))
        for i=1:length(handles.mydata.name)
            if(strcmp(handles.mydata.name{i},image))
                spacing = handles.mydata.info{i}.Spacing;
                origin = handles.mydata.info{i}.ImagePositionPatient;
                imageSize = size(handles.mydata.data{i});
                myInfo = handles.mydata.info{i};
                type = 3;
            end
        end
    end
    if(ischar(contours))
        try
            contours = read_dicomrtstruct(contours,myInfo);
        catch ME
            reggui_logger.info(['This is not a valid RTStruct file for the selected image. ',ME.message],handles.log_filename);
            rethrow(ME);
        end
    end
elseif(type==3)
    for i=1:length(handles.mydata.name)
        if(strcmp(handles.mydata.name{i},image))
            spacing = handles.mydata.info{i}.Spacing;
            origin = handles.mydata.info{i}.ImagePositionPatient;
            imageSize = size(handles.mydata.data{i});
            myInfo = handles.mydata.info{i};
        end
    end
    if(ischar(contours))
        try
            contours = read_dicomrtstruct(contours,myInfo);
        catch ME
            reggui_logger.info(['This is not a valid RTStruct file for the selected image. ',ME.message],handles.log_filename);
            rethrow(ME);
        end
    end
else
    error(['Wrong type (',num2str(type),') ... abort.'])
end

ObservationSequence = contours.DicomHeader.RTROIObservationsSequence;
ROIContourSequence = contours.DicomHeader.ROIContourSequence;

% convert names into indices if necessary
if(iscell(selectedContours))
    selectedContoursIndices = [];
    for i=1:length(selectedContours)
        for j=1:length(contours.Struct)
            if strcmpi(selectedContours{i},contours.Struct(j).Name) || strcmpi(remove_bad_chars(selectedContours{i}),remove_bad_chars(contours.Struct(j).Name))
                selectedContoursIndices(end+1) = j;
                break
            end
        end
    end
    selectedContours = selectedContoursIndices;
elseif(strcmp(selectedContours,'all'))
    selectedContours = 1:length(fieldnames(ROIContourSequence));
end

% Add a new object contPoints, which holds the contourn data for each selected contours.
% This fixes a bug when a contourn was added to ObservationSequence but had no data stored in ROIContourSequence.
contPoints = struct;
contoursToExclude = [];
for c = 1:length(selectedContours)
    
    cont = selectedContours(c);
    
    StructCurItem   =   ['Item_',num2str(cont)];
    ReferencedROINumber = ObservationSequence.(StructCurItem).ReferencedROINumber;

    % look for a contour sequence with the same ROI number, if none is found return 0
    new_cont_index = 0;
    for cont2 = 1:length(fieldnames(ROIContourSequence))
        StructCurItem2   =   ['Item_',num2str(cont2)];
        if(ReferencedROINumber == ROIContourSequence.(StructCurItem2).ReferencedROINumber)
            new_cont_index = cont2;
            if(exclude_empty)
                if strcmpi('POINT',ROIContourSequence.(StructCurItem2).ContourSequence.Item_1.ContourGeometricType)
                    new_cont_index = 0;
                end
            end
            break
        end
    end

    % add contour data for the selected contour, if none was found add an empty vector
    if(new_cont_index == 0)
        contPoints.Struct(cont).Slice = [];
    else
        contPoints.Struct(cont).Slice = contours.Struct(new_cont_index).Slice;
    end
    
    if(exclude_empty && isempty(contPoints.Struct(cont).Slice))        
        contoursToExclude(end+1) = c;
    end
    
end

% remove excluded contours (if any)
if(exclude_empty)
    selectedContours(contoursToExclude) = [];
    if(nargin>5)
        contour_names(contoursToExclude) = [];
    end
end

% reconstruct binary mask
index = 0;
myContourName = {};
for c = 1:length(selectedContours)
    
    cont = selectedContours(c);
    
    disp(['    ',contours.Struct(cont).Name])
    myMat = zeros(imageSize,'single');
    try
        points = contPoints.Struct(cont).Slice;
    catch
        disp('Invalid number !');
    end

    %Loop for every slice in the reference image    
    for slices = 1:imageSize(3)
        coordX = [];
        coordY = [];
        myMat_temp = zeros(imageSize(1),imageSize(2));

        %Loop for every slice in the RT struct
        for contSlices = 1:size(points,2)
            %check whether the Z coordinate of the RT struct is contained inside the thickness of the referencei mage slices
            % The 0.5 pixel offset is because DICOM coordinates (e.g. 'origin') have origin at the centre of the voxel, i.e. in the middle of a slice
            % If 2 RTstruct slices are located inside the same slice of the reference image, use XOR to combine them. According to DICOM standard, it is possible to 'cut holes' inside a large contour by defining smaller contour inside the large one.
            % This mechanism will be applied by the exlcusive or (XOR)
            if ( (points(contSlices).Z(1) >= (slices-1.5)*spacing(3)+origin(3)) && ...
                    (points(contSlices).Z(1) < (slices-0.5)*spacing(3)+origin(3)) );

                    coordY = (points(contSlices).X-origin(1))/spacing(1)+1;
                    coordX = (points(contSlices).Y-origin(2))/spacing(2)+1;

                    if numel(coordY) > 1
                        %There is more than 1 point: This is a contour
                        coordX = [coordX; coordX(1)]; %Close the contour
                        coordY = [coordY; coordY(1)];
                        %                 myMat_temp = xor(poly2mask(double(coordX),double(coordY),imageSize(1),imageSize(2)),myMat_temp); % TO BE REMOVED !!!!!!!!!!!!!!!!!
                        myMat_temp = xor(poly2mask(double(coordX),double(coordY),imageSize(1),imageSize(2)),myMat_temp);
                    else
                      %There is a single point: this is an observation point
                      %Flip the bit value of the point
                      coordX = round(coordX);
                      coordY = round(coordY);
                      myMat_temp(coordY,coordX) = ~myMat_temp(coordY,coordX); %poly2mask defines Y as the 1st index of the matrix
                    end


            end
        end
        myMat(:,:,slices) = single(myMat_temp);
    end
    
    % remove empty masks (if requested)
    if(exclude_empty && max(myMat(:))==0)        
        continue
    end

    myContourName{end+1} = '';
    use_default_name = 1;
    if(nargin>5)
        try
            index = index+1;
            if(not(isempty(contour_names{index})))
                myContourName{end} = contour_names{index};
                use_default_name = 0;
            end
        catch
        end
    end

    if(use_default_name)
        myContourName{c} = [image '_' remove_bad_chars(contours.Struct(cont).Name)];
        if(length(selectedContours)==1 && ~handles.auto_mode)
            default_name = cell(0);
            default_name{1} = myContourName{end};
            myContourName{end} = char(inputdlg({'Choose a name for this contour image'},' ',1,default_name));
            if(isempty(myContourName{end}))
                return
            end
        end
    end

    StructCurItem   =   ['Item_',num2str(cont)];

    % create meta-info
    info = Create_default_info('image',handles);
    info.Contour_name = contours.Struct(cont).Name;
    if(isfield(myInfo,'OriginalHeader'))
        info.OriginalHeader = myInfo.OriginalHeader;
    end
    if(not(isempty(contours.Struct(cont).Color)))
        info.Color = contours.Struct(cont).Color;
    end
    if(isfield(ObservationSequence.(StructCurItem), 'ROIPhysicalPropertiesSequence'))
        ItemLitst = fieldnames(ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence);
        for ItemNumber = 1:length(ItemLitst)            
            if(strcmp(ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalProperty, 'REL_MASS_DENSITY'))
                info.MassDensity = ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalPropertyValue;
            end
            if(strcmp(ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalProperty, 'REL_ELEC_DENSITY'))
                info.ElectronDensity = ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalPropertyValue;
            end
            if(strcmp(ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalProperty, 'EFFECTIVE_Z'))
                info.EffectiveZ = ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalPropertyValue;
            end
            if(strcmp(ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalProperty, 'EFF_Z_PER_A'))
                info.EffectiveZ_per_A = ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalPropertyValue;
            end
            if(strcmp(ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalProperty, 'REL_STOP_RATIO'))
                info.SPR = ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalPropertyValue;
            end
            if(strcmp(ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalProperty, 'ELEM_FRACTION'))
                info.ElectronDensity = ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalPropertyValue;
            end
            if(strcmp(ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalProperty, 'MEAN_EXCI_ENERGY'))
                info.Ivalue = ObservationSequence.(StructCurItem).ROIPhysicalPropertiesSequence.(ItemLitst{ItemNumber}).ROIPhysicalPropertyValue;
            end            
        end
    end

    if type ==1
        myContourName{end} = check_existing_names(myContourName{end},handles.images.name);
        handles.images.name{length(handles.images.name)+1} = myContourName{end};
        handles.images.data{length(handles.images.data)+1} = single(myMat);
        handles.images.info{length(handles.images.info)+1} = info;
    else
        info.Spacing = spacing;
        info.ImagePositionPatient = origin;
        myContourName{end} = check_existing_names(myContourName{end},handles.mydata.name);
        handles.mydata.name{length(handles.mydata.name)+1} = myContourName{end};
        handles.mydata.data{length(handles.mydata.data)+1} = single(myMat);
        handles.mydata.info{length(handles.mydata.info)+1} = info;
    end
end

contour_names = myContourName;
