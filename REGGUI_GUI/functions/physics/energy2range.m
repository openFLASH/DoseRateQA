%% energy2range
% Compute the range from the initial beam energy
% range = alpha .* E.^p

%
%% Syntax
% |R = energy2range(E, alpha,p)|
%
%
%% Description
% |R = energy2range(E, alpha,p)| Description
%
%
%% Input arguments
%
% * |E| : energy MeV
%  * |alpha| - _SCALAR_ - (cm MeV^(-p)) Factor of the  range vs energy curve.
%  * |p| - _SCALAR_ - Exponent of the Bragg Kelman equation. No unit.
%
%% Output arguments
%
%  * |R| : range (cm)
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)
%
% REFERENCE
% [1] https://gray.mgh.harvard.edu/attachments/article/212/pbs.pdf

function R = energy2range(E, alpha,p)
  R = alpha .* E.^p;
end
