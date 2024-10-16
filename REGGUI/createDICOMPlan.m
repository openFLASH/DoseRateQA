%% createDICOMPlan
% This function writes an RT-DICOM plan (.dcm), containing all the beam 
% parameters and machine configuration required for a given treatment.
% So far, only Pencil Beam Scanning (PBS) modality is supported, which
% comprises information about the energy layers, spot positions, spot 
% weights, beam angles, etc.
%%

%% Syntax
% |createDICOMPlan(Plan, CTinfo, dataPath)|

%% Description
% |createDICOMPlan(Plan, CTinfo, dataPath)| returns a RT-DICOM plan 
% containing the beam parameters in |Plan|, associated to the patient info
% in |CTinfo|. The .dcm file is writen in the path |dataPath|.

%% Input arguments
% |Plan| - _struct_ - MIROpt data structure containing the plan parameters.
% The following data must be present in the structure:
%
% * |Plan.name| - _string_ - Name of the RT plan.
% * |Plan.TargetROI_ID| - _scalar_ - Index of the target volume, as it
%   appears in the RTSTRUCT list.
% * |Plan.fractions| - _scalar_ - Number of treatment fractions.
% * |Plan.Beams| - _struct_ - Structure containing the information about the proton beam with index i. The following data must be present:
% * |Plan.Machine| - _struct_ - Information about the treatment machine, including the name (|name|), the virtual distance from source to axis (|VDSA|) and the snout position (|SnoutPosition|).
% * |Plan.FileName| - _string_ - Name of the RT plan file.
%
% |CTinfo| - _struct_ - Structure containing all the information stored in
% the CT DICOM header. The following data must be present:
% * |CTinfo.PatientID|- _string_ - Patient ID.
% * |CTinfo.PatientBirthDate| - _string_ - Patient birth day date.
% * |CTinfo.PatientSex| - _string_ - Patient sex.
%
% |dataPath| - _string_ - path where you want the RT-DICOM plan to be 
% located.
%
% |dictionary| -_STRING_- [OTPIONAL. If absent, do not save private DICOM tags] Path and filename of the DICOM dictionary with the additional private dicom tags

%% Output arguments
% none

%% Contributors
% Author(s): Ana Barragan, Lucian Hotoiu


function  createDICOMPlan( Plan, CTinfo, dataPath , dictionary)

if nargin < 4
  dictionary = [];
end

if (isempty(dictionary))
  % Use MATLAB dicom dictionary
    dicomdict('set',[matlabroot '/toolbox/images/iptformats/dicom-dict.txt'])
  else
    %Use special DICOM dictionamry containing private tags
    dicomdict('set',dictionary)
  end


% Patient and RTplan file info
                          info.Filename= Plan.name;
                       info.FileModDate= date;
                          info.FileSize= [];
                            info.Format= 'DICOM';
                     info.FormatVersion= [];
                             info.Width= [];
                            info.Height= [];
                          info.BitDepth= [];
                         info.ColorType= 'grayscale';
    info.FileMetaInformationGroupLength= [];
        info.FileMetaInformationVersion= [];
           info.MediaStorageSOPClassUID= '1.2.840.10008.5.1.4.1.1.481.8';% Radiation Therapy Ion Plan Storage check this: http://www.dicomlibrary.com/dicom/sop/
        info.MediaStorageSOPInstanceUID= dicomuid;
                 info.TransferSyntaxUID= '1.2.840.10008.1.2'; % Implicit VR Endian: Default Transfer Syntax for DICOM, check this http://www.dicomlibrary.com/dicom/transfer-syntax/
            info.ImplementationClassUID= '1.2.246.352.70.2.1.7'; 
         info.ImplementationVersionName= ['MATLAB', version];
              info.SpecificCharacterSet= 'ISO_IR 100';
              info.InstanceCreationDate= datestr(now,'yyyymmdd');
              info.InstanceCreationTime= datestr(now,'HHMMSS');
                       info.SOPClassUID= '1.2.840.10008.5.1.4.1.1.481.8'; % Radiation Therapy Ion Plan Storage check this: http://www.dicomlibrary.com/dicom/sop/
                    info.SOPInstanceUID= dicomuid;
                         info.StudyDate= datestr(now,'yyyymmdd');
                         info.StudyTime= datestr(now,'HHMMSS');
                   info.AccessionNumber= '';
                          info.Modality= 'RTPLAN';
                      info.Manufacturer= 'MIROpt';
            info.ReferringPhysicianName= struct('FamilyName','','GivenName','','MiddleName','','NamePrefix','','NameSuffix','');
             info.ManufacturerModelName= 'MIROpt';
                       info.PatientName= struct('FamilyName','','GivenName','','MiddleName','','NamePrefix','','NameSuffix','');
                         info.PatientID= CTinfo.PatientID;
                         if(isfield(CTinfo,'OriginalHeader'))
                            info.PatientBirthDate= CTinfo.OriginalHeader.PatientBirthDate;
                            info.PatientSex= CTinfo.OriginalHeader.PatientSex;
                         end
            info.PatientIdentityRemoved= '';
            info.DeidentificationMethod= '';
            if isfield(Plan, 'SoftwareVersion')
                if iscell(Plan.SoftwareVersion)
                    %This is a cell vector. This is a multi-valued Attribute
                    %DICOM supports the concept of "Value Multiplicity". This means that a single attribute can contain multiple values which are separated by backslashes. As the VR is a property of the attribute, all values must have the same type.
                    % As the VR is a property of the attribute, all values must have the same type. This will be a list of characters separated by ‘\’. For example:
                    % MIROPT version \ scanAlgo version
                    %Most toolkits support an indexed access to the attributes. https://stackoverflow.com/questions/38618694/write-a-struct-into-a-dicom-header
                    SWver = Plan.SoftwareVersion{1};
                    for idx = 2:length(Plan.SoftwareVersion)
                        SWver = [SWver '\' Plan.SoftwareVersion{idx}];
                    end
                    info.SoftwareVersion = SWver;
                else
                    %This is a string. There is a single value
                    info.SoftwareVersion = Plan.SoftwareVersion;
                end
            else
                   info.SoftwareVersion = 'MIROPT' ;
            end
                  info.StudyInstanceUID= dicomuid;
                 info.SeriesInstanceUID= dicomuid;
                           info.StudyID= '';
                      info.SeriesNumber= [];
               info.FrameOfReferenceUID= dicomuid;
        info.PositionReferenceIndicator= '';
                   info.SamplesPerPixel= 1;
         info.PhotometricInterpretation= 'MONOCHROME2';
                              info.Rows= 0;
                           info.Columns= 0;
                     info.BitsAllocated= 16;
                        info.BitsStored= 16;
                           info.HighBit= 15;
               info.PixelRepresentation= 0;
           info.SmallestImagePixelValue= [];
            info.LargestImagePixelValue= [];
                       info.RTPlanLabel= 'PBS';
                        info.RTPlanDate= '';
                        info.RTPlanTime= '';
                        info.PlanIntent= 'RESEARCH';
                    info.RTPlanGeometry= 'PATIENT';
                    
% Plan delivery parameters

             %info.DoseReferenceSequence = struct('Item_1',{});
             
% CHECK this: http://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.8.8.10.html
if isfield(Plan , 'TargetROI_ID')
  info.DoseReferenceSequence.Item_1.ReferencedROINumber = Plan.TargetROI_ID - 1; % because in ROI the first structure is empty ''
end
info.DoseReferenceSequence.Item_1.DoseReferenceNumber = 1; % I don't know exactly what does this means but in the RN_PBS.dcm was 1 (in RayStation plan was 0)
info.DoseReferenceSequence.Item_1.DoseReferenceUID = dicomuid;
info.DoseReferenceSequence.Item_1.DoseReferenceStructureType = 'SITE'; % types: POINT (dose reference point specified as ROI), VOLUME (dose reference volume specified as ROI), SITE (dose reference clinical site), COORDINATES (point specified by Dose Reference Point Coordinates (300A,0018))
info.DoseReferenceSequence.Item_1.DoseReferenceDescription = 'Primary prescription'; % user-defined
info.DoseReferenceSequence.Item_1.DoseReferenceType = 'TARGET'; % types: 'TARGET' and 'ORGAN_AT_RISK'
% info.DoseReferenceSequence.Item_1.TargetPrescriptionDose
% info.DoseReferenceSequence.Item_1.TargetUnderdoseVolumeFraction 

             %info.FractionGroupSequence= struct('Item_1',{});

info.FractionGroupSequence.Item_1.FractionGroupNumber = 1;
info.FractionGroupSequence.Item_1.NumberOfFractionsPlanned = Plan.fractions;
info.FractionGroupSequence.Item_1.NumberOfBeams = length(Plan.Beams);
info.FractionGroupSequence.Item_1.NumberOfBrachyApplicationSetups = 0;

meterset = cell(length(Plan.Beams),1);
cumulative_meterset = cell(length(Plan.Beams),1);
total_meterset = cell(length(Plan.Beams),1);
    
for i = 1:length(Plan.Beams)
    itemBeam = sprintf('Item_%i',i);
    info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(itemBeam).BeamDose = 1; % It is used by FoCa in PBSPlan line 116 as Field weight, I set to 1 so that all the beams have the same weigth
    
    % Compute cumulative metersets (Monitor Units)
    for j=1:length(Plan.Beams(i).Layers)
        meterset{i}(j) = sum(Plan.Beams(i).Layers(j).SpotWeights);
    end
    cumulative_meterset{i} = cumsum(meterset{i});
    total_meterset{i} = sum(meterset{i});
          
    info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(itemBeam).BeamMeterset = total_meterset{i}; % number of MU's for the beam , for the moment I assume that a 1 weight = 1 MU, so that BeamMeterset = FinalCumulativeMetersetWeight
    info.FractionGroupSequence.Item_1.ReferencedBeamSequence.(itemBeam).ReferencedBeamNumber = i;
end

             
              %info.PatientSetupSequence = {};
              
for i = 1:length(Plan.Beams)
  itemBeam = sprintf('Item_%i',i);
  info.PatientSetupSequence.(itemBeam).PatientPosition = 'HFS'; % most of the cases are HFS but ATTENTION can be also in the other way around
  info.PatientSetupSequence.(itemBeam).PatientSetupNumber = i;
  info.PatientSetupSequence.(itemBeam).SetupTechnique = ''; % 'ISOCENTRIC'
end


         %info.IonToleranceTableSequence = struct('Item_1',{});
            
info.IonToleranceTableSequence.Item_1.ToleranceTableNumber = []; %10049
info.IonToleranceTableSequence.Item_1.ToleranceTableLabel =''; %'CAM Head'
info.IonToleranceTableSequence.Item_1.GantryAngleTolerance = []; %0.2000
info.IonToleranceTableSequence.Item_1.BeamLimitingDeviceAngleTolerance = [];%0.2000
info.IonToleranceTableSequence.Item_1.BeamLimitingDeviceToleranceSequence = {}; % check in plan: BeamLimitingDevicePositionTolerance: 2, RTBeamLimitingDeviceType: 'X'
info.IonToleranceTableSequence.Item_1.SnoutPositionTolerance = []; %10
info.IonToleranceTableSequence.Item_1.PatientSupportAngleTolerance = []; %1
info.IonToleranceTableSequence.Item_1.TableTopPitchAngleTolerance = []; %3
info.IonToleranceTableSequence.Item_1.TableTopRollAngleTolerance = []; %3
info.IonToleranceTableSequence.Item_1.TableTopVerticalPositionTolerance = []; %10
info.IonToleranceTableSequence.Item_1.TableTopLongitudinalPositionTolerance = []; %10
info.IonToleranceTableSequence.Item_1.TableTopLateralPositionTolerance = []; %10      
         
                   info.IonBeamSequence = {};
                   
 for i = 1:length(Plan.Beams)
  itemBeam = sprintf('Item_%i',i);
  
  info.IonBeamSequence.(itemBeam).Manufacturer = 'IBA';
  info.IonBeamSequence.(itemBeam).InstitutionName = 'MIRO - ImagX - UCL';
  info.IonBeamSequence.(itemBeam).InstitutionalDepartmentName = 'MIRO';
  info.IonBeamSequence.(itemBeam).ManufacturerModelName = 'IBA';
  info.IonBeamSequence.(itemBeam).TreatmentMachineName = Plan.Machine.name; % room 2 for UPenn...
  info.IonBeamSequence.(itemBeam).PrimaryDosimeterUnit = 'MU';
  info.IonBeamSequence.(itemBeam).BeamNumber= i;
  info.IonBeamSequence.(itemBeam).BeamName=  Plan.Beams(i).name;
  info.IonBeamSequence.(itemBeam).BeamType = 'STATIC';
  info.IonBeamSequence.(itemBeam).RadiationType = 'PROTON';
  info.IonBeamSequence.(itemBeam).TreatmentDeliveryType = 'TREATMENT';
  info.IonBeamSequence.(itemBeam).NumberOfWedges = 0;
  info.IonBeamSequence.(itemBeam).NumberOfBoli = 0;
  info.IonBeamSequence.(itemBeam).FinalCumulativeMetersetWeight =  total_meterset{i};
  info.IonBeamSequence.(itemBeam).NumberOfControlPoints = length(Plan.Beams(i).Layers)*2; % Number of layers (*2 because they appear twice)
  info.IonBeamSequence.(itemBeam).ScanMode = 'MODULATED';
  info.IonBeamSequence.(itemBeam).VirtualSourceAxisDistances = Plan.Beams(i).VDSA;
  if isfield(Plan.Beams(i), 'SnoutID')
    %Store the defined value
    info.IonBeamSequence.(itemBeam).SnoutSequence = struct('Item_1',struct('SnoutID',Plan.Beams(i).SnoutID));
  else
    %Use a default value
    info.IonBeamSequence.(itemBeam).SnoutSequence = struct('Item_1',struct('SnoutID','PBS Snout'));
  end
  info.IonBeamSequence.(itemBeam).NumberOfRangeShifters = Plan.Beams(i).NumberOfRangeShifters; % check http://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.8.8.26.html

  if (Plan.Beams(i).NumberOfRangeShifters ~= 0)
      for rs = 1:Plan.Beams(i).NumberOfRangeShifters
          itemRS = sprintf('Item_%i',rs);
          info.IonBeamSequence.(itemBeam).RangeShifterSequence.(itemRS).RangeShifterNumber = rs;
          info.IonBeamSequence.(itemBeam).RangeShifterSequence.(itemRS).RangeShifterID = Plan.Beams(i).RSinfo(rs).RangeShifterID;
          if isfield(Plan.Beams(i).RSinfo(rs) , 'RangeShifterDescription')
            info.IonBeamSequence.(itemBeam).RangeShifterSequence.(itemRS).RangeShifterDescription = Plan.Beams(i).RSinfo(rs).RangeShifterDescription; %User defined description of Range Shifter.
          end
          if isfield(Plan.Beams(i).RSinfo(rs) , 'AccessoryCode')
            info.IonBeamSequence.(itemBeam).RangeShifterSequence.(itemRS).AccessoryCode = Plan.Beams(i).RSinfo(rs).AccessoryCode; %User defined description of Range Shifter.
          end
          if (isfield(Plan.Beams(i).RSinfo(rs),'RangeShifterType'))
            info.IonBeamSequence.(itemBeam).RangeShifterSequence.(itemRS).RangeShifterType = Plan.Beams(i).RSinfo(rs).RangeShifterType;
          else
              info.IonBeamSequence.(itemBeam).RangeShifterSequence.(itemRS).RangeShifterType = 'binary';
          end
      end
  end

  %Export the aperture data
  if (isfield(Plan.Beams(i) , 'IonBlockSequence'))
    fprintf('Beam contains an aperture \n')
    info.IonBeamSequence.(itemBeam).NumberOfBlocks = numel(Plan.Beams(i).IonBlockSequence);
    %If there are several blocks, this corresponds to several holes in the same aperture block
    %Each controu of hole is represented in a different 'IonBlockSequence' but they are all located at the
    %same distance from the isocentre
    for BlckNb = 1:numel(Plan.Beams(i).IonBlockSequence)
        itemBlock = sprintf('Item_%i',BlckNb);
        info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockTrayID = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockTrayID;

        switch Plan.Beams(i).IonBlockSequence{BlckNb}.BlockMountingPosition
          case 'PATIENT_SIDE'
            %Always save as 'SOURCE_SIDE'
            %shift the reference position toi the downstream side of the block by removing the block thickness
            info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockMountingPosition = 'SOURCE_SIDE';
            info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).IsocenterToBlockTrayDistance = Plan.Beams(i).IonBlockSequence{BlckNb}.IsocenterToBlockTrayDistance - Plan.Beams(i).IonBlockSequence{BlckNb}.BlockThickness;
          case 'SOURCE_SIDE'
            info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockMountingPosition = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockMountingPosition;
            info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).IsocenterToBlockTrayDistance = Plan.Beams(i).IonBlockSequence{BlckNb}.IsocenterToBlockTrayDistance;
        end

        info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockType = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockType;
        info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockDivergence = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockDivergence;
        info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockNumber = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockNumber;
        info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockName = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockName;
        info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).MaterialID = Plan.Beams(i).IonBlockSequence{BlckNb}.MaterialID;
        info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockThickness = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockThickness;
        info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockNumberOfPoints = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockNumberOfPoints;
        if size(Plan.Beams(i).IonBlockSequence{BlckNb}.BlockData,1) > size(Plan.Beams(i).IonBlockSequence{BlckNb}.BlockData,2)
            %Export the point in the correct order
            info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockData = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockData';
          else
            info.IonBeamSequence.(itemBeam).IonBlockSequence.(itemBlock).BlockData = Plan.Beams(i).IonBlockSequence{BlckNb}.BlockData;
          end
    end
  else
    %No aperture is defined
    info.IonBeamSequence.(itemBeam).NumberOfBlocks = 0;
  end
  %Export the CEF or the range compensator if there is one
  % CAUTION: This asusmes that BeamLimitingDeviceAngle =0
  % If not, CompensatorThicknessData must be rotated accordingly
  if (isfield(Plan.Beams(i), 'NumberOfRangeModulators'))
    if (Plan.Beams(i).NumberOfRangeModulators)
      info.IonBeamSequence.(itemBeam).NumberOfRangeModulators = 1;
      itemRS = sprintf('Item_%i',1);

      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).IBA_ConformalFLASH_energy_modulator =  Plan.Beams(i).RangeModulator.IBA_ConformalFLASH_energy_modulator;
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).RangeModulatorNumber = 1;
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).RangeModulatorID = Plan.Beams(i).RangeModulator.RangeModulatorID;
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).AccessoryCode = Plan.Beams(i).RangeModulator.AccessoryCode;
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).RangeModulatorType = Plan.Beams(i).RangeModulator.RangeModulatorType;
      if isfield(Plan.Beams(i).RangeModulator , 'RangeModulatorDescription')
        info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).RangeModulatorDescription = Plan.Beams(i).RangeModulator.RangeModulatorDescription;
      end


      % DICOM order the pixels row by row. The row are paralell to the X axis (IEC gantry).
      % The first row is at +Y. The last row is at -Y
      % Within one row, the pixels are ordered from -x to +X
      %
      %                         ^ +Y
      % ---1----------------->   |
      % ---2----------------->   | -----> +X
      % ---3----------------->   |
      % ---4----------------->   |
      %
      % The elemnets are therefore ordered [A(:,N) , A(:,N-1) , A(:,N-2), ....]
      % where the first index is X (row) and the second index is Y (column)
      CEMdata = flipdim(Plan.Beams(i).RangeModulator.ModulatorThicknessData,2);
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).ModulatorThicknessData = single(CEMdata(:));

      %The X,Y coordinates are in the gantry CS and scaled in the plane of isocentre
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).ModulatorPosition = [Plan.Beams(i).RangeModulator.ModulatorOrigin(1) , ...
                              Plan.Beams(i).RangeModulator.ModulatorOrigin(2) +  Plan.Beams(i).RangeModulator.Modulator3DPixelSpacing(2) .* (size(Plan.Beams(i).RangeModulator.CEMThicknessData,2) -1 ) ];
                                           %[-x,+y] in plane of of the CEM
                                           %Coordinate (mm) [-x,+y] of the first pixel of |CompensatorThicknessData(x,y)| in plane of isocentre

      sCEF = size(Plan.Beams(i).RangeModulator.ModulatorThicknessData);
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).ModulatorRows = uint32(sCEF(2));
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).ModulatorColumns = uint32(sCEF(1));
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).ModulatorPixelSpacing = single(flipdim(Plan.Beams(i).RangeModulator.Modulator3DPixelSpacing(1:2),1)); %The X,Y coordinates are in the gantry CS and scaled in the plane of the CEM. Saved as [Y,X]
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).ModulatorMaterialID = Plan.Beams(i).RangeModulator.ModulatorMaterialID;
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).ReferencedRangeModulator = Plan.Beams(i).RangeModulator.ReferencedRangeModulator; %UID of the file in which the binary data of the CEM is stored
      info.IonBeamSequence.(itemBeam).RangeModulatorSequence.(itemRS).ModulatorMountingPosition = Plan.Beams(i).RangeModulator.ModulatorMountingPosition;
    else
      info.IonBeamSequence.(itemBeam).NumberOfRangeModulators = 0;
    end
  else
    info.IonBeamSequence.(itemBeam).NumberOfRangeModulators = 0;
  end


  info.IonBeamSequence.(itemBeam).NumberOfLateralSpreadingDevices = 0;
  info.IonBeamSequence.(itemBeam).LateralSpreadingDeviceSequence = {}; % Check in plan:  Item_i.LateralSpreadingDeviceNumber: 1
                                                                       %                        LateralSpreadingDeviceID: 'MagnetX'
                                                                       %                        LateralSpreadingDeviceType: 'MAGNET'
  info.IonBeamSequence.(itemBeam).PatientSupportType = 'TABLE';
  info.IonBeamSequence.(itemBeam).PatientSupportID = '';
  info.IonBeamSequence.(itemBeam).PatientSupportAccessoryCode = '';
  
  info.IonBeamSequence.(itemBeam).IonControlPointSequence = {};
  
  CMW = 0;
  counter = 1;
  
  for l = 1:length(Plan.Beams(i).Layers)
      
      % OJO layers appear twice in the dicom RTplan. The only difference is
      % the CumulativeMetersetWeight which is updated only in the second
      % version.
      
      % First layer occurrence
      
      
      itemLayer = sprintf('Item_%i',counter);
      
      
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).NominalBeamEnergyUnit = 'MEV';
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).ControlPointIndex = counter-1;
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).NominalBeamEnergy=  Plan.Beams(i).Layers(l).Energy;
      
      if l == 1
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).GantryAngle = Plan.Beams(i).GantryAngle;
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).GantryRotationDirection = 'NONE';
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).BeamLimitingDeviceAngle = 0; %CAUTION: The BLD CS is now aligned with the gantry CS. If this angle is changed, we must also change the orientation of the exported range compensator
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).BeamLimitingDeviceRotationDirection = 'NONE';
          if (isfield(Plan.Beams(i),'PatientSupportAngle'))
            fprintf('Found couch angle %f \n',Plan.Beams(i).PatientSupportAngle)
            info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).PatientSupportAngle = Plan.Beams(i).PatientSupportAngle;
          else
            info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).PatientSupportAngle = 0; % ???
          end
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).PatientSupportRotationDirection = 'NONE';
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).TableTopVerticalPosition = [];
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).TableTopLongitudinalPosition = [];
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).TableTopLateralPosition = [];
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).IsocenterPosition = Plan.Beams(i).isocenter; %%%%%%%%%%%%%%%% OJO check coords!
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).TableTopPitchAngle = 0;
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).TableTopPitchRotationDirection = 'NONE';
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).TableTopRollAngle = 0;
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).TableTopRollRotationDirection = 'NONE';
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).GantryPitchAngle = [];
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).GantryPitchRotationDirection = '';
          if isfield(Plan.Beams(i), 'SnoutPosition')
            info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).SnoutPosition = Plan.Beams(i).SnoutPosition;
          end
          if isfield(Plan.Beams(i) , 'MetersetRate')
            info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).MetersetRate = Plan.Beams(i).MetersetRate; %MU/min
          else
            info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).MetersetRate = []; % 200 in the PATIENT FoCa example
          end

          if (Plan.Beams(i).NumberOfRangeShifters ~= 0)
              for rs = 1:Plan.Beams(i).NumberOfRangeShifters
                  itemRS = sprintf('Item_%i',rs);
                  info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).RangeShifterSettingsSequence.(itemRS).RangeShifterSetting = Plan.Beams(i).RSinfo(rs).RangeShifterSetting;
                  info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).RangeShifterSettingsSequence.(itemRS).IsocenterToRangeShifterDistance = Plan.Beams(i).RSinfo(rs).IsocenterToRangeShifterDistance;
                  info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).RangeShifterSettingsSequence.(itemRS).RangeShifterWaterEquivalentThickness = Plan.Beams(i).RSinfo(rs).RangeShifterWET;
                  info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).RangeShifterSettingsSequence.(itemRS).ReferencedRangeShifterNumber=rs;
              end
          end
          
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).LateralSpreadingDeviceSettingsSequence = {}; % check this in plan
          
                                                                              %                        for Item_i (for each beam).
                                                                              %     LateralSpreadingDeviceWaterEquivalentThickness: 0
                                                                              %                      LateralSpreadingDeviceSetting: '9.7711684342'
                                                                              %          IsocenterToLateralSpreadingDeviceDistance: 2.3385e+03
                                                                              %             ReferencedLateralSpreadingDeviceNumber: 1

          if (isfield(Plan.Beams(i), 'NumberOfRangeModulators'))
            itemRM = sprintf('Item_%i',1);
            info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).RangeModulatorSettingsSequence.(itemRM).IsocenterToRangeModulatorDistance = Plan.Beams(i).RangeModulator.IsocenterToRangeModulatorDistance;
          end


      end
      
      
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).CumulativeMetersetWeight = CMW; 
      CMW = CMW + sum(Plan.Beams(i).Layers(l).SpotWeights);
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).ScanSpotTuneID = 'Spot';
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).NumberOfScanSpotPositions = numel(Plan.Beams(i).Layers(l).SpotWeights);
      
      pos = zeros(numel(Plan.Beams(i).Layers(l).SpotWeights)*2,1);
      pos(1:2:end-1) = Plan.Beams(i).Layers(l).SpotPositions(:,1); % X_BEV
      pos(2:2:end) = Plan.Beams(i).Layers(l).SpotPositions(:,2); % Y_BEV
      
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).ScanSpotPositionMap =  pos;
      
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).ScanSpotMetersetWeights = Plan.Beams(i).Layers(l).SpotWeights';
      % Check this with Daniel....
      % I assume a sigma of 4mm so that FWMH = 4*2.355= 9.4200 but this
      % should be properly calculated with the beam model at least for the
      % first layer which is the value used by FoCa in PBSPlan line 135.
      % Actually, for the FAST mode, only the value of the first layer is
      % used, while for the ROBUST mode, the spot sizes for each layer are
      % recalculated using the BeamData in flillFlu of DG
      FWMHx = 9.4200;
      FWMHy = 9.4200;
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).ScanningSpotSize = [FWMHx;FWMHy]; % [2x1 single]
      if isfield(Plan.Beams(i).Layers(l),'NumberOfPaintings')
          %The layer contains de definition of the number of paintings. Use it
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).NumberOfPaintings = Plan.Beams(i).Layers(l).NumberOfPaintings;
      else
          %The plan does not contains a definition of the number of painting. Set it to 1 by default
          info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).NumberOfPaintings = 1;
      end
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).Private_300b_10xx_Creator= 'IMPAC';
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).Private_300b_1017= [];
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer).ReferencedDoseReferenceSequence = struct('Item_1',{}); % check on plan
                                                                            %       CumulativeDoseReferenceCoefficient: 0.3756
                                                                            %          ReferencedDoseReferenceNumber: 1
                                                                            
      % Second layer occurrence
      
      counter = counter + 1;
      
      itemLayer2 = sprintf('Item_%i',counter);
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer2) = info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer);
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer2).ScanSpotMetersetWeights(:) = 0;
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer2).ControlPointIndex = counter-1;
      info.IonBeamSequence.(itemBeam).IonControlPointSequence.(itemLayer2).CumulativeMetersetWeight = CMW;
      
      counter = counter + 1;
      
  end
  
  
  info.IonBeamSequence.(itemBeam).Private_300b_10xx_Creator = 'IMPAC';
  info.IonBeamSequence.(itemBeam).Private_300b_1002 = []; % ????
  info.IonBeamSequence.(itemBeam).Private_300b_1004 = []; % ????
  info.IonBeamSequence.(itemBeam).Private_300b_100e = []; % ????
  info.IonBeamSequence.(itemBeam).ReferencedPatientSetupNumber = 1;
  info.IonBeamSequence.(itemBeam).ReferencedToleranceTableNumber = [];
  %info.IonBeamSequence.(itemBeam).Private_SpotSpacing = Plan.Beams(i).SpotSpacing;
end                  
                   
                   
    %info.ReferencedStructureSetSequence = struct('Item_1',{});

info.ReferencedStructureSetSequence.Item_1.ReferencedSOPClassUID = '1.2.840.10008.5.1.4.1.1.481.3'; %Radiation Therapy Structure Set Storage check this http://www.dicomlibrary.com/dicom/sop/
info.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID = dicomuid;
    
    
                    info.ApprovalStatus= 'UNAPPROVED';
                   
data = [];

if (isempty(dictionary))
    dicomwrite(data,fullfile(dataPath,[Plan.FileName,'.dcm']),info,'createmode','copy');
  else
    %Allow the export of private tags
    dicomwrite(data,fullfile(dataPath,[Plan.FileName,'.dcm']),info,'createmode','copy','WritePrivate',1);
  end

end
