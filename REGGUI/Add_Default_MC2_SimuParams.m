function SimuParam = Add_Default_MC2_SimuParams(SimuParam)

%[~ , MCsqExecPath , BDLPath , ~ , ScannersPath] = get_MCsquare_folders(); %This will not work with the compiler
MCsqExecPath = []; %The folder must have been provided in SimuParam. If not present, this is an error
BDLPath  = [];
ScannersPath = [];

MC2_lib_path =  MCsqExecPath;
SimuParam = add_default(SimuParam,'Scanner',fullfile(ScannersPath,'default'));
SimuParam = add_default(SimuParam,'BDL',fullfile(BDLPath,'BDL_default_DN_RangeShifter.txt'));
SimuParam = add_default(SimuParam,'Folder',fullfile(pwd,['MCsquare_',strrep(strrep(strrep(datestr(now,'yy-mm-dd-HH-MM-SS'),'-','_'),' ','_'),':','_')]));
SimuParam = add_default(SimuParam,'RunSimu',1);
SimuParam = add_default(SimuParam,'NumberOfPrimaries',1e7);
SimuParam = add_default(SimuParam,'ComputeStat',0);
SimuParam = add_default(SimuParam,'StatUncertainty',2);
SimuParam = add_default(SimuParam,'NumberOfThreads',0);
SimuParam = add_default(SimuParam,'Dose',1);
SimuParam = add_default(SimuParam,'DoseName','MCsquare_dose');
SimuParam = add_default(SimuParam,'Energy',0);
SimuParam = add_default(SimuParam,'EnergyName','MCsquare_energy');
SimuParam = add_default(SimuParam,'LET',0);
SimuParam = add_default(SimuParam,'LETName','MCsquare_LET');
SimuParam = add_default(SimuParam,'DoseToWater',0);
SimuParam = add_default(SimuParam,'CropBody',0);
SimuParam = add_default(SimuParam,'BodyContour','');
SimuParam = add_default(SimuParam,'OverwriteHU',{});
SimuParam = add_default(SimuParam,'Simu4D',0);
SimuParam = add_default(SimuParam,'Robustness_Mode',0);
SimuParam = add_default(SimuParam,'Export_beam_dose',0);
SimuParam = add_default(SimuParam,'Export_beamlet',0);
SimuParam = add_default(SimuParam,'E_Cut_Pro', 0.5);
SimuParam = add_default(SimuParam,'D_Max', 0.2);
SimuParam = add_default(SimuParam,'Epsilon_Max', 0.25);
SimuParam = add_default(SimuParam,'Te_Min', 0.05);
SimuParam = add_default(SimuParam,'Simulate_Nuclear_Interactions', 1);
SimuParam = add_default(SimuParam,'Simulate_Secondary_Protons', 1);
SimuParam = add_default(SimuParam,'Simulate_Secondary_Deuterons', 1);
SimuParam = add_default(SimuParam,'Simulate_Secondary_Alphas', 1);
SimuParam = add_default(SimuParam,'ProtonOnly',0);
SimuParam = add_default(SimuParam,'Independent_scoring_grid',0);
SimuParam = add_default(SimuParam,'Dose_weighting_algorithm','Volume');

end

function SimuParam = add_default(SimuParam,tag,value)
if(not(isfield(SimuParam,tag)))
    SimuParam.(tag) = value;
end
end
