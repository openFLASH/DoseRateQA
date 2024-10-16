function Export_MC2_Field(myInfo, myField, DestinationFile)


disp(' ')

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

disp(['Export MHD Field: ' MHD_File]);

% convert pixel to distance
for n=1:size(myField,1)
    myField(n,:,:,:) = myField(n,:,:,:)*myInfo.Spacing(n);
end

myField = single(myField);
%myField = permute(myField, [1 3 2 4]);
myField = flipdim(myField, 2);
myField = flipdim(myField, 3);

dims = size(myField);
MC2_origin = Dicom_to_MC2_coordinates(myInfo.ImagePositionPatient, myInfo.Spacing, myInfo.Spacing.*dims(2:4));

fid = fopen(MHD_File,'wt');
fprintf(fid, 'ObjectType = Image \n');
fprintf(fid, 'NDims = 3\n');
fprintf(fid, 'BinaryData = True\n');
fprintf(fid, 'DimSize = %d %d %d\n', dims(2:4));
fprintf(fid, 'ElementNumberOfChannels = 3\n');
fprintf(fid, 'ElementSpacing = %f %f %f\n', myInfo.Spacing);
%fprintf(fid,'Offset = %f %f %f\n', MC2_origin);
fprintf(fid, 'ElementType = MET_FLOAT\n');
fprintf(fid, 'ElementByteOrderMSB = False\n');
fprintf(fid, 'ElementDataFile = %s \n', RAW_File_name);
fclose(fid);
  
% write data file
fid = fopen(RAW_File,'wb');
fwrite(fid, myField,'float');
fclose(fid);

end
