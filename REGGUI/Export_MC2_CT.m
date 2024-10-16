function Export_MC2_CT(SimuParam, ct, info, DestinationFile)


disp(' ')

if(nargin < 4)
    DestinationFile = fullfile(SimuParam.Folder, 'CT.mhd');
end

[DestPath,DestName,DestExt] = fileparts(DestinationFile);
if(strcmp(DestExt, '.mhd') || strcmp(DestExt, '.MHD'))
    MHD_File = fullfile(DestPath, [DestName DestExt]);
    RAW_File = fullfile(DestPath, [DestName '.raw']);
    RAW_File_name = [DestName '.raw'];
else
    MHD_File = fullfile(DestPath, [DestName DestExt '.mhd']);
    RAW_File = fullfile(DestPath, [DestName DestExt '.raw']);
    RAW_File_name = [DestName DestExt '.raw'];
end

disp(['Export MHD CT: ' MHD_File]);

ct = flipdim(ct, 1);
ct = flipdim(ct, 2);

MC2_origin = Dicom_to_MC2_coordinates(info.ImagePositionPatient, info.Spacing, info.Spacing(:).*size(ct)');

% Write header file (info)
fid = fopen(MHD_File, 'w', 'l');
fprintf(fid,'ObjectType = Image\n');
fprintf(fid,'NDims = 3\n');
fprintf(fid,'DimSize = %d %d %d\n', size(ct));
fprintf(fid,'ElementSpacing = %f %f %f\n', info.Spacing);
fprintf(fid,'Offset = %f %f %f\n', MC2_origin);
fprintf(fid,'ElementType = MET_FLOAT\n');
fprintf(fid,'ElementByteOrderMSB = False\n');
fprintf(fid,'ElementDataFile = %s\n', RAW_File_name);
fclose(fid);

% Write binary file (data)
fid = fopen(RAW_File, 'w', 'l');
fwrite(fid, ct, 'float', 0, 'l');
fclose(fid);

end
