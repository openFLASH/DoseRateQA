function HU = density_to_hu(density,calib_filename)

HU=NaN;

fid = fopen(calib_filename,'r');
idx=0;
while ~feof(fid)
    tline = fgetl(fid);
    if(not(isempty(tline)))
        if ~strcmp(tline(1),'#')
            idx=idx+1;
            C =strsplit(tline);
            CTcalib(idx,1)=str2double(C{1});
            CTcalib(idx,2)=str2double(C{2});
        end
    end
end

if density<= CTcalib(1,2)
    HU=CTcalib(1,1);
elseif density>=CTcalib(end,2)
    HU=CTcalib(end,1);
else    
    for i=1:size(CTcalib,1)-1
        if density>= CTcalib(i,2) && density <CTcalib(i+1,2)
            idx=i;
        end
    end
end

if(idx>=size(CTcalib,1))
    idx = size(CTcalib,1)-1;
end

if idx~=-1
    if CTcalib(idx+1,2)-CTcalib(idx,2)==0
        HU=CTcalib(idx,1);
    else
        slope =(CTcalib(idx+1,1)-CTcalib(idx,1))/(CTcalib(idx+1,2)-CTcalib(idx,2));
        intercept=CTcalib(idx,1);
        HU=slope*(density-CTcalib(idx,2) )+intercept;
    end
end

