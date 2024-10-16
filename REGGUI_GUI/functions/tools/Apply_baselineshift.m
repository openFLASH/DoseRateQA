function handles = Apply_baselineshift(handles,ct_name,mask_name,im_dest,shift,sigma,def_field)

if(nargin<6)
    sigma = 2;
end
if(nargin<7)
    def_field = [];
end

shift_vx(1) = shift(1) ./ handles.spacing(1);
shift_vx(2) = shift(2) ./ handles.spacing(2);
shift_vx(3) = shift(3) ./ handles.spacing(3);

[myIm,info,type] = Get_reggui_data(handles,ct_name);
mask = Get_reggui_data(handles,mask_name);

k_size = 2*sigma+1;
center = ([k_size k_size k_size]+1)/2;
[Y,X,Z] = meshgrid(1:k_size,1:k_size,1:k_size);
myStrel = sqrt((X-center(1)).^2+(Y-center(2)).^2+(Z-center(3)).^2)<=sigma;
mask = imdilate(mask,myStrel);

d(1,:,:,:) = -ones(size(myIm))*shift_vx(1);
d(2,:,:,:) = -ones(size(myIm))*shift_vx(2);
d(3,:,:,:) = -ones(size(myIm))*shift_vx(3);
d = single(d);
mask = single(mask>=0.5 | linear_deformation(mask,'',d)>=0.5);

cert = mask/1.1 + 0.1;
cert(myIm>200) = 100;

vf = d*0;
for n=1:3
    vf = forceShiftInMask(vf,mask,shift_vx);
    for i=1:3
        vf(i,:,:,:) = normgauss_smoothing(squeeze(vf(i,:,:,:)), cert, sigma);
    end
end

df = field_exponentiation(vf);
myIm = linear_deformation(myIm,'',df);

handles = Set_reggui_data(handles,im_dest,myIm,info,type,0);

if(not(isempty(def_field)))
    handles = Set_reggui_data(handles,def_field,df,Create_default_info('deformation_field',handles),'fields',0);
end

end

function d = forceShiftInMask(d,mask,shift)
for i=1:3
    temp = squeeze(d(i,:,:,:));
    temp(mask>=0.5) = -shift(i);
    d(i,:,:,:) = temp;
end
end
