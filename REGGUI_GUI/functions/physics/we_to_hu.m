function HU = we_to_hu(SPR,Density_file,Material_file)

HU = nan(size(SPR));

if(nargin<3)
    Material_file = strrep(Density_file,'HU_Density_Conversion.txt','HU_Material_Conversion.txt');
end

[HU_Material,Material_Data] = MC2_import_scanner_file(Material_file);
[HU_Density,Density_Data] = MC2_import_scanner_file(Density_file);

HU_all = sort(unique([HU_Material(:);HU_Density(:)]));

[~,SPR_all] = HU_convert(HU_all,HU_Density,Density_Data,HU_Material,Material_Data);

for n=1:length(SPR)
    
    % Find interval in the piece-wise curve
    idx = 0;
    if SPR(n)<=SPR_all(1)
        HU(n)=HU_all(1);
    elseif SPR(n)>=SPR_all(end)
        HU(n)=HU_all(end);
    else
        for i=1:length(HU_all)-1
            if SPR(n)>= SPR_all(i) && SPR(n) <SPR_all(i+1)
                idx=i;
            end
        end
    end
    
    % Find intersection within the interval
    if(idx>0)
        if SPR_all(idx+1)-SPR_all(idx)==0
            HU(n)=HU_all(idx);
        else
            slope =(HU_all(idx+1)-HU_all(idx))/(SPR_all(idx+1)-SPR_all(idx));
            intercept=HU_all(idx);
            HU(n)=slope*(SPR(n)-SPR_all(idx))+intercept;
        end
    end
    
end
