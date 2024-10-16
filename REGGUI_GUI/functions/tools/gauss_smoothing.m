%% gauss_smoothing
% Performs gaussian smoothing (in pixel space !) by convolving a gaussian kernel with the image
%
%% Syntax
% |outdata = gauss_smoothing(indata, sigma)|
%
% |outdata = gauss_smoothing(indata, sigma, sigmaY, sigmaZ)|
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
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function outdata = gauss_smoothing(indata, sigma, sigmaY, sigmaZ)

dims = length(size(indata));
process = sigma>0;
if(nargin>2)
    process = process || (sigmaY>0) || (sigmaZ>0);
end

if(process)
    
    if(dims == 3)
        
        % Choose a proper filter kernel size
        sz = round(sigma*5);        
        % Ensure odd sized filter
        sz = sz+(1-mod(sz,2));
        
        if(nargin>2)
            
            disp(['Non-uniform gaussian smoothing (in pixels): ',num2str(sigma), ' ', num2str(sigmaY), ' ', num2str(sigmaZ)])
            
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
                outdata = conv3f(indata, krn1);
            else
                outdata = indata;
            end
            if(sigmaY>0)
                outdata = conv3f(outdata, krn2');
            end
            if(sigmaZ>0)
                outdata = conv3f(outdata, permute(krn3, [3 2 1]));
            end
            
        else
            
            % Create a filter
            krn = gaussian_kernel(sz, sigma);
            krn = krn/sum(krn(:));
            krn = single(krn);
            
            % Perform value convolution
            outdata = conv3f(indata, krn);
            outdata = conv3f(outdata, krn');
            outdata = conv3f(outdata, permute(krn, [3 2 1]));
            
        end
        
    elseif(dims == 2)
        
        % Choose a proper filter kernel size
        sz = round(sigma*5);
        
        % Ensure odd sized filter
        sz = sz+(1-mod(sz,2));
        
        % Create a filter
        krn = gaussian_kernel(sz, sigma);
        krn = krn/sum(krn(:));
        
        % Perform value convolution
        outdata = conv2(indata, krn, 'same');
        outdata = conv2(outdata, krn', 'same');
        
    elseif(dims == 1)
        
        % Choose a proper filter kernel size
        sz = round(sigma*5);
        
        % Ensure odd sized filter
        sz = sz+(1-mod(sz,2));
        
        % Create a filter
        krn = gaussian_kernel(sz, sigma);
        krn = krn/sum(krn(:));
        
        % Perform value convolution
        outdata = conv(indata, krn, 'same');
        
    end
    
else
    
    outdata = indata;
    
end

