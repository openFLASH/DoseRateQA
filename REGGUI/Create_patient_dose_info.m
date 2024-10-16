function [ info_out ] = Create_patient_dose_info( handles, CT_info, plan_info , SimuParam )

info_out = Create_default_info('image',handles);
info_out.OriginalHeader.Modality = 'RTDOSE';
info_out.OriginalHeader.DoseUnits = 'GY';
info_out.OriginalHeader.DoseType = 'PHYSICAL';
info_out.OriginalHeader.DoseSummationType = 'PLAN';

try
    info_out.OriginalHeader.ReferencedRTPlanSequence.Item_1.ReferencedSOPClassUID = '1.2.840.10008.5.1.4.1.1.481.8';
    info_out.OriginalHeader.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID = plan_info.OriginalHeader.SOPInstanceUID;
    if(isfield(plan_info.OriginalHeader,'PatientName'))
        info_out.PatientName = plan_info.OriginalHeader.PatientName;
        info_out.OriginalHeader.PatientName = plan_info.OriginalHeader.PatientName;
    end
    if(isfield(plan_info.OriginalHeader,'PatientID'))
        info_out.PatientID = plan_info.OriginalHeader.PatientID;
        info_out.OriginalHeader.PatientID = plan_info.OriginalHeader.PatientID;
    end
    if(isfield(plan_info.OriginalHeader,'PatientBirthDate'))
        info_out.PatientBirthDate = plan_info.OriginalHeader.PatientBirthDate;
        info_out.OriginalHeader.PatientBirthDate = plan_info.OriginalHeader.PatientBirthDate;
    end
    if(isfield(plan_info.OriginalHeader,'PatientSex'))
        info_out.PatientSex = plan_info.OriginalHeader.PatientSex;
        info_out.OriginalHeader.PatientSex = plan_info.OriginalHeader.PatientSex;
    end
    if(isfield(plan_info.OriginalHeader,'StudyID'))
        info_out.StudyID = plan_info.OriginalHeader.StudyID;
        info_out.OriginalHeader.StudyID = plan_info.OriginalHeader.StudyID;
    end
catch
    disp('Could not find patient information in the plan header');
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end


try
    info_out.FrameOfReferenceUID = CT_info.OriginalHeader.FrameOfReferenceUID;
    info_out.OriginalHeader.FrameOfReferenceUID = CT_info.OriginalHeader.FrameOfReferenceUID;
catch
    disp('Could not find frame of reference uid in the ct header');
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end

info_out.SOPClassUID = '1.2.840.10008.5.1.4.1.1.481.2';
info_out.OriginalHeader.SOPClassUID = '1.2.840.10008.5.1.4.1.1.481.2';
info_out.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.481.2';
info_out.OriginalHeader.MediaStorageSOPClassUID = '1.2.840.10008.5.1.4.1.1.481.2';
info_out.OriginalHeader.DoseGridScaling = 1;
info_out.PatientOrientation = CT_info.PatientOrientation;

if(nargin>3)
    if(SimuParam.Independent_scoring_grid == 1)
        info_out.Spacing = SimuParam.Scoring_voxel_spacing(:);
        info_out.ImagePositionPatient = SimuParam.Scoring_origin(:);
    end
end

end
