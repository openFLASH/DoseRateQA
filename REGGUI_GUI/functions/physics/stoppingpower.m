%% stoppingpower
% Compute the Stopping Power for a given material (of known composition and density) with a given I-value,
% at a given energy using the Bethe Bloch equation.
%
%
%% Syntax
%
% | S | = stoppingpower(density_t , w_t , Z_t , I_t, E_in)
%
%% Input arguments
%
% |density_t| - _SCALAR_ -  Density of the material, expressed in kg/m^3
%
% |w_t| - _SCALAR VECTOR_ - Elemental composition of the material, in mass fractions
%
% |Z_t| - _SCALAR VECTOR_ -  Atomic numbers of elemental composition of the material
%
% |I_t| - _SCALAR_ -  Mean excitation energy (I-value) of the material, expressed in eV
%
% |E_in| - _SCALAR_ - Proton energy, expressed in MeV
%
%% Output arguments
%
% |S| - _SCALAR_ - Stopping power, expressed in MeV/cm
%
%
%% Contributors
% Authors : Valerie De Smet(va.desmet@uclouvain.be)
% 2017-05-24

function [ S ] = stoppingpower(density_t , w_t , Z_t , I_t, E_in)

% Physical constants (natural units)
physicsConstants;


beta = KE_to_beta(E_in);
A_t = A(Z_t);
ZA_t =  sum(w_t .*  Z_t./A_t);
I_t = I_t * eV ;

e = eV;  % electron charge [C]  -> eV defined in physics_constants

S = density_t * (1/(4*pi*(epsilon_0)^2) * e^4/(m_e*c^2 * u * beta^2 )) * ZA_t * ( log(2*m_e*c^2*beta^2/(I_t*(1-beta^2))) - beta^2 ) ; % expressed in J/m

S = S ./ MeV ./ 100 ; % convert to MeV/cm

end
