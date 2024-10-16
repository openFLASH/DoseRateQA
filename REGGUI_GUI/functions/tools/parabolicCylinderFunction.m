%% function
% Compute parabolic cylinder function D(p,z)
% Equation defined in [1], page 1028, equation 9.240
% The computation uses Cojocaru's library [2].
%
%% Syntax
% |Dpz = parabolicCylinderFunction(p,z)|
%
%
%% Description
% |Dpz = parabolicCylinderFunction(p,z)| Compute parabolic cylinder function D(p,z)
%
%
%% Input arguments
% |p| - _SCALAR_ -  Name
%
% |z| - _SCALAR VECTOR_ -  Name
%
%
%% Output arguments
%
% |res| - _STRUCTURE_ -  Description
%
%% REFERENCE
% [1] Gradshteyn, I. S., & Ryzhik, I. M. (n.d.). Table of integrals, series and products. Retrieved from http://fisica.ciens.ucv.ve/~svincenz/TISPISGIMR.pdf
% [2] https://nl.mathworks.com/matlabcentral/fileexchange/22620-parabolic-cylinder-functions
% [3] https://en.wikipedia.org/wiki/Parabolic_cylinder_function
% [4] https://dlmf.nist.gov/12.3
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function Dpz = parabolicCylinderFunction(p,z)

Dpz = zeros(1,length(z));

for index = 1:length(z)

    %check the condition under which the numerical model
    % is well behaved. If outside those condition, write a warning
    if(abs(p) > 5)
      %warning('|p| ~< 5')
    end
    if(abs(z) > 5)
      %warning('|z| ~< 5')
    end
    % See [3] for relation between Dpz and pu
       Dpz(index) = pu(-p-0.5,z(index)); %|a| < 5 and |z| < 5
end

end
