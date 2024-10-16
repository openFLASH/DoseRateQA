%% rounding
% Round the number |X| to a multiple of |Step|
%
%% Syntax
% |Xr = rounding(X , Step)|
%
%
%% Description
% |Xr = rounding(X , Step)| Description
%
%
%% Input arguments
% |X| -_SCALAR VECTOR_- Numbers to be rounded
%
% |Step| -_SCALAR_- The rounding is a multiple of the step
%
%
%% Output arguments
%
% |Xr| -_SCALARVECTOR _- The rounded numbers |X| to a multiple of |Step|
%
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function Xr = rounding(X , Step)
  NbSteps = round(X ./ Step); %Get a round number of multiple of |Step|
  Xr = Step .* NbSteps;
end
