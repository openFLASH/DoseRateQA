%% aggregate_PBS_paintings
% Merge together the records from PBS spots with the same |spots(n).spot_id|.
% This assumes that the |spots(n).spot_id| are unique to the |spots(n).xy| position.
% Several spots could have the same |spots(n).spot_id| if they are located at the same |spots(n).xy| position.
% If this condition is not satified, then you must set |regenerateIDs = true| to regenrate the spot ID based on the spot position
%
% The order of occurence ofthe spots is preserved
%
% The computation is :
%  * |spots(n).weight| : the weight is the sum of the weight of all the spots
%  * |spots(n).duration| : the duration is the sum of the duration of all the spots
%  * |spots(n).xy| : the postiion is the average of the spot position, weighted by |spots(n).weight|
%
%% Syntax
% |myBeamData = aggregate_PBS_paintings(myBeamData)|
%
% |myBeamData = aggregate_PBS_paintings(myBeamData, aggregate_separate_layers)|
%
% |myBeamData = aggregate_PBS_paintings(myBeamData, aggregate_separate_layers , regenerateIDs)|
%
%
%% Description
% |myBeamData = aggregate_PBS_paintings(myBeamData, aggregate_separate_layers)| Description
%
%
%% Input arguments
% * myBeamData{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th LAYER of PBS spots of the f-th beam/field in first treatment plan
% * ----|spots(j).spot_id| - _SCALAR_ - Unique number for each spot
% * ----|spots(j).xy(s)| -_SCALR VECTOR_- |spots(j).xy(s)= [x,y]| the position of the s-th spot
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).time(s)| - _SCALAR_ - Time stamp (s) of the start  of the s-th spot in the j-th energy layer
% * ----|spots(j).duration(s)| - _SCALAR_ - Duration (s)  of the s-th spot in the j-th energy layer
% * ----|spots(j).charge(s)| - _SCALAR_ - Electric charge of the s-th spot in the j-th energy layer
%
% |aggregate_separate_layers| -_BOOL_- [OPTIONAL : default = 1] Aggregate layers of same energy
%
% |regenerateIDs|  -_BOOL_- [OPTIONAL : default = false] If TRUE, the provided |spots(j).spot_id| is ignored and a new ID is generated, based on the spot position
%
%% Output arguments
%
% * myBeamData{1,f}.spots(j)| - _STRUCTURE_ - Description of the j-th LAYER of PBS spots of the f-th beam/field in first treatment plan
% * ----|spots(j).spot_id| - _SCALAR_ - Unique number for each spot.
%                                       If |regenerateIDs=false|, then it is the provided ID
%                                       If |regenerateIDs=true|, then it is a new ID, based on the spot position
% * ----|spots(j).xy(s)| -_SCALR VECTOR_- |spots(j).xy(s)= [x,y]| the position of the s-th spot. This is the average of the spot position, weighted by |spots(n).weight|
% * ----|spots(j).energy| - _SCALAR_ - Energy (MeV) of the j-th energy layer
% * ----|spots(j).time(s)| - _SCALAR_ - Time stamp (s) of the start  of the s-th spot in the j-th energy layer. This is the minimum time of all the identical spots
% * ----|spots(j).duration(s)| - _SCALAR_ - Duration (s)  of the s-th spot in the j-th energy layer. This is the sum of the duration of all the spots
% * ----|spots(j).charge(s)| - _SCALAR_ - Electric charge of the s-th spot in the j-th energy layer
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function myBeamData = aggregate_PBS_paintings(myBeamData, aggregate_separate_layers , regenerateIDs)

if(nargin<2)
    aggregate_separate_layers = 1;
end
if(nargin < 3)
    regenerateIDs = false;
end

%If required, regenerate a new spotID, based on the spot position
%The spot ID is used to collect all the spots together
if regenerateIDs
  for i=1:length(myBeamData)
    for layerIndex = 1:numel(myBeamData{i}.spots)
      for spotIndex = 1:numel(myBeamData{i}.spots(layerIndex).spot_id(:,1))
          myBeamData{i}.spots(layerIndex).spot_id(spotIndex,1) = -1e6 + round(myBeamData{i}.spots(layerIndex).xy(spotIndex,2))*1e4 + round(myBeamData{i}.spots(layerIndex).xy(spotIndex,1)); % set spot ID as a function of its position (with a 1 mm rounding)
      end
    end
  end
end

for i=1:length(myBeamData)
    if(isfield(myBeamData{i}.spots(1),'spot_id'))
        % Aggregate layers of same energy
        if(aggregate_separate_layers)
            temp = myBeamData{i}.spots(1);
            for n=2:length(myBeamData{i}.spots)
                if(myBeamData{i}.spots(n).energy==myBeamData{i}.spots(n-1).energy)
                    temp(end).spot_id = [temp(end).spot_id;myBeamData{i}.spots(n).spot_id];
                    temp(end).weight = [temp(end).weight;myBeamData{i}.spots(n).weight];
                    temp(end).xy = [temp(end).xy;myBeamData{i}.spots(n).xy];
                    if(isfield(myBeamData{i}.spots(n),'tuning'))
                        temp(end).tuning = [temp(end).tuning;myBeamData{i}.spots(n).tuning];
                    end
                    if(isfield(myBeamData{i}.spots(n),'duration'))
                        temp(end).duration = [temp(end).duration;myBeamData{i}.spots(n).duration];
                    end
                else
                    temp(end+1) = myBeamData{i}.spots(n);
                end
            end
        else
            temp = myBeamData{i}.spots;
        end
        % Aggregate spots of same ID
        myBeamData{i} = rmfield(myBeamData{i},'spots');
        for n=1:length(temp)
            if(isfield(temp,'energy'))
                myBeamData{i}.spots(n).energy = temp(n).energy;
            end
            if(isfield(temp,'nb_paintings'))
                myBeamData{i}.spots(n).nb_paintings = temp(n).nb_paintings;
            end
            if(isfield(temp,'RangeShifterSetting'))
                myBeamData{i}.spots(n).RangeShifterSetting = temp(n).RangeShifterSetting;
            end
            if(isfield(temp,'IsocenterToRangeShifterDistance'))
                myBeamData{i}.spots(n).IsocenterToRangeShifterDistance = temp(n).IsocenterToRangeShifterDistance;
            end
            if(isfield(temp,'RangeShifterEquivalentThickness'))
                myBeamData{i}.spots(n).RangeShifterEquivalentThickness = temp(n).RangeShifterEquivalentThickness;
            end
            if(isfield(temp,'ReferencedRangeShifterNumber'))
                myBeamData{i}.spots(n).ReferencedRangeShifterNumber = temp(n).ReferencedRangeShifterNumber;
            end
            spot_ids = temp(n).spot_id;

            [list_of_ids1 , idx_fist ]= unique(spot_ids); %Find the unique spot IDs and the index of their first occurence in |spot_ids|. The ID are sorted in increasing order.
            [~ , idx_sorted] = sort(idx_fist); %sort in order of first occurence
            list_of_ids = spot_ids(idx_fist(idx_sorted)); %Keep the order of first occurence of all IDs. In this way, the spots are kept in the same order of occurence


            for j=1:length(list_of_ids)
                myBeamData{i}.spots(n).spot_id(j,1) = list_of_ids(j);
                myBeamData{i}.spots(n).weight(j,1) = sum(temp(n).weight(spot_ids==list_of_ids(j)));
                myBeamData{i}.spots(n).xy(j,1) = sum(temp(n).xy(spot_ids==list_of_ids(j),1).*temp(n).weight(spot_ids==list_of_ids(j)))/sum(temp(n).weight(spot_ids==list_of_ids(j)));
                myBeamData{i}.spots(n).xy(j,2) = sum(temp(n).xy(spot_ids==list_of_ids(j),2).*temp(n).weight(spot_ids==list_of_ids(j)))/sum(temp(n).weight(spot_ids==list_of_ids(j)));
                if(isfield(temp(n),'tuning'))
                    myBeamData{i}.spots(n).tuning(j,1) = sum(temp(n).tuning(spot_ids==list_of_ids(j)))/length(temp(n).tuning(spot_ids==list_of_ids(j)));
                end
                if(isfield(temp(n),'duration'))
                    myBeamData{i}.spots(n).duration(j,1) = sum(temp(n).duration(spot_ids==list_of_ids(j)));
                end
                if (isfield(temp(n),'time'))
                    myBeamData{i}.spots(n).time(j,1) = min(temp(n).time(spot_ids==list_of_ids(j)));
                end
            end
        end
    else
        disp('Warning: cannot aggregate repainted spots because no spot id found.')
    end
end
