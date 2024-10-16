%% compute_processing_time
% Compute the time elapsed between |init_time| and the time of call of the function |compute_processing_time|.
% Days (|total_time(4)|) is computed modulo 24. Hours (|total_time(5)|) and minutes (|total_time(6)|) are displayed modulo 60.
%
%% Syntax
% |total_time = compute_processing_time(init_time)|
%
%
%% Description
% |total_time = compute_processing_time(init_time)| Time elapsed since |init_time|
%
%
%% Input arguments
% |init_time| - _SCALAR VECTOR_ -  Six-element date vector containing the current date and time in decimal form. See |clock| for more information
%
%
%% Output arguments
%
% |total_time| - _STRUCTURE_ -  Description
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function total_time = compute_processing_time(init_time)

total_time = clock - init_time;
if(total_time(4)<0);
    total_time(4) = 24 + total_time(4);
end;
if(total_time(5)<0);
    total_time(4) = total_time(4)-1;
    total_time(5) = 60 + total_time(5);
end
if(total_time(6)<0);
    total_time(5) = total_time(5)-1;
    total_time(6) = 60 + total_time(6);
end
