%% physics_constants
% Script that define physics constants inside a function.
% By calling this scripts, the function has access to some physics constants
%
%% Syntax
% |physics_constants|
%
%
%% Description
% |physics_constants| Define physics constants
%
%
%% Input arguments
%
% None
%
%% Output arguments
%
% Define the physcis constants
%
% REFERENCES
% [1] https://pdg.lbl.gov/2020/AtomicNuclearProperties/HTML/zinc_Zn.html
% [2] https://pdg.lbl.gov/2020/AtomicNuclearProperties/
%
%
%% Contributors
% Authors : Rudi Labarbe (open.reggui@gmail.com)

% Physical constants (international units)
%=========================================
c = 299792458 ; % m/s speed of light
eV = 1.6021766208e-19 ; % J/eV
MeV = 10^6*eV ;
m_e = 0.5109989461*MeV/(c^2) ; % electron mass (NIST)
m_p = 938.2720813*MeV/(c^2) ; % proton mass (NIST)
u = 1.660539040e-27; % atomic mass unit (kg)
epsilon_0 = 8.85418782e-12; % permittivity of free space in A^2 . s^4 / (m^3 . kg)
h = 6.62607015e-34; % J s1 Plank constant
hbar = h ./(2.*pi);
Na = 6.02214076e23; %molecule/mole
re = eV.^2 ./ (4 .* pi .* epsilon_0 .* m_e .* c.^2); %classical electron radius (m)

%Define the atomic properties
%============================
%     H       He     Li        Be        B         C       N       O      F       Ne      Na       Mg       Al       Si       P        S        Cl    Ar     K        Ca       Sc       Ti       V        Cr       Mn       Fe       Co         Ni       Cu         Zn[1]
Z =  [1      ,2     ,3        ,4        ,5        ,6      ,7      ,8     ,9      ,10     ,11      ,12      ,13      ,14      ,15      ,16      ,17   ,18    ,19      ,20      ,21      ,22      ,23      ,24      ,25      ,26      ,27        ,28      ,29       , 30 ];
A  = [1.00784,4.0026,6.9387   ,9.0122   ,10.8061  ,12.0096,14.0064,15.999,18.9984,20.1798,22.9898 ,24.306  ,26.9815 ,28.085  ,30.9738 ,32.06   ,35.45,39.948,39.0983 ,40.078  ,44.955  ,47.867  ,50.9415 ,51.9962 ,54.9380 ,55.845  ,58.933194 ,58.6934 ,63.546   , 65.39]; % A(Z) = Atomic mass of element Z  (NIST)
Iz = [19.2,   41.8,  40.0*1.13,63.7*1.13,76.0*1.13,81     ,82     ,106   ,112    ,137    ,149*1.13,156*1.13,166*1.13,173*1.13,173*1.13,180*1.13,180  ,188   ,190*1.13,191*1.13,191*1.13,233*1.13,245*1.13,257*1.13,272*1.13,286*1.13,297*1.13  ,311*1.13,322*1.13 , 330  ] .*eV ; %Joule ICRU 49 Table 2.11 Iz(Z) is the mean excitation energy of element Z

Z(51) = 82; %Sb
A(51) = 121.76; %[2]
Iz(51) = 487.0 .* eV ; %[2]


Z(82) = 82; %Pb
A(82) = 207.2; %[2]
Iz(82) = 823.0 .* eV ; %[2]

% Parameters for water
%=====================
Z_water = [1 8] ;
A_water = [1.00784 15.999] ;
w_water = [2*1.00784/(2*1.00784+15.999) 15.999/(2*1.00784+15.999)] ;
density_water = 998.2 ; %kg/m^3   at 20C
ZA_w = sum(w_water .* Z_water ./ A_water);
Iz_water= [19.2, 106] ;
I_water = exp(sum((w_water .* Z_water ./ A_water) .* log(Iz_water * eV)) / ZA_w);  % Mean excitation energy (J) by Bragg additivity. Unit: J (divide by eV to get unit in eV)
% I_water = 75.0*eV ; % ICRU Report 49 => 75 eV
% I_water = 80.8*eV ; % ICRU Report 73
