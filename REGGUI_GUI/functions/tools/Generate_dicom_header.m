function handles = Generate_dicom_header(handles,image_name)

[myData,myInfo,type] = Get_reggui_data(handles,image_name);

% Export & import dicom file
dicomwrite(zeros(2,2),[pwd,'temp_dicom_exported_file.dcm']);
myMeta = dicominfo([pwd,'temp_dicom_exported_file.dcm']);
delete([pwd,'temp_dicom_exported_file.dcm']);

% Replace existing tags
if(isfield(myInfo,'PatientName'))
    myMeta.PatientName = myInfo.PatientName;
end
if(isfield(myInfo,'PatientID'))
    myMeta.PatientID = myMeta.PatientID;
end
if(isfield(myInfo,'FrameOfReferenceUID'))
    myMeta.FrameOfReferenceUID = myMeta.FrameOfReferenceUID;
end
if(isfield(myInfo,'SeriesInstanceUID'))
    myMeta.SeriesInstanceUID = myMeta.SeriesInstanceUID;
end
if(isfield(myInfo,'SOPClassUID'))
    myMeta.SOPClassUID = myMeta.SOPClassUID;
end
if(isfield(myInfo,'StudyInstanceUID'))
    myMeta.StudyInstanceUID = myMeta.StudyInstanceUID;
end
if(isfield(myInfo,'PatientOrientation'))
    myMeta.PatientOrientation = mat2str(myMeta.PatientOrientation);
end

myInfo.OriginalHeader = myMeta;
handles = Set_reggui_data(handles,image_name,myData,myInfo,type,1);
