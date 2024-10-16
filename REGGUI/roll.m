%============================================================
% Construct the rotation 4x4 matrice from the roll angle (around Y)
%
% INPUT:
%       ang: the roll angle (degree)
%       off: vector (mm) defining the offset of the rotation axis
% OUTPUT
%       R: the 4x4 rotation matrice
%
% Author: rla
% date: 14/5/07
% 18/7/07 Include axis offset
%============================================================

function R = roll(ang, off)

a = pi *ang / 180;
ca = cos(a);
sa = sin(a);

R = [ca , 0 , sa , off(1) ;
     0      , 1 , 0      , off(2) ; 
     -sa, 0 , ca , off(3) ;
     0      , 0 , 0      , 1 ];

return;