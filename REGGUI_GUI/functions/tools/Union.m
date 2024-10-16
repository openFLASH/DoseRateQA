%% Union
% Compute the union of masks
%
%% Syntax
% |handles = Union(images,im_dest,handles)|
%
%
%% Description
% |handles = Union(images,im_dest,handles)| Compute the union of binary masks
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Union(masks,im_dest,handles)

[roi_union,info,type] = Get_reggui_data(handles,masks{1},'images');
for i = 2:length(masks)
    roi = Get_reggui_data(handles,masks{i},type);
    roi_union = roi_union | roi>=0.5;
end
handles = Set_reggui_data(handles,im_dest,single(roi_union),info,type);
