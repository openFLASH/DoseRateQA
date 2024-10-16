%====================================
% Compute the dose averaged dose rate [3]
% INPUT
% |Dose| -_SCALAR MATRIX_- |Dose(spot,pxl)| Dose (Gy) delivered by spot number |spot| to the pixel |pxl|
%
% |spotTimingStart| -_SCALAR VECTOR_- |spotTimingStart(i)| Timing (ms) at the begining of the i-th spot delivery
%
% |spotTimingStop| -_SCALAR VECTOR_- |spotTimingStop(i)| Timing (ms) at the end of the i-th spot delivery
%
% |percentile| -_SCALAR_-  Define the lower and higher dose percentile to ignore to compute dose rate and delivery time (eg. 0.01 for the 98-percentile)
%
% OUTPUT
% |DADR| -_SCALAR VECTOR_- |DADR(pxl)| Dose averaged dose rate (Gy/s) as defined in [3] delivered to the pxl-th pixel
%====================================

function DADR = doseAveragedDoseRate(Dose , spotTimingStart, spotTimingStop)
    nBPxl = size(Dose,2);
    dT = spotTimingStop - spotTimingStart; %dT(spot) Time to deliver i-th spot
    DR = Dose ./ repmat(dT', 1,nBPxl); % DR(spot,pxl) Dose rate at pxl-th voxel and for delivery of spot
    Dtot = sum(Dose,1); %Dtot(pxl) Total dose delivered at pixel |pxl|
    DADR = 1000 .* sum(DR .* Dose ,1) ./ Dtot; %Convert into Gy/s from ms
end
