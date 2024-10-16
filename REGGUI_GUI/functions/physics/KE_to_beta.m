%% KE_to_beta
% Compute beta (velocity divided by speed of light in vacuum) from the kinetic energy
%
%% Syntax
% |[beta] = KE_to_beta(KE) |
% |[beta] = KE_to_beta(KE,RestEnergy)|
%
%% Description
% |[beta] = KE_to_beta(KE) |  - Compute beta for a PROTON of kinetic energy KE
% |[beta] = KE_to_beta(KE,RestEnergy)|  - Compute beta for a particle of kinetic energy KE and rest energy RestEnergy
%
%% Input arguments
% |KE| - _SCALAR_ - Kinetic energy, expressed in MeV (or in the same units as RestEnergy if it is provided)
% |RestEnergy| - _SCALAR_ -  energy of the particle at rest (mass at rest *
% speed of light in vacuum)
%
%% Output arguments
%
% |beta| - _SCALAR_ -  particle velocity divided by speed of light in vacuum
%
%% Contributors
% Authors : Valerie De Smet (va.desmet@uclouvain.be)

function [beta] = KE_to_beta(KE,RestEnergy)

if (nargin == 1)
 RestEnergy = 938.2720813; % mc2 for proton [MeV]
end

TotalEnergy = KE + RestEnergy;

beta = sqrt(1 - (RestEnergy ./ TotalEnergy).^2);

return
