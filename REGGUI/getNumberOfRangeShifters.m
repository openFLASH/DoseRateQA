function NumberOfRangeShifters = getNumberOfRangeShifters(plan,beam_index)

if(nargin<2)
    beam_index = 1:length(plan);
end

NumberOfRangeShifters = zeros(length(beam_index),1);
for i = 1:length(beam_index)
    if(isfield(plan{beam_index(i)},'NumberOfRangeShifters'))
        NumberOfRangeShifters(i) = plan{beam_index(i)}.NumberOfRangeShifters;
    end
end