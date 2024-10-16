function plan_filtered = remove_low_MU_spots(plan,MU_threshold)

plan_filtered = cell(0);

for f=1:length(plan)
    spots = [];
    for layer=1:length(plan{f}.spots)
        indices = find(plan{f}.spots(layer).weight>MU_threshold);
        if(not(isempty(indices)))
            spots(end+1).energy = plan{f}.spots(layer).energy;            
            fn = fieldnames(plan{f}.spots(layer));
            for i=1:length(fn)
                if(size(plan{f}.spots(layer).(fn{i}))==length(plan{f}.spots(layer).weight))
                    spots(end).(fn{i}) = plan{f}.spots(layer).(fn{i})(indices,:); 
                else
                    spots(end).(fn{i}) = plan{f}.spots(layer).(fn{i});
                end
            end            
        end
    end
    if(not(isempty(spots)))
        plan_filtered{end+1} = plan{f};
        plan_filtered{end}.spots = spots;
    end
end
