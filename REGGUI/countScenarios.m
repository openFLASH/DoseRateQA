%% countScenarios
% This function computes the number of scenarios for each type of 
% uncertainty simulated during the robust optimization process.
%%

%% Syntax
% |Plan = countScenarios(Plan)|

%% Description
% |Plan = countScenarios(Plan)| receives the |Plan| structure with the
% information about the errors that must be taken into account during the
% optimization, and returns the same structure |Plan| completed with the
% information about the total number of scenarios to simulate.

%% Input arguments
% |Plan| - _struct_ - MIROpt structure where all the plan parameters are stored, without the total number of scenarios. The following data must be present in the structure:
%
% * |Plan.SystSetUpError| - _array_ - Row (1x6) vector with the setup error values (in mm) for x,y and z DICOM axis in the positive and negative directions: [x -x y -y z -z].
% * |Plan.RangeError| - _scalar_ - Density perturbation to simulate range uncertainties, expressed in %. This is used to automatically generate three scenarios: undershoot, overshoot and the nominal case. For instace, if Plan.RangeError = 3, --> scenarios corresponding to +3%,-3% and 0% (no perturbation) are generated.
% * |Plan.RandSetUpError| - _cell_ - Cell array containing as many entries as the number of random setup error scenarios defined by the user. Random setup errors are sampled for a Gaussian probability distribution. Therefore, each entry is a row (1x3) vector containing the standard deviation in x, y, and z DICOM axis for the corresponding scenario.
% * |Plan.Opt4Dmode| - _scalar_ - Parameter with binary value to swith on (if equal to 1) or off (if equal to zero) the 4D optimization mode. 
% * |Plan.Opt4D| - _struct_ - Structure containing the paths pointing to the location of the 4DCT files (|Plan.Opt4D.Dir4DCT|), deformation fields (|Plan.Opt4D.DirDeformFields|), and number of phases (|Num_4D_Phases|). 

%% Output arguments
% |Plan| - _struct_ - MIROpt structure where all the plan parameters are
% stored, including the information regarding the number of scenarios.

%% Contributors
% Authors : Ana Barragan, Lucian Hotoiu


function [ Plan] = countScenarios( Plan )

% Calculate number of setup error scenarios and their ID
Plan.NbrSystSetUpScenarios = (nnz(Plan.SystSetUpError) + 1); % nnz() + nominal case
for s = 1:Plan.NbrSystSetUpScenarios
    Plan.SystSetUpScenario(s).wID = []; % 1D vector with the spots indices for each scenario
end
% Calculate number of range scenarios
Plan.NbrRangeScenarios = (nnz(Plan.RangeError)*2 + 1); % nnz gives the number of nonzero values, +1 to count the nominal case
% Calculate number of random scenarios
Plan.NbrRandomScenarios = length(Plan.RandSetUpError);
% Calculate number of 4D breathing signals scenarios
if (Plan.Opt4Dmode == 1)
    Plan.Nbr4DScenarios = length(Plan.Opt4D);
else
    Plan.Nbr4DScenarios = 1;
end

end
