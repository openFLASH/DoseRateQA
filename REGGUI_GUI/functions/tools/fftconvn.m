%% fftconvn
% Performs a fast N-dimensional convolution in the Fourier domain.
% The result corresponds to Y = convn(X,K,'same');
% It is real if both X and K are.
%
%% Syntax
% |Y = fftconvn(X,K)|
%
% |Y = fftconvn(X,K,gpu)|
%
%
%% Description
% |Y = fftconvn(X,K,gpu)| Performs a fast N-dimensional convolution. Set GPU = false
%
% |Y = fftconvn(X,K,gpu)| Performs a fast N-dimensional convolution.
%
%
%% Input arguments
% |X| - _SCALAR MATRIX_ -  N-dimensional volume (single or double, real or complex)
%
% |K| - _SCALAR MATRIX_ -  N-dimensional kernel (single or double, real or complex)
%
% |gpu| - _BOOL_ -  Boolean flag to enable computations on GPU (hardware dependent) 
%
%
%% Output arguments
%
% |Y| - _SCALAR MATRIX_ - N-dimensional convolution of X by K (same precision, and size as X)
%
%% Contributors
% Copyright J.A.Lee, February 16, 2013.

function Y = fftconvn(X,K,gpu)


% default argument for GPU computations
if nargin<3, gpu = false; else gpu = logical(gpu(1)); end
if gpu
    tmp = version('-release');
    if str2double(tmp(1:4))<2012, gpu = false; end
end
    
% check dimensions
dim = ndims(X);
if dim~=ndims(K), error('X and K have not the same dimensions'); end

% remember whether arguments are real numbers
rl = isreal(X) && isreal(K);

% (max.) sizes of the input volumes
Xs = size(X);
Xm = max(Xs);
Ks = size(K);
Km = max(Ks);

% transfer to GPU if required
if gpu
    try
        X = gpuArray(X);
        K = gpuArray(K);
    catch msg
        disp(msg);
        disp('Encountering some problem with GPU, switching back to CPU... Sorry!');
        gpu = false;
    end
end

% Fourier tranform of X and K
idx = cell(dim,1);
for d = 1:dim
    % FFT transform in each dimension
    X = fft(X,Xm+Km-1,d);
    K = fft(K,Xm+Km-1,d);
    
    % indices in each dimension (to get back to same size as X)
    idx{d} = ceil((Ks(d)-1)/2) + (1:Xs(d));
end

% convolution by multiplication of the Fourier tranforms
Y = X.*K;

% inverse Fourier transform of the product
for d = 1:dim
    Y = ifft(Y,[],d);
end

% tranfer back from GPU if required
if gpu
    Y = gather(Y);
end

% go to original size of X
Y = Y(idx{:});

% remove unwanted imaginary parts if real args
if rl, Y = real(Y); end
