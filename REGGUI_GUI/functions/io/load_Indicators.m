%% load_Indicators
% Load a treatment indicators from file at the indicators format.
%
%% Syntax
% |[myIndicators,myInfo] = load_Indicators(indicators_filename)|
%
%% Description
% |[myIndicators,myInfo] = load_Indicators(indicators_filename)| Load a treatment indicators from file
%
%% Input arguments
% |indicators_filename| - _STRING_ - File name (including path) of the data to be loaded
%
% |format| -_STRING_- [OPTIONAL. Default = "json"] Format of the file to load. The options are:
% * |"json"|. Two types of json files are recognised: (a) REGGUI input file. This format is described on the web site [1]. (b) RayStation input file for ClinicalGoalList.
%
%% Output arguments
%
% |myIndicators| - _CELL VECTOR of STRUCTURE_ -  |myIndicators{i}|
%
% |myInfo| - _STRUCTURE_ - Meta information.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)
%
%% Reference
% [1] https://openreggui.org/git/open/REGGUI/wikis/QA_indicators

function [myIndicators,myInfo] = load_Indicators(indicators_filename,format)

if(nargin<2)
    format = 'json';
end

myInfo.Type = 'indicators';

switch format
    case 'json'
        
        % read json
        input = loadjson(indicators_filename);
        names = fieldnames(input);
        for n=1:length(names)
            if(strcmp(names{n},'indicators')) % REGGUI input file
                myIndicators = input.indicators;
            elseif(strcmp(names{n},'ClinicalGoalList')) %  RayStation input file
                for i=1:length(input.ClinicalGoalList)
                    tags = fieldnames(input.ClinicalGoalList{i});
                    for t=1:length(tags)
                        switch tags{t}
                            case 'Name'
                                myIndicators{i}.struct = input.ClinicalGoalList{i}.Name;
                            case 'Type'
                                switch input.ClinicalGoalList{i}.Type
                                    case 'AverageDose'
                                        myIndicators{i}.type = 'D';
                                        myIndicators{i}.value = 'mean';
                                        myIndicators{i}.unit = '[Gy]';
                                    case 'DoseAtVolume'
                                        myIndicators{i}.type = 'D';
                                        myIndicators{i}.value = '';
                                        myIndicators{i}.unit = '[Gy]';
                                    case 'DoseAtAbsoluteVolume'
                                        myIndicators{i}.type = 'D';
                                        myIndicators{i}.value = '';
                                        myIndicators{i}.unit = '[Gy]';
                                    case 'VolumeAtDose'
                                        myIndicators{i}.type = 'V';
                                        myIndicators{i}.value = '';
                                        myIndicators{i}.unit = '[%]';
                                    case 'ConformityIndex'
                                        myIndicators{i}.type = 'D_index';
                                        myIndicators{i}.value = 'conformity';
                                        myIndicators{i}.unit = '';
                                    case 'HomogeneityIndex'
                                        myIndicators{i}.type = 'D_index';
                                        myIndicators{i}.value = 'homogeneity';
                                        myIndicators{i}.unit = '';
                                    case 'DoseAtPoint'
                                        myIndicators{i}.type = 'D';
                                        myIndicators{i}.value = 'mean';
                                        myIndicators{i}.unit = '[Gy]';
                                end
                            case 'ParameterValue'
                                switch input.ClinicalGoalList{i}.Type
                                    case 'DoseAtVolume'
                                        myIndicators{i}.param = input.ClinicalGoalList{i}.ParameterValue*100;
                                        myIndicators{i}.param_unit = '[%]';
                                    case 'DoseAtAbsoluteVolume'
                                        myIndicators{i}.param = input.ClinicalGoalList{i}.ParameterValue;
                                        myIndicators{i}.param_unit = '[cc]';
                                    case 'VolumeAtDose'
                                        myIndicators{i}.param = input.ClinicalGoalList{i}.ParameterValue/100;
                                        myIndicators{i}.param_unit = '[Gy]';
                                    case 'ConformityIndex'
                                        myIndicators{i}.param = input.ClinicalGoalList{i}.ParameterValue/100;
                                        myIndicators{i}.param_unit = '[Gy]';
                                    case 'HomogeneityIndex'
                                        myIndicators{i}.param = input.ClinicalGoalList{i}.ParameterValue*100;
                                        myIndicators{i}.param_unit = '[%]';
                                end
                            case 'GoalCriteria'
                                switch input.ClinicalGoalList{i}.GoalCriteria
                                    case 'AtMost'
                                        myIndicators{i}.acceptance_test = '<';
                                    case 'AtLeast'
                                        myIndicators{i}.acceptance_test = '>';
                                end
                            case 'AcceptanceLevel'
                                switch input.ClinicalGoalList{i}.Type
                                    case {'AverageDose','DoseAtVolume','DoseAtAbsoluteVolume','DoseAtPoint'}
                                        myIndicators{i}.acceptance_level = input.ClinicalGoalList{i}.AcceptanceLevel/100;
                                        myIndicators{i}.acceptance_unit = '[Gy]';
                                    case 'VolumeAtDose'
                                        myIndicators{i}.acceptance_level = input.ClinicalGoalList{i}.AcceptanceLevel*100;
                                        myIndicators{i}.acceptance_unit = '[%]';
                                    case {'ConformityIndex','HomogeneityIndex'}
                                        myIndicators{i}.acceptance_level = input.ClinicalGoalList{i}.AcceptanceLevel;
                                        myIndicators{i}.acceptance_unit = '';
                                end
                            case 'IsComparativeGoal'
                                if(input.ClinicalGoalList{i}.IsComparativeGoal)
                                    myIndicators{i}.acceptance_unit = 'relative';
                                end
                            case 'Tolerance'
                                myIndicators{i}.acceptance_tolerance = input.ClinicalGoalList{i}.Tolerance;
                        end
                    end
                end
            elseif(ischar(input.(names{n}))) % other tags
                try
                    myInfo.(names{n}) = input.(names{n});
                catch
                end
            end
        end
        
        % Correct for 'NaN' values
        for i=1:length(myIndicators)
            fields = fieldnames(myIndicators{i});
            for n=1:length(fields)
                if(ischar(myIndicators{i}.(fields{n})))
                    if(strcmp(myIndicators{i}.(fields{n}),'NaN'))
                        myIndicators{i}.(fields{n}) = NaN;
                    end
                end
            end
        end
        
        % set default value for missing tags
        for i=1:length(myIndicators)
            if(not(isfield(myIndicators{i},'beam')))
                myIndicators{i}.beam = 0;
            elseif(ischar(myIndicators{i}.beam))
                myIndicators{i}.beam = str2double(myIndicators{i}.beam);
            end
            if(not(isfield(myIndicators{i},'type')))
                myIndicators{i}.type = '';
            end
            if(not(isfield(myIndicators{i},'value')))
                myIndicators{i}.value = '';
            end
            if(not(isfield(myIndicators{i},'unit')))
                myIndicators{i}.unit = '';
            end
            if(not(isfield(myIndicators{i},'param')))
                myIndicators{i}.param = [];
                myIndicators{i}.param_unit = '';
            end
            if(not(isfield(myIndicators{i},'param_unit')))
                myIndicators{i}.param_unit = '';
            end
            if(not(isfield(myIndicators{i},'acceptance_test')))
                myIndicators{i}.acceptance_test = '';
                myIndicators{i}.acceptance_level = [];
                myIndicators{i}.acceptance_tolerance = [];
                myIndicators{i}.acceptance_unit = '';
            end
            if(not(isfield(myIndicators{i},'acceptance_level')))
                myIndicators{i}.acceptance_level = [];
                myIndicators{i}.acceptance_unit = '';
            elseif(ischar(myIndicators{i}.acceptance_level))
                myIndicators{i}.acceptance_level = str2double(myIndicators{i}.acceptance_level);
            end
            if(not(isfield(myIndicators{i},'acceptance_tolerance')))
                myIndicators{i}.acceptance_tolerance = [];
            elseif(ischar(myIndicators{i}.acceptance_tolerance))
                myIndicators{i}.acceptance_tolerance = str2double(myIndicators{i}.acceptance_tolerance);
            end
            if(not(isfield(myIndicators{i},'acceptance_unit')))
                myIndicators{i}.acceptance_unit = myIndicators{i}.unit;
            end
            if(not(isfield(myIndicators{i},'prescription')))
                myIndicators{i}.prescription = [];
            elseif(ischar(myIndicators{i}.prescription))
                myIndicators{i}.prescription = str2double(myIndicators{i}.prescription);
            end
            
        end
        
    otherwise
        disp('Unrecognized format. Abort.')
end
