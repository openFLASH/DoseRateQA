function burst_switch_index = find_burst_switchings(layer)

for i=1:length(layer.spot_tune_id)
    burst_index(i) = length(find(layer.spot_tune_id(1:i-1)==layer.spot_tune_id(i)));
end

bursts = unique(burst_index);
for i=1:length(bursts)
     burst_switch_index(i) = find(burst_index==bursts(i),1,'first');
end
