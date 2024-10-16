function SP = MC2_import_SP_data(FileName)

% Authors : K. Souris

fid=fopen(FileName,'r');
if(fid < 0)
    error(['Unable to open file ' FileName])
end

data = fscanf(fid, '%f %f', [2 inf]);

fclose(fid);

SP = interp1(data(1,:), data(2,:), 100.0, 'spline', 'extrap');

end