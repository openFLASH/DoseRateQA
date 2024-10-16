%% find_contour
% Binarise an image with a threshold set at 50% of the dynamic range of the image. Find the boundary off the binarise image. Return the coordinate of the pixels forming the boundary.
%
%% Syntax
% |bound = find_contour(im)|
%
% |bound = find_contour(im,method)|
%
%% Description
% |bound = find_contour(im)| Extract border pixel coordinates
%
% |bound = find_contour(im,method)| Extract coordinate of the border pixel using the slected method.
%
%
%% Input arguments
%
% |im| - _SCALAR MATRIX_ - |im(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
%
% |method| - _SCALAR_ -  [OPTIONAL. default = 0 ]0 = dilate object, then extract boundary using |bwboundaries|. 1 = extract border pixel coordinates using the difference between binarised and erorded binarised images. 
%
%
%% Output arguments
%
% |bound| - _CELL ARRAY_ - P-by-1 cell array, where P is the number of objects and holes. Each cell in the cell array contains a Q-by-2 matrix. Each row in the matrix contains the row and column coordinates of a boundary pixel. Q is the number of boundary pixels for the corresponding region.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function bound = find_contour(im,method)

bound = cell(0);

if(nargin<2)
    method = 0;
end

im = im-min(im(:));
im = single(im>(max(im(:))/2));

if(method) % compute border pixel boundaries
    
    bb = [2;2];
    [i j] = find(im);
        
        if (~isempty(i))
            
            semi_voxel = 1.0;
            
            minimum = [max(1,min(i)-bb(1));max(1,min(j)-bb(2))];
            maximum = [min(size(im,1),max(i)+bb(1));min(size(im,2),max(j)+bb(2))];
            im = im(minimum(1):maximum(1),minimum(2):maximum(2));

            % Oversampling
            im_oversampled = zeros(3*size(im));
            im_oversampled(1:3:end-2,1:3:end-2) = im;
            im_oversampled(1:3:end-2,2:3:end-1) = im;
            im_oversampled(1:3:end-2,3:3:end) = im;
            im_oversampled(2:3:end-1,1:3:end-2) = im;
            im_oversampled(2:3:end-1,2:3:end-1) = im;
            im_oversampled(2:3:end-1,3:3:end) = im;
            im_oversampled(3:3:end,1:3:end-2) = im;
            im_oversampled(3:3:end,2:3:end-1) = im;
            im_oversampled(3:3:end,3:3:end) = im;
            im_oversampled = imdilate(im_oversampled,[0 1 0; 1 1 1; 0 1 0]);
            im_oversampled(isinf(im_oversampled)) = 0;
            
            % Boundary extraction
            boundCell = bwboundaries(im_oversampled);
            
            for ireg = 1:size(boundCell,1) %if several shapes                
                temp = cell2mat(boundCell(ireg,1));            
                temp = (temp+semi_voxel)/3;                
                temp(:,1) = temp(:,1)+minimum(1)-1;
                temp(:,2) = temp(:,2)+minimum(2)-1;
                bound(ireg,1) = {temp};                
            end
            
        end
    
else % extract border pixel coordinates only
    
    im_eroded = imerode(im,ones(3,3));
    im = im - im_eroded;
    [i j] = find(im);
    temp(:,1) = i;
    temp(:,2) = j;
    bound(1,1) = {temp};
    
end
