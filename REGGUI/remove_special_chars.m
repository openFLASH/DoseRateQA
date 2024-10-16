function name = remove_special_chars(name,exceptions)

indices = isstrprop(name,'digit')|isstrprop(name,'lower')|isstrprop(name,'upper')|name=='_';

if(nargin>1)
    for i=1:length(exceptions)
        try
            indices = indices | name==exceptions{i};
        catch
        end
    end
end

name = name(indices);