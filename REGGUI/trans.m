%============================================================
% Construct the translation 4x4 matrice 
%
% INPUT:
%       X: translation along the X axis (mm)
%       Y: translation along the Y axis (mm)
%       Z: translation along the Z axis (mm)
% OUTPUT
%       T: the 4x4 translation matrice
%
% Author: rla
% date: 14/5/07
%============================================================

function T = trans(X , Y , Z)

T = [1  ,   0   ,   0   ,   X;
     0  ,   1   ,   0   ,   Y;
     0  ,   0   ,   1   ,   Z;
     0  ,   0   ,   0   ,   1 ];

return;