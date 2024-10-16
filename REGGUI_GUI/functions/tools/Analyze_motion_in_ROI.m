function motion = Analyze_motion_in_ROI(field_names,ROI_name,handles)

for i=1:length(field_names)
    temp = Get_reggui_data(handles,field_names{i},'field');
	dfx = squeeze(temp(1,:,:,:)).*handles.spacing(1);
    dfy = squeeze(temp(2,:,:,:)).*handles.spacing(2);
    dfz = squeeze(temp(3,:,:,:)).*handles.spacing(3);
    temp = Get_reggui_data(handles,ROI_name,'image');
    df(:,1,i) = dfx(temp>=0.5);
    df(:,2,i) = dfy(temp>=0.5);
    df(:,3,i) = dfz(temp>=0.5);
end

motion = zeros(size(df,1),1);

for j=1:size(df,1)
    pts = squeeze(df(j,:,:));
    distances = zeros(size(pts,2),size(pts,2));
    for k=1:size(pts,2)
        distances(k,:) = sqrt( (pts(1,:)-pts(1,k)).^2+ (pts(2,:)-pts(2,k)).^2+ (pts(3,:)-pts(3,k)).^2);
    end
    motion(j) = max(distances(:));
end
