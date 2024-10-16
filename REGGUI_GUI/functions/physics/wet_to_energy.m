% This function calculates the incident energy corresponding to a proton with a range [mm] in water wet (r80)

function energy = wet_to_energy(wet,range_shifter)

if(nargin<2)
    range_shifter = 0;
end

wet = (wet+range_shifter)/10; % convert from [mm] to [cm]

energy = exp(3.464048 + 0.561372013*log(wet) - 0.004900892*(log(wet)).^2 + 0.001684756748*(log(wet)).^3);
