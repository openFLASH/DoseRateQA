function [handles,legend_txt] = patient_file_update_txt(handles,reset_selected_line)

color_grey = '#808080';
color_ct = '#2222FF';
color_plan = '#228822';
color_field = '#DD2222';
color_struct = '#BB8800';
color_dose = '#AA00AA';
color_pet = '#00AAAA';

legend_txt = {'';['<html>Legend : <font color="',color_ct,'">CT</font> ; <font color="',color_pet,'">PET</font> ; <font color="',color_dose,'">RT Dose</font> ; <font color="',color_struct,'">RT contour</font> ; <font color="',color_plan,'">RT plan</font> ; <font color="',color_field,'">Vector field</font></html>'];['<html><font color="E0E0FF">Legend :</font> <i>Date</i> ; <font color="#808080">Serie UID</font> ; <font color="#808080"><b>Reference serie UID</b></font> ; <u>4D serie</u> </html>'];' ';' '};

if(isfield(handles,'dicom_sorting_option'))
    sorting = handles.dicom_sorting_option;
else
    sorting = get(handles.sort_by_time,'Value');
end

switch sorting
    case 1
        if(nargin<2)
            reset_selected_line = 1;
        end
        % sort list according to study time and modality
        study_order = handles.list_of_data(:,8);
        [~,study_order] = sort(study_order);
        handles.list_of_data = handles.list_of_data(study_order,:);
        study_order = str2double(handles.list_of_data(:,2));
        [~,study_order] = sort(study_order);
        handles.list_of_data = handles.list_of_data(study_order,:);
        % get links between data
        selected_4DID = 0;
        selected_RefID = 'no_id';
        selected_SOPID = 'no_id';
        if(reset_selected_line)
            set(handles.timeline,'Value',1);
        else
            selected_line = get(handles.timeline,'Value')+1;
            if(handles.timeline_indices(selected_line))
                selected_4DID = handles.list_of_data{handles.timeline_indices(selected_line(1)),13};
                selected_RefID = handles.list_of_data{handles.timeline_indices(selected_line(1)),12};
                selected_SOPID = handles.list_of_data{handles.timeline_indices(selected_line(1)),16};
                for i=2:length(selected_line)
                    if(not(selected_4DID==handles.list_of_data{handles.timeline_indices(selected_line(i)),13}))
                        selected_4DID = 0;
                        selected_RefID = 'no_id';
                        selected_SOPID = 'no_id';
                    end
                end
            else
                set(handles.timeline,'Value',1);
            end
        end
        handles.timeline_string = cell(0);
        handles.timeline_indices = [];
        index = 1;
        prev_date = '00000000';
        for i=1:size(handles.list_of_data,1)
            if(sum(handles.list_of_data{i,2}(1:8)~=prev_date))
                handles.timeline_string{index} = '';index = index+1;
                prev_date = handles.list_of_data{i,2}(1:8);
                handles.timeline_string{index} = italic([datestr(datenum(prev_date,'yyyymmdd')),' : ']);index = index+1;
            end
            current_RefID = handles.list_of_data{i,12};
            current_SOPID = handles.list_of_data{i,16};
            if(strcmp(current_RefID,selected_RefID) || strcmp(current_SOPID,selected_RefID) || strcmp(current_RefID,selected_SOPID))
                current_RefID = ['<b>',current_RefID,'</b>'];
            end
            switch handles.list_of_data{i,8}
                case 'CT'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_ct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_ct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case 'PT'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_pet,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_pet,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case 'REG'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_field,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_field,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case {'RTDOSE','RTDOSERATE'}
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_dose,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_dose,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>'];index = index+1;
                    end
                case 'RTSTRUCT'
                    handles.timeline_string{index} = ['<html><font color="',color_struct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>'];index = index+1;
                case 'RTPLAN'
                    handles.timeline_string{index} = ['<html><font color="',color_plan,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>'];index = index+1;
                otherwise
                    handles.timeline_string{index} = ['<html><font color="black"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
            end
            handles.timeline_indices(index) = i;
        end
        set(handles.timeline,'String',handles.timeline_string);
        set(handles.dir_name,'String',handles.patientDir);
        if(not(isempty(handles.list_of_data)))
            set(handles.patient_name_id,'String',[handles.list_of_data{1,7},' (',handles.list_of_data{1,6},')']);
            if(isfield(handles,'workflow_data'))
                handles.workflow_data.patientID = handles.list_of_data{1,6};
            end
        end
        cd(handles.currentDir)
    case 0
        if(nargin<2)
            reset_selected_line = 1;
        end
        % sort list according to study time and modality
        study_order = handles.list_of_data(:,8);
        [~,study_order] = sort(study_order);
        handles.list_of_data = handles.list_of_data(study_order,:);
        study_order = str2double(handles.list_of_data(:,10));
        [~,study_order] = sort(study_order);
        handles.list_of_data = handles.list_of_data(study_order,:);
        % get links between data
        selected_4DID = 0;
        selected_RefID = 'no_id';
        selected_SOPID = 'no_id';
        if(reset_selected_line)
            set(handles.timeline,'Value',1);
        else
            selected_line = get(handles.timeline,'Value')+1;
            if(handles.timeline_indices(selected_line))
                selected_4DID = handles.list_of_data{handles.timeline_indices(selected_line(1)),13};
                selected_RefID = handles.list_of_data{handles.timeline_indices(selected_line(1)),12};
                selected_SOPID = handles.list_of_data{handles.timeline_indices(selected_line(1)),16};
                for i=2:length(selected_line)
                    if(not(selected_4DID==handles.list_of_data{handles.timeline_indices(selected_line(i)),13}))
                        selected_4DID = 0;
                        selected_RefID = 'no_id';
                        selected_SOPID = 'no_id';
                    end
                end
            else
                set(handles.timeline,'Value',1);
            end
        end
        handles.timeline_string = cell(0);
        handles.timeline_indices = [];
        index = 1;
        prev_date = '00000000';
        order_by_day = [];
        for i=1:size(handles.list_of_data,1)
            if(not(sum(i==order_by_day)))
                if(sum(strcmp(handles.list_of_data{i,8},{'CT','PT'})))
                    order_by_day = [order_by_day i];
                    current_RefID = handles.list_of_data{i,12};
                    current_SOPID = handles.list_of_data{i,16};
                    for j=1:size(handles.list_of_data,1)
                        if(strcmp(current_RefID,handles.list_of_data{j,12}) && not(sum(strcmp(handles.list_of_data{j,8},{'CT','PT'}))))
                            order_by_day = [order_by_day j];
                        end
                    end
                else
                    order_by_day = [order_by_day i];
                end
            end
        end
        for i=order_by_day
            if(isempty(handles.list_of_data{i,10}))
                handles.list_of_data{i,10} = '        ';
            end
            if(sum(strcmp(handles.list_of_data{i,8},{'CT','PT'})) && sum(handles.list_of_data{i,10}(1:8)~=prev_date))
                handles.timeline_string{index} = '';index = index+1;
                prev_date = handles.list_of_data{i,10}(1:8);
                handles.timeline_string{index} = italic([datestr(datenum(prev_date,'yyyymmdd')),' : ']);index = index+1;
            end
            current_RefID = handles.list_of_data{i,12};
            current_SOPID = handles.list_of_data{i,16};
            if(strcmp(current_RefID,selected_RefID) || strcmp(current_SOPID,selected_RefID) || strcmp(current_RefID,selected_SOPID))
                current_RefID = ['<b>',current_RefID,'</b>'];
            end
            switch handles.list_of_data{i,8}
                case 'CT'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_ct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_ct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case 'PT'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_pet,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_pet,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case 'REG'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_field,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_field,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case {'RTDOSE','RTDOSERATE'}
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_dose,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_dose,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>'];index = index+1;
                    end
                case 'RTSTRUCT'
                    handles.timeline_string{index} = ['<html><font color="',color_struct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>'];index = index+1;
                case 'RTPLAN'
                    handles.timeline_string{index} = ['<html><font color="',color_plan,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                otherwise
                    handles.timeline_string{index} = ['<html><font color="black"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
            end
            handles.timeline_indices(index) = i;
        end
        set(handles.timeline,'String',handles.timeline_string);
        set(handles.dir_name,'String',handles.patientDir);
        if(not(isempty(handles.list_of_data)))
            set(handles.patient_name_id,'String',[handles.list_of_data{1,7},' (',handles.list_of_data{1,6},')']);
            if(isfield(handles,'workflow_data'))
                handles.workflow_data.patientID = handles.list_of_data{1,6};
            end
        end
        cd(handles.currentDir)
    otherwise
        if(nargin<2)
            reset_selected_line = 1;
        end
        % sort list according to filename, dirname and modality
        study_order = handles.list_of_data(:,5);
        [~,study_order] = sort(study_order);
        handles.list_of_data = handles.list_of_data(study_order,:);
        study_order = str2double(handles.list_of_data(:,4));
        [~,study_order] = sort(study_order);
        handles.list_of_data = handles.list_of_data(study_order,:);
        study_order = str2double(handles.list_of_data(:,8));
        [~,study_order] = sort(study_order);
        handles.list_of_data = handles.list_of_data(study_order,:);
        % get links between data
        selected_4DID = 0;
        selected_RefID = 'no_id';
        selected_SOPID = 'no_id';
        if(reset_selected_line)
            set(handles.timeline,'Value',1);
        else
            selected_line = get(handles.timeline,'Value')+1;
            if(handles.timeline_indices(selected_line))
                selected_4DID = handles.list_of_data{handles.timeline_indices(selected_line(1)),13};
                selected_RefID = handles.list_of_data{handles.timeline_indices(selected_line(1)),12};
                selected_SOPID = handles.list_of_data{handles.timeline_indices(selected_line(1)),16};
                for i=2:length(selected_line)
                    if(not(selected_4DID==handles.list_of_data{handles.timeline_indices(selected_line(i)),13}))
                        selected_4DID = 0;
                        selected_RefID = 'no_id';
                        selected_SOPID = 'no_id';
                    end
                end
            else
                set(handles.timeline,'Value',1);
            end
        end
        handles.timeline_string = cell(0);
        handles.timeline_indices = [];
        index = 1;
        for i=1:size(handles.list_of_data,1)
            current_RefID = handles.list_of_data{i,12};
            current_SOPID = handles.list_of_data{i,16};
            if(strcmp(current_RefID,selected_RefID) || strcmp(current_SOPID,selected_RefID) || strcmp(current_RefID,selected_SOPID))
                current_RefID = ['<b>',current_RefID,'</b>'];
            end
            switch handles.list_of_data{i,8}
                case 'CT'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_ct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_ct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case 'PT'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_pet,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_pet,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,4},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case 'REG'
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_field,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_field,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                    end
                case {'RTDOSE','RTDOSERATE'}
                    if((selected_4DID>0) && (handles.list_of_data{i,13}==selected_4DID))
                        handles.timeline_string{index} = underline(['<html><font color="',color_dose,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>']);index = index+1;
                    else
                        handles.timeline_string{index} = ['<html><font color="',color_dose,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>'];index = index+1;
                    end
                case 'RTSTRUCT'
                    handles.timeline_string{index} = ['<html><font color="',color_struct,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font> ',handles.list_of_data{i,15},'</html>'];index = index+1;
                case 'RTPLAN'
                    handles.timeline_string{index} = ['<html><font color="',color_plan,'"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
                otherwise
                    handles.timeline_string{index} = ['<html><font color="black"><b>',handles.list_of_data{i,1},' - </b>  ',handles.list_of_data{i,5},'</font> <font color="',color_grey,'">( ',current_RefID,' )</font></html>'];index = index+1;
            end
            handles.timeline_indices(index) = i;
        end
        set(handles.timeline,'String',handles.timeline_string);
        set(handles.dir_name,'String',handles.patientDir);
        if(not(isempty(handles.list_of_data)))
            set(handles.patient_name_id,'String',[handles.list_of_data{1,7},' (',handles.list_of_data{1,6},')']);
            if(isfield(handles,'workflow_data'))
                handles.workflow_data.patientID = handles.list_of_data{1,6};
            end
        end
        cd(handles.currentDir)
end
end

function str = bold(str)
if(strcmp(str(1:6),'<html>')&&strcmp(str(end-6:end),'</html>'))
    str = ['<html><b>',str(7:end-7),'</b></html>'];
else
    str = ['<html><b>',str,'</b></html>'];
end
end

function str = italic(str)
if(strcmp(str(1:6),'<html>')&&strcmp(str(end-6:end),'</html>'))
    str = ['<html><i>',str(7:end-7),'</i></html>'];
else
    str = ['<html><i>',str,'</i></html>'];
end
end

function str = underline(str)
if(strcmp(str(1:6),'<html>')&&strcmp(str(end-6:end),'</html>'))
    str = ['<html><u>',str(7:end-7),'</u></html>'];
else
    str = ['<html><u>',str,'</u></html>'];
end
end
