%% MU_to_NumProtons
% Compute the number of protons in a PBS spot with given energy and monitoring units.
%
%% Syntax
% |NumProtons = MU_to_NumProtons(weight, energy)|
%
%
%% Description
% |NumProtons = MU_to_NumProtons(weight, energy)| Description
%
%
%% Input arguments
% |weight| - _SCALAR_ - Monitoring unit for the spot
%
% |energy| - _SCALAR_ - Spot energy (MeV)
%
%
%% Output arguments
%
% |NumProtons| - _SCALAR_ - Number of protons
%
%
%% Contributors
% Authors : K. Souris (open.reggui@gmail.com)

function NumProtons = MU_to_NumProtons(weight, energy)

% Constant which depends on the mean energy loss (W) to create an electron/hole pair
K = 35.87; % in eV (other value 34.23 ?)

% Air stopping power (fit ICRU) multiplied by air density
SP = (9.6139e-9*energy^4 - 7.0508e-6*energy^3 + 2.0028e-3*energy^2 - 2.7615e-1*energy + 2.0082e1) * 1.20479E-3 * 1E6; % in eV / cm

% Temp & Pressure correction
PTP = 1.0; 

% MU calibration (1 MU = 3 nC/cm)
% 1cm de gap effectif
C = 3.0E-9; % in C / cm

% Gain: 1eV = 1.602176E-19 J
Gain = (C*K) / (SP*PTP*1.602176E-19);

NumProtons = weight*Gain;


% Loic's formula
%K=37.60933;
%SP= 9.6139e-9*energy^4 - 7.0508e-6*energy^3 + 2.0028e-3*energy^2 - 2.7615e-1*energy + 2.0082e1;
%PTP=1;
%Gain=3./(K*SP*PTP*1.602176E-10);
%NumProtons = weight*Gain;

end
