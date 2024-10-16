%% function
% Compute parabolic cylinder function D(p,z)
% Equation defined in [1], page 1028, equation 9.240
% The computation uses confluent hypergeometric function from library [2].
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
% [2] https://nl.mathworks.com/matlabcentral/fileexchange/12665-confluent-hypergeometric-function-kummer-function
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function Dpz = parabolicCylinderFunction1(p,z)

Dpz = zeros(1,length(z));

for index = 1:length(z)

    phi1=KummerComplex(-p./2    ,0.5 ,z(index).^2 ./2); % confluent hypergeometric function from [2]
    if(~isnumeric(phi1))
        fprintf('p = %f \n',p);
        fprintf('z = %f \n',z(index))
        error('Cannot compute the hypergeometric function')
      end

    phi2=KummerComplex((1-p)./2 ,1.5 ,z(index).^2 ./2);
    if(~isnumeric(phi2))
        fprintf('p = %f \n',p);
        fprintf('z = %f \n',z(index))
        error('Cannot compute the hypergeometric function')
      end

     Dpz(index) = power(2,p./2) .* exp(-z(index).^2 ./4) .* ...
                      (phi1 .* sqrt(pi) ./ gamma((1-p)./2) ...
                     - phi2 .* sqrt(2.*pi).*z(index) ./ gamma(-p./2));
end

end
