%% Addition
% Compute the sum of input data stored in handles
%
%% Syntax
% |handles = Addition(data_list,result,handles)|
%
%
%% Description
% |handles = Addition(data_list,result,handles)| computes the sum |im1 + im2|
%
%
%% Input arguments
% |data_list| - _CELL_ -  List of names of the data in |handles.images|, |handles.fields| or |handles.mydata| or |handles.plans|
%
% |result| - _STRING_ -  Name of the output in |handles.images|, |handles.fields|, |handles.mydata| or |handles.plans|, depending on location of input data
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure (where XXX is either 'images', 'fields' or "mydata"):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the ith image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the ith image
% * |handles.XXX.info{i}| - _STRUCTURE_ DICOM Information about the ith image
%
%
%% Output arguments
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the updated data. The following data will be updated (where XXX is either 'images', 'fields' or "mydata"; depending on where the input data is located):
%
% * |handles.XXX.name{i}| - _STRING_ - Name of the resulting image
% * |handles.XXX.data{i}| - _SCALAR MATRIX_ - |data(x,y,z)| resulting intensity at voxel (x,y,z)
% * |handles.XXX.info{i}| - _STRUCTURE_ - Meta information from the DICOM file. Created with Create_default_info.m
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = Addition(data_list,result,handles)

if(length(data_list)<2 || not(iscell(data_list)))
    disp('Wrong number of input data.')
    return
end

[data,myInfo1,type] = Get_reggui_data(handles,data_list{1});

for i=2:length(data_list)
    [dataN,myInfo2,typeN] = Get_reggui_data(handles,data_list{i});
    if(strcmp(type,'images') && strcmp(typeN,'images'))
        try
            data = data + dataN;
        catch
            error('Error : data not found or uncorrect size!')
        end        
    elseif(strcmp(type,'fields') && strcmp(typeN,'fields'))
        if(strcmp(myInfo1.Type,'rigid_transform') && strcmp(myInfo2.Type,'rigid_transform'))
            try
                data = data + dataN;
                data(3:5,:) = data(3:5,:)*dataN(3:5,:);
            catch
                error('Error : data not found or uncorrect size!')
            end
        else
            if(strcmp(myInfo1.Type,'rigid_transform') && not(strcmp(myInfo2.Type,'rigid_transform')))
                data = rigid_trans_to_def_field(data,handles.size',handles.spacing,handles.origin);
            end
            if(strcmp(myInfo2.Type,'rigid_transform') && not(strcmp(myInfo1.Type,'rigid_transform')))
                dataN = rigid_trans_to_def_field(dataN,handles.size',handles.spacing,handles.origin);
            end
            try
                data = data + dataN;
            catch
                error('Error : data not found or uncorrect size!')
            end
        end        
    elseif(strcmp(type,'mydata') && strcmp(typeN,'mydata'))
        if(strcmp(myInfo1.Type,'rigid_transform') && strcmp(myInfo2.Type,'rigid_transform'))
            try
                data = data + dataN;
                data(3:5,:) = data(3:5,:)*dataN(3:5,:);
            catch
                error('Error : data not found or uncorrect size!')
            end
        else
            if(strcmp(myInfo1.Type,'rigid_transform') && not(strcmp(myInfo2.Type,'rigid_transform')))
                data = rigid_trans_to_def_field(data,[size(dataN,2) size(dataN,3) size(dataN,4)],handles.spacing,handles.origin);
            end
            if(strcmp(myInfo2.Type,'rigid_transform') && not(strcmp(myInfo1.Type,'rigid_transform')))
                dataN = rigid_trans_to_def_field(dataN,[size(data,2) size(data,3) size(data,4)],handles.spacing,handles.origin);
            end
            try
                data = data + dataN;
            catch
                error('Error : data not found or uncorrect size!')
            end
        end        
    elseif(strcmp(type,'plans') && strcmp(typeN,'plans'))        
        for fN=1:length(dataN)
            add_beam = 1;
            for f=1:length(data)
                if(min(data{f}.isocenter==dataN{fN}.isocenter)>0 && data{f}.gantry_angle==dataN{fN}.gantry_angle && data{f}.table_angle==dataN{fN}.table_angle)
                    add_beam = 0;
                    for nN=1:length(dataN{fN}.spots)
                        add_layer = 1;
                        for n=1:length(data{f}.spots)
                            if(data{f}.spots(n).energy == dataN{fN}.spots(nN).energy)
                                add_layer = 0;
                                for s=1:length(dataN{fN}.spots(nN).weight)
                                    index = find( (data{f}.spots(n).xy(:,1)==dataN{fN}.spots(nN).xy(s,1)) & (data{f}.spots(n).xy(:,2)==dataN{fN}.spots(nN).xy(s,2)) );
                                    if(isempty(index))
                                        data{f}.spots(n).xy(end+1,:) = dataN{fN}.spots(nN).xy(s,:);
                                        data{f}.spots(n).weight(end+1) = dataN{fN}.spots(nN).weight(s);
                                    else
                                        data{f}.spots(n).weight(index(1),:) = data{f}.spots(n).weight(index(1),:) + dataN{fN}.spots(nN).weight(s);
                                    end
                                end
                                break
                            end                            
                        end
                        if(add_layer)
                            data{f}.spots(end+1) =  dataN{fN}.spots(nN);
                        end
                    end
                    data{f}.BeamMeterset = data{f}.BeamMeterset + dataN{fN}.BeamMeterset;
                    data{f}.final_weight = data{f}.final_weight + dataN{fN}.final_weight;
                    break
                end                
            end
            if(add_beam)
                data{end+1} = dataN{fN};
            end
        end       
    end
end

% save result in handles
handles = Set_reggui_data(handles,result,single(data),myInfo1,type,0);
