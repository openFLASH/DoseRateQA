function col = find_csv_column(tline,str)

i = strfind(tline,str);

if(isempty(i))
   col = [];
   return
end

c = strfind(tline,',');
[~,col] = find((c-i(1))>0,1,'first');

if(isempty(col))
    col = length(c)+1;
end