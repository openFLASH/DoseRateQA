function [gamma,myMask] = gamma_3D_slow(myIm0,info0,myIm1,info1,myMask,options)

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
    sd = 2*dd;
end

% Get image voxel grid
Nx0=size(myIm0,1); Ny0=size(myIm0,2); Nz0=size(myIm0,3);
Nx1=size(myIm1,1); Ny1=size(myIm1,2); Nz1=size(myIm1,3);

lastpt0 = info0.ImagePositionPatient + ([Nx0;Ny0;Nz0]-1).*info0.Spacing;
x0 = linspace(info0.ImagePositionPatient(1),lastpt0(1),size(myIm0,1));
y0 = linspace(info0.ImagePositionPatient(2),lastpt0(2),size(myIm0,2));
z0 = linspace(info0.ImagePositionPatient(3),lastpt0(3),size(myIm0,3));

[meshX0,meshY0,meshZ0] = meshgrid(y0,x0,z0);

lastpt1 = info1.ImagePositionPatient + ([Nx1;Ny1;Nz1]-1).*info1.Spacing;
x1 = linspace(info1.ImagePositionPatient(1),lastpt1(1),size(myIm1,1));
y1 = linspace(info1.ImagePositionPatient(2),lastpt1(2),size(myIm1,2));
z1 = linspace(info1.ImagePositionPatient(3),lastpt1(3),size(myIm1,3));

[meshX1,meshY1,meshZ1] = meshgrid(y1,x1,z1);

% Create mask for computation
myIm1_resampled = interp3(meshX1, meshY1, meshZ1, myIm1, meshX0, meshY0, meshZ0, 'nearest',0);
myMask = myMask & ((myIm0 >= threshold /100 * D_ref) | (myIm1_resampled >= threshold /100 * D_ref));

% Create local over-sampling vectors
over_sampling = 10;
s1 = info0.Spacing(1)/over_sampling;
half_v1 = 0:s1:sd+s1;
v1 = [-half_v1(end:-1:2),half_v1];
s2 = info0.Spacing(2)/over_sampling;
half_v2 = 0:s2:sd+s2;
v2 = [-half_v2(end:-1:2),half_v2];
s3 = info0.Spacing(3)/over_sampling;
half_v3 = 0:s3:sd+s3;
v3 = [-half_v3(end:-1:2),half_v3];

% Loop over region of interest
[i,j,~] = find(myMask);
[j,k] = ind2sub([size(myMask,2) size(myMask,3)],j);
minimum = [max(1,min(i)-dd*2);max(1,min(j)-dd*2);max(1,min(k)-dd*2)];
maximum = [min(size(myMask,1),max(i)+dd*2);min(size(myMask,2),max(j)+dd*2);min(size(myMask,3),max(k)+dd*2)];

gamma = -ones(size(myMask));
for i = minimum(1):maximum(1)
    for j = minimum(2):maximum(2)
        for k = minimum(3):maximum(3)
            if myMask(i,j,k)
                [meshA, meshB, meshC] = meshgrid(meshX0(i,j,k)+v1, meshY0(i,j,k)+v2, meshZ0(i,j,k)+v3);
                distances = (meshA-meshX0(i,j,k)).^2 + (meshB-meshY0(i,j,k)).^2 + (meshC-meshZ0(i,j,k)).^2;
                G = interp3(meshX1, meshY1, meshZ1, myIm1, meshA, meshB, meshC, 'linear',Inf);
                if(not(global_ref))
                    D_ref = myIm0(i,j,k);
                end                
                if(abs(dd)>0 && abs(DD)>0)
                    G = sqrt(((G(distances<=sd^2)-myIm0(i,j,k))/(D_ref*DD/100)).^2 + distances(distances<=sd^2)/dd.^2);
                elseif(abs(DD)>0)
                    G = sqrt(((G(distances<=sd^2)-myIm0(i,j,k))/(D_ref*DD/100)).^2);
                else
                    G = NaN;
                end                   
                gamma(i,j,k) = min(G(:));
            end
        end
    end
    disp([num2str(round((i-minimum(1))/(maximum(1)-minimum(1))*100)),'%...'])
end
gamma = single(gamma);
