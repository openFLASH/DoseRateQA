%% getNumberLogicalCores
% Return the number of logical core installed on the machine and the number of logical core that the OS allocated to MAtlab
%
%% Syntax
% |[CoreTotal , CoreMatlab] = getNumberLogicalCores()|
%
%
%% Description
% |[CoreTotal , CoreMatlab] = getNumberLogicalCores()| Description
%
%
%% Input arguments
% None
%
%
%% Output arguments
%
% |CoreTotal| - _SCALAR_ - Total number of logical cores available on the machine
%
% |CoreMatlab| - _SCALAR_ - Number of logical cores allocated by the operating system to Matlab
%
%
%%REFERENCE
% [1] https://undocumentedmatlab.com/articles/undocumented-feature-function
% [2] https://nl.mathworks.com/matlabcentral/answers/306812-how-to-get-the-number-of-logical-cores-parallel-computing-toolbox
% [3] https://www.xmodulo.com/run-program-process-specific-cpu-cores-linux.html
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function [CoreTotal , CoreMatlab] = getNumberLogicalCores()

  core_info = evalc('feature(''numcores'')'); %Retreive all core info [1]
  Dcell =  textscan(core_info,'%s','delimiter','\n'); %Split the text output into lines
  Dcell = Dcell{1};

  %A = cell2mat(strfind(Dcell , 'MATLAB detected:'))
  IndexDetected    = cellfun(@(s) ~isempty(strfind(s , 'MATLAB detected:')), Dcell);
  IndexAssigned    = cellfun(@(s) ~isempty(strfind(s , 'MATLAB was assigned:')), Dcell);
  IndexLogicalCore = cellfun(@(s) ~isempty(strfind(s , 'logical cores')), Dcell);

  IndexDetected = IndexDetected .* IndexLogicalCore; %Index of the line reporting detected logical cores
  IndexAssigned = IndexAssigned .* IndexLogicalCore; %Index of the line reporting assigned logical cores


  A = strsplit(Dcell{find(IndexDetected)});
  CoreTotal = str2num(A{3});

  A = strsplit(Dcell{find(IndexAssigned)});
  CoreMatlab = str2num(A{4});


end
