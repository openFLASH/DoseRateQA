%% points2image
% Create a binary images (of the same size as |im|) which is null everywhere, except near the coordinates specified by |pts|. |pts| defines the coordinate of a sphere of diameter 4 pixels with a pixel value of 1.
%
%% Syntax
% |im_res = points2image(pts,im)|
%
%
%% Description
% |im_res = points2image(pts,im)| Create the binary image with sphere of intensity 1 in a zero background
%
%
%% Input arguments
% |pts| - _SCALAR MATRIX_ -  |pts(:,i)=(x,y,z)| Coordinate (in pixel index) of the centre of the sphere with pixel intensity =1 
%
% |im| - _SCALAR MATRIX_ - the diemnsion of this matrix are used to define the dimension of the matrix |im_res|
%
%
%% Output arguments
%
% |im_res| - _SCALAR MATRIX_ - Matrix with the same dimension as |im|. The matrix is null everywhere. There are sphere of pixel=1 centered at the cooridnates defined in |pts|.
%
%
%% Contributors
% Authors : G.Janssens, J.Orban (open.reggui@gmail.com)

function im_res = points2image(pts,im)

im_res = zeros(size(im));

pts = round(pts);

if(size(pts,1)==3)

    for i=1:size(pts,2)
        try
            im_res(pts(1,i),pts(2,i),pts(3,i)) = 1;
        catch
            disp('Point out of bounds !!!')
        end
    end

else
    disp('Error: wrong dimension')
end


myStrel = zeros(4+1);
for i = 1:4+1
    myStrel(:,:,i)= zeros(4+1);
    for j = 1:4
        for k = 1:4
            if (sqrt((i-2)^2+(j-2-1)^2+(k-2-1)^2)<2)
                myStrel(j,k,i)=1;
            end
        end
    end
end
im_res = imdilate(single(im_res),myStrel);
im_res(isinf(im_res)) = 0;
