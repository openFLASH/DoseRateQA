function [handles,com_motion] = Propagate_to_4D(handles,def_field_names,input_image_names,input_target_names)

if(nargin<4)
    input_target_names = {};
end

com_motion = {};

handles = Automatic(handles,1);

for n=1:length(input_image_names)
    for phase=1:length(def_field_names)
        handles = Deformation(input_image_names{n},def_field_names{phase},[input_image_names{n},'_def_',num2str(phase)],handles);
    end
end

if(not(isempty(input_target_names)))
    for n=1:length(input_target_names)
        [~,com_init,handles] = CenterOfMass(input_target_names{n},handles);
        com_motion{n} = NaN(length(def_field_names),3);
        for phase=1:length(def_field_names)
            handles = Deformation(input_target_names{n},def_field_names{phase},[input_target_names{n},'_def_',num2str(phase)],handles);
            [~,com] = CenterOfMass([input_target_names{n},'_def_',num2str(phase)],handles);
            com_motion{n}(phase,:) = com-com_init;
        end
    end
end
