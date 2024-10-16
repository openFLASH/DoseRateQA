%============================================================
% Construct the rotation 4x4 matrice from the rotation angle (around Z)
%
% INPUT:
%       ang: the rotation angle (degree)
%       off: vector (mm) defining the offset of the rotation axis
% OUTPUT
%       R: the 4x4 rotation matrice
%
% Author: rla
% date: 14/5/07
% 18/7/07 Include axis offset
%============================================================

function R = rot(ang , off)

a = pi *ang / 180;
ca = cos(a);
sa = sin(a);

R = [ca , -sa , 0 , off(1) ;
     sa , ca  , 0 , off(2) ;
     0      , 0       , 1 , off(3) ; 
     0      , 0       , 0 , 1 ];

return;