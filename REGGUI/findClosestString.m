%% findClosestString
% Find the string that give the closest match (in terms of Levenshtein distance) to a pattern in a vector of strings
% Use a fuzzy logic algorithm
%
%% Syntax
% |[string , index ] = findClosestString( stringVector , pattern )|
%
%% Description
% |[string , index ] = findClosestString( stringVector , pattern )| Returns the closest match
%
%% Input arguments
% |stringVector| -_CELL VECTOR of STRING_- VEctor of strings in which the matching string should be identified
%
% |pattern| -_STRING_- Pattern to use to identifiy the string
%
%% Output arguments
%
% |string| -_STRING CELL VECTOR_- The matching strings from |stringVector|
%
% |index| -_INTEGER_VECTOR- The indexes of the matching strings in the vector |stringVector|
%
% |minDistance| -_SCALAR_- Levenshtein distance of the best match
%
%% Contributors
% Authors : Rudi Labarbe (open.reggui@gmail.com)
%
%% reference
% [1] https://nl.mathworks.com/matlabcentral/fileexchange/66271-fuzzy-search?focused=8916096&tab=example

function [string , index , minDistance ] = findClosestString( stringVector , pattern )

distance = [];
for index = 1:length(stringVector)
  ans=fzsearch(stringVector{index},pattern,0,1); %make the match case insensitive
  if(iscell(ans))
    distance(index) = ans{1}(1); %record the value of the Levenshtein distance
  else
    distance(index) = ans(1); %record the value of the Levenshtein distance
  end
end %for

%Find the shortest Distance
minDistance = min(distance);
wminDistance = find(distance == minDistance);

index = wminDistance;
string = {stringVector{index}};

end  % function
