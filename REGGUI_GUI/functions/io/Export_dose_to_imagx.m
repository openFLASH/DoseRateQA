%% Export_dose_to_imagx
% Write in a text file the values of the dose and the water equivalent path length (WEPL) at every pixels contained inside an image mask.
% The text file contains one line per pixel with the x,y,z coordinates (in mm), the dose and the WEPL at the corresponding pixel.
%
%% Syntax
% |Export_dose_to_imagx(outname,handles,dose_name,roi_name,wepl_name)|
%
%
%% Description
% |Export_dose_to_imagx(outname,handles,dose_name,roi_name,wepl_name)| Export the dose and WEPL to a text file
%
%
%% Input arguments
% |outname| - _STRING_ -  Name of the file in which the data shall be saved
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name{i}| - _STRING_ - Name of the new image
% * |handles.images.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.mydata.info| 
%
% |dose_name| - _STRING_ -  Name of the dose map stored in |handles.images|
%
% |roi_name| - _STRING_ -  Name of the region of of interest stored in |handles.images| 
%
% |wepl_name| - _STRING_ -  Name of the WEPL map  stored in |handles.images|
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Export_dose_to_imagx(outname,handles,dose_name,roi_name,wepl_name)

for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},dose_name))
        dose = handles.images.data{i};
        dose_info = handles.images.info{i};
    end
end

if(nargin<4)
    roi = ones(size(dose));
else
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},roi_name))
            roi = handles.images.data{i};
        end
    end
    roi = roi>(max(roi(:))/2);
end

if(nargin<5)
    wepl = zeros(size(dose));
else
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},wepl_name))
            wepl = handles.images.data{i};
        end
    end
end

if(isempty(outname))
    default_name = cell(0);
    default_name{1} = remove_bad_chars([dose_info.OriginalHeader.PatientName.FamilyName,'_',dose_info.OriginalHeader.PatientID]);
    filename = inputdlg({'Choose a name to store dose map'},' ',1,default_name);
    outname = fullfile(handles.dataPath,[filename{1},'.wepl']);
end
if(isempty(strfind(outname,'.')))
    outname = [outname,'.wepl'];
end

try
    data_waitbar = waitbar(0,'Writing to file...');
    fid = fopen(outname,'w');
    
    fprintf(fid,dose_info.OriginalHeader.PatientID);
    fprintf(fid,',');fprintf(fid,dose_info.OriginalHeader.PatientName.FamilyName);
    fprintf(fid,',');fprintf(fid,[dose_info.OriginalHeader.PatientName.FamilyName(1),dose_info.OriginalHeader.PatientName.GivenName(1)]);
    fprintf(fid,',');fprintf(fid,dose_info.OriginalHeader.PatientName.GivenName);
    fprintf(fid,',');fprintf(fid,'Treatment Plan Label');
    fprintf(fid,',');fprintf(fid,'Beam Name');
    fprintf(fid,',');fprintf(fid,'Gantry treatment angle');
    fprintf(fid,',');fprintf(fid,'TPS BEAM RANGE');
    fprintf(fid,',');fprintf(fid,'\n');fprintf(fid,'Static Checks');
    fprintf(fid,',');fprintf(fid,'WEPLCalVer');
    fprintf(fid,',');fprintf(fid,'Xmin');
    fprintf(fid,',');fprintf(fid,'Xmax');
    fprintf(fid,',');fprintf(fid,'Ymin');
    fprintf(fid,',');fprintf(fid,'Ymax');
    fprintf(fid,',');fprintf(fid,'Zmin');
    fprintf(fid,',');fprintf(fid,'Zmax');
    fprintf(fid,',');fprintf(fid,'Grid size');
    fprintf(fid,',');fprintf(fid,num2str(size(dose,1)*size(dose,2)*size(dose,3)));
    fprintf(fid,',');fprintf(fid,num2str(mean(wepl(:))));
    fprintf(fid,'\n');
    
    for i=1:size(dose,3)
        waitbar(i/size(dose,3),data_waitbar);
        for j=1:size(dose,2)
            for k=1:size(dose,1)
                if(roi(k,j,i))
                    % coordinates in TPS coordinate system (same origin as DICOM, but y=z and z=-y)
                    fprintf(fid,'Element,%3.1f,%3.1f,%3.1f,%1.2e,%1.3e\n',handles.origin(1)+(k-1)*handles.spacing(1),handles.origin(3)+(i-1)*handles.spacing(3),-(handles.origin(2)+(j-1)*handles.spacing(2)),wepl(k,j,i),dose(k,j,i));
                end
            end
        end
    end
    
    fclose(fid);
    close(data_waitbar);
    
catch ME
    fclose(fid);
    rethrow(ME);
end
