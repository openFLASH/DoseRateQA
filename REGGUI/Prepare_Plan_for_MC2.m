function [ plan, plan_info ] = Prepare_Plan_for_MC2( handles, SimuParam, CT_info )

plan = [];
for i=1:length(handles.plans.name)
    if(strcmp(handles.plans.name{i},SimuParam.Plan))
        plan = handles.plans.data{i};
        plan_info = handles.plans.info{i};
    end
end
if(isempty(plan))
    disp('Plan not found. Abort.')
    return
end


nb_fields = length(plan);
for f=1:nb_fields
    if(size(plan{f}.isocenter,1)==1 && size(plan{f}.isocenter,2)==3)
        plan{f}.isocenter = plan{f}.isocenter';
    end
    plan{f}.isocenter = plan{f}.isocenter - CT_info.ImagePositionPatient + CT_info.Spacing/2;
    plan{f}.isocenter(2) = CT_info.size(2)*CT_info.Spacing(2) - plan{f}.isocenter(2);
end


% Add dicom information if no plan header exists
if(not(isfield(plan_info,'OriginalHeader')))
    try
        plan_info.OriginalHeader.PatientName = CT_info.OriginalHeader.PatientName;
        plan_info.OriginalHeader.PatientID = CT_info.OriginalHeader.PatientID;
        plan_info.OriginalHeader.PatientBirthDate = CT_info.OriginalHeader.PatientBirthDate;
        plan_info.OriginalHeader.PatientSex = CT_info.OriginalHeader.PatientSex;
        plan_info.OriginalHeader.StudyID = CT_info.OriginalHeader.StudyID;
    catch
        plan_info.OriginalHeader.PatientName = 'unknown';
        plan_info.OriginalHeader.PatientID = '000';
        plan_info.OriginalHeader.PatientBirthDate = '';
        plan_info.OriginalHeader.PatientSex = 'M';
        plan_info.OriginalHeader.StudyID = dicomuid;
    end

    plan_info.OriginalHeader.SOPInstanceUID = dicomuid;
end


% BDL type
try
    fid = fopen(SimuParam.BDL,'r');
    BDL_format = fgetl(fid);
    fclose(fid);
catch ME
    disp(['ERROR: Could not import BDL. ',SimuParam.BDL,' not found! Abort.'])
    rethrow(ME)
end

% Extract range shifter data from BDL
BDL_text=textread(SimuParam.BDL,'%s','delimiter','\n');

plan_info.RangeShifter_BDL = {};

if sum(getNumberOfRangeShifters(plan)) ~= 0
    % compatible with MATLAB versions above 2016b
    %lines_ID = find(contains(BDL_text,'RS_ID'));
    %lines_type = find(contains(BDL_text,'RS_type'));
    %lines_material = find(contains(BDL_text,'RS_material'));
    %lines_density = find(contains(BDL_text,'RS_density'));
    %lines_WET = find(contains(BDL_text,'RS_WET'));
    % compatible with MATLAB versions below 2016b
    lines_ID = [];
    lines_type = [];
    lines_material = [];
    lines_density = [];
    lines_WET = [];
    for i = 1:length(BDL_text)
        if ~isempty(strfind(BDL_text{i},'RS_ID'))
            lines_ID(end+1) = i;
        end
        if ~isempty(strfind(BDL_text{i},'RS_type'))
            lines_type(end+1) = i;

        end
        if ~isempty(strfind(BDL_text{i},'RS_material'))
            lines_material(end+1) = i;
        end
        if ~isempty(strfind(BDL_text{i},'RS_density'))
            lines_density(end+1) = i;
        end
        if ~isempty(strfind(BDL_text{i},'RS_WET'))
            lines_WET(end+1) = i;
        end
    end

    if(isempty(lines_ID) && sum(getNumberOfRangeShifters(plan)) ~= 0)
        error('Error: Range shifter found in the plan, but not defined in the BDL')
    end
    if(length(lines_ID) ~= length(lines_type) || length(lines_ID) ~= length(lines_material) || length(lines_ID) ~= length(lines_density) || length(lines_ID) ~= length(lines_WET))
        error('Error: Range shifter not properly defined in BDL')
    end
    for i=1:length(lines_ID)
        tmp = strsplit(BDL_text{lines_ID(i)}, {'#'});
        tmp = strsplit(tmp{1}, {'=', ' ', '\t'});
        plan_info.RangeShifter_BDL{i}.RS_ID = '';
        for j=2:length(tmp)
            plan_info.RangeShifter_BDL{i}.RS_ID = [plan_info.RangeShifter_BDL{i}.RS_ID,tmp{j}];
        end
        tmp = strsplit(BDL_text{lines_type(i)}, {'=',' ','\t','#'});
        plan_info.RangeShifter_BDL{i}.RS_type = tmp{2};
        tmp = strsplit(BDL_text{lines_material(i)}, {'=',' ','\t','#'});
        plan_info.RangeShifter_BDL{i}.RS_material = str2num(tmp{2});
        tmp = strsplit(BDL_text{lines_density(i)}, {'=',' ','\t','#'});
        plan_info.RangeShifter_BDL{i}.RS_density = str2num(tmp{2});
        tmp = strsplit(BDL_text{lines_WET(i)}, {'=',' ','\t','#'});
        plan_info.RangeShifter_BDL{i}.RS_WET = str2num(tmp{2});
    end

end

% Extract number of protons per MU
if(strcmpi(BDL_format, '--UPenn beam model (double gaussian)--') == 1)
    % compatible with MATLAB versions above 2016b
    %Line_start = find(contains(BDL_text,'NominalEnergy'));
    % compatible with MATLAB versions below 2016b
    for i = 1:length(BDL_text)
        if ~isempty(strfind(BDL_text{i},'NominalEnergy'))
            Line_start = i;
        end
    end
    MU2Protons = importdata(SimuParam.BDL, ' ', Line_start);
    Energies = MU2Protons.data(:,1);
    MU2Protons = MU2Protons.data(:,4);
    MUtoProtons_from_BDL = 1;
else
    MUtoProtons_from_BDL = 0;
end


% Evaluates number of delivered protons
plan_info.SpotNumProtons = {};
DeliveredProtons = 0;
if(MUtoProtons_from_BDL == 0)
    for f=1:nb_fields
        for j=1:length(plan{f}.spots)
            DeliveredProtons = DeliveredProtons + MU_to_NumProtons(sum(plan{f}.spots(j).weight), plan{f}.spots(j).energy);
            MU2Proton = MU_to_NumProtons(1.0, plan{f}.spots(j).energy);
            for k=1:length(plan{f}.spots(j).weight)
                plan_info.SpotNumProtons{end+1} = plan{f}.spots(j).weight(k) * MU2Proton;
            end
        end
    end
else
    for f=1:nb_fields
        for j=1:length(plan{f}.spots)
            DeliveredProtons = DeliveredProtons + sum(plan{f}.spots(j).weight) * interp1(Energies, MU2Protons, plan{f}.spots(j).energy, 'linear','extrap');
            MU2Proton = interp1(Energies, MU2Protons, plan{f}.spots(j).energy, 'linear','extrap');
            for k=1:length(plan{f}.spots(j).weight)
                plan_info.SpotNumProtons{end+1} = plan{f}.spots(j).weight(k) * MU2Proton;
            end
        end
    end
end

plan_info.DeliveredProtons = DeliveredProtons;


% number of fractions
try
    if(~isfield(plan_info,'NumberOfFractions'))
        plan_info.NumberOfFractions = plan_info.OriginalHeader.FractionGroupSequence.Item_1.NumberOfFractionsPlanned;
    end
catch
    plan_info.NumberOfFractions =  1;  % If no number of fractions specified, consider 1 by default
end


% verify range shifter info in the plan

if(~isempty(plan_info.RangeShifter_BDL) && sum(getNumberOfRangeShifters(plan)) ~= 0)

    nb_fields = length(plan);
    for f=1:nb_fields

        if(getNumberOfRangeShifters(plan,f) == 0)
            continue
        elseif(getNumberOfRangeShifters(plan,f) > 1)
            error('Error: only one range shifter per beam is currently supported');
        end

        nb_layers = length(plan{f}.spots);
        for l=1:nb_layers
            if(strcmpi(plan{f}.spots(l).RangeShifterSetting, 'IN') == 1)

                rs_index = 0;
                for r = 1:getNumberOfRangeShifters(plan,f)
                    if(plan{f}.spots(l).ReferencedRangeShifterNumber == plan{f}.RangeShifters(r).RangeShifterNumber)
                        rs_index = r;
                    end
                end

                if(rs_index == 0)
                    error(['Error: Referenced Range Shifter Number ' num2str(plan{f}.spots(l).ReferencedRangeShifterNumber) ' not found']);
                end

                if(strcmpi(plan{f}.RangeShifters(rs_index).RangeShifterType, 'BINARY') == 0)
                    error(['ERROR: Range shifter type ' plan{f}.RangeShifters(r).RangeShifterType ' is not supported'])
                end

                plan{f}.spots(l).RS_ID = plan{f}.RangeShifters(rs_index).RangeShifterID;

                RS_BDL_index = 0;
                for r = 1:length(plan_info.RangeShifter_BDL)
                    if(strcmp(remove_special_chars(plan_info.RangeShifter_BDL{r}.RS_ID,{'.',','}),remove_special_chars(plan{f}.spots(l).RS_ID,{'.',','})))
                        RS_BDL_index = r;

                    end
                end

                if(RS_BDL_index == 0)
                    error(['Error: Range Shifter ID ' plan{f}.spots(l).RS_ID ' not found in the BDL']);
                end

                if(plan{f}.spots(l).RangeShifterWaterEquivalentThickness == 0)
                    plan{f}.spots(l).RangeShifterWaterEquivalentThickness = plan_info.RangeShifter_BDL{RS_BDL_index}.RS_WET;
                end
            end
        end
    end
end

