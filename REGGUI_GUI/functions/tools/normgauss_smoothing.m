%% gauss_smoothing
% Performs normalized gaussian smoothing (in pixel space !) by convolving a gaussian kernel with the image
%
%% Syntax
% |outdata = gauss_smoothing(indata, cert, sigma)|
%
% |outdata = gauss_smoothing(indata, cert, sigma, sigmaY, sigmaZ)|
%
%
%% Description
% |outdata = gauss_smoothing(indata, sigma)| perform uniform gaussian smoothing
%
% |outdata = gauss_smoothing(indata, sigma, sigmaY, sigmaZ)| perform non uniform gaussian smoothing
%
%
%% Input arguments
% |indata| - _MATRIX_ - |indata(x,y,z)| is the intensity of the image at voxel (x,y,z)
%
% |cert| - _MATRICE_ - The certainty about the value of the intensity at voxel (x,y,z) of the accumulated field |acc_field|. In some applications, the accuracy of intensity values may be reduced for some voxels due to acquisition noise or image processing singularities. In some cases, the pixel values are even a biased representation of some hidden truth. When the certainty relative of each pixel value is known, this information can be taken into account by a filtering process using normalized convolution. See reference [1], section 2.1.3 Image Filtering (b) Normalized convolution.
%
% |sigma| - _SCALAR_ -  Standard deviation (in pixel) of the gaussian filter along the X dimension. If |sigmaY| and |sigmaZ| are omitted, defines the standard deviation along the 3 dimensions.
%
% |sigmaY| - _SCALAR_ -  Standard deviation (in pixel) of the gaussian filter along the Y dimension.
%
% |sigmaZ| - _SCALAR_ -  Standard deviation (in pixel) of the gaussian filter along the Z dimension.
%
%
%% Output arguments
%
% |outdata| - _MATRIX_ - |outdata(x,y,z)| is the intensity of the filtered image at voxel (x,y,z)
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Université catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function outdata = normgauss_smoothing(indata, cert, sigma, sigmaY, sigmaZ)

cert = cert+eps;

dims = length(size(indata));
process = sigma>0;
if(nargin>3)
    process = process || (sigmaY>0) || (sigmaZ>0);
end

if(process)
    
    if(dims == 3)
        
        % Choose a proper filter kernel size
        sz = round(sigma*5);
        % Ensure odd sized filter
        sz = sz+(1-mod(sz,2));
        
        if(nargin>3)
            
            disp(['Non-uniform normalized gaussian smoothing (in pixels): ',num2str(sigma), ' ', num2str(sigmaY), ' ', num2str(sigmaZ)])
            
            % Choose a proper filter kernel size
            szY = round(sigmaY*5);
            % Ensure odd sized filter
            szY = szY+(1-mod(szY,2));
            
            % Choose a proper filter kernel size
            szZ = round(sigmaZ*5);
            % Ensure odd sized filter
            szZ = szZ+(1-mod(szZ,2));
            
            % Create filters
            krn1 = gaussian_kernel(sz, sigma);
            krn1 = krn1/sum(krn1(:));
            krn1 = single(krn1);
            
            krn2 = gaussian_kernel(szY, sigmaY);
            krn2 = krn2/sum(krn2(:));
            krn2 = single(krn2);
            
            krn3 = gaussian_kernel(szZ, sigmaZ);
            krn3 = krn3/sum(krn3(:));
            krn3 = single(krn3);
            
            % Perform value convolution
            if(sigma>0)
                indata = conv3f(indata.*cert, krn1);
            else
                indata = indata.*cert;
            end
            if(sigmaY>0)
                indata = conv3f(indata, krn2');
            end
            if(sigmaZ>0)
                indata = conv3f(indata, permute(krn3, [3 2 1]));
            end
            
            % Perform certainty convolution
            if(sigma>0)
                cert = conv3f(cert, krn1);
            end
            if(sigmaY>0)
                cert = conv3f(cert, krn2');
            end
            if(sigmaZ>0)
                cert = conv3f(cert, permute(krn3, [3 2 1]));
            end
            
        else
            
            % Create a filter
            krn = gaussian_kernel(sz, sigma);
            krn = krn/sum(krn(:));
            krn = single(krn);
            
            % Perform value convolution
            indata = conv3f(indata.*cert, krn);
            indata = conv3f(indata, krn');
            indata = conv3f(indata, permute(krn, [3 2 1]));
            
            % Perform certainty convolution
            cert = conv3f(cert, krn);
            cert = conv3f(cert, krn');
            cert = conv3f(cert, permute(krn, [3 2 1]));
            
        end
        
        % Deal with zero certainty voxels
        z = find(cert==0);
        cert(z) = 1;
        indata(z) = 0;
        
        % Compute result
        outdata = indata./cert;
        
    elseif(dims == 2)
        
        % Choose a proper filter kernel size
        sz = round(sigma*5);
        
        % Ensure odd sized filter
        sz = sz+(1-mod(sz,2));
        
        % Create a filter
        krn = gaussian_kernel(sz, sigma);
        krn = krn/sum(krn(:));
        
        % Perform value convolution
        indata = conv2(indata.*cert, krn, 'same');
        indata = conv2(indata, krn', 'same');
        
        % Perform certainty convolution
        cert = conv2(cert, krn, 'same');
        cert = conv2(cert, krn', 'same');
        
        % Deal with zero certainty voxels
        z = find(cert==0);
        cert(z) = 1;
        indata(z) = 0;
        
        % Compute result
        outdata = indata./cert;
        
    end
    
else
    
    outdata = indata;
    
end

