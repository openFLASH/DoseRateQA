function [ Image_data, Image_info ] = Import_MC2_MHD_image( FileName )

disp(' ')


if(exist(FileName) == 0)
    error(['File ' FileName ' not found! Perhaps MC2simulation has not generated any Dose map...'])
end


try
    disp(['Read MHD file: ' FileName]);
    Image_info = mha_read_header(FileName);
    Image_data = mha_read_volume(Image_info);
catch
    disp('Could not open output dose map');
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
    return
end


% Convert data for compatibility with MCsquare
% These transformations may be modified in a future version
Image_data = flipdim(Image_data, 1);
Image_data = flipdim(Image_data, 2);
%Image_data = permute(Image_data, [2 1 3]);

end

