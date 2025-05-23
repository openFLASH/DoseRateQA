
%READ_RS_PARAM reads a Raystation conversion table from densities to materials
%
% res = read_RS_param(filename) returns a data structure containing the
% information stored in a Raystation conversion table (RayStation version
% 4.7).
%
% See also density2spr_RS
%
% Authors : S. Deffet
%

function res = read_RS_param(filename)
    fid = fopen(filename) ;
    
    max_iter = 200 ;
    i = 1 ;
    while 1      
        d = fgetl(fid) ;
        
        if i==1 && isempty(d)
            continue
        end
        
        d = strsplit(d);
        
        if(length(d) < 12)
            break
        end
        
        if ~isnan(str2double(d(1)))
            shifInd = -1;
        else
            shifInd = 0; % Line starts with whitespaces
        end
        
        material_nb(i) = str2double(d(2+shifInd)) ;
        Density(i) = str2double(d(5+shifInd)) ;
        nElements(i) = str2double(d(9+shifInd)) ;
        I(i) = str2double(d(12+shifInd)) ;
        
        for j=1 : nElements(i)
            line = str2num(fgetl(fid));
            Z(i, j) = line(2) ;
            A(i, j) = line(3) ;
            w(i, j) = line(4) ;
        end
        
        fgetl(fid) ;
        i = i+1 ;
        
        if i>max_iter
            break
        end
    end
    
    fclose(fid) ;
    
    res.material_nb = material_nb ;
    res.Density = Density ;
    res.nElements = nElements ;
    res.I = I ;
    res.Z = Z ;
    res.A = A ;
    res.w = w ;
end

