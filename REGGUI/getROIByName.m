%% getROIByName
% This function finds the index of a given region of interest (ROI),
% provided its name. This index corresponds to its position in the DICOM 
% RTSTRUCT list.
%%

%% Syntax
% |ROIindex = getROIByName(ROI,ROIname)|

%% Description
% |ROIindex = getROIByName(ROI,ROIname)| returns the index 
% (|ROIindex|) of a certain ROI with name |ROIname| from the list of 
% structures (|ROI|) read from the RTSTRUCT file.

%% Input arguments
% |ROI| - _struct_ - MIROpt structure containing information about all volumes in the RTSTRUCT file. The following data must be present in thestructure:
%
% * |ROI(i).name| - _string_ - Name of the i-th ROI in the RTSTRUCT list. This must be encoded for all structures, i. e., i = 1, ..., N; where N is the total number of ROIs.

%% Output arguments
% |ROIindex| - _integer_ - Index of the given ROI (position in the RTSTRUCT list).

%% Contributors
% Authors : Ana Barragan, Lucian Hotoiu


function ROIindex = getROIByName(ROI,ROIname)

% This function receives the name of the ROI and gives the ROI index in
% order to use the corresponding mask
ROInames = cell(length(ROI),1);
for i = 1:length(ROI)
    ROInames{i} = ROI(i).name;
end
ROIindex=find(strcmp(ROIname,ROInames));

