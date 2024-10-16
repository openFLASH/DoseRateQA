function [gamma,myMask,myIm1_resampled] = gamma_2D(myIm0,info0,myIm1,info1,myMask,options)

if(isempty(myMask))
    myMask = ones(size(myIm0));
end

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
    FI = 10;
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
if(isfield(options,'search_distance'))
    sd = options.search_distance;
else
    sd = 0;
end
if(sd==0) % default search distance
    sd = 1.5*dd;
end

myIm0=double(myIm0);
myIm1=double(myIm1);

Nx0=size(myIm0,1);
Ny0=size(myIm0,2) ;

lastpt0 = info0.ImagePositionPatient + ([Nx0;Ny0;0]-1).*info0.Spacing;
x0 = linspace(info0.ImagePositionPatient(1),lastpt0(1),size(myIm0,1));
y0 = linspace(info0.ImagePositionPatient(2),lastpt0(2),size(myIm0,2));

Nx1=size(myIm1,1); Ny1=size(myIm1,2);

lastpt1 = info1.ImagePositionPatient + ([Nx1;Ny1;0]-1).*info1.Spacing;
x1 = linspace(info1.ImagePositionPatient(1),lastpt1(1),size(myIm1,1));
y1 = linspace(info1.ImagePositionPatient(2),lastpt1(2),size(myIm1,2));

[meshX0,meshY0] = meshgrid(y0,x0);
[meshX1,meshY1] = meshgrid(y1,x1);

% create mask for computation
myIm1_resampled = interp2(meshX1, meshY1, myIm1, meshX0, meshY0, 'nearest',-Inf);
myMask = myMask & ((myIm0 >= threshold /100 * D_ref) | (myIm1_resampled >= threshold /100 * D_ref));

% create local over-sampling vectors
s1 = info0.Spacing(1)/FI;
half_v1 = 0:s1:sd+s1;
v1 = [-half_v1(end:-1:2),half_v1];
s2 = info0.Spacing(2)/FI;
half_v2 = 0:s2:sd+s2;
v2 = [-half_v2(end:-1:2),half_v2];

% compute gamma
gamma = -ones(Nx0, Ny0);
for i = 1:Nx0
    for j = 1:Ny0
        if myMask(i,j)
            [meshA, meshB] = meshgrid(meshX0(i,j)+v1, meshY0(i,j)+v2);
            distances = (meshA-meshX0(i,j)).^2 + (meshB-meshY0(i,j)).^2;   
            G = interp2(meshX1, meshY1, myIm1, meshA, meshB, 'linear',Inf);
            if(not(global_ref))
                D_ref = myIm0(i,j);
            end
            if(abs(dd)>0 && abs(DD)>0)
                G = sqrt(((G(distances<=sd^2)-myIm0(i,j))/(D_ref*DD/100)).^2 + distances(distances<=sd^2)/dd.^2);
            elseif(abs(DD)>0)
                G = sqrt(((G(distances<=sd^2)-myIm0(i,j))/(D_ref*DD/100)).^2);
            else
                G = NaN;
            end            
            gamma(i,j) = min(G(:));
            if(isinf(gamma(i,j)))
                gamma(i,j) = -1;
            end
        end
    end
end
gamma = single(gamma);

% figure
% subplot(1,3,1)
% imshow(myIm0,[min(myIm0(:)) max(myIm0(:))])
% subplot(1,3,2)
% imshow(myIm1_resampled,[min(myIm0(:)) max(myIm0(:))])
% subplot(1,3,3)
% imshow(gamma,[min(gamma(:)) max(gamma(:))])
