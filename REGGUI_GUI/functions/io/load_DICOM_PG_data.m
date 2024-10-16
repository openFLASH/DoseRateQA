%% load_DICOM_PG_data
% Load prompt gamma measurements from a DICOM file
%
%% Syntax
% |[myBeamData,myInfo] = load_DICOM_PG_data(dicom_filename)|
%
%
%% Description
% |[myBeamData,myInfo] = load_DICOM_PG_data(dicom_filename)| Load the PG measurements from the DICOM file
%
%
%% Input arguments
% |dicom_filename| - _STRING_ -  Name of the DICOM file to be loaded
%
%
%% Output arguments
%
% |myBeamData| - _STRUCTURE_ - PG Measurement results for the different treatment beams
%
% * |myBeamData{f}.gantry_angle|  - _SCALAR_ - Gantry angle (in degree) of the treatment beam beam
% * |myBeamData{f}.table_angle| - _SCALAR_ - Table top yaw angle (degree) of the treatment beam
% * |myBeamData{f}.isocenter| - _SCALAR VECTOR_ - |beam.isocenter= [x,y,z]| Cooridnate (in mm) of the isocentre in the CT scan for the treatment beam
% * |myBeamData{f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in first treatment plan
% * ----|myBeamData{f}.spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer 
% * ----|myBeamData{f}.spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer 
% * ----|myBeamData{f}.spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer
% * ----|myBeamData{f}.spots(j).nb_protons(s) - _INTEGER_ - Number of protons delivered for the s-th spot in the j-th energy layer 
% * ----|myBeamData{f}.spots(j).measure{s,:} - _SCALAR VECTOR_ - PG signal versus channel number for the s-th spot in the j-th energy layer 
% * ----|myBeamData{f}.spots(j).delivery_time(s) - _SCALAR_ - Time (s) required to deliver the s-th spot in the j-th energy layer 
%
% |myInfo| - _STRUCTURE_ - Meta information from the DICOM file.
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [myBeamData,myInfo] = load_DICOM_PG_data(dicom_filename)

myBeamData = struct;
myInfo = struct;

Current_dir = pwd;

[myDir,myPlan] = fileparts(dicom_filename);

info = struct;
try
    info = dicominfo(fullfile(myDir,myPlan));
    myBeamData = [];
    myInfo = struct;
catch ME
    disp('Failed to read file as dicom... ');
    rethrow(ME);
end

if(not(isfield(info,'IonBeamSequence')))
    error('No IonBeamSequence found')
end

if(not(isfield(info.IonBeamSequence.Item_1.IonControlPointSequence.Item_1,'ScanSpotTuneID')))
    error('No pencil beam data found')
end

myInfo.Type = 'pbs_plan';

beamFieldNames = fieldnames(info.IonBeamSequence);	%Field names for the treatment beams.
nb_fields = length(beamFieldNames);

for i=1:nb_fields
    
    beamSequence = info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence;
    layerFieldNames = fieldnames(info.IonBeamSequence.(beamFieldNames{i}).IonControlPointSequence);
    nb_layers = length(layerFieldNames)/2;
    
    myBeamData{i}.isocenter = beamSequence.(layerFieldNames{1}).IsocenterPosition;
    myBeamData{i}.gantry_angle = beamSequence.(layerFieldNames{1}).GantryAngle;
    myBeamData{i}.table_angle = beamSequence.(layerFieldNames{1}).PatientSupportAngle;
    
    for j=1:nb_layers
        
        fprintf('%s, Layer %d (%g MeV)\n',info.IonBeamSequence.(beamFieldNames{1}).BeamName,j,beamSequence.(layerFieldNames{2*j-1}).NominalBeamEnergy);
        
        %Check spot data
        if(not(isfield(beamSequence.(layerFieldNames{2*j}),'ScanSpotMetersetWeights')))
            fprintf('ScanSpotMetersetWeights not found. \n')
            break
        end
        if any(beamSequence.(layerFieldNames{2*j}).ScanSpotMetersetWeights~=0)
            fprintf('Non-zero ScanSpotMetersetWeights found in info.IonBeamSequence.%s.IonControlPointSequence.%s!\n',beamFieldNames{1},layerFieldNames{2*j});
        end
        if beamSequence.(layerFieldNames{2*j}).NumberOfScanSpotPositions~=beamSequence.(layerFieldNames{2*j-1}).NumberOfScanSpotPositions
            fprintf('info.IonBeamSequence.%s.IonControlPointSequence.%s.NumberOfScanSpotPositions does not match info.IonBeamSequence.%s.IonControlPointSequence.%s.NumberOfScanSpotPositions!\n',...
                beamFieldNames{1},layerFieldNames{2*j},beamFieldNames{1},layerFieldNames{2*j-1});
        end
        if(length(beamSequence.(layerFieldNames{2*j}).ScanSpotPositionMap)~=length(beamSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap))
            beamSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap = beamSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap(1:length(beamSequence.(layerFieldNames{2*j}).ScanSpotPositionMap));
        end
        if any(beamSequence.(layerFieldNames{2*j}).ScanSpotPositionMap~=beamSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap)
            fprintf('info.IonBeamSequence.%s.IonControlPointSequence.%s.ScanSpotPositionMap does not match info.IonBeamSequence.%s.IonControlPointSequence.%s.ScanSpotPositionMap!\n',...
                beamFieldNames{1},layerFieldNames{2*j},beamFieldNames{1},layerFieldNames{2*j-1});
        end
        
        myBeamData{i}.spots(j).energy = beamSequence.(layerFieldNames{2*j-1}).NominalBeamEnergy;
        myBeamData{i}.spots(j).xy = [reshape(beamSequence.(layerFieldNames{2*j-1}).ScanSpotPositionMap,2,beamSequence.(layerFieldNames{2*j-1}).NumberOfScanSpotPositions).'];
        myBeamData{i}.spots(j).weight = [beamSequence.(layerFieldNames{2*j-1}).ScanSpotMetersetWeights];
        
        % read PG data
        try
            % read delivery time
            delivery_time = beamSequence.(layerFieldNames{2*j-1}).Private_300b_15xx_Creator;
            disp(['delivery_time = [',delivery_time,'];']); 
            eval(['delivery_time = [',delivery_time,'];']); 
            % read number of protons
            norm_factor = beamSequence.(layerFieldNames{2*j-1}).Private_300b_13xx_Creator;
            eval(['norm_factor = [',norm_factor,'];']);            
            % read and normalize profiles
            temp = beamSequence.(layerFieldNames{2*j-1}).Private_300b_11xx_Creator;
            eval(['temp = [',temp,'];']);
            temp = reshape(temp,20,[])';
            
            % temp = temp(:,end:-1:1);
            
            for s=1:size(temp,1)
                myBeamData{i}.spots(j).nb_protons(s) = norm_factor(s);
                if(norm_factor(s)~=0)
                    myBeamData{i}.spots(j).measure{s} = temp(s,:)/norm_factor(s);
                end
                myBeamData{i}.spots(j).delivery_time(s) = delivery_time(s);
            end
        catch
            disp(['Cannot read PG data for field ',num2str(i),' layer ',num2str(j)]);
        end
        
    end	%for j=1:nb_layers
    
end %for i=1:nb_fields


myInfo.PatientID = info.PatientID;
myInfo.FrameOfReferenceUID = info.FrameOfReferenceUID;
myInfo.SOPInstanceUID = info.SOPInstanceUID;
myInfo.SeriesInstanceUID = info.SeriesInstanceUID;
myInfo.SOPClassUID = info.SOPClassUID;
myInfo.StudyInstanceUID = info.StudyInstanceUID;
myInfo.OriginalHeader = info;

cd(Current_dir);

