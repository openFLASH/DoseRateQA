function [ ct, info ] = Prepare_CT_for_MC2( handles, SimuParam, CT_name )

if(nargin < 3)
    CT_name = SimuParam.CT;
end

% find ct image in the lists
ct = [];
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},CT_name))
        ct = handles.mydata.data{i};
        info = handles.mydata.info{i};
    end
end
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},CT_name))
        ct = handles.images.data{i};
        info = handles.images.info{i};
    end
end
if(isempty(ct))
    disp('Image not found. Abort.')
    return
end

if(SimuParam.CropBody == 1)
    Body_contour = [];
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},SimuParam.BodyContour))
            Body_contour = handles.images.data{i};
        end
    end
    if(isempty(Body_contour))
        disp([SimuParam.BodyContour ' contour not found. Abort.'])
        return
    end
    ct(Body_contour < 0.5) = -1000;
end

if(~isempty(SimuParam.OverwriteHU))
    contour = [];
    NumContours = size(SimuParam.OverwriteHU,1);
    for j=1:NumContours
        for i=1:length(handles.images.name)
            if(strcmp(handles.images.name{i},SimuParam.OverwriteHU{j,1}))
                contour = handles.images.data{i};
            end
        end
        if(isempty(contour))
            disp([SimuParam.OverwriteHU{j,1} ' contour not found. Abort.'])
            return
        end
        ct(contour > 0.5) = SimuParam.OverwriteHU{j,2};
    end
end

info.size = size(ct);

end

