%% CBCT_couch_detection
% Identify the couch in the CBCT image. Returns a mask defining the position of the couch.
%
%% Syntax
% |res = CBCT_couch_detection(handles,image_name,couch_name)|
%
%
%% Description
% |res = CBCT_couch_detection(handles,image_name,couch_name)| describes the function
%
%
%% Input arguments
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name| - _STRING_ - Name of the image
% * |handles.images.data| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.images.info| - _STRUCTURE_ DICOM Information about the image
%
% |image_name| - _STRING_ -  Name of the CBCT in |handles.images| in which the couch should be identified
%
% |couch_name| - _STRING_ -  Name of the new image in |handles.images| where the couch mask will be stored
%
%
%% Output arguments
%
% |res| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |res.images.name| - _STRING_ - Name of the couch mask = |couch_name|
% * |res.images.data| - _SCALAR MATRIX_ - |data(x,y,z)| 1 if the voxel at coordinate (x,y,z) belongs to the couch. 0 otherwise.
% * |res.images.info| - _STRUCTURE_ - Meta information from the DICOM file. Copied from  |handles.images.OriginalHeader| or |handles.mydata.OriginalHeader|
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = CBCT_couch_detection(handles,image_name,couch_name)

res = handles;

if(nargin<3)
   couch_name = [image_name,'_couch'];
end

cbct_index = [];
for i=1:length(handles.images.name)
    if(strcmp(handles.images.name{i},image_name))
        cbct_index = i;        
    end
end
if(isempty(cbct_index))
    error('Error : input image not found in the current list !')
end

% automatic segmentation
intensities = handles.images.data{cbct_index};
intensities(intensities<-300)=-300;
intensities = cumsum(sum(sum(intensities+300,3),1));
intensities = intensities/(max(intensities)+eps);
couch_name = check_existing_names(couch_name,handles.images.name);
handles = AutoThreshold(image_name,[128],couch_name,handles);
handles = Opening(couch_name,[1 3 1],'temp_CBCT_seg_1',handles);
handles = Difference(couch_name,'temp_CBCT_seg_1','temp_CBCT_seg_2',handles);
handles = Opening('temp_CBCT_seg_2',[3 1 1],'temp_CBCT_seg_3',handles);
transitions = sum(sum(handles.images.data{end},3),1);
transitions(transitions<10*mean(transitions)) = 0;
transitions(intensities<0.95)=0;
if(sum(transitions)>0)
    [~,table_index]=max(transitions);
else
    table_index = length(transitions)+1;
end

% figure(777)
% subplot(2,1,1)
% plot(intensities)
% subplot(2,1,2)
% plot(transitions)

% remove temporary data
handles.images.data = handles.images.data(1:end-3);
handles.images.info = handles.images.info(1:end-3);
handles.images.name = handles.images.name(1:end-3);

% fill in couch
handles.images.data{end} = handles.images.data{end}*0;
handles.images.data{end}(:,table_index:end,:)=1;

% set handles as output
res = handles;
