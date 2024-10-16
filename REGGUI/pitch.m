%============================================================
% Construct the rotation 4x4 matrice from the pitch angle (around X)
%
% INPUT:
%       ang: the pitch angle (degree)
%       off: vector (mm) defining the offset of the rotation axis
% OUTPUT
%       R: the 4x4 rotation matrice
%
% Author: rla
% date: 14/5/07
% 18/7/07 Include axis offset
%============================================================

function R = pitch(ang, off)

a = pi *ang / 180;
ca = cos(a);
sa = sin(a);

R = [1  , 0     , 0         ,off(1) ;
     0  ,ca , -sa   ,off(2) ;
     0  ,sa , ca    ,off(3) ;
     0  , 0     ,    0      , 1 ];

return;