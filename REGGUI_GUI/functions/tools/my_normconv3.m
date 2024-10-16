%% my_normconv3
% Perform normalised convolution of in_data using cert and quad_filter.
% The function works in 3 dimensional space.
% For details see chapter 5 of reference [2].
%
%% Syntax
% |[outdata, outcert] = my_normconv3(indata, cert, quad_filter)|
%
%
%% Description
% |[outdata, outcert] = my_normconv3(indata, cert, quad_filter)| describes the function
%
%
%% Input arguments
% |indata| - _SCALAR MATRIX_ - |indata(x,y,z)| Intensity at voxel (x,y,z) of the image
%
% |cert| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the |indata| image.
%
% |quad_filter| - _SCALAR MATRIX_ |quad_filter(x,y,z)| Intensity of the voxel (x,y,z) of the quadrature filter kernel. See section "3.1.2 Morphon" of reference [1] for more details.
%
%
%% Output arguments
%
% |outdata| - _SCALAR MATRIX_ - |outdata(x,y,z)| Intensity at voxel (x,y,z) of the convolved image
%
% |outcert| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the field |out_field|.
%
%% References
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
% [2] CJ Westelius Focus of Attention and Gaze Control for Robot Vision Carl-Johan Westelius. PhD thesis Linkoping (1995) [http://liu.diva-portal.org/smash/get/diva2:302463/FULLTEXT01.pdf]
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [outdata, outcert] = my_normconv3(indata, cert, quad_filter)

% applicability
quad_filter = flipdim(flipdim(flipdim(quad_filter)));
a = single(abs(quad_filter));

G11 = fftconvn(cert, a);
G21 = fftconvn(cert, single(real(quad_filter))) + 1i*fftconvn(cert, single(imag(quad_filter)));
G12 = conj(G21);

Gdet = G11.*G11 - G12.*G21;
Gnorm = 1./(Gdet+eps);
Gi11 = Gnorm.*G11; 
Gi21 = -Gnorm.*G21;

% First basis function
indata_b1 = fftconvn(indata.*cert, a);

% Second basis function
indata_b2 = fftconvn(indata.*cert, single(real(quad_filter))) + 1i*fftconvn(indata.*cert, single(imag(quad_filter)));

% Compute result
outdata = Gi21.*indata_b1 + Gi11.*indata_b2;

% Set output certainty equal to Gdet
outcert = Gdet;

% Remove possible NaN values
outcert(isnan(outdata))=0;
outdata(isnan(outdata))=0;
outcert(isnan(outcert))=0;
