function [handles, Plan] = parsePLDplan(planFileName , Plan, handles)

    if nargin < 2
        %Create the Plan structure
        Plan = struct;
        [~,Plan.output_path] = get_reggui_path();
        Plan.showGraph = false;
    end

    if nargin < 3
        %Create the handles structure
        handles = struct;
        handles.path = Plan.output_path;
        handles = Initialize_reggui_handles(handles);
    end

    [planDir,planFile,EXT] = fileparts(planFileName);
    handles.path = planDir;
    handles.dataPath = planDir;
    name = 'FLASHplan';

    %Load the plan from disk
    handles = Import_plan(planDir, [planFile EXT], 2, name, handles); %2 for pld import_plan
    data = Get_reggui_data(handles,name,'plans');


    %Analyse the content of the FLASH plan and convert into a MIROPT plan
    NbBeams = numel(data);

    Plan.fractions = 1;
    Plan.name = data{1}.PlanLabel;
    Plan.FileName = 'Plan'; %default value for the file name of the plan

    %Construct the beam structure
    %------------------------------
    for b = 1:NbBeams

        % Build energy layers from PLD spots 
        spotsPLD = data{b}.spots;
        Layers = buildPLDLayers(spotsPLD);
        NbLayers = numel(Layers);
         %Retrieve the machine name in the BDL 
        [Plan.MachineType , Plan.Machine.name] = getMachineFromBDL(Plan.BDL);

        Plan.MachineNameDICOM = Plan.Machine.name;

        Plan.Beams(b).GantryAngle = data{b}.gantry_angle;
        Plan.Beams(b).PatientSupportAngle = data{b}.table_angle;
        Plan.Beams(b).isocenter = data{b}.isocenter;
        Plan.Beams(b).name = data{b}.name;
        param = getMachineParam(Plan.BDL);
        Plan.Beams(b).VDSA = param.VDSA';

        if ( ~isempty(Plan) && isfield(Plan, 'Extras') )
            if isfield(Plan.Extras, 'NbScarves')
                Plan.Beams(b).NbScarves = Plan.Extras.NbScarves;
            end
        end

        %Create the beam structure in the Plan
        for layerIdx = 1:NbLayers
            Plan.Beams(b).Layers(layerIdx).Energy = Layers(layerIdx).energy;
            Plan.Beams(b).Layers(layerIdx).nominalSpotPosition = Layers(layerIdx).xy;
            Plan.Beams(b).Layers(layerIdx).SpotPositions = Layers(layerIdx).xy;
            Plan.Beams(b).Layers(layerIdx).SpotWeights = (Layers(layerIdx).weight)' ; %This is understood as the weight PER fraction by MIROPT
                          % If the BDL is different in MIROPT and RayStation some rescaling of the MU definition will be required using the doseMeterSet tag
            minW = min(Layers(layerIdx).weight);
            maxW = max(Layers(layerIdx).weight);
            if Plan.showGraph
                figure(100+b)
                scatter(Layers(layerIdx).xy(:,1),Layers(layerIdx).xy(:,2) , 50 , round(255.*(Layers(layerIdx).weight-minW) ./ (maxW-minW)) , 'filled')
                hold on
            end
        end

        % Display spot map
        if Plan.showGraph
            hcb = colorbar;
            set(get(hcb,'Title'),'String','Spot charge (AU)')

            figure(100+b)
            grid on
            title(['Spot grid for beam ' num2str(b) '@ isocenter'])
            xlabel('X (mm)')
            ylabel('Y (mm)')
            hold off
            drawnow
        end

        % Configure beam current
        physicsConstants;
        maxE =max([Plan.Beams(b).Layers(:).Energy]);
        ChargePerMU = MU_to_NumProtons(1, maxE) .* eV; %Cb per MU
        if ~isfield(Plan,'Inozzle')
            warning('PLD plan: using default machine current from BDL.')
            Plan.Inozzle = param.MAXcurrent * 1000; % nA
        else
            fprintf('Inozzle already defined in variable Plan\n')
        end
        fprintf('Proton beam current (theoretical, not used for log-based) : %f nA\n', Plan.Inozzle)

        % Add aperture information
        % ----------------------
        Plan = addApertureInformation(Plan, b, Plan.ShootThroughSettings, Plan.showGraph);

        %Get snout information
        %---------------------
        Plan.Beams(b).SnoutID = Plan.ShootThroughSettings.SnoutType;
        % if ~strcmp(Plan.Beams(b).SnoutID , 'FLASH_Snout_S')
        %   fprintf('SnoutID in the plan : %s \n',Plan.Beams(b).SnoutID)
        %   warning('This is not a FLASH snout. Overwriting snout ID')
        %   Plan.Beams(b).SnoutID = 'FLASH_Snout_S';
        % end
        %The plan defines the snout position on the UPSTREAM side of the aperture block
        Plan.Beams(b).SnoutPosition = Plan.ShootThroughSettings.SnoutPosition;

        % Range shifter configuration
        %-------------------------------
        Plan = addRangeShifterInformation(Plan, b, Plan.ShootThroughSettings);

      Plan.Beams(b).spotSigma = 10; %mm It is only used to determine neighbourgh spots. The exact value is not too critical

    end %for b
end


function Plan = addApertureInformation(Plan, beamIdx, settings, showGraph)
    % Create aperture geometry from Shoot Through settings.
    if settings.UseAperture       
        Plan.Beams(beamIdx).ApertureBlock = 1;
        Plan.Beams(beamIdx).BlockMountingPosition = 'PATIENT_SIDE';
        Plan.Beams(beamIdx).BlockMaterialID = 'BRASS';
        Plan.Beams(beamIdx).BlockThickness = settings.ApertureThickness;
        Plan.Beams(beamIdx).IsocenterToBlockTrayDistance = settings.SnoutPosition;

        switch settings.Shape

            case 'Circle'

                radius = settings.Radius;
                theta = linspace(0,2*pi,100);

                x = radius*cos(theta);
                y = radius*sin(theta);

                Plan.Beams(beamIdx).BlockData{1} = [x(:) y(:)];

            case 'Rectangle'

                w = settings.Width/2;
                h = settings.Height/2;

                Plan.Beams(beamIdx).BlockData{1} = [ ...
                     w   h ;
                     w  -h ;
                    -w  -h ;
                    -w   h ;
                     w   h ];

        end

        if showGraph
            figure(100+beamIdx)
            hold on
            plot(Plan.Beams(beamIdx).BlockData{1}(:,1), Plan.Beams(beamIdx).BlockData{1}(:,2), '-r');
            hold off
            drawnow
        end

    else

        Plan.Beams(beamIdx).ApertureBlock = 0;

    end

end

function Layers = buildPLDLayers(spotsPLD)
    % Group PLD spots into energy layers.
    % All spots sharing the same energy are merged into a single layer.
    spotEnergies = [spotsPLD.energy];
    uniqueEnergies = unique(spotEnergies);
    NbLayers = length(uniqueEnergies);

    for layerIdx = 1:NbLayers

        currentEnergy = uniqueEnergies(layerIdx);

        spotMask = spotEnergies == currentEnergy;

        Layers(layerIdx).energy = currentEnergy;
        Layers(layerIdx).xy = vertcat(spotsPLD(spotMask).xy);
        Layers(layerIdx).weight = [spotsPLD(spotMask).weight];

    end

end

function Plan = addRangeShifterInformation(Plan, beamIdx,  settings)
    % Populate range shifter information using the selected
    % accessory and snout configuration.

    Plan.Beams(beamIdx).NumberOfRangeShifters = settings.UseRangeShifter;

    if Plan.Beams(beamIdx).NumberOfRangeShifters

        % There is a range shifter
        Plan.Beams(beamIdx).RSinfo = struct;

        snout = getParamSnout(Plan.Beams(beamIdx).SnoutID);

        Plan.Beams(beamIdx).RSinfo.RangeShifterID = settings.AccessoryCode;

        Plan.Beams(beamIdx).RSinfo.RSslabThickness = ...
            snout.RSslabThickness( ...
            snout.RangeShifterSlabs(Plan.Beams(beamIdx).RSinfo.RangeShifterID));

        Plan.Beams(beamIdx).RSinfo.NbSlabs = ...
            numel(find(Plan.Beams(beamIdx).RSinfo.RSslabThickness));

        Plan.Beams(beamIdx).RSinfo.RangeShifterType = ...
            snout.RangeShifterType;

        Plan.Beams(beamIdx).RSinfo.SlabOffset = ...
            snout.RangeShifterOffset(1:Plan.Beams(beamIdx).RSinfo.NbSlabs) ...
            - snout.RangeShifterOffset(1) ...
            + Plan.Beams(beamIdx).RSinfo.RSslabThickness(1);

        fprintf('Range shifter thickness : %f mm\n', ...
            Plan.Beams(beamIdx).RSinfo.RSslabThickness)

        fprintf('Number of slabs : %d\n', ...
            Plan.Beams(beamIdx).RSinfo.NbSlabs)

        if Plan.Beams(beamIdx).RSinfo.NbSlabs ~= 0

            Plan.Beams(beamIdx).RSinfo.IsocenterToRangeShifterDistance = ...
                Plan.Beams(beamIdx).SnoutPosition ...
                + snout.RangeShifterOffset(1) ...
                - Plan.Beams(beamIdx).RSinfo.RSslabThickness(1);

        else

            printf('No slabs in the range shifter')

        end

        Plan.Beams(beamIdx).RSinfo.RangeShifterSetting = 'IN';

        Plan.Beams(beamIdx).RSinfo.RangeShifterMaterial = ...
            snout.RangeShifterMaterial;

        fprintf('Range shifter material : %s\n', ...
            Plan.Beams(beamIdx).RSinfo.RangeShifterMaterial)

        Plan.Beams(beamIdx).RSinfo.RangeShifterWET = NaN;

    end

end