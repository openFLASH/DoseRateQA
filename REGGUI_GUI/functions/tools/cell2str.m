function s = cell2str(c)

if(isempty(c))
    s = '{}';
else    
    s = '{';    
    for i=1:length(c)
        s = [s,'''',c{i},''';'];
    end    
    s = [s(1:end-1),'}'];
end
