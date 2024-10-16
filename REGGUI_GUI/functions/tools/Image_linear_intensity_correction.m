%% Image_linear_intensity_correction
% For more information, see reference [1].
%
%% Syntax
% |handles = Image_linear_intensity_correction(im1,im2,roi,im_dest,handles) |
%
%
%% Description
% |handles = Image_linear_intensity_correction(im1,im2,roi,im_dest,handles) | describes the function
%'CBCT_raw','vCT','pCT_BODY_def','CBCT',handles
%
%% Input arguments
% |im1| - _STRING_ -  Name of the uncorrected CBCT in |handles.images|
%
% |im2| - _STRING_ -  Name of the virtual CT in |handles.images|
%
% |roi| - _STRING_ -  Name of the structure defining the region of interest (stored in |handles.images|) in which the computation shall be done
%
% |im_dest| - _STRING_ -  Name of the new image in |handles.images| where the corrected CBCT will be stored
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name| - _STRING_ - Name of the image
% * |handles.images.data| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info| - _STRUCTURE_ DICOM Information about the image
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data is updated:
%
% * |handles.images.name| - _STRING_ - Name of the corrected CBCT
% * |handles.images.data| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel of the corrected CBCT at coordinate (x,y,z)
% * |handles.images.info| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.image.info| of |im1|
%
%
%% Reference
%
% [1] Veiga, C., Janssens, G., Teng, C.-L., Baudier, T., Hotoiu, L., McClelland, J. R., … Teo, B.-K. K. (2016). First clinical investigation of CBCT and deformable registration for adaptive proton therapy of lung cancer. International Journal of Radiation Oncology Biology Physics, 95(1), 549–559. http://doi.org/10.1016/j.ijrobp.2016.01.055
%
%% Contributors
% Authors : T. Baudier, G.Janssens (open.reggui@gmail.com)

function handles = Image_linear_intensity_correction(im1,im2,roi,im_dest,handles,display)

if(nargin<6)
    display = 0;
end

prctile = 1;

for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},im1))
        myIm1 = handles.images.data{i};
        myInfo1 = handles.images.info{i};
    end
    if(strcmp(handles.images.name{i},im2))
        myIm2 = handles.images.data{i};
    end
    if(strcmp(handles.images.name{i},roi))
        myROI = handles.images.data{i};
    end
end

% Compute global background values
myIm1_sorted = sort(myIm1(:));
myIm2_sorted = sort(myIm2(:));
try
    myIm1_bkgd = myIm1_sorted(ceil(prctile/100*length(myIm1_sorted)));
catch
    myIm1_bkgd = min(myIm1_sorted);
end
try
    myIm2_bkgd = myIm2_sorted(ceil(prctile/100*length(myIm2_sorted)));
catch
    myIm2_bkgd = min(myIm2_sorted);
end

% Exclude values out of the ROI from the computation
myIm1(myROI<=max(myROI(:)/2))=NaN;
myIm2(myROI<=max(myROI(:)/2))=NaN;

if(display)
    try 
        close(1) 
    catch
    end
    figure(1);
    n = 0;
    subplot(3,4,1+4*n); histogram(myIm1(myROI>max(myROI(:)/2)),255,'FaceColor','none','EdgeColor','b');hold on;histogram(myIm2(myROI>max(myROI(:)/2)),255,'FaceColor','none','EdgeColor','r');
    subplot(3,4,2+4*n); imshow(myIm1(:,:,50),[-1000,1000]);
    subplot(3,4,3+4*n); imshow(myIm2(:,:,50),[-1000,1000]);
    dd = myIm1-myIm2; dd(myROI<=max(myROI(:)/2))=0;
    subplot(3,4,4+4*n); imshow(dd(:,:,50),[-1000,1000])
    xlabel(num2str(sum(abs(myIm1(myROI>max(myROI(:)/2))-myIm2(myROI>max(myROI(:)/2)))) /length(myIm1(myROI>max(myROI(:)/2)))))
end

% Correct lowest HU values :
myIm1_sorted = sort(myIm1(not(isnan(myIm1))));
myIm2_sorted = sort(myIm2(not(isnan(myIm2))));
try
    myIm1_low = myIm1_sorted(ceil(prctile/100*length(myIm1_sorted)));
catch
    myIm1_low = min(myIm1_sorted);
end
try
    myIm2_low = myIm2_sorted(ceil(prctile/100*length(myIm2_sorted)));
catch
    myIm2_low = min(myIm2_sorted);
end

% Initial scaling based on median value
myIm1_med = median(myIm1(myROI>max(myROI(:)/2))) - myIm1_low;
myIm2_med = median(myIm2(myROI>max(myROI(:)/2))) - myIm2_low;
myIm1 = myIm1 - myIm1_low;
myIm1 = myIm1 .* (myIm2_med+eps) ./ (myIm1_med+eps);
myIm1 = myIm1 + myIm2_low;

if(display)
    figure(1);
    n = 1;
    subplot(3,4,1+4*n); histogram(myIm1(myROI>max(myROI(:)/2)),255,'FaceColor','none','EdgeColor','b');hold on;histogram(myIm2(myROI>max(myROI(:)/2)),255,'FaceColor','none','EdgeColor','r');
    subplot(3,4,2+4*n); imshow(myIm1(:,:,50),[-1000,1000]);
    subplot(3,4,3+4*n); imshow(myIm2(:,:,50),[-1000,1000]);
    dd = myIm1-myIm2; dd(myROI<=max(myROI(:)/2))=0;
    subplot(3,4,4+4*n); imshow(dd(:,:,50),[-1000,1000])
    xlabel(num2str(sum(abs(myIm1(myROI>max(myROI(:)/2))-myIm2(myROI>max(myROI(:)/2)))) /length(myIm1(myROI>max(myROI(:)/2)))))
end

% M-estimator : 
B = myIm1(myROI>max(myROI(:)/2)) - myIm2_low;
A = myIm2(myROI>max(myROI(:)/2)) - myIm2_low;
coeff = (A'*A)\A'*B;
tempCoeff = [1;1];
compteur = 1;
while norm(tempCoeff - coeff,2)/norm(tempCoeff,2) >0.001 && compteur < 10
   tempCoeff = coeff;
   r = B-A*coeff;
   sigma = 1.48*median(abs(r-median(r)));
   r = r/sigma; 
   b = 1./(1+r.^2);
   W = b.*A;
   coeff = (W'*A)\W'*B;
   compteur = compteur+1;
end
coeff = [coeff;abs(myIm2_low)*(coeff(1)-1)];


myIm1 = (myIm1-coeff(2))/coeff(1);
myIm1(isnan(myIm1)) = myIm2_bkgd;
myIm1(isinf(myIm1)&myIm1<0) = min(myIm1(:));
myIm1(isinf(myIm1)&myIm1>0) = max(myIm1(:));

im_dest = check_existing_names(im_dest,handles.images.name);
handles.images.name{length(handles.images.name)+1} = im_dest;
handles.images.data{length(handles.images.data)+1} = single(myIm1);
handles.images.info{length(handles.images.info)+1} = myInfo1;

if(display)
    myIm2(isnan(myIm2)) = myIm2_bkgd;
    figure(1);
    n = 2;
    subplot(3,4,1+4*n); histogram(myIm1(myROI>max(myROI(:)/2)),255,'FaceColor','none','EdgeColor','b');hold on;histogram(myIm2(myROI>max(myROI(:)/2)),255,'FaceColor','none','EdgeColor','r');
    subplot(3,4,2+4*n); imshow(myIm1(:,:,50),[-1000,1000]);
    subplot(3,4,3+4*n); imshow(myIm2(:,:,50),[-1000,1000]);
    dd = myIm1-myIm2; dd(myROI<=max(myROI(:)/2))=0;
    subplot(3,4,4+4*n); imshow(dd(:,:,50),[-1000,1000])
    xlabel(num2str(sum(abs(myIm1(myROI>max(myROI(:)/2))-myIm2(myROI>max(myROI(:)/2)))) /length(myIm1(myROI>max(myROI(:)/2)))))
    disp('Done')
end

