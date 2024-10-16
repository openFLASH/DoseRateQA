%% PBSspotModel
% Create the 3D dose distribution of a PBS beamlet
%
%% Syntax
% |[D,X,Y] = PBSBeamModel(x,y,z,beam,material)|
%
%
%% Description
% |[D,X,Y] = PBSBeamModel(x,y,z,beam,material)| Description
%
%
%% Input arguments
% |x| - _SCALAR VECTOR_ -  X (cm) axis sampling (transversal axis)
% |y| - _SCALAR VECTOR_ -  Y (cm) axis sampling (transversal axis)
% |z| - _SCALAR VECTOR_ -  Z (cm) axis sampling along the proton beam axis
%
% |material| - _STRUCTURE_ - Definition of the material through which the beam is going:
%  * |material.alpha| - _SCALAR_ - (cm MeV^(-p)) Factor of the  range vs energy curve.
%  * |material.p| - _SCALAR_ - Exponent of the Bragg Kelman equation. No unit.  From [2]
%  * |material.rho| - _SCALAR_ - Mass density (g/cm^3) of the absorbing material
%  * |material.k| - _SCALAR_ -  material-dependent factor for computing the range stragling sigma. (no unit)
%  * |material.m| - _SCALAR_ -  experimentally determined exponent for computing the range stragling sigma (no unit)
%  * |material.Xs| - _SCALAR_ -  Scattering length (cm) for WATER. E.g. material.Xs = 46.88 ./ material.rho; %Scattering length (cm) for WATER Table 2 in [5]
%
% |beam| - _STRUCTURE_ - Definition of the beam properties:
%  * |beam.R0| - _SCALAR_ -  Range (cm) of the pronton beam
%  * |beam.current| - _SCALAR_ -  Beam current density in uA
%  * |beam.SpotDuration| - _SCALAR_ -  Time (ms) during which the beam is delivered
%  * |beam.SpotSigma| -_SCALAR_- Sigma (cm) of the Gaussian beam profile at entrance of phantom
%  * |beam.epsilon| - _SCALAR_ - Fraction of primary fluence contributing to the ‘‘tail’’ of the energy spectrum. epsilon =0 for strictly monoenergetic beam. Typically epsilon <=0.2
%
%% Output arguments
%
% |D| - _SCALAR MATRIX_ -  D(x,y,z) Dose (Gy) at depth the coordiante x,y,z
%
% |X| - _SCALAR MATRIX_ - Mesh grid in the tranversal plane X(i,j)
%
% |Y| - _SCALAR MATRIX_ - Mesh grid in the tranversal plane X(i,j)
%
% |Scatter| -_BOOLEAN_- [OPTIONAL. Default = true]. If true, then compute the lateral scatter. If false, ignore larteral beam spreading
%
%% Output arguments
%
% |res| - _STRUCTURE_ -  Description
%
%% Reference
% [1] Newhauser, W. D., & Zhang, R. (2015). The physics of proton therapy. Physics in Medicine and Biology, 60(8), R155–R209. https://doi.org/10.1088/0031-9155/60/8/R155
% [2] Bortfeld, T., & Introduction, I. (1997). An analytical approximation of the Bragg curve for therapeutic proton beams, 2024–2033.
% [3] Pedroni, E., Scheib, S., Bohringer, T., Coray, A., Grossmann, M., Lin, S., … Division. (2005). Experimental characterization and physical modelling of the dose distribution of scanned proton pencil beams. Phys. Med. Biol., 50, 541–561. https://doi.org/10.1088/0031-9155/50/3/011
% [4] Russell, K. R., Isacsson, U., Carlsson, K., Andreo, P., & Brahme, A. (1997). Physics in Medicine & Biology Related content Monte Carlo and analytical calculation of proton pencil beams for computerized treatment plan optimization Monte Carlo and analytical calculation of proton pencil beams for computerized treatment plan optimiza. Retrieved from https://iopscience.iop.org/article/10.1088/0031-9155/42/6/004/pdf
% [5] Gottschalk, B. (2009). On the scattering power of radiotherapy protons, 1–33. Retrieved from https://arxiv.org/pdf/0908.1413.pdf
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function [D,X,Y] = PBSBeamModel(x,y,z,beam,material,Scatter)

if nargin < 6
  Scatter = true;
end

%Compute the BP profile
% The beam current is given in uA. "beamletBortfeld" expects a beam current density (uA/cm2)
% However, the function beamprofile is normalise so that its SURFACE (=integral) is equal to 1
% As we are multiplying Dz by Dlat, we can afford to use the current instead of hte current density as input of "beamletBortfeld"
% In addition, the Gaussian uses cm as units. therefore, the area under the Gaussian is 1cm2
%
% Current = integ [cur_density * dx.dy]
% Current = integ [J * Gauss(x,y) * dx.dy]
% Current = J * integ [Gauss(x,y) * dx.dy]
% Current = J * 1cm2
%  J = Current / 1cm2
Dz = beamletBortfeld(z, material , beam); %Dose in Gy
[X,Y] = meshgrid(x,y);


%Compute beam lateral profile at each depth
sigmaM = zeros(length(z),1);

for index = 1:length(z)
  if(Scatter)
    [Dlat, sigma] = beamProfile(x,y,z(index),beam,material); %Compute the transversal beam profile at depth z
    D(:,:,index)= Dlat .* Dz(index);
    sigmaM(index)=sigma;
    %fprintf('sigma(z=%fcm) = %f cm \n',z(Zindex),sigmaM(Zindex));
  else
    % PBSBeamModel require the current density in uA/cm2
    % Divide by the beam surface so that the fluence work out correctly
    % Circular spot, with radius beam.SpotSigma
    D(:,:,index)= ones(size(X)).*Dz(index)./(pi.*beam.SpotSigma.^2);
  end %if
end %for

fprintf('Max current density at entrance = %f uA/cm2 \n',max(max(squeeze(D(:,:,1)))));

[~ , Zindex] = min(abs(Dz-beam.R0));


%===========================
%If there is a ridge filter
% spread the dose in Depth
%===========================
if(isfield(beam,'RidgeFilterFunction'))
  H = beam.RidgeFilterFunction();
  fprintf('Ridge filter height = %f cm \n', H);
  dZ = diff(z);
  Zstep = dZ(1);
  fprintf('Voxel height = %f cm\n', Zstep);
  NbSteps = round(H./Zstep);
  fprintf('Nb of Z shifts = %f\n', NbSteps(1));

  weightSUM = beam.RidgeFilterFunction(0);
  Dout = D .* weightSUM ; %Multiply by the weight of full range proton in ridge filter

  for Z = 1:NbSteps-1
    [~ , Zindex] = min(abs(z-Z.*Zstep)); ; %Cut this inital part of the BP profile because ofthe range shifter
    weight = beam.RidgeFilterFunction(Z.*Zstep);
    weightSUM = weightSUM + weight;
    fprintf('Range shift = %f cm :: Weight = %f \n',Z.*Zstep,weight);
    Dout(:,:,1:length(z)-Zindex+1)=Dout(:,:,1:length(z)-Zindex+1) + D(:,:,Zindex:length(z)).*weight;
  end %for Z
  D = Dout ./weightSUM; %REnormalise so that the sum of weight is equal to one. We spread the proton in depth but we do not want to loose protons
  fprintf('Sum of weights = %f \n',weightSUM);
end %if(isfield

end


%=================================
% Compute beam profile at depth z
% by taking into account the increase of beam sigma with multi coulonb scattering
% as decribed in [3]
% The function is normalised so that for each plane (X,Y), the integral of the Gaussian in the plane is equal to 1
%
% INPUT
% |x| -_SCALAR VECTOR_- X (cm) axis sampling (transversal axis)
% |y| -_SCALAR VECTOR_- Z (cm) axis sampling (transversal axis)
% |z| -_SCALAR_- Depth (cm) at which the lateral profile is computerized
%
% OUPUT
% |Dlat| -_SCALAR VECTOR_- |Dlat(x,y,z)| Relative beam intensity at depth coordinate x,y,z
% |sigma| -_SCALAR_- Sigma (cm) of the Gaussian profile
%=================================

function [Dlat , sigma] = beamProfile(x,y,z,beam,material)

%Prepare the output variable
Dlat = zeros(length(x),length(y),length(z));

%Define the physics constant
physicsConstants;

%Compute some physics parameters
E0 = range2energy(beam.R0, material.alpha,material.p); %Proton initial energy MeV
T0 = MassScatteringPower(E0, material.Xs, material.rho); % Mass scattering power at initial proton energy  Mass scattering power = scattering pwer / density material
S0 = stoppingpower(material.rho .* 1000 , w_water , Z_water , I_water, E0); %stopping power MeV/cm NB: density must be in kg/m3
epsilon0 = S0./E0; %specific stopping power: S0 mass stopping power at initial energy E0

%Compute the beam sigma at the Z depth
sigma2 = spotSigmaRMSradius(z,T0,epsilon0,beam.SpotSigma);
sigma = sqrt(sigma2);
%sigma2 = spotSigmaPowerLawRMS(z,beam.SpotSigma)

%Compute the transversal beam profile at depth z
[X,Y] = meshgrid(x,y);
Dlat = (1./(2.*pi.*sigma2)).*exp(-(X.^2 + Y.^2)./(2.*sigma2)); %Gaussian beam profile Eq. 11 in [4]

end

%================================================
% sigma (cm) of the beam at depth z Equation 12 in [4]
%
% INPUT
% z : depth (cm)
% T0 : Mass scattering power at initial proton energy  Mass scattering power = scattering pwer / density material
% epsilon0 : specific stopping power: S0 mass stopping power at initial energy E0

%================================================
function sigma2 = spotSigmaRMSradius(z,T0,epsilon0,SpotSigma0)
  r2 = (T0./3).*z.^3 .* (1 + 0.5.*epsilon0.*z); %Mean square radius (cm) of the beam at depth z Equation 12 in [4]
  sigma2 = (SpotSigma0 + sqrt(r2./2)).^2;
end

%================================================
% sigma (cm) of the beam at depth z Equation 12 in [4]
%
% INPUT
% z : depth (cm)
% T0 : Mass scattering power at initial proton energy  Mass scattering power = scattering pwer / density material

%================================================
function sigma2 = spotSigmaPowerLawRMS(z,SpotSigma0)
  a = 0.0294; %for water [1]
  b = 0.896; %for water [1]
  r = a.*z.^b;
  sigma2 = (SpotSigma0 + r./sqrt(2)).^2;
end


%==================================
% Mass scattering power (T/rho) according to ICRU35
% Equation 24 in [5]
% Applicable to radiotherapy protons, 3 to 300MeV
%
% Input
%
% |E| : proton energy (MeV)
% |Xs| : scattering length (cm)
% |rho| : material density (g/cm3)
%
% OUTPUT
% |T| : Mass scattering power (cm2/g)
%==================================
function T = MassScatteringPower(E, Xs, rho)

physicsConstants;

E = E .* 1e6 .* eV; %J Proton enrgy
tau = E./(m_p.*c.^2); %eq 3 in [5]
pv = E.*(tau+2)./(tau+1); %Eq 4 in [5]
Es = 15 .* 1e6 .*eV; %J Eq 19 in [5]

T = (1./rho) .* (Es ./ pv).^2 .* (1./Xs);

end
