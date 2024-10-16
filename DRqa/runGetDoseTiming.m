%% runGetDoseTiming(
%
% Load the data on the PBS spot timing and soe.
% Load the DADR map
% Plot the instantaneous dose rate vs time at the point specified in the input
% Print the value of the DADR at those point as well
%
%% Syntax
% |runGetDoseTiming(configFile)|
%
%
%% Description
% |runGetDoseTiming(configFile)| Description
%
%
%% Input arguments
% |config| -_STRUCT_- Structure with all the file name and data for computation
%
%
%% Output arguments
%
% |handles| -_STRUCT_- REGGUI structure
%   * |handles.plans| -CELL VECTOR of STRUCT- The treatment plan from TPS and the plan reconstructed from logs
%
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)


function runGetDoseTiming(config , Pg , titleSTR)


    DADRfileName = fullfile(config.files.output_path , 'Outputs','Outputs_beam1' , ['DADR_beam_1_in_ct_' config.RTstruct.ExternalROI '.dcm']);

    DRname = 'DADR';
    plaName = 'plan';

    handles = struct;
    handles.path = config.files.output_path;
    handles = Initialize_reggui_handles(handles);

    %Load dose rate map
    [FILEPATH,NAME,EXT] = fileparts(DADRfileName);
    [handles , DADRname] = Import_image(FILEPATH, [NAME,EXT] , 'dcm', DRname , handles);
    [DADR,info,type] = Get_reggui_data(handles,DRname);

    %Load plan
    [FILEPATH,NAME,EXT] = fileparts(config.files.planFileName);
    handles = Import_plan(FILEPATH, [NAME,EXT] , 1, plaName, handles);

    % Extract the dose rate from the DADR map
    %--------------------------------------------
    Plan = handles.plans.data{2}{1};
    M = matDICOM2IECgantry(Plan.gantry_angle , Plan.table_angle , Plan.isocenter); %gantry = M * dicom

    M = inv(M); %dicom = M * gantry

    %Make a 4-vector so that the math plumbing works with the matrix
    Pg = [Pg , ones(size(Pg,1),1)];

    Pdcm = M * Pg'; %Convert from DICOM CS to IEC gantry CS
    Pdcm = Pdcm'; %Transpose to get correct orientation for DICOM2PXLindex

    Axyz = DICOM2PXLindex(Pdcm , handles.spacing , handles.origin , 1 ); %Get the pixel indices

    sDADR = size(DADR);
    fprintf('DADR from dose rate map : \n')
    for idx = 1:size(Axyz,1)
      fprintf('%s [%d , %d , %d]mm = %f Gy/s \n', titleSTR{idx} , Pg(idx,1), Pg(idx,2), Pg(idx,3) , DADR(Axyz(idx,1),Axyz(idx,2),Axyz(idx,3)))
    end


    % PLot the dose rate time trace
    %----------------------------------
    %Load the data for dose time trace
    fprintf('Loading pre-computed data ...')
    FileName = fullfile(config.files.output_path , 'Outputs','Outputs_beam1' , 'DoseTimingData.mat');
    data = load(FileName);
    DoseTimingStruct = data.DoseTimingStruct;

    FileName = fullfile(config.files.output_path , 'Outputs','Outputs_beam1' , 'DoseTimingConfig.mat');
    data = load(FileName);
    DoseTimingConfig = data.DoseTimingConfig;
    fprintf('Done \n')

    fprintf('DADR from time trace : \n')
    fig = 499;
    for idx = 1:size(Axyz , 1)

        idxDADRmap = sub2ind(sDADR , Axyz(idx,1), Axyz(idx,2), sDADR(3)-Axyz(idx,3)+1); %Get the pixel indices in the beamlet dose map. The Z axis of the dose map is inverted
                              % The matrix index starts at 1, not zero. If the matrix has 10 elements in Z and we look for element A=1 (i.e. the first element) after flip, it will be at location 10-A +1 = 10
        pxlSelected = find(DoseTimingConfig.T==idxDADRmap); % The dose map contained only the pixels inside the structure. T contains the mapping between the full dose map and the structure
        if ~isempty(pxlSelected)
          plotDoseRate(DoseTimingStruct.spotTimingStart , DoseTimingStruct.Dose(:,pxlSelected) , DoseTimingStruct.TimePerSpot , fig + idx );
          title(titleSTR{idx})

          DADR2 = doseAveragedDoseRate(DoseTimingStruct.Dose(:,pxlSelected) , DoseTimingStruct.spotTimingStart, DoseTimingStruct.spotTimingStart+DoseTimingStruct.TimePerSpot); %Compute DADR from time trace. Must be equal to DADR from sdose rate map
          fprintf('%s [%d , %d , %d]mm = %f Gy/s \n', titleSTR{idx} , Pg(idx,1), Pg(idx,2), Pg(idx,3) , full(DADR2))
        else
          fprintf('%s [%d , %d , %d]mm : Outside irradiated zone \n', titleSTR{idx} , Pg(idx,1), Pg(idx,2), Pg(idx,3))
        end
    end


end
