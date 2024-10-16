%% isDoseOrDoseRate
% Check whether the image modality is 'RTDOSE' or 'RTDOSERATE'
%
%% Syntax
% |r = isDoseOrDoseRate(modality)|
%
%
%% Description
% |r = isDoseOrDoseRate(modality)| Description
%
%
%% Input arguments
% |modality| - _STRING_ -  DICOM image modality
%
%
%% Output arguments
%
% |r| -_BOOLEAN_- |true| if the image is a RTDOSE or RTDOSERATE. |false| otherwise
%
%
%% Contributors
% Authors : R. Labarbe (open.reggui@gmail.com)

function r = isDoseOrDoseRate(modality)
  r = sum(strcmp(modality,{'RTDOSE','RTDOSERATE'}));
end
