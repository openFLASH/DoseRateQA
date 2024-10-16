function [ handles ] = Crop_body_contour( handles, DoseName, BodyName , dose_type)

[dose,dose_info] = Get_reggui_data(handles,DoseName,dose_type);

if(not(strcmp(dose_type,'images')))
    [handles,BodyName] = Resample_image(BodyName,DoseName,[BodyName,'_resampled'],handles);    
    body = Get_reggui_data(handles,BodyName,'mydata');
    handles = Remove_data(BodyName, handles);
else
    body = Get_reggui_data(handles,BodyName,'images');
end

if(sum(size(body)~=size(dose))==0)
    handles = Set_reggui_data(handles,DoseName,dose.*(body>=0.5),dose_info,dose_type,1);
else
   disp('Could not crop to body. Sizes do not match.') 
end
