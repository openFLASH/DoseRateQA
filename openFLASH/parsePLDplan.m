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

        itemBeam = sprintf('Item_%i',b);

        %--Begin modification to have the same structure as parseFLASHplzn for the spots
        spotsPLD = data{b}.spots;
        E = [spotsPLD.energy];
        uniqueE = unique(E);
        
        NbLayers = length(uniqueE);
        
        clear Layers
        
        for e = 1:NbLayers
        
            idx = E == uniqueE(e);
        
            Layers(e).energy = uniqueE(e);
            Layers(e).xy = vertcat(spotsPLD(idx).xy);
            Layers(e).weight = [spotsPLD(idx).weight];
        
        end
         %Retrieve the machine name in the BDL 
        [Plan.MachineType , Plan.Machine.name] = getMachineFromBDL(Plan.BDL);

        Plan.MachineNameDICOM = Plan.Machine.name;
        % end modification

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
        %--------------------------------------
        for e = 1:NbLayers
            Plan.Beams(b).Layers(e).Energy = Layers(e).energy;
            Plan.Beams(b).Layers(e).nominalSpotPosition = Layers(e).xy;
            Plan.Beams(b).Layers(e).SpotPositions = Layers(e).xy;
            Plan.Beams(b).Layers(e).SpotWeights = (Layers(e).weight)' ; %This is understood as the weight PER fraction by MIROPT
                          % If the BDL is different in MIROPT and RayStation some rescaling of the MU definition will be required using the doseMeterSet tag
            minW = min(Layers(e).weight);
            maxW = max(Layers(e).weight);
            if Plan.showGraph
                figure(100+b)
                scatter(Layers(e).xy(:,1),Layers(e).xy(:,2) , 50 , round(255.*(Layers(e).weight-minW) ./ (maxW-minW)) , 'filled')
                hold on
            end
        end

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

        %Read the aperture data
        %-------------------------------
        Plan.Beams(b).ApertureBlock = 1;  %there is an aperture from the ShootThrough interface  
        Plan.Beams(b).BlockMountingPosition = 'PATIENT_SIDE';
        Plan.Beams(b).BlockMaterialID = 'BRASS';
        Plan.Beams(b).BlockThickness = Plan.ShootThroughSettings.ApertureThickness;  %mm
        Plan.Beams(b).IsocenterToBlockTrayDistance = Plan.ShootThroughSettings.SnoutPosition;
        switch Plan.ShootThroughSettings.Shape
            case 'Circle'
                r = Plan.ShootThroughSettings.Radius;
                theta = linspace(0,2*pi,100);

                x = r*cos(theta);
                y = r*sin(theta);
                Plan.Beams(b).BlockData{1} = [x(:) y(:)];
    
            case 'Rectangle'
                w = Plan.ShootThroughSettings.Width/2;
                h = Plan.ShootThroughSettings.Height/2;

                Plan.Beams(b).BlockData{1} = [ ...
                     w   h ;
                     w  -h ;
                    -w  -h ;
                    -w   h ;
                     w   h ];

                    

        end
        if Plan.showGraph
            figure(100+b)
            hold on
            plot(Plan.Beams(b).BlockData{1}(:,1),Plan.Beams(b).BlockData{1}(:,2), '-r');
            hold off
            drawnow
        end



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

        %Define range shifter properties
        %-------------------------------
        Plan.Beams(b).NumberOfRangeShifters = 1;
        if Plan.Beams(b).NumberOfRangeShifters
              %There is a range shifter
              Plan.Beams(b).RSinfo = struct;
              snout = getParamSnout(Plan.Beams(b).SnoutID);
              Plan.Beams(b).RSinfo.RangeShifterID = Plan.ShootThroughSettings.AccessoryCode;
              Plan.Beams(b).RSinfo.RSslabThickness = snout.RSslabThickness(snout.RangeShifterSlabs(Plan.Beams(b).RSinfo.RangeShifterID));
              Plan.Beams(b).RSinfo.NbSlabs = numel(find(Plan.Beams(b).RSinfo.RSslabThickness));
              Plan.Beams(b).RSinfo.RangeShifterType = snout.RangeShifterType;
              Plan.Beams(b).RSinfo.SlabOffset = snout.RangeShifterOffset(1:Plan.Beams(b).RSinfo.NbSlabs) - snout.RangeShifterOffset(1) + Plan.Beams(b).RSinfo.RSslabThickness(1) ; %Offset from |IsocenterToRangeShifterDistance| and the upstream side of the i-th slab
              fprintf('Range shifter thickness : %f mm \n', Plan.Beams(b).RSinfo.RSslabThickness)
              fprintf('Number of slabs : %d \n', Plan.Beams(b).RSinfo.NbSlabs)
              if Plan.Beams(b).RSinfo.NbSlabs ~=0
                  Plan.Beams(b).RSinfo.IsocenterToRangeShifterDistance = Plan.Beams(b).SnoutPosition + snout.RangeShifterOffset(1)-Plan.Beams(b).RSinfo.RSslabThickness(1); %Distance from isocenter to downstream surface of range shifter
              else
                  printf('No slabs in the range shifter')
              end
              Plan.Beams(b).RSinfo.RangeShifterSetting = 'IN';
              Plan.Beams(b).RSinfo.RangeShifterMaterial = snout.RangeShifterMaterial;
              fprintf('Range shifter material : %s \n', Plan.Beams(b).RSinfo.RangeShifterMaterial)
              Plan.Beams(b).RSinfo.RangeShifterWET=NaN;
        end
      Plan.Beams(b).spotSigma = 10; %mm It is only used to determine neighbourgh spots. The exact value is not too critical

    end %for b
end
