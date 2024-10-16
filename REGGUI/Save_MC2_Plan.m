%% Save_MC2_Plan
% Create a text file with a description of the PBS treatment plan. The file will be used by the MCsquare simulation algorithm.
%
%% Syntax
% |Save_MC2_Plan(plan,plan_info,outname,format)|
%
%
%% Description
% |Save_MC2_Plan(plan,plan_info,outname,format)| Save the treatment plan in a text file
%
%
%% Input arguments
% |plan| - _STRUCTURE_ - Definition of the treatment plan
%

% * |plan{f}.spots(j)| - _STRUCTURE_ - Description of the j-th PBS spot of the f-th beam/field in treatment plan

% * ----|spots(j).nb_paintings| - _INTEGER_ - Number of painting for the j-th energy layer
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer. The coordinate system is IEC-GANTRY.
% * ----|spots(j).weight(s)| - _INTEGER_ - Number of monitoring unit to deliver for the s-th spot in the j-th energy layer
% * |plan{f}.isocenter| - _VECTOR of INTEGERS_ - [x,y,z] coordinate of the isocentre |mm| in beam/field f
% * |plan{f}.gantry_angle| - _SCALAR_ -  Gantry angle |mm| in beam/field f
% * |plan{f}.table_angle| - _SCALAR_ -  Yaw angle of the PPS table |degree| in beam/field f
%
%
% |plan_info| - _STRUCTURE_ - Meta information from the DICOM file. See |load_DICOM_RT_Plan| or |load_PLD| or |load_Gate_Plan| for more details.
%
% |outname| - _STRING_ - File name (including directory) of the exported text file describing the plan
%
% |format| - _STRING_ - Definition of the format of the text file. Options: : 'gate'
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : K. Souris (open.reggui@gmail.com)

function Save_MC2_Plan(plan,plan_info,outname,format)

[outdir,outfilename] = fileparts(outname);

%disp(['Save PBS plan (',outname,')']);

% get number of fields and layers
nb_fields = length(plan);
for f=1:nb_fields
    nb_layers(f) = length(plan{f}.spots);
end

% Compute cumulative metersets
meterset = cell(nb_fields,1);
cumulative_meterset = cell(nb_fields,1);
tot_meterset = 0;
for f=1:nb_fields
    for j=1:nb_layers(f)
        meterset{f}(j) = sum(plan{f}.spots(j).weight);
    end
    cumulative_meterset{f} = cumsum(meterset{f});
    tot_meterset = tot_meterset + sum(meterset{f});
end

switch format

    case 'gate'

        % create output text lines
        Plan_text = cell(0);
        Plan_text{end+1} = '#TREATMENT-PLAN-DESCRIPTION';
        Plan_text{end+1} = '#PlanName';
        Plan_text{end+1} = outfilename;
        Plan_text{end+1} = '#NumberOfFractions';
        if(isfield(plan_info,'NumberOfFractions'))
            Plan_text{end+1} = num2str(plan_info.NumberOfFractions);
        elseif(isfield(plan_info,'OriginalHeader'))
            Plan_text{end+1} = num2str(plan_info.OriginalHeader.FractionGroupSequence.Item_1.NumberOfFractionsPlanned);
        else
            Plan_text{end+1} = '1';
        end
        Plan_text{end+1} = '##FractionID';
        Plan_text{end+1} = '1';
        Plan_text{end+1} = '##NumberOfFields';
        Plan_text{end+1} = num2str(nb_fields);
        for f=1:nb_fields
            Plan_text{end+1} = '###FieldsID';
            Plan_text{end+1} = num2str(f);
        end
        Plan_text{end+1} = '#TotalMetersetWeightOfAllFields';
        Plan_text{end+1} = num2str(tot_meterset);

        for f=1:nb_fields

            Plan_text{end+1} = ' ';
            Plan_text{end+1} = '#FIELD-DESCRIPTION';
            Plan_text{end+1} = '###FieldID';
            Plan_text{end+1} = num2str(f);
            Plan_text{end+1} = '#RadiationType';
            if(isfield(plan{f},'radiation_type'))
                if(strcmp(plan{f}.radiation_type,'ION') && isfield(plan{f},'ion_AZQ'))
                    Plan_text{end+1} = [plan{f}.radiation_type,'_A',num2str(plan{f}.ion_AZQ(1)),'_Z',num2str(plan{f}.ion_AZQ(2)),'_Q',num2str(plan{f}.ion_AZQ(3))];
                else
                    Plan_text{end+1} = plan{f}.radiation_type;
                end
            else
                Plan_text{end+1} = 'PROTON';
            end
            Plan_text{end+1} = '###FinalCumulativeMeterSetWeight';
            Plan_text{end+1} = num2str(sum(meterset{f}));
            Plan_text{end+1} = '###GantryAngle';
            Plan_text{end+1} = num2str(plan{f}.gantry_angle);
            Plan_text{end+1} = '###PatientSupportAngle';
            Plan_text{end+1} = num2str(plan{f}.table_angle);
            Plan_text{end+1} = '###IsocenterPosition';
            if(size(plan{f}.isocenter,1)==3 && size(plan{f}.isocenter,2)==1)
                plan{f}.isocenter = plan{f}.isocenter';
            end
            Plan_text{end+1} = num2str(plan{f}.isocenter);
            if(sum(getNumberOfRangeShifters(plan)))
                if(getNumberOfRangeShifters(plan,f) == 1 && strcmpi(plan{f}.RangeShifters(1).RangeShifterType, 'BINARY') == 1)
                    Plan_text{end+1} = '###RangeShifterID';
                    Plan_text{end+1} = remove_special_chars(plan{f}.RangeShifters(1).RangeShifterID,{'.',','});
                    Plan_text{end+1} = '###RangeShifterType';
                    Plan_text{end+1} = 'binary';
                end
            end
            Plan_text{end+1} = '###NumberOfControlPoints';
            Plan_text{end+1} = num2str(nb_layers(f));
            Plan_text{end+1} = ' ';
            Plan_text{end+1} = '#SPOTS-DESCRIPTION';

            for j=1:nb_layers(f)


                nb_spots = length(plan{f}.spots(j).weight);

                %                Plan_text{end+1} = '#SPOTS-DESCRIPTION';

                Plan_text{end+1} = '####ControlPointIndex';
                Plan_text{end+1} = num2str(j);
                Plan_text{end+1} = '####SpotTunnedID';
                Plan_text{end+1} = '1';
                Plan_text{end+1} = '####CumulativeMetersetWeight';
                Plan_text{end+1} = num2str(cumulative_meterset{f}(j));
                Plan_text{end+1} = '####Energy (MeV)';
                Plan_text{end+1} = num2str(plan{f}.spots(j).energy);
                if(sum(getNumberOfRangeShifters(plan)))
                    if(getNumberOfRangeShifters(plan,f) == 1 && strcmpi(plan{f}.RangeShifters(1).RangeShifterType, 'BINARY') == 1)
                        Plan_text{end+1} = '####RangeShifterSetting';
                        Plan_text{end+1} = plan{f}.spots(j).RangeShifterSetting;
                        Plan_text{end+1} = '####IsocenterToRangeShifterDistance';
                        Plan_text{end+1} = num2str(plan{f}.spots(j).IsocenterToRangeShifterDistance);
                        Plan_text{end+1} = '####RangeShifterWaterEquivalentThickness';
                        Plan_text{end+1} = num2str(plan{f}.spots(j).RangeShifterWaterEquivalentThickness);
                    end
                end
                Plan_text{end+1} = '####NbOfScannedSpots';
                Plan_text{end+1} = num2str(nb_spots);
                Plan_text{end+1} = '####X Y Weight';
                for s=1:nb_spots
                    Plan_text{end+1} = [num2str(plan{f}.spots(j).xy(s,1)),' ',num2str(plan{f}.spots(j).xy(s,2)),' ',num2str(plan{f}.spots(j).weight(s))];
                end

            end

        end

        fid = fopen(outname,'w');
        for i=1:length(Plan_text)
            fprintf(fid,[Plan_text{i},'\n']);
        end
        fclose(fid);

    case 'pld'

        for f=1:nb_fields

            headline = ['Beam,Patient ID,Patient Name,Patient Initial,Patient Firstname,Plan Label,Beam Name,',num2str(sum(meterset{f})),',',num2str(sum(meterset{f})),',',num2str(nb_layers(f))];
            Plan_text = {headline};

            for j=1:nb_layers(f)

                nb_spots = length(plan{f}.spots(j).weight);
                Plan_text{end+1} = ['Layer,Spot1,',num2str(plan{f}.spots(j).energy),',',num2str(cumulative_meterset{f}(j)),',',num2str(nb_spots)];
                for s=1:nb_spots
                    Plan_text{end+1} = ['Element,',num2str(plan{f}.spots(j).xy(s,1)),',',num2str(plan{f}.spots(j).xy(s,2)),',',num2str(plan{f}.spots(j).weight(s)),',0.0'];
                end
            end

            fid = fopen(fullfile(outdir,[num2str(f),'.pld']),'w');
            for i=1:length(Plan_text)
                fprintf(fid,[Plan_text{i},'\n']);
            end
            fclose(fid);

        end

    otherwise

        disp('Unknow format')

end
