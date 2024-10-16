function [handles,output_name] = Import_external_contour(StructName,ref_image_name,output_name,handles,types_to_include)

if(nargin<5)
    types_to_include = {};
end
if(ischar(output_name))
    output_name = {output_name};
end

types_to_include{end+1} = 'external';

% Get CT information
[~,ct_info,ct_type] = Get_reggui_data(handles,ref_image_name,'images');
switch ct_type
    case 'mydata'
        ct_type = 3;
    otherwise
        ct_type = 1;
end

% Load RT struct
StructOUT = read_dicomrtstruct(StructName,ct_info);

contourNum = [];
fields = fieldnames(StructOUT.DicomHeader.RTROIObservationsSequence);
for i=1:numel(fields)
    if sum(strcmpi(types_to_include,StructOUT.DicomHeader.RTROIObservationsSequence.(fields{i}).RTROIInterpretedType))
        contourNum(end+1) = i;
    end
end
if(numel(contourNum)==1) % only 1 external contour
    [handles,output_name] = Import_contour(StructName,contourNum,ref_image_name,ct_type,handles,output_name);
elseif(numel(contourNum)>1) % several contours to be included in the external    
    temp_names = {'temp_contour_1'};
    for i=2:numel(contourNum)
        temp_names{i} = ['temp_contour_',num2str(i)];
    end
    handles = Import_contour(StructName,contourNum,ref_image_name,ct_type,handles,temp_names);
    % aggregate contours
    [body,info,type] = Get_reggui_data(handles,temp_names{1});
    for i=2:numel(contourNum)
        body = max(body,Get_reggui_data(handles,temp_names{i}));
    end    
    for i=1:numel(contourNum)
        handles = Remove_image(temp_names{i},handles);
    end    
    [handles,output_name{1}] = Set_reggui_data(handles,output_name{1},single(body>=0.5),info,type,0);    
else
    output_name = {};
    reggui_logger.warning('Could not find external contour in RT struct.',handles.log_filename);
end
