function res = get_csv_data(tline,col)

params = strsplit(tline,',');

res = params{col};

temp = str2double(res);
if(not(isnan(temp)))
   res = temp; 
end