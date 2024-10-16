%% sort_dicom_series
% Sort the DICOM files contained in a directory into sub-directories according to their SeriesInstanceUID.
% The function create a sub-directory per SeriesInstanceUID and move all DICOM file with that SeriesInstanceUID into this sub-directory.
%
%% Syntax
% |sort_dicom_series(dirname)|
%
%
%% Description
% |sort_dicom_series(dirname)| Sort the directory according to SeriesInstanceUID.
%
%
%% Input arguments
% |dirname| - _STRING_ - Name of the directory to sort according to SeriesInstanceUID.
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens, J.Orban (open.reggui@gmail.com)

function sort_dicom_series(dirname)

current_dir = pwd;
existing = struct;

try
    cd(dirname)
    files = dir;
    existing(1).str = 'test';

    for i = 3:length(files)
        if(not(isdir(files(i).name)))
            disp([dirname '/' files(i).name])
            a = dicominfo(files(i).name);
            done = 0;
            for j = 1:length(existing)

                if strcmp(existing(j).str, a.SeriesInstanceUID)
                    movefile(files(i).name,[existing(j).str '/' files(i).name]);
                    done = 1;
                end

            end
            if done == 0
                mkdir(a.SeriesInstanceUID);
                existing(j+1).str = a.SeriesInstanceUID;
                movefile(files(i).name,[existing(j+1).str '/' files(i).name]);
            end
        end
    end

catch ME
    disp('Error while sorting dicom series')
    cd(current_dir);
    rethrow(ME);
end

cd(current_dir);
