%% Test_field
% Return a deformation field with the size defined in |handles.size|. The deformation field contains the specified frequencies at the different scales, for each vector component of the field.
% If no frequency are provided, the function returns a null field.
%
%% Syntax
% |handles = Test_field(field_dest,handles)|
%
% |handles = Test_field(field_dest,handles,scales1,scales2,scales3)|
%
%
%% Description
% |handles = Test_field(field_dest,handles)| Return a nul deformation field
%
% |handles = Test_field(field_dest,handles,scales1,scales2,scales3)| Return the deformation field withthe specified spatial frequencies at the different scales
%
%
%% Input arguments
% |field_dest| - _STRING_ - Name of the new field created in |handles.fields|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
%
% |scales1| - _SCALAR VECTOR_ - |scales1(i)| Vector component X frequencies in the field at scale i
%
% |scales2| - _SCALAR VECTOR_ - |scales2(i)| Vector component Y frequencies in the field at scale i
%
% |scales3| - _SCALAR VECTOR_ - |scales3(i)| Vector component Z frequencies in the field at scale i
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following information is updated  in the destimation image |i|:
%
% * |handles.fields.name{i}| - _STRING_ - Name of the field
% * |handles.fields.data{i}| _MATRIX of SCALAR_ |input_field(1,x,y,z)| is X component of the deformation field at the voxel (x,y,z). The Y and Z components are defined in matrix components |input_field(2,x,y,z)| and |input_field(3,x,y,z)|.
% * |handles.fields.info{i}| - _STRUCTURE_ DICOM Information about the field
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Test_field(field_dest,handles,scales1,scales2,scales3)
if(handles.size(1) && handles.size(2) && handles.size(3))
    if(nargin>2)
        s = zeros(3,handles.size(1),handles.size(2),handles.size(3),'single');
        s(:,1,1,1) = 0;
        
        % The component of frequency 1/per [1/voxl] will have an amplitude of A*per
        A = 1/max([handles.size(1),handles.size(2),handles.size(3)]);
        %A = 1/16;
        
        % for the highest frequency, only one value in the spectrum (and doubled)
        freqX1 = round((handles.size(1)-1)/2^(1/2+1/2));
        freqY1 = round((handles.size(2)-1)/2^(1/2+1/2));
        freqZ1 = round((handles.size(3)-1)/2^(1/2+1/2));
        
        freqX2 = round((handles.size(1)-1)/2^(1/2+1/2));
        freqY2 = round((handles.size(2)-1)/2^(1/2+1/2));
        freqZ2 = round((handles.size(3)-1)/2^(1/2+1/2));
        
        freqX3 = round((handles.size(1)-1)/2^(1/2+1/2));
        freqY3 = round((handles.size(2)-1)/2^(1/2+1/2));
        freqZ3 = round((handles.size(3)-1)/2^(1/2+1/2));
        
        per1 = 2^(1/2+1/2);
        s(1,1+freqX1,1,1) = A*per1*scales1(1);
        s(1,1,1+freqY1,1) = A*per1*scales1(1);
        s(1,1,1,1+freqZ1) = A*per1*scales1(1);
        
        s(2,1+freqX2,1,1) = A*per1*scales2(1);
        s(2,1,1+freqY2,1) = A*per1*scales2(1);
        s(2,1,1,1+freqZ2) = A*per1*scales2(1);
        
        s(3,1+freqX3,1,1) = A*per1*scales3(1);
        s(3,1,1+freqY3,1) = A*per1*scales3(1);
        s(3,1,1,1+freqZ3) = A*per1*scales3(1);
        
        if(length(scales1)>(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1)
            disp('Warning: vector of x-frequencies too long for the size of the image. Vector limited to continuous component');
            s(1,1,1,1) = 6*max(scales1(floor(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1:end));
            scales1 = scales1(1:floor(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1);
        end
        if(length(scales2)>(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1)
            disp('Warning: vector of y-frequencies too long for the size of the image. Vector limited to continuous component');
            s(2,1,1,1) = 6*max(scales2(floor(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1:end));
            scales2 = scales2(1:floor(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1);
        end
        
        if(length(scales3)>(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1)
            disp('Warning: vector of z-frequencies too long for the size of the image. Vector limited to continuous component');
            s(3,1,1,1) = 6*max(scales3(floor(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1:end));
            scales3 = scales3(1:floor(log2(min([handles.size(1),handles.size(2),handles.size(3)])-1-1/2)*2)-1);
        end
        
        for k=2:length(scales1)
            freqX1 = round((handles.size(1)-1)/2^(1/2+k/2));
            freqY1 = round((handles.size(2)-1)/2^(1/2+k/2));
            freqZ1 = round((handles.size(3)-1)/2^(1/2+k/2));
            perk = 2^(1/2+k/2);
            
            s(1,1+freqX1,1,1) = A*perk*scales1(k);
            s(1,mod(end-freqX1,end)+1,1,1) = s(1,1+freqX1,1,1);
            
            s(1,1,1+freqY1,1) = A*perk*scales1(k);
            s(1,1,mod(end-freqY1,end)+1,1) = s(1,1,1+freqY1,1);
            
            s(1,1,1,1+freqZ1) = A*perk*scales1(k);
            s(1,1,1,mod(end-freqZ1,end)+1) = s(1,1,1,1+freqZ1);
        end
        
        for k=2:length(scales2)
            freqX2 = round((handles.size(1)-1)/2^(1/2+k/2));
            freqY2 = round((handles.size(2)-1)/2^(1/2+k/2));
            freqZ2 = round((handles.size(3)-1)/2^(1/2+k/2));
            perk=2^(1/2+k/2);
            
            s(2,1+freqX2,1,1) = A*perk*scales2(k);
            s(2,mod(end-freqX2,end)+1,1,1) = s(2,1+freqX2,1,1);
            
            s(2,1,1+freqY2,1) = A*perk*scales2(k);
            s(2,1,mod(end-freqY2,end)+1,1) = s(2,1,1+freqY2,1);
            
            s(2,1,1,1+freqZ2) = A*perk*scales2(k);
            s(2,1,1,mod(end-freqZ2,end)+1) = s(2,1,1,1+freqZ2);
        end
        
        for k=2:length(scales3)
            freqX3 = round((handles.size(1)-1)/2^(1/2+k/2));
            freqY3 = round((handles.size(2)-1)/2^(1/2+k/2));
            freqZ3 = round((handles.size(3)-1)/2^(1/2+k/2));
            perk = 2^(1/2+k/2);
            
            s(3,1+freqX3,1,1) = A*perk*scales3(k);
            s(3,mod(end-freqX3,end)+1,1,1) = s(3,1+freqX3,1,1);
            
            s(3,1,1+freqY3,1) = A*perk*scales3(k);
            s(3,1,mod(end-freqY3,end)+1,1) = s(3,1,1+freqY3,1);
            
            s(3,1,1,1+freqZ3) = A*perk*scales3(k);
            s(3,1,1,mod(end-freqZ3,end)+1) = s(3,1,1,1+freqZ3);
        end
        norm_factor = handles.size(1)*handles.size(2)*handles.size(3)/3; %to compensate for the normalization factor used in the ifft definition
        
        fieldTest(1,:,:,:) = norm_factor*real(ifftn(s(1,:,:,:)));
        
        fieldTest(2,:,:,:) = norm_factor*real(ifftn(s(2,:,:,:)));
        
        fieldTest(3,:,:,:) = norm_factor*real(ifftn(s(3,:,:,:)));
        
        myInfo = Create_default_info('deformation_field',handles);
        myDataName = check_existing_names(field_dest,handles.mydata.name);
        handles.mydata.name{length(handles.mydata.name)+1} = myDataName;
        handles.mydata.data{length(handles.mydata.data)+1} = fieldTest;
        handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
        handles = Data2field(myDataName,field_dest,handles);
        handles = Remove_data(myDataName, handles);
    else
        fieldEmpty = zeros(handles.size(1),handles.size(2),handles.size(3),'single');
        field_dest = check_existing_names(field_dest,handles.fields.name);
        handles.fields.name{length(handles.fields.name)+1} = field_dest;
        handles.fields.data{length(handles.fields.data)+1} = fieldEmpty;
        handles.fields.info{length(handles.fields.info)+1} = Create_default_info('field',handles);
    end
else
    disp('Error : you have to load an image first (to set dimensions) !')
end
