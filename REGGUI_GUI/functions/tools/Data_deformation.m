%% Data_deformation
% An image can be internally stored as _data_ or as _image_ (_cf._ functions _Image2data_ & _Data2image_). This function applies a deformation field on the data container |handles.mydata|.
%
%% Syntax
% |handles = Data_deformation(data,field,im_dest,handles)|
%
% |handles = Data_deformation(data,field,im_dest,handles,crop)|

%% Description
% |handles = Data_deformation(data,field,im_dest,handles)| applies a deformation field to an image stored in the data container |handles.mydata| *without cropping* the image to match its intial size. For example, if the applied deformation leads to a rotation, the new image will have a larger size.
%
% |handles = Data_deformation(data,field,im_dest,handles,crop)| applies a deformation field to an image stored in the data container |handles.mydata| and *crops* the newly created image to match its intial size.

%% Input arguments
% |data| - _STRING_ - name of the image stored in |handles.mydata.name| on which to apply a deformation.
%
% |field| - _STRING_ - name of deformation field in |handles.fields.name| to be applied to image |data|.
%
% |im_dest| - _STRING_ - name of the newly created image to be stored in |handles.mydata|.
%
% |handles| - _STRUCTURE_ - REGGUI data structure containing the newly deformed image. 
%
% |crop| - _INTEGER_ - can take _0_ or _1_ value. If _1_ crop, if _0_ don't. The _0_ case performs the same as the function overload not bearing the _crop_ input parameter.

%% Output arguments
% |handles| - _STRUCTURE_ - REGGUI internal structure containing the deformed image inside |handles.mydata|.

%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Data_deformation(data,field,im_dest,handles,crop)

myField = [];
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},field))
        myInfo = handles.mydata.info{i};
        if(strcmp(myInfo.Type,'rigid_transform'))
            myField = handles.mydata.data{i};
        end
    end
end
for i=1:length(handles.fields.name)
    if(strcmp(handles.fields.name{i},field))
        myInfo = handles.fields.info{i};
        if(strcmp(myInfo.Type,'rigid_transform'))
            myField = handles.fields.data{i};
        end
    end
end
for i=1:length(handles.mydata.name)
    if(strcmp(handles.mydata.name{i},data))
        myData = handles.mydata.data{i};
        myDataInfo = handles.mydata.info{i};
    end
end
try
    if(isempty(myField))
        error('You have to select a rigid transformation if you want to deform data.');
    end
    
    if(nargin<5)
        crop = 0; % use crop=0 only if significant rotation
    end
    
    translation = myField(2,:);
    if(not(sum(sum(find(translation)))~=0))
        translation = myField(1,:).*myDataInfo.Spacing';
    end
    myField(1:2,:) = 0;
    
    rotation = myField(3:5,:);
    isrotation = (sum(sum(find(rotation)))~=0);

    if(crop)
        if(isrotation)
            if(strcmp(myDataInfo.Type,'deformation_field')) % vector field
                temp = [];
                for n=1:size(myData,1)
                    temp(n,:,:,:) = rigid_deformation(squeeze(myData(n,:,:,:)),myField,myDataInfo.Spacing,myDataInfo.ImagePositionPatient-translation');                    
                end
                myData = temp;
                clear temp
            else % image
                myData = rigid_deformation(myData,myField,myDataInfo.Spacing,myDataInfo.ImagePositionPatient-translation');
            end
        end
        myDataInfo.ImagePositionPatient = myDataInfo.ImagePositionPatient - translation';
    else
        if(isrotation)
            if(strcmp(myDataInfo.Type,'deformation_field')) % vector field
                temp = [];
                for n=1:size(myData,1)
                    [temp(n,:,:,:),tmp_iso] = rigid_deformation(squeeze(myData(n,:,:,:)),myField,myDataInfo.Spacing,myDataInfo.ImagePositionPatient-translation');                    
                end
                myData = temp;
                myDataInfo.ImagePositionPatient = tmp_iso;
                clear temp
            else % image
                [myData,myDataInfo.ImagePositionPatient] = rigid_deformation(myData,myField,myDataInfo.Spacing,myDataInfo.ImagePositionPatient-translation');
            end
        end
    end
    
    im_dest = check_existing_names(im_dest,handles.mydata.name);
    handles.mydata.name{length(handles.mydata.name)+1} = im_dest;
    handles.mydata.data{length(handles.mydata.data)+1} = myData;
    handles.mydata.info{length(handles.mydata.info)+1} = myDataInfo;

catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
