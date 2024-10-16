%% create_default_dicom_header
%
%% Syntax
% |info = create_default_dicom_header(type)|
%
% |info = create_default_dicom_header(type,input_info)|
%
%% Description
% |info = create_default_dicom_header(type)|  create the 'info' dicom data structure.
%
% |info = create_default_dicom_header(type,input_info)|  create the 'info' dicom data structure. Replace some fields with those defined in input_info.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function info = create_default_dicom_header(type,input_info)

info = struct;

switch type
    
    case 'RTPLAN'
        
        info.PatientName = '';
        info.PatientID = '';
        info.PatientBirthDate = '';
        info.PatientSex = '';
        info.StudyInstanceUID = dicomuid;
        info.StudyDate = '';
        info.StudyTime = '';
        info.ReferringPhysicianName = '';
        info.StudyID = '';
        info.AccessionNumber = '';
        info.Modality = 'RTPLAN';
        info.SeriesInstanceUID = dicomuid;
        info.SeriesNumber = '';
        info.OperatorsName = '';
        info.FrameOfReferenceUID = '';
        info.PositionReferenceIndicator = '';
        info.Manufacturer = 'REGGUI';
        info.RTPlanLabel = 'PBS_plan';
        info.RTPlanDate = '';
        info.RTPlanTime = '';
        info.RTPlanGeometry = 'TREATMENT_DEVICE';
        info.SOPClassUID = '1.2.840.10008.5.1.4.1.1.481.8';
        info.SOPInstanceUID = dicomuid;

        info.FractionGroupSequence = struct;
        info.FractionGroupSequence.Item_1.FractionGroupNumber = 1;
        info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned = 1;
        info.FractionGroupSequence.Item_1.NumberOfBrachyApplicationSetups = 0;

        info.IonBeamSequence = struct;
        info.IonBeamSequence.Item_1.BeamType = 'STATIC';
        info.IonBeamSequence.Item_1.RadiationType = 'PROTON';
        info.IonBeamSequence.Item_1.ScanMode = 'MODULATED';
        info.IonBeamSequence.Item_1.TreatmentMachineName = '';
        info.IonBeamSequence.Item_1.PrimaryDosimeterUnit = 'MU';
        info.IonBeamSequence.Item_1.VirtualSourceAxisDistances = [2e3;2e3];
        info.IonBeamSequence.Item_1.TreatmentDeliveryType = 'TREATMENT';
        info.IonBeamSequence.Item_1.NumberOfWedges = 0;
        info.IonBeamSequence.Item_1.NumberOfCompensators = 0;
        info.IonBeamSequence.Item_1.NumberOfBoli = 0;
        info.IonBeamSequence.Item_1.NumberOfBlocks = 0;
        info.IonBeamSequence.Item_1.NumberOfRangeShifters = 0;
        info.IonBeamSequence.Item_1.NumberOfLateralSpreadingDevices = 0;
        info.IonBeamSequence.Item_1.NumberOfRangeModulators = 0;
        info.IonBeamSequence.Item_1.PatientSupportType = 'TABLE';
        
    case 'RTRECORD'
        
        info.PatientName = '';
        info.PatientID = '';
        info.PatientBirthDate = '';
        info.PatientSex = '';
        info.StudyInstanceUID = dicomuid;
        info.StudyDate = '';
        info.StudyTime = '';
        info.ReferringPhysicianName = '';
        info.StudyID = '';
        info.AccessionNumber = '';
        info.Modality = 'RTRECORD';
        info.SeriesInstanceUID = dicomuid;
        info.SeriesNumber = '';
        info.OperatorsName = '';
        info.Manufacturer = 'REGGUI';
        info.InstanceNumber = 1;
        info.TreatmentDate = '';
        info.TreatmentTime = '';        
        info.NumberOfFractionsPlanned = '';
        info.PrimaryDosimeterUnit = 'MU';
        info.SOPClassUID = '1.2.840.10008.5.1.4.1.1.481.9';
        info.SOPInstanceUID = dicomuid;
        
        info.ReferencedRTPlanSequence = struct;
        info.ReferencedRTPlanSequence.Item_1.ReferencedSOPClassUID = '1.2.840.10008.5.1.4.1.1.481.8';
        
        info.TreatmentMachineSequence = struct;
        info.TreatmentMachineSequence.Item_1.TreatmentMachineName = '';
        info.TreatmentMachineSequence.Item_1.Manufacturer = '';
        info.TreatmentMachineSequence.Item_1.InstitutionName = '';
        info.TreatmentMachineSequence.Item_1.ManufacturerModelName = '';
        info.TreatmentMachineSequence.Item_1.DeviceSerialNumber = '';
                
        info.TreatmentSessionIonBeamSequence = struct;
        info.TreatmentSessionIonBeamSequence.Item_1.ReferencedBeamNumber = 1;
        info.TreatmentSessionIonBeamSequence.Item_1.BeamName = '1';
        info.TreatmentSessionIonBeamSequence.Item_1.BeamType = 'STATIC';
        info.TreatmentSessionIonBeamSequence.Item_1.RadiationType = 'PROTON';
        info.TreatmentSessionIonBeamSequence.Item_1.TreatmentDeliveryType = 'TREATMENT';
        info.TreatmentSessionIonBeamSequence.Item_1.ScanMode = 'MODULATED';
        info.TreatmentSessionIonBeamSequence.Item_1.NumberOfWedges = 0;
        info.TreatmentSessionIonBeamSequence.Item_1.NumberOfCompensators = 0;
        info.TreatmentSessionIonBeamSequence.Item_1.NumberOfBoli = 0;
        info.TreatmentSessionIonBeamSequence.Item_1.NumberOfBlocks = 0;
        info.TreatmentSessionIonBeamSequence.Item_1.NumberOfRangeShifters = 0;
        info.TreatmentSessionIonBeamSequence.Item_1.NumberOfLateralSpreadingDevices = 0;
        info.TreatmentSessionIonBeamSequence.Item_1.NumberOfRangeModulators = 0;
        info.TreatmentSessionIonBeamSequence.Item_1.PatientSupportType = 'TABLE';
        info.TreatmentSessionIonBeamSequence.Item_1.TreatmentTerminationStatus = 'NORMAL';
        info.TreatmentSessionIonBeamSequence.Item_1.TreatmentVerificationStatus = '';
  
    otherwise
        disp('Not yet implemented')
end

% replace dicom values from input_info
if(nargin>1)
    field_list = {'PatientID','PatientName','PatientSex','PatientBirthDate','StudyInstanceUID'};
    for i=1:length(field_list)
        if(isfield(input_info,field_list{i}))
            info.(field_list{i}) = input_info.(field_list{i});
        end
    end
end
