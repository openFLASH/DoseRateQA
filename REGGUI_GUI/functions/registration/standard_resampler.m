%% standard_resampler
% Resamples data (scalar matrix or cell vector of scalar matrices) using a standard resampling method.
% See section "2.1.6 Scale-space representation" of reference [1] for more information on rescaling.
%
%% Syntax
% |output = standard_resampler(indata, resampler_type, in_scale, out_scale, relative_values, orig_size)|
%
%
%% Description
% |output = standard_resampler(indata, resampler_type, in_scale, out_scale, relative_values, orig_size)| Resamples data using a standard resampling method.
%
%
%% Input arguments
% |indata| - The data to resample. |indata| can be either:
%
% * _MATRIX of SCALAR_ : A scalar matrix with N dimensions. For example: |v(J,x,y,z)| or |v(x,y,z)| 
% * _CELL VECTOR of MATRICES_ : N cells with scalar matrices. For example: |indata{J}(x,y,z)| with J<=N. N has to be equal to the number of dimensions of the matrix. That is, we can resample vector fields of the same dimensionality as the definition space. If |relative_value = 0|, N is unconstrained.
%
% |resampler_type| - _STRING_ - Defines the type of resampling:
% 
% * 'linear' : linear resampling with pre-smoothing 
% * 'nearest' : nearest neighbor with pre-smoothing 
% * 'none' : nearest neighbourgh without pre-smoothing
%
% |in_scale| - _INTEGER_ -  The scale before resampling.
%
% |out_scale| - _INTEGER_ -  The scale after resampling. The scale is defining the downscaling |F| factor of the image: |F = 2^(scale/2)|. (e.g. |scale=2| downscale the image by a factor 4). The sigma of the Gaussian filtering (see section "2.1.6 Scale-space representation" of reference [1]) applied on the image is |0.4*F|.
%
% |relative_values| - _INTEGER_ -  This is used to enable fitting deformation fields to the new scale. Indicates how the data values should be rescaled:
%
% * 1 = in accordance with the scale change 
% * 0 = left unchanged. 
%
% |orig_size| - _VECTOR of SCALAR_ Size (x,y,z) (in pixels) of |indata|.
%
%
%% Output arguments
%
% |output| - _Same type as |indata|_ - The rescaled image
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function output = standard_resampler(indata, resampler_type, in_scale, out_scale, relative_values, orig_size)

if(in_scale==out_scale && sum(size(indata)==orig_size)==length(size(indata)))
    
    output = indata;
    
else
    switch resampler_type
        case 'none'
            interp = 0;
            pre_smoothing = 0;
        case {'nearest',''}
            interp = 0;
            pre_smoothing = 1;
        case 'linear'
            interp = 1;
            pre_smoothing = 1;
        otherwise
            disp('Invalid resampling type. No resampling.')
            output = indata;
            return
    end
    
    % First check if the indata has several components
    if(iscell(indata))
        vdata = length(indata);
        dims = length(size(indata{1}));
        if((dims ~= vdata) && relative_values)
            error(['--- standard_resampler: ', num2str(vdata),'-dimensional relative data in ',...
                num2str(dims),'-dimensional space. Don''t know how to handle this...']);
        end
        cur_sz = size(indata{1});
    else
        vdata = 0;
        dims = length(size(indata));
        cur_sz = size(indata);
    end
    
    % Compute target size based on scale 0 size and nothing local
    target_sz = round(orig_size*2^(-out_scale/2));
    if(sum(target_sz<=1))
        disp('Image size is too small for this resampling factor. No resampling.')
        output = indata;
        return
    end
    downfactor = (cur_sz-1)./(target_sz-1);
    
    sigma = downfactor*.4;
    fsz = round(sigma * 5);
    fsz = fsz + (1-mod(fsz,2));
    
    filterx = gaussian_kernel(fsz(2), sigma(2));
    filtery = gaussian_kernel(fsz(1), sigma(1));
    filterx = filterx/sum(filterx);
    filtery = filtery'/sum(filtery);
    
    if(dims == 3)
        filterz = gaussian_kernel(fsz(3), sigma(3));
        filterz = filterz/sum(filterz);
        
        if(~vdata)
            if(pre_smoothing)
                indata = padarray(indata, [length(filterx) length(filtery) length(filterz)], 'replicate');
                output = conv3f(indata, single(filtery));
                output = conv3f(output, single(filterx));
                output = conv3f(output, single(permute(filterz, [3 2 1])));
                output = output(length(filterx)+1:end-length(filterx), length(filtery)+1:end-length(filtery),length(filterz)+1:end-length(filterz));
            else
                output = indata;
            end
            if(interp)
                output = resampler3(output,linspace(1,cur_sz(1),target_sz(1)),linspace(1,cur_sz(2),target_sz(2)),linspace(1,cur_sz(3),target_sz(3)));
            else
                [X Y Z] = meshgrid(linspace(1,cur_sz(2),target_sz(2)),linspace(1,cur_sz(1),target_sz(1)),linspace(1,cur_sz(3),target_sz(3)));
                X = single(X);
                Y = single(Y);
                Z = single(Z);
                output = interp3(output,X,Y,Z,'nearest');
            end
        else
            for n = 1:vdata
                if(pre_smoothing)
                    indata{n} = padarray(indata{n}, [length(filterx) length(filtery) length(filterz)], 'replicate');
                    output{n} = conv3f(indata{n}, single(filtery));
                    output{n} = conv3f(output{n}, single(filterx));
                    output{n} = conv3f(output{n}, single(permute(filterz, [3 2 1])));
                    output{n} = output{n}(length(filterx)+1:end-length(filterx), length(filtery)+1:end-length(filtery),length(filterz)+1:end-length(filterz));
                else
                    output{n} = indata{n};
                end
                if(interp)
                    output{n} = resampler3(output{n},linspace(1,cur_sz(1),target_sz(1)),linspace(1,cur_sz(2),target_sz(2)),linspace(1,cur_sz(3),target_sz(3)));
                else
                    [X Y Z] = meshgrid(linspace(1,cur_sz(2),target_sz(2)),linspace(1,cur_sz(1),target_sz(1)),linspace(1,cur_sz(3),target_sz(3)));
                    X = single(X);
                    Y = single(Y);
                    Z = single(Z);
                    output{n} = interp3(output{n},X,Y,Z,'nearest');
                end
                if(relative_values)
                    output{n} = output{n} / downfactor(n);
                end
            end
        end
        
    elseif(dims == 2)
        [inX,inY] = meshgrid(linspace(0, 1, cur_sz(2)), linspace(0,1,cur_sz(1)));
        [outX,outY] = meshgrid(linspace(0,1,target_sz(2)), linspace(0,1,target_sz(1)));
        
        if(~vdata)
            if(pre_smoothing)
                output = imfilter(indata, filtery, 'replicate','same');
                output = imfilter(output, filterx, 'replicate', 'same');
            else
                output = indata;
            end
            output = interp2(inX, inY, output, outX, outY, resampler_type);
        else
            for n = 1:vdata
                if(pre_smoothing)
                    output{n} = imfilter(indata{n}, filtery, 'replicate', 'same');
                    output{n} = imfilter(output{n}, filterx, 'replicate', 'same');
                else
                    output{n} = indata{n};
                end
                output{n} = interp2(inX, inY, output{n}, outX, outY, resampler_type);
                if(relative_values)
                    output{n} = output{n} / downfactor(n);
                end
            end
        end
    else
        error('--- standard_resampler: Number of dimensions must be 2 or 3');
    end
    
end

