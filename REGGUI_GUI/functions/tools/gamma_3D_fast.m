function [gamma,myMask] = gamma_3D_fast(myIm0,info0,myIm1,info1,myMask,options)

% Authors : J. Hubeau

% ***************************************************
% *      INPUT:                                     *
% *      x0: axis no.1 of "good" dose               *
% *      y0: axis no.2 of "good" dose               *
% *      z0: axis no.3 of "good" dose               *
% *      myIm0: "good" dose matrix myIm0(x,y)       *
% *      x1: axis no.1 of "bad" dose                *
% *      y1: axis no.2 of "bad" dose                *
% *      z1: axis no.3 of "bad" dose                *
% *      myIm1: "bad" dose matrix                   *
% *      dd: distance tolerance in mm, typically 1  *
% *          (1st ellispoid axis)                   *
% *      DD: dose tolerance in %, typically 1       *
% *      FI: number of points for "bad" dose        *
% *          interpolation                          *
% *      OUTPUT:                                    *
% *      gamma: gamma index matrix                  *
% ***************************************************

if(isempty(myMask))
    myMask = ones(size(myIm0));
end

% Default input parameters
if(isfield(options,'dd'))
    dd = options.dd;
else
    dd = 1;
end
if(isfield(options,'DD'))
    DD = options.DD;
else
    DD = 1;
end
if(isfield(options,'FI'))
    FI = round(options.FI);
else
    FI = 5;
end
if(isfield(options,'global_ref'))
    global_ref = options.global_ref;
else
    global_ref = 1;
end
if(isfield(options,'threshold'))
    threshold = options.threshold;
else
    threshold = 0;
end
if(isfield(options,'prescription'))
    D_ref = options.prescription;
else
    D_ref = max(myIm0(myMask>=0.5));
end
if(isfield(options,'interpolator'))
    interpolator = options.interpolator;
else
    interpolator = 'linear';
end

% Display parameters
if(global_ref)
    disp(['Computing global gamma (',num2str(DD),'%/',num2str(dd),'mm) for D>',num2str(threshold/100*D_ref),'Gy'])
else
    disp(['Computing local gamma (',num2str(DD),'%/',num2str(dd),'mm) for D>',num2str(threshold/100*D_ref),'Gy'])
end

% Get image voxel grid
Nx0=size(myIm0,1); Ny0=size(myIm0,2); Nz0=size(myIm0,3);
lastpt0 = info0.ImagePositionPatient + ([Nx0;Ny0;Nz0]-1).*info0.Spacing;
x0 = linspace(info0.ImagePositionPatient(1),lastpt0(1),size(myIm0,1));
y0 = linspace(info0.ImagePositionPatient(2),lastpt0(2),size(myIm0,2));
z0 = linspace(info0.ImagePositionPatient(3),lastpt0(3),size(myIm0,3));

Nx1=size(myIm1,1); Ny1=size(myIm1,2); Nz1=size(myIm1,3);
lastpt1 = info1.ImagePositionPatient + ([Nx1;Ny1;Nz1]-1).*info1.Spacing;
x1 = linspace(info1.ImagePositionPatient(1),lastpt1(1),size(myIm1,1));
y1 = linspace(info1.ImagePositionPatient(2),lastpt1(2),size(myIm1,2));
z1 = linspace(info1.ImagePositionPatient(3),lastpt1(3),size(myIm1,3));

% Create mask for computation
[meshX0,meshY0,meshZ0] = meshgrid(y0,x0,z0);
[meshX1,meshY1,meshZ1] = meshgrid(y1,x1,z1);
myIm1_resampled = interp3(meshX1, meshY1, meshZ1, myIm1, meshX0, meshY0, meshZ0, 'nearest',0);
myMask = myMask & ((myIm0 >= threshold /100 * D_ref) | (myIm1_resampled >= threshold /100 * D_ref));

% Crop bad image from mask
myMask_resampled = interp3(meshX0, meshY0, meshZ0, myMask, meshX1, meshY1, meshZ1, 'nearest',0);
clear meshX0 meshX1 meshY0 meshY1 meshZ0 meshZ1
[i,j,~] = find(myMask_resampled);
[j,k] = ind2sub([size(myMask_resampled,2) size(myMask_resampled,3)],j);
first = [max(1,min(i)-ceil(2*dd./info1.Spacing(1))-1);max(1,min(j)-ceil(2*dd./info1.Spacing(2))-1);max(1,min(k)-ceil(2*dd./info1.Spacing(3))-1)];
last = [min(size(myMask_resampled,1),max(i)+ceil(2*dd./info1.Spacing(1))+1);min(size(myMask_resampled,2),max(j)+ceil(2*dd./info1.Spacing(2))+1);min(size(myMask_resampled,3),max(k)+ceil(2*dd./info1.Spacing(3))+1)];
myIm1 = myIm1(first(1):last(1),first(2):last(2),first(3):last(3));
info1.ImagePositionPatient = info1.ImagePositionPatient + (first-1).*info1.Spacing;
Nx1=size(myIm1,1); Ny1=size(myIm1,2); Nz1=size(myIm1,3);
lastpt1 = info1.ImagePositionPatient + ([Nx1;Ny1;Nz1]-1).*info1.Spacing;
x1 = linspace(info1.ImagePositionPatient(1),lastpt1(1),size(myIm1,1));
y1 = linspace(info1.ImagePositionPatient(2),lastpt1(2),size(myIm1,2));
z1 = linspace(info1.ImagePositionPatient(3),lastpt1(3),size(myIm1,3));

% Check Efficient gamma index calculation using fast Euclidean distance transform
% Mingli Chen et al 2009 Phys. Med. Biol. 54 2037-2047
% Implemented by J. Hubeau

if FI>0
    disp(['Number of points for "bad" dose interpolation: ',num2str(FI)])
    dx=x1(2)-x1(1);
    dy=y1(2)-y1(1);
    dz=z1(2)-z1(1);
    x1_F=x1(1):dx/FI:x1(Nx1); Nx1_F=length(x1_F);
    y1_F=y1(1):dy/FI:y1(Ny1); Ny1_F=length(y1_F);
    z1_F=z1(1):dz/FI:z1(Nz1); Nz1_F=length(z1_F);
    InterpObject = griddedInterpolant({x1, y1, z1},myIm1,interpolator);
    myIm1_F = InterpObject({x1_F, y1_F, z1_F});
else
    x1_F=x1; Nx1_F=Nx1;
    y1_F=y1; Ny1_F=Ny1;
    z1_F=z1; Nz1_F=Nz1;
    myIm1_F=myIm1;
end
dx=round(dd/(x1_F(2)-x1_F(1)));
dy=round(dd/(y1_F(2)-y1_F(1)));
dz=round(dd/(z1_F(2)-z1_F(1)));

gamma=zeros(Nx0,Ny0,Nz0)-1;
myMask_vec = squeeze(reshape(myMask,[size(myMask,1) size(myMask,2)*size(myMask,3) 1]));
pts_mask = find(myMask_vec);
[Ix0,Iy0,Iz0] = ind2sub(size(myMask),pts_mask);

condition_border = 0;
if(min(Ix0)<dx+1||max(Ix0)>size(myMask,1)-dx)
    condition_border = 1;
end
if(min(Iy0)<dy+1||max(Iy0)>size(myMask,2)-dy)
    condition_border = 1;
end
if(min(Iz0)<dz+1||max(Iz0)>size(myMask,3)-dz)
    condition_border = 1;
end

IX1_0 = zeros(Nx0,1);
for ix0=1:Nx0
    [~,ix1_0]=min(abs(x1_F-x0(ix0)));
    IX1_0(ix0) = ix1_0;
end

IY1_0 = zeros(Ny0,1);
for iy0=1:Ny0
    [~,iy1_0]=min(abs(y1_F-y0(iy0)));
    IY1_0(iy0) = iy1_0;
end

IZ1_0 = zeros(Nz0,1);
for iz0=1:Nz0
    [~,iz1_0]=min(abs(z1_F-z0(iz0)));
    IZ1_0(iz0) = iz1_0;
end

[Y1_global,X1_global,Z1_global] = meshgrid([-dy:dy]*(y1_F(2)-y1_F(1)),[-dx:dx]*(x1_F(2)-x1_F(1)),[-dz:dz]*(z1_F(2)-z1_F(1)));

for current = 1:length(pts_mask)
    
    if(condition_border)
        
        if (IX1_0(Ix0(current)) - dx) < 1
            ixt_begin = 2+dx-IX1_0(Ix0(current));
        else
            ixt_begin=1;
        end
        if (IX1_0(Ix0(current)) + dx) > Nx1_F
            ixt_end = 2*dx+1+Nx1_F-(IX1_0(Ix0(current))+dx);
        else
            ixt_end = 2*dx+1;
        end
        
        if (IY1_0(Iy0(current)) - dy) < 1
            iyt_begin = 2+dy-IY1_0(Iy0(current));
        else
            iyt_begin=1;
        end
        if (IY1_0(Iy0(current)) + dy) > Ny1_F
            iyt_end = 2*dy+1+Ny1_F-(IY1_0(Iy0(current))+dy);
        else
            iyt_end = 2*dy+1;
        end
        
        if (IZ1_0(Iz0(current)) - dz) < 1
            izt_begin = 2+dz-IZ1_0(Iz0(current));
        else
            izt_begin=1;
        end
        if (IZ1_0(Iz0(current)) + dz) > Nz1_F
            izt_end = 2*dz+1+Nz1_F-(IZ1_0(Iz0(current))+dz);
        else
            izt_end = 2*dz+1;
        end
        X1 = X1_global(ixt_begin:ixt_end,iyt_begin:iyt_end,izt_begin:izt_end);
        Y1 = Y1_global(ixt_begin:ixt_end,iyt_begin:iyt_end,izt_begin:izt_end);
        Z1 = Z1_global(ixt_begin:ixt_end,iyt_begin:iyt_end,izt_begin:izt_end);
    else
        X1 = X1_global;
        Y1 = Y1_global;
        Z1 = Z1_global;
    end
    
    r = sqrt((X1-x0(Ix0(current))+x1_F(IX1_0(Ix0(current)))).^2+(Y1-y0(Iy0(current))+y1_F(IY1_0(Iy0(current)))).^2+(Z1-z0(Iz0(current))+z1_F(IZ1_0(Iz0(current)))).^2);
    if(global_ref)
        d = (myIm1_F(max(1,IX1_0(Ix0(current))-dx):min(IX1_0(Ix0(current))+dx,Nx1_F) , max(1,IY1_0(Iy0(current))-dy):min(IY1_0(Iy0(current))+dy,Ny1_F) , max(1,IZ1_0(Iz0(current))-dz):min(IZ1_0(Iz0(current))+dz,Nz1_F)) - myIm0(Ix0(current),Iy0(current),Iz0(current)))/D_ref;
    else
        d = (myIm1_F(max(1,IX1_0(Ix0(current))-dx):min(IX1_0(Ix0(current))+dx,Nx1_F) , max(1,IY1_0(Iy0(current))-dy):min(IY1_0(Iy0(current))+dy,Ny1_F) , max(1,IZ1_0(Iz0(current))-dz):min(IZ1_0(Iz0(current))+dz,Nz1_F)) - myIm0(Ix0(current),Iy0(current),Iz0(current)))/abs(myIm0(Ix0(current),Iy0(current),Iz0(current)));
    end
    if(isinf(min(abs(d(:)))))
        G = NaN;
    else
        if(abs(dd)>0 && abs(DD)>0)
            if(isequal(size(r),size(d)))
                G = sqrt(r.^2/dd^2+d.^2/(DD/100).^2);
            else
                G = NaN;
            end
        elseif(abs(DD)>0)
            G = sqrt(d.^2/(DD/100).^2);
        else
            G = NaN;
        end
    end    
    gamma(Ix0(current),Iy0(current),Iz0(current)) = min(G(:));
    
end
