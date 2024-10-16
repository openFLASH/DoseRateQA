%% dose_to_volume
% Compute the minimum dose |Dv| given to the fraction of the volume |volume_ratio| of an organ.
%
%% Syntax
% |Dv = dose_to_volume(dose,volume_ratio)|
%
%
%% Description
% |Dv = dose_to_volume(dose,volume_ratio)| describes the function
%
%
%% Input arguments
% |dose|- _SCALAR MATRIX_ - |dose(x,y,z)| is the dose (in Gy) given to the voxel (x,y,z) belonging to some structure. |dose(x,y,z)=0| in the voxels not belonging to the strucutre
%
% |volume_ratio| - _SCALAR_ -  Fraction (|0 <= volume_ratio <=1|) of the volume
%
%
%% Output arguments
%
% |Dv| - _TYPE_ - Minimum dose (in Gy) given to the fraction |volume_ratio|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function Dv = dose_to_volume(dose,volume_ratio)

if(isempty(dose))
    Dv = NaN;
    return
end

if(volume_ratio>1) % if volume_ratio is in percent
    volume_ratio = volume_ratio/100;
end

dose = dose(:);

v_tot = length(dose);

% first 'rough' estimation
n = 1e3;
v = zeros(n,1);
d = linspace(0,max(dose),n);
for i=1:length(d)
    v(i) = sum(dose>=d(i))/v_tot;
end
Dv = (find(v<volume_ratio,1,'first')-1)/n*max(dose);

if(isempty(Dv))
    Dv = max(dose);
end

% finer estimation
n = 1e3;
v = zeros(n,1);
d = linspace(Dv-1,Dv+1,n);
for i=1:length(d)
    v(i) = sum(dose>=d(i))/v_tot;
end
Dv = Dv-1+((find(v<volume_ratio,1,'first')-1)/n*2); % volume ratio between 0 and 1

if(isempty(Dv))
    Dv = max(dose);
end