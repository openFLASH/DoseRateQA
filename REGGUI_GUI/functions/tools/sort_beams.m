function [plan,order,info,gantry_angles,table_angles] = sort_beams(plan,sorting_type,info)

for f=1:length(plan)
    gantry_angles(f)=plan{f}.gantry_angle;
end
for f=1:length(plan)
    table_angles(f)=plan{f}.table_angle;
end

switch sorting_type
    
    case 'POne'
        
        % Correct angles bigger than 270
        gantry_angles(gantry_angles>270) = gantry_angles(gantry_angles>270)-360;
        for f=1:length(plan)
            if(plan{f}.gantry_angle>270)
                plan{f}.gantry_angle = plan{f}.gantry_angle-360;
            end
        end
        
        % Sort per table angle
        t = sort(unique(table_angles));
        descend = 0;
        order = [];
        for i=1:length(t)
            g = gantry_angles;
            if descend
                g(table_angles~=t(i)) = -Inf;
                [g,order_t] = sort(g,'descend');
                order_t = order_t(1:sum(not(isinf(g))));
            else
                g(table_angles~=t(i)) = +Inf;
                [g,order_t] = sort(g);
                order_t = order_t(1:sum(not(isinf(g))));
            end
            descend = not(descend);
            order = [order,order_t];
        end
        
    otherwise % sort according to beam angle
        
        % Correct negative angles
        gantry_angles(gantry_angles<0) = gantry_angles(gantry_angles<0)+360;
        for f=1:length(plan)
            if(plan{f}.gantry_angle<0)
                plan{f}.gantry_angle = plan{f}.gantry_angle+360;
            end
        end
        
        [~,order] = sort(gantry_angles);
        
end

plan = plan(order);
gantry_angles = gantry_angles(order);
table_angles = table_angles(order);

if(nargin>2)
    seq = info.OriginalHeader.IonBeamSequence;
    info.OriginalHeader.IonBeamSequence = struct;
    for i=1:length(order)
        info.OriginalHeader.IonBeamSequence.(['Item_',num2str(i)]) = seq.(['Item_',num2str(order(i))]);
    end
else
    info = [];
end
