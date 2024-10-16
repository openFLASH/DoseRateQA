%% range2energy
% Compute the initial beam energy from the range
% range = alpha .* E.^p

%
%% Syntax
% |E = range2energy(R, alpha,p)|
%
%
%% Description
% |E = range2energy(R, alpha,p)| Description
%
%
%% Input arguments
%
%  * |R| : range (cm)
%  * |alpha| - _SCALAR_ - (cm MeV^(-p)) Factor of the  range vs energy curve.
%  * |p| - _SCALAR_ - Exponent of the Bragg Kelman equation. No unit.
%
%% Output arguments
%
% * |E| : energy MeV
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)
%
% REFERENCE
% [1] https://gray.mgh.harvard.edu/attachments/article/212/pbs.pdf

function E = range2energy(R, alpha,p)
  E = (R./alpha).^(1./p);
end
