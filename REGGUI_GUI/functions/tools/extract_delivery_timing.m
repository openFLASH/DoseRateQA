function t = extract_delivery_timing(plan,max_energy_switching_time,max_burst_switching_time)

if(nargin<2)
    max_energy_switching_time = 0;
end
if(nargin<3)
    max_burst_switching_time = 0;
end

for n = 1:length(plan)
    % check whether time information is present
    if (not(isfield(plan{n}.spots(1),'time')) || not(isfield(plan{n}.spots(1),'duration')))
        t{n} = [];
        continue
    end
    % check whether there are less spot_id than weights: this is an indcation that 'duration' was reconstructed from weight and not from reading logs.
    if not(isfield(plan{n}.spots(1), 'spot_id')) || (length(plan{n}.spots(1).spot_id) < length(plan{n}.spots(1).weight)-1)
        t{n} = [];
        continue
    end

    % Initialize timing summary
    t{n}.nb_spots = 0;
    t{n}.nb_layers = 0;
    t{n}.nb_spot_deliveries = 0;
    t{n}.nb_bursts= 0;
    t{n}.nb_energy_switch = 0;
    t{n}.total_time = 0;
    t{n}.beam_delivery_time = [];
    t{n}.spot_delivery = [];
    t{n}.scanning = [];
    t{n}.tuning = [];
    t{n}.burst_switching = [];
    t{n}.energy_switching = [];
    t{n}.delivered_MU = [0,0];

    t{n}.beam_delivery_time(end+1) = plan{n}.spots(end).time(end);
    t{n}.total_time = t{n}.total_time + plan{n}.spots(end).time(end);

    for i=1:length(plan{n}.spots)

        if(isfield(plan{n}.spots(i),'spot_id'))
            t{n}.nb_spots = t{n}.nb_spots + length(unique(plan{n}.spots(i).spot_id));
            t{n}.nb_spot_deliveries = t{n}.nb_spot_deliveries + length(plan{n}.spots(i).spot_id);
        else
            t{n}.nb_spots = t{n}.nb_spots + length(plan{n}.spots(i).weight);
            t{n}.nb_spot_deliveries = t{n}.nb_spots;
        end
        t{n}.nb_layers = t{n}.nb_layers + 1;
        t{n}.nb_bursts = t{n}.nb_bursts + 1;

        if(i>1)
            t{n}.energy_switching(end+1,:) = [plan{n}.spots(i).time(1) - plan{n}.spots(i-1).time(end) , plan{n}.spots(i).energy-plan{n}.spots(i-1).energy];
            t{n}.nb_energy_switch = t{n}.nb_energy_switch + 1;
        end

        burst_id = 0;
        nb_spots_in_previous_bursts = 0;
        for j=1:length(plan{n}.spots(i).weight)-1
            if(isfield(plan{n}.spots(i),'timeTuning')) % tuning time available (tuning spot was merged with the rest)
                if(j==1)
                    t{n}.tuning(end+1) = plan{n}.spots(i).timeTuning;
                end
            elseif(isfield(plan{n}.spots(i),'tuning'))
                if(plan{n}.spots(i).tuning(j)==0 && j>1) % first non-tuning spot
                    t{n}.tuning(end+1) = plan{n}.spots(i).time(j) - plan{n}.spots(i).time(j-1);
                elseif(plan{n}.spots(i).tuning(j)>0) % tuning spots are removed from further analysis
                    plan{n}.spots(i).spot_id(j) = -1;
                end
            elseif(j==1) % no tuning information available
                t{n}.tuning(end+1) = NaN;
            end
            new_burst = 1;

            if(not(isfield(plan{n}.spots(i),'spot_id')))
                new_burst = 0;
            elseif(length(find(plan{n}.spots(i).spot_id(j) == plan{n}.spots(i).spot_id(1:j-1)))<=burst_id)
                new_burst = 0;
            end
            if(new_burst)
                burst_id = burst_id + 1;
                nb_spots_in_burst = j - nb_spots_in_previous_bursts;
                nb_spots_in_previous_bursts = j;
                t{n}.burst_switching(end+1,:) = [plan{n}.spots(i).time(j) - plan{n}.spots(i).time(j-1), nb_spots_in_burst];
                t{n}.nb_bursts = t{n}.nb_bursts + 1;
            else
                dxy = sqrt(sum((plan{n}.spots(i).xy(j+1)-plan{n}.spots(i).xy(j)).^2)) + eps;
                if(dxy>1)
                    t{n}.scanning(end+1,:) = [(plan{n}.spots(i).time(j+1) - (plan{n}.spots(i).time(j)+plan{n}.spots(i).duration(j))), dxy ,plan{n}.spots(i).energy];
                end
            end
        end

        for j=1:length(plan{n}.spots(i).weight)
            t{n}.spot_delivery(end+1,:) = [plan{n}.spots(i).duration(j),plan{n}.spots(i).weight(j),plan{n}.spots(i).energy];
            t{n}.delivered_MU(end+1,:) = [plan{n}.spots(i).time(j),t{n}.delivered_MU(end,2)+plan{n}.spots(i).weight(j)];
        end
    end

    if(max_burst_switching_time>0 && not(isempty(t{n}.burst_switching)))
        t{n}.burst_switching(t{n}.burst_switching(:,1)>max_burst_switching_time,1) = max_burst_switching_time;
    end
    if(max_energy_switching_time>0 && not(isempty(t{n}.energy_switching)))
        t{n}.energy_switching(t{n}.energy_switching(:,1)>max_energy_switching_time,1) = max_energy_switching_time;
    end

end
