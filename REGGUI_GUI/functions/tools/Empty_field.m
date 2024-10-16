%% Empty_field
% Create a new field that can be:
%
% * Either an empty field, i.e. all vectors are null with a scaling factor of zero
% * Or a field with random vectors (in magnitude and orientation) with Gaussian filtering to smooth the field and with the specified scaling factor
% * Or the tangent components to a sliding surface of a field (see function |compute_field_in_mask|) with random vectors (in magnitude and orientation) with Gaussian filtering to smooth the field and with the specified scaling factor
% * Or a radial field with random vector magnitude
% * In addition, the inverse diffeomorphic field cna be computed. The inverse field is stored in |handles.fields.name{i} = [|f_dest| '_inverse']|
%
%% Syntax
% |handles = Empty_field(f_dest,handles|
%
% |handles = Empty_field(f_dest,handles,input_params)|
%
% |handles = Empty_field(f_dest,handles,input_params,angle=_SCALAR_)|
%
% |handles = Empty_field(f_dest,handles,input_params,angle=_SCALAR_,sm)|
%
% |handles = Empty_field(f_dest,handles,input_params,angle=_SCALAR_sm,Org)|
%
% |handles = Empty_field(f_dest,handles,input_params,mask=_STRING_)|
%
%
%% Description
% |handles = Empty_field(f_dest,handles| Create a deformation field, with a scaling factor of 0, where all vectors are null. Do not compute the inverse field.
%
% |handles = Empty_field(f_dest,handles,input_params)| Create a deformation field with random vectors and the specified scaling factor.
%
% |handles = Empty_field(f_dest,handles,input_params,angle=_SCALAR_)| Create a radial deformation field originating from the centre of the image and with vector magnitude defined by |randAngleFun| (with parameter |sm=5|).
%
% |handles = Empty_field(f_dest,handles,input_params,angle=_SCALAR_,sm)| Create a radial deformation field originating from the centre of the image and with vector magnitude defined by |randAngleFun| (see |randAngleFun| for definition of |sm|).
%
% |handles = Empty_field(f_dest,handles,input_params,angle=_SCALAR_,sm,Org)| Create a radial deformation field originating from the coordinate |Org| and with vector magnitude defined by |randAngleFun| (with parameter |sm|).
%
% |handles = Empty_field(f_dest,handles,input_params,mask=_STRING_)| Create the tangent components to a sliding surface (defined by |mask|) of a field with random vectors (in magnitude and orientation)
%
%
%% Input arguments
% |f_dest| - _STRING_ - Name of the new field created in |handles.fields|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
%
% |input_params| - _SCALAR VECTOR_ -  Parameters defining the creation of the deformation fields
%
% * |input_params(1)| - _INTEGER_ - Scaling factor. The image size is reduced by a factor |sqrt(2)^input_params(1)| from the original size
% * |input_params(2)| - _INTEGER_ - 1 = Additionally compute the inverse diffeomorphic field. 0 = do not compute inverse diffeomorphic field
%
% |angle| - _STRING_ -  Name 
%
% |sm| - _STRING_ -  Name 
%
% |Org| - _SCALAR VECTRO_ -  |Org(x,y,z)| Coordinates (in pixel) of the centre of the radial deformation field. The origin of the coordinate system is at the centre of an image with size defined by |handles.size|.
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

function handles = Empty_field(f_dest,handles,input_params,angle,sm,Org)
use_mask = 0;
if nargin<4
    angle=0;
elseif ischar(angle)
    mask_name = angle;
    for i=1:length(handles.images.name)
        if(strcmp(handles.images.name{i},mask_name))
            myMask = handles.images.data{i};
        end
    end
    if(isempty(myMask))
        error('Error : mask image not found in the current list !')
    else
        use_mask = 1;
    end
    angle = 0;
end
if nargin<5
    sm=5;
end
if nargin<6
    Org = [0 0 0];
end
if(handles.size(1) && handles.size(2) && handles.size(3))
    if(nargin>2)
        if(handles.size(1)==1 || handles.size(2)==1 || handles.size(3)==1)
            error('Not yet implemented in 2D.')
        end
        myInfo = Create_default_info('deformation_field',handles);
        mySize = round([handles.size(1)/(2^(input_params(1)/2));handles.size(2)/(2^(input_params(1)/2));handles.size(3)/(2^(input_params(1)/2))]);
        myOrg = [Org(1)/(2^(input_params(1)/2));Org(2)/(2^(input_params(1)/2));Org(3)/(2^(input_params(1)/2))];
        mySize(find(mySize<1))=1;
        myInfo.Spacing = handles.spacing.*handles.size./mySize;
        if(angle)
            fun = randAngleFun(sm);
            x = linspace(myOrg(1)-mySize(1)/2,myOrg(1)+mySize(1)/2,mySize(1));
            y = linspace(myOrg(2)-mySize(2)/2,myOrg(2)+mySize(2)/2,mySize(2));
            z = linspace(myOrg(3)-mySize(3)/2,myOrg(3)+mySize(3)/2,mySize(3));
            [X,Y,Z] = meshgrid(x,y,z);
            [THETA,PHI] = cart2sph(X,Y,Z);
            fieldn = fun(THETA/pi*180,PHI/pi*180);
            %fieldn(floor(end/2):ceil(end/2),floor(end/2):ceil(end/2),floor(end/2):ceil(end/2)) = 0;
            field(2,:,:,:) = fieldn.*cos(THETA).*cos(PHI);
            field(1,:,:,:) = fieldn.*sin(THETA).*cos(PHI);
            field(3,:,:,:) = fieldn.*sin(PHI);
            field = single(field);
            clear fieldn;
        else
            field = single(rand(2+(handles.size(3)>1),mySize(1),mySize(2),mySize(3))-0.5)*(2^((input_params(1)+1)/4));
        end
        
        params = [((2^(input_params(1)/2))*0.2) ((2^(input_params(1)/2))*0.2)*5];
        inverse = 0;
        if(length(input_params)>1)
            inverse = input_params(2);
        end
        params(2) = max(params(2),5);
        if (~angle)
            field(1,:,:,:) = matitk('FGA',params,squeeze(field(1,:,:,:)));
            field(2,:,:,:) = matitk('FGA',params,squeeze(field(2,:,:,:)));
            field(3,:,:,:) = matitk('FGA',params,squeeze(field(3,:,:,:)));
        end
        
        if(inverse)
            N = ceil(2 + log2(max(max(max(sqrt(squeeze(sum(field.^2)))))))/2)+2;
            field = field*2^(-N);
            est_field = cell(0);
            
            for n=1:size(field,1)
                est_field{n} = squeeze(-field(n,:,:,:));  % For computing the inverse diffeomorphic field
            end
            for r=1:N
                for n = 1:length(est_field)
                    [new_field{n} new_cert] = linear_deformation(est_field{n}, '', est_field, []);
                    new_field{n} = new_field{n}+est_field{n};
                end
                est_field = new_field;
            end
            
            for n=1:size(field,1)
                est_field{n} = squeeze(field(n,:,:,:));  % For computing a diffeomorphic field
            end
            
            for n=1:size(field,1)
                field(n,:,:,:) = new_field{n};
            end
            
            myDataName = check_existing_names([f_dest,'_inverse'],handles.mydata.name);
            handles.mydata.name{length(handles.mydata.name)+1} = myDataName;
            handles.mydata.data{length(handles.mydata.data)+1} = field;
            handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
            handles = Data2field(myDataName,[f_dest,'_inverse'],handles);
            if(use_mask)
                handles.fields.data{length(handles.fields.data)} = compute_field_in_mask(handles.fields.data{length(handles.fields.data)},myMask);
            end
            handles = Remove_data(myDataName, handles);
            
            for r=1:N
                for n = 1:length(est_field)
                    [new_field{n} new_cert] = linear_deformation(est_field{n}, '', est_field, []);
                    new_field{n} = new_field{n}+est_field{n};
                end
                est_field = new_field;
            end
            for n=1:size(field,1)
                field(n,:,:,:) = est_field{n};
            end
        end
        myDataName = check_existing_names(f_dest,handles.mydata.name);
        handles.mydata.name{length(handles.mydata.name)+1} = myDataName;
        handles.mydata.data{length(handles.mydata.data)+1} = field;
        handles.mydata.info{length(handles.mydata.info)+1} = myInfo;
        handles = Data2field(myDataName,f_dest,handles);
        if(use_mask)
            handles.fields.data{length(handles.fields.data)} = compute_field_in_mask(handles.fields.data{length(handles.fields.data)},myMask);
        end
        handles = Remove_data(myDataName, handles);
        
    else
        fEmpty = zeros(2+(handles.size(3)>1),handles.size(1),handles.size(2),handles.size(3),'single');
        f_dest = check_existing_names(f_dest,handles.fields.name);
        handles.fields.name{length(handles.fields.name)+1} = f_dest;
        handles.fields.data{length(handles.fields.data)+1} = fEmpty;
        handles.fields.info{length(handles.fields.info)+1} = Create_default_info('deformation_field',handles);
    end
else
    error('Error : you have to load an image first (to set dimensions) !')
end
