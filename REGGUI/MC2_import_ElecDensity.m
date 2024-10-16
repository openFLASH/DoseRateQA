function ElecDensity = MC2_import_ElecDensity(FileName)

% Authors : K. Souris

fid=fopen(FileName,'r');
if(fid < 0)
    error(['Unable to open file ' FileName])
end

while ~feof(fid)
    tmp = fgetl(fid);
    key = strsplit(tmp, {' ', '\t'});
    id = find(strcmp(key, 'Electron_Density'));
    if(not(isempty(id)))
        ElecDensity = key{id+1};
        ElecDensity = str2num(ElecDensity);
    end
end

fclose(fid);
end