function [dvh] = compute_DVH_NoGUI(handles, dose_name, contour_name)

for i=1:length(handles.images.name)
   if(strcmp(handles.images.name{i}, dose_name))
      myDose = handles.images.data{i};
   end
   if(strcmp(handles.images.name{i}, contour_name))
      myMask = handles.images.data{i};
      myMaskInfo = handles.images.info{i};
   end
end

number_of_bins = 1024;

if(sum(myMask(:)))
   myDose(find(myMask<max(max(max(myMask)))/2)) = NaN;
else
   myDose(:) =  NaN;
end

myDose = reshape(myDose,size(myDose,1)*size(myDose,2)*size(myDose,3),1,1);
myDose = myDose(find(not(isnan(myDose))));
myDose(find(myDose<0)) = 0;
if(length(unique(myDose))==0)
   h = 0;
   Xd = 0;
elseif(length(unique(myDose))==1)
   h = length(myDose);
   Xd = unique(myDose);
else
   [h,Xd] = hist(myDose,number_of_bins);
   h = h(end:-1:1);
   h = cumsum(h);
   h = h(end:-1:1);
end

h = 100 * h / length(myDose);

dvh.volume = h;
dvh.dose = Xd;
dvh.dmin = min(myDose(:));
dvh.dmax = max(myDose(:));
dvh.dmean = mean(myDose(:));
dvh.dmedian = median(myDose(:));
dvh.geud = (mean(myDose(:).^(-10)))^(-1/10);

% compute D95
D = 95;
w2 = (h(find(h<D,1)-1)-D)/(h(find(h<D,1)-1) - h(find(h<D,1)) + eps);
w1 = (D-h(find(h<D,1)))/(h(find(h<D,1)-1) - h(find(h<D,1)) + eps);
dvh.D95 = (w1*Xd(find(h<D,1)-1)+w2*Xd(find(h<D,1)));

% compute D5
D = 5;
w2 = (h(find(h<D,1)-1)-D)/(h(find(h<D,1)-1) - h(find(h<D,1)) + eps);
w1 = (D-h(find(h<D,1)))/(h(find(h<D,1)-1) - h(find(h<D,1)) + eps);
dvh.D5 = (w1*Xd(find(h<D,1)-1)+w2*Xd(find(h<D,1)));

if(isfield(myMaskInfo,'Color'))
   current_color = myMaskInfo.Color/255;
else
   current_color = [rand() rand() rand()];
end

dvh.color = current_color;
dvh.hexcolor = [dec2hex(round(255*current_color(1)),2),dec2hex(round(255*current_color(2)),2),dec2hex(round(255*current_color(3)),2)];

end
