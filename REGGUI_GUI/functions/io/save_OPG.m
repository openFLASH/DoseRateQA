function save_OPG(outdata,info,outname,additional_tags)

if(nargin<4)
   additional_tags = struct; 
end

y = (0:size(outdata,1)-1)*info.Spacing(1) + info.ImagePositionPatient(1);
x = (0:size(outdata,2)-1)*info.Spacing(2) + info.ImagePositionPatient(2);
y = -y(end:-1:1);

[dirname,filename,~] = fileparts(outname);
outname = fullfile(dirname,[filename,'.opg']);

fid = fopen(outname,'w');
fprintf(fid,'<opimrtascii>');fprintf(fid,'\n\n');
fprintf(fid,'<asciiheader>');fprintf(fid,'\n');
%fprintf(fid,'File Version: 3');fprintf(fid,'\n');
fprintf(fid,'Separator: ","');fprintf(fid,'\n');
%fprintf(fid,'Workspace Name: ');fprintf(fid,'\n');
%fprintf(fid,['File Name: ',strrep(outname,'\','\\')]);fprintf(fid,'\n');
%fprintf(fid,['Image Name: ',strrep(filename,'\','\\')]);fprintf(fid,'\n');
%fprintf(fid,'Radiation Type: ');fprintf(fid,'\n');
%fprintf(fid,'Energy: ');fprintf(fid,'\n');
%fprintf(fid,'SSD:');fprintf(fid,'\n');
%fprintf(fid,'SID: ');fprintf(fid,'\n');
%fprintf(fid,'Field Size Cr:');fprintf(fid,'\n');
%fprintf(fid,'Field Size In: ');fprintf(fid,'\n');
%fprintf(fid,'Data Type: Absolute');fprintf(fid,'\n');
%fprintf(fid,'Data Factor: 1.000');fprintf(fid,'\n');
%fprintf(fid,'Data Unit: ');fprintf(fid,'\n');
fprintf(fid,'Length Unit: mm');fprintf(fid,'\n');
fprintf(fid,['Plane: ',info.ImageOrientation]);fprintf(fid,'\n');
fprintf(fid,['No. of Columns: ',num2str(length(x))]);fprintf(fid,'\n');
fprintf(fid,['No. of Rows: ',num2str(length(y))]);fprintf(fid,'\n');
%fprintf(fid,'Number of Bodies: 1');fprintf(fid,'\n');
tags = fieldnames(additional_tags);
for i=1:length(tags)
    val = additional_tags.(tags{i});
    if(isnumeric(val))
        val = num2str(val);
    end
    eval(['fprintf(fid,''',strrep(tags{i},'_',' '),': ',val,''');fprintf(fid,''\n'');']);
end
fprintf(fid,'</asciiheader>');fprintf(fid,'\n\n');
fprintf(fid,'<asciibody>');fprintf(fid,'\n');
%fprintf(fid,'Plane Position: 0.0 mm');fprintf(fid,'\n');
fprintf(fid,'\n');
fprintf(fid,'X[mm]    ,');
for i=1:length(x)
    fprintf(fid,[num2str(x(i)),' ,']);
end
fprintf(fid,'\n');
fprintf(fid,'Y[mm]');fprintf(fid,'\n');
fclose(fid);
outdata = [y',outdata(end:-1:1,:)];
dlmwrite(outname,outdata,'precision','%.4f','-append');
fid = fopen(outname,'a');
fprintf(fid,'</asciibody>');fprintf(fid,'\n\n\n\n');
fprintf(fid,'</opimrtascii>');fprintf(fid,'\n');
fclose(fid);
