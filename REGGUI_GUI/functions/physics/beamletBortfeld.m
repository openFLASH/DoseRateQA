%% beamletBortfeld
% Analytical equation to calculate the Bragg curve for proton energies between 10 and 200 MeV going through an homogeneous medium.
% Bortfeld model [2] provides an analytical approximation of the Bragg curve in closed form.
% The  model is valid for proton energies between about 10 and 200 MeV
%
% The range is assumed to be related to the initial energy via: R0 = alpha * E0^p
%
% The factor alpha is approximately proportional to the square root of the effective atomic mass of the absorbing medium (Bragg–Kleeman rule). It is also inversely proportional to the mass density of the medium. [2]
%
% The sigma of the beam straggling is the convenient power law approximations of the proton beam range (equation 12 in [1]):
% sigma = beam.k .* R0 .^ beam.m;
%
%% Syntax
% |res = beamlet_Bortfeld()|
%
%
%% Description
% |res = beamlet_Bortfeld()| Description
%
%
%% Input arguments
% |z| - _SCALAR VECTOR_ -  z(i) Depth (cm) of the i-th point
%
% |material| - _STRUCTURE_ - Definition of the material through which the beam is going:
%  * |material.alpha| - _SCALAR_ - (cm MeV^(-p)) Factor of the  range vs energy curve.
%  * |material.p| - _SCALAR_ - Exponent of the Bragg Kelman equation. No unit.  From [2]
%  * |material.rho| - _SCALAR_ - Mass density (g/cm^3) of the absorbing material
%  * |material.k| - _SCALAR_ -  material-dependent factor for computing the range stragling sigma. (no unit)
%  * |material.m| - _SCALAR_ -  experimentally determined exponent for computing the range stragling sigma (no unit)
%
% |beam| - _STRUCTURE_ - Definition of the beam properties:
%  * |beam.R0| - _SCALAR_ -  Range (cm) of the pronton beam
%  * |beam.current| - _SCALAR_ -  Beam current density in uA/cm2
%  * |beam.SpotDuration| - _SCALAR_ -  Time (ms) during which the beam is delivered
%  * |beam.epsilon| - _SCALAR_ - [OPTIONAL. Default = 0.2] Fraction of primary fluence contributing to the ‘‘tail’’ of the energy spectrum. epsilon =0 for strictly monoenergetic beam. Typically epsilon <=0.2
%  * |beam.RidgeFilterFunction| -_FUNCTION POINTER_- [OPTIONAL] Pointer to a function (weight = ridgeFilter(Rangeshift (cm))) defining the shape of the ridge filter
%  * |beam.RidgeFilterWeight = [1 0.2 0.1 0.05 0.02 0.01 0.05];
%  * |beam.RidgeFilterShift =  [0 0.5 1   1.5  2    2.5   3]; %cm WET
%
% |ignoreStraggling| -_BOOLEAN_- [OPTIONAL: default = false]. If true, use the eqaution ignoring the range straggling
%
%% Output arguments
%
% |D| - _SCALAR VECTOR_ -  D(i) Dose (Gy) at depth z(i)
%
%% Reference
% [1] Newhauser, W. D., & Zhang, R. (2015). The physics of proton therapy. Physics in Medicine and Biology, 60(8), R155–R209. https://doi.org/10.1088/0031-9155/60/8/R155
% [2] Bortfeld, T., & Introduction, I. (1997). An analytical approximation of the Bragg curve for therapeutic proton beams, 2024–2033.
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function Dz = beamletBortfeld(z, material , beam , ignoreStraggling , verbose)

if nargin < 4
    ignoreStraggling = false;
end
if nargin < 5
    verbose = true;
end

%Physics constants
physicsConstants;

% Define the beam parameters
%===========================
if(~isfield(beam, 'epsilon'))
  beam.epsilon = 0.2;
  fprintf('Using default beam.epsilon = %f \n',beam.epsilon)
end
flux = beam.current .* 1e-6 ./ eV ; % (proton /cm2/s) Convert beam current (in uA/cm2) into nb of proton and divide by unit surface
                        % The lateral Gaussian profile is normalised to 1 so that by multiplying by the profile and integrating over time and surface, we get the proper number of protons
phy0 = beam.SpotDuration .* 1e-3 .* flux; %- _SCALAR_ - Primary fluence (proton / cm^2)
if verbose
  fprintf('Spot duration   = %1.2e ms \n',beam.SpotDuration)
  fprintf('current density = %1.2e uA/cm2 \n',beam.current)
  fprintf('Flux            = %1.2e protons / s.cm2 \n',flux)
  %fprintf('Fluence         = %1.2e protons / cm2 \n',phy0)
  fprintf('Nb protons      = %1.2e protons \n',phy0)
end
R0 = beam.R0; %Range of the pronton beam
sigma = material.k .* R0 .^ material.m; % standard deviation (cm) of the Gaussian distribution of the proton depth (range stragelling)
epsilon = beam.epsilon ; %fraction of low energy proton fluence to the total proton fluence

% Factor of the  stopping power vs energy curve R0 = alpha * E0^p
alpha = material.alpha;%material dependent constant. Material dependent constant. From [2]
p = material.p; % Exponent of the Bragg Kelman equation.  From [2]
rho = material.rho; % Mass density (g/cm^3) of the absorbing material

bta = 0.012; % cm^(-1) Slope parameter of the fluence reduction with depth. Value from [2]
gma = 0.6; % In Bortfeld model, a certain fraction, gamma, of the energy released in the nonelastic nuclear interactions is absorbed locally, and the rest is ignored. Used the same value as [2]


Dz = zeros(1,length(z));

for index = 1:length(z)
    Z = z(index);

    if(ignoreStraggling)
        %Ignore range straggling
        %========================
        if(Z<=R0)
          Dz(index) = DepthDoseNoStraggling(Z, phy0, R0,p,bta,gma,alpha,rho);
        else
          Dz(index) = 0; %Beyond range. Force dose to zero
        end %if(Z<R0)
      else
        %Take range straggling into account
        %====================================
        if(Z<R0-10.*sigma)
          %Far from Bragg peak. Ignore range straggling
          %Equation 11 in [2]
          Dz(index) = DepthDoseNoStraggling(Z, phy0, R0,p,bta,gma,alpha,rho);
        else
          if(Z<=R0+5.*sigma)
              % Near the Bragg peak. Take range straggling and energy tail into account
              Dz(index) = DepthDoseWithStraggling(Z, phy0, R0,p,bta,gma,alpha,rho,sigma,epsilon);
          else
             %Beyond range. Force dose to zero
             Dz(index) =0;
           end %if(z<=R0+5.*sigma)
        end %if(z<R0-10.*sigma)
      end %if(ignoreStraggling)
end %for

%Convert from MeV/g to dose in Gy (J/kg): 1e6 for Mega, e for the proton charge and 1e3 for kilograms
Dz = Dz.*1e6.* eV .* 1e3;

end

%==================================================================
% Ignore range straging
% Equation 11 in [2]
%==================================================================
function Dz = DepthDoseNoStraggling(Z, phy0, R0,p,bta,gma,alpha,rho)
  Dz = phy0 .* ( (R0-Z).^((1./p)-1) + (bta+gma.*bta.*p).*(R0-Z).^(1./p) ) ./ (rho.*p.*alpha.^(1./p).*(1+bta.*R0));
end


%==================================================================
% Take range straggling and tail of the energy spectrum into account
% Equation 26 in [2]
%==================================================================
function Dz = DepthDoseWithStraggling(Z, phy0, R0,p,bta,gma,alpha,rho,sigma,epsilon)
  % Equation 36 in [1] Dose deposited at depth z in MeV/g
  zeta = (R0-Z)./sigma;

  %parabolic cylinder function
  Dp1 = parabolicCylinderFunction(-1./p,-zeta);
  Dp2 = parabolicCylinderFunction(-1./(p-1),-zeta);

  Dz = phy0 .* ( (exp(-zeta.^2./4).*sigma.^(1./p).*gamma(1./p))./(sqrt(2.*pi).*rho.*p.*alpha.^(1./p).*(1+bta.*R0)) )...
       .*((1/sigma).*Dp1 + (bta./p + gma.*bta + epsilon./R0).*Dp2); %Dose at depth z. Eq 36 in [1]
end
