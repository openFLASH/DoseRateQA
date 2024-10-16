%% Check_var
% The string |myIn| contains a mathematical expression using image names. The string is parsed to find image name defined in |handles.XXX.names| (where XXX is |images|, |mydata|, |fields|, |plans| or |indicators|) *surrounded by SPACE character* (i.e. [' ' name ' ']). If a match is found, the name contained in |myIn| is replaced by a string representing the matlab syntax to use to make reference to that image in computation (e.g. |handle.images.data{i}|). The resulting |newIn| becomes a valid Matlab comand that can be executed to make the mathematical operation on the images.
%
% If |handles.roi_mode=1|, then in addition, the image name is replaced by the Matlab data of the image multiplied by the mask, so that the computation is done only on the region of interest: |handles.images.data{i}.*handles.images.data{handles.current_roi}|.
%
% For example: |newIn  = Check_var('imag1 + image2',handles)| results in: 
% |newIn  = 'handles.images.data{2} + handles.mydata.data{6}'}
%
%% Syntax
% |newIn  = Check_var(myIn,handles)|
%
%
%% Description
% |newIn  = Check_var(myIn,handles)| describes the function
%
%
%% Input arguments
% |myIn| - _STRING_ -  Mathematical expression including Name of images contained in one of the data structure of |handles|
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed.
%
% * |handles.roi_mode| _SCALAR_ - If not null, the computation is done only for the field contained inside the ROI defined by |handles.images.data{handles.current_roi}|.0= The computation is done for the whole image.
%
%
%% Output arguments
%
% |newIn| - _STRING_ - The same mathematical expression with the image name replaced by the full sMatlab syntax to get access to the data contained in |handle|
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function newIn  = Check_var(myIn,handles)

newIn = [' ' myIn ' '];
i = 1;
use_roi_mode = 0;

if(handles.roi_mode == 1)
    try
        if(strcmp(handles.images.name{handles.current_roi{2}},handles.current_roi{1}))
            use_roi_mode = handles.current_roi{2};
        else
            handles.roi_mode = 0;
            handles.current_roi = cell(0);
            if(isfield(handles,'On_region_of_interest'))
                set(handles.On_region_of_interest,'Value',handles.roi_mode);
                disp('ROI mode desactivated')
            end            
        end
    catch
        handles.roi_mode = 0;
        handles.current_roi = cell(0);
        if(isfield(handles,'On_region_of_interest'))
            set(handles.On_region_of_interest,'Value',handles.roi_mode);
            disp('ROI mode desactivated')
        end        
    end
end

if(use_roi_mode>1) % Execution on ROI...
    while i<=length(handles.images.name)
        index_equal = strfind(newIn,'=');
        if(length(index_equal)>1)
            if(index_equal(2)==index_equal(1))
                index_equal = -1;
            end
            index_equal = index_equal(1);
        elseif(isempty(index_equal))
            index_equal = -1;
        end
        index = strfind(newIn,[' ' handles.images.name{i} ' ']);
        if( ~isempty(index) )
            if(index>index_equal)
                disp([handles.images.name{i} ' recognized as ' 'handles.images.data{' num2str(i) '}  (will be multiplied and divided by region_of_interest)']);
                newIn = [newIn(1:index(1)-1) 'handles.images.data{' num2str(i) '}.*handles.images.data{' num2str(use_roi_mode) '}./(handles.images.data{' num2str(use_roi_mode) '}+eps)' newIn(index(1)+length(handles.images.name{i})+2:end) ];
                disp(newIn)
            else
                disp([handles.images.name{i} ' recognized as ' 'handles.images.data{' num2str(i) '}']);
                newIn = [newIn(1:index(1)-1) 'handles.images.data{' num2str(i) '}' newIn(index(1)+length(handles.images.name{i})+2:end) ];
            end
        else
            i = i+1;
        end
    end
    i = 1;
    while i<=length(handles.fields.name)
        index_equal = strfind(newIn,'=');
        if(length(index_equal)>1)
            if(index_equal(2)==index_equal(1))
                index_equal = -1;
            end
            index_equal = index_equal(1);
        elseif(isempty(index_equal))
            index_equal = -1;
        end
        index = strfind(newIn,[' ' handles.fields.name{i} ' ']);
        if( ~isempty(index) )
            if(index>index_equal)
                disp([handles.fields.name{i} ' recognized as ' 'handles.fields.data{' num2str(i) '}  (will be multiplied and divided by region_of_interest)']);
                newIn = ['roi_vector=zeros(size(handles.fields.data{' num2str(i) '}));for vector_dim=1:size(roi_vector,1);roi_vector(vector_dim,:,:,:)=handles.images.data{' num2str(use_roi_mode) '};end; ' newIn(1:index(1)-1) 'handles.fields.data{' num2str(i) '}.*roi_vector./(roi_vector+eps)' newIn(index(1)+length(handles.fields.name{i})+2:end) ];
                disp(newIn)
            else
                disp([handles.fields.name{i} ' recognized as ' 'handles.fields.data{' num2str(i) '}']);
                newIn = [newIn(1:index(1)-1) 'handles.fields.data{' num2str(i) '}' newIn(index(1)+length(handles.fields.name{i})+2:end) ];
            end
        else
            i = i+1;
        end
    end
else % Normal execution...
    while i<=length(handles.images.name)
        index = strfind(newIn,[' ' handles.images.name{i} ' ']);
        if( ~isempty(index) )
            disp([handles.images.name{i} ' recognized as ' 'handles.images.data{' num2str(i) '}']);
            newIn = [newIn(1:index(1)-1) 'handles.images.data{' num2str(i) '}' newIn(index(1)+length(handles.images.name{i})+2:end) ];
        else
            i = i+1;
        end
    end
    i = 1;
    while i<=length(handles.fields.name)
        index = strfind(newIn,[' ' handles.fields.name{i} ' ']);
        if( ~isempty(index) )
            disp([handles.fields.name{i} ' recognized as ' 'handles.fields.data{' num2str(i) '}']);
            newIn = [newIn(1:index(1)-1) 'handles.fields.data{' num2str(i) '}' newIn(index(1)+length(handles.fields.name{i})+2:end) ];
        else
            i = i+1;
        end
    end
end
i = 1;
while i<=length(handles.mydata.name)
    index = strfind(newIn,[' ' handles.mydata.name{i} ' ']);
    if( ~isempty(index) )
        disp([handles.mydata.name{i} ' recognized as ' 'handles.mydata.data{' num2str(i) '}']);
        newIn = [newIn(1:index(1)-1) 'handles.mydata.data{' num2str(i) '}' newIn(index(1)+length(handles.mydata.name{i})+2:end) ];
    else
        i = i+1;
    end
end
i = 1;
while i<=length(handles.plans.name)
    index = strfind(newIn,[' ' handles.plans.name{i} ' ']);
    if( ~isempty(index) )
        disp([handles.plans.name{i} ' recognized as ' 'handles.plans.data{' num2str(i) '}']);
        newIn = [newIn(1:index(1)-1) 'handles.plans.data{' num2str(i) '}' newIn(index(1)+length(handles.plans.name{i})+2:end) ];
    else
        i = i+1;
    end
end
i = 1;
while i<=length(handles.indicators.name)
    index = strfind(newIn,[' ' handles.indicators.name{i} ' ']);
    if( ~isempty(index) )
        disp([handles.indicators.name{i} ' recognized as ' 'handles.indicators.data{' num2str(i) '}']);
        newIn = [newIn(1:index(1)-1) 'handles.indicators.data{' num2str(i) '}' newIn(index(1)+length(handles.indicators.name{i})+2:end) ];
    else
        i = i+1;
    end
end
