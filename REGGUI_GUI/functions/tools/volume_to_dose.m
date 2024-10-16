%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Vd = volume_to_dose(dose,mask,dose_value)

Vd = 100*length(mask(dose>=dose_value & mask>=0.5))/length(mask(mask>=0.5));