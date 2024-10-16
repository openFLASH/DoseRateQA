function [handles,output_names,overwrite_table] = Import_overwrite_contours(StructName,ref_image_name,handles,Scanner)

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
structList=fieldnames(StructOUT.DicomHeader.RTROIObservationsSequence);

contourNum = [];
output_names = {};
overwrite_table = {};
for i=1:length(structList)
    field_current = StructOUT.DicomHeader.RTROIObservationsSequence.(structList{i});
    if isfield(field_current,'ROIPhysicalPropertiesSequence')
        propSequence = field_current.ROIPhysicalPropertiesSequence;
        propList=fieldnames(propSequence);
        for j = 1:length(propList)
            prop=propSequence.(propList{j});
            if strcmp(prop.ROIPhysicalProperty,'REL_STOP_RATIO')
                contourNum(end+1) = i;
                overwrite_table{end+1,1}=strcat('CT','_',remove_bad_chars(StructOUT.Struct(i).Name));
                overwrite_table{end,2}=we_to_hu(prop.ROIPhysicalPropertyValue,fullfile(Scanner,'HU_Density_Conversion.txt'));
                if isnan(overwrite_table{end,2})
                    error('unable to override the HU of the CT: density or materials not defined in CT calib')
                end
                break
            elseif strcmp(prop.ROIPhysicalProperty,'REL_MASS_DENSITY')
                contourNum(end+1) = i;
                overwrite_table{end+1,1}=strcat('CT','_',remove_bad_chars(StructOUT.Struct(i).Name));
                overwrite_table{end,2}=density_to_hu(prop.ROIPhysicalPropertyValue,fullfile(Scanner,'HU_Density_Conversion.txt'));
                if isnan(overwrite_table{end,2})
                    error('unable to override the HU of the CT: density not defined in CT calib')
                end
                break
            elseif strcmp(prop.ROIPhysicalProperty,'REL_ELEC_DENSITY')
                contourNum(end+1) = i;
                overwrite_table{end+1,1}=strcat('CT','_',remove_bad_chars(StructOUT.Struct(i).Name));
                overwrite_table{end,2}=density_to_hu(prop.ROIPhysicalPropertyValue,fullfile(Scanner,'HU_Elec_Density_Conversion.txt'));
                if isnan(overwrite_table{end,2})
                    error('unable to override the HU of the CT: elec density not defined in CT calib')
                end
                break
            end
        end
    end
end

if(not(isempty(contourNum)))
    [handles,output_names] = Import_contour(StructName,contourNum,ref_image_name,ct_type,handles);
end
