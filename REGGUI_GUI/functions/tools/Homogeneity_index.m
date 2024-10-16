%% Homogeneity_index
% Compute the homogeneity index of a dose map in a volume.
%
%% Syntax
% |res = Homogeneity_index(dose_name,tv_name,at_volume,handles)|
%
%
%% Description
% |res = Homogeneity_index(dose_name,tv_name,at_volume,handles)| Compute the Homogeneity_index coefficient
%
%
%% Input arguments
% |dose_name| - _STRING_ -  Name of the dose map in |handles.images|, |handles.fileds| or |handles.mydata|
%
% |tv_name| - _STRING_ -  Name of the target volume in |handles.images|, |handles.fileds| or |handles.mydata|
%
% |at_volume| - _DOUBLE_ -  Percentage of volume for homogeneity index computation (in percent)
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images', 'fields' or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%% Output arguments
%
% |res| - _SCALAR VECTOR_ - The results:
%
% * |res(1)| = the Homogeneity_index coefficient
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = Homogeneity_index(dose_name,tv_name,at_volume,handles)

for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},dose_name))
        D = handles.mydata.data{i};
    end
    if(strcmp(handles.mydata.name{i},tv_name))
        TV = handles.mydata.data{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},dose_name))
        D = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},tv_name))
        TV = handles.images.data{i};
    end
end
try    
    TV = double(TV >= max(TV(:))/2);
    d1 = dose_to_volume(D(TV>=0.5),at_volume/100);
    d2 = dose_to_volume(D(TV>=0.5),1-at_volume/100);
    HI = min(d1,d2)/max(d1,d2);    
    if(isnan(HI))
        disp('These images are empty...')
    else
        res = HI;
        disp(['Homogeneity index of ', dose_name, ' in ', tv_name, '  =  ', num2str(HI)]);
    end
catch
    disp('Error : images not found or uncorrect size!')
end
