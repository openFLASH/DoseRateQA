%% reg_accumulation
% Creates a structure with the necessary function names and parameters to accumulate the displacement fields computed at each level of a multi-scale deformable registration process.
%
%% Syntax
% |acc_struct = reg_accumulation(acc_name,logdomain)|
%
% |acc_struct = reg_accumulation(acc_name)|
%
%% Description
% |acc_struct = reg_accumulation(acc_name,logdomain)| returns a structure describing the method for accumulating displacement fields.
%
% |acc_struct = reg_accumulation(acc_name)| return a structure describing the method for accumulating displacement fields. Does not work in log domain (|logdomain=0|).
%
%% Input arguments
% |acc_name| - _STRING_ - Algorithm to use to accumulate the deformation fields. The following strings are possible:
%
% * 'diffeomorphic' or 'diffeomorphic_and_mask' in logdomain : accumulation function is 'accumulator_diffeomorphic_without_certainty_logdomain.m'
% * 'diffeomorphic_certainty' or 'diffeomorphic_certainty_and_mask' in logdomain : function is 'accumulator_diffeomorphic_without_certainty_logdomain.m'
% * 'default' or 'morphons' or 'weighted_sum' : accumulation function is 'accumulator_with_certainty.m'
% * 'none' or 'sum' : accumulation function is 'accumulator_without_certainty.m'
% * 'compositive' or 'demons' : accumulation function is 'accumulator_compositive_without_certainty.m'
% * 'compositive_certainty' : accumulation function is 'accumulator_compositive_with_certainty.m'
% * 'diffeomorphic_certainty' : accumulation function is 'accumulator_diffeomorphic_without_certainty.m'
% * 'diffeomorphic_certainty_and_mask' : accumulation function is  'accumulator_diffeomorphic_with_certainty_and_mask.m'
%
% |logdomain| - _INTEGRER_ -  (Default: |logdomain=0|) |logdomain=1|: Use the logarithmic diffeomorphic domain to combine the transform. |logdomain=1| can be used ONLY when using diffeomorphic |acc_name|. |logdomain=0| Directly add the transform.
%
%% Output arguments
%
% |acc_struct| - _STRUCTURE_ - Structure describing the accumulation function
%
% * acc_struct.function - _STRING_ String of the name of the '*.m' file containing the implementation of the accumulation function. See |acc_name| for a description of the function names. (Default: 'accumulator_with_certainty')
%
% * acc_struct.name - _STRING_ Name of the accumulation algorithm (|acc_name|)
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function acc_struct = reg_accumulation(acc_name,logdomain)
acc_struct = struct;
acc_struct.name = acc_name;

if(nargin<2)
    logdomain = 0;
end

if(logdomain)
    switch lower(acc_name)
        case {'diffeomorphic','diffeomorphic_and_mask'}
            acc_struct.function = 'accumulator_without_certainty';%'accumulator_diffeomorphic_without_certainty_logdomain';
        case {'diffeomorphic_certainty','diffeomorphic_certainty_and_mask'}
            acc_struct.function = 'accumulator_with_certainty';%'accumulator_diffeomorphic_with_certainty_logdomain';
        otherwise
            error(['--- reg_accumulation: Unknown accumulator method for log-domain registration: ', acc_name]);
    end
else
    switch lower(acc_name)
        case {'default','morphons','weighted_sum'}
            acc_struct.function = 'accumulator_with_certainty';
        case {'none','sum'}
            acc_struct.function = 'accumulator_without_certainty';
        case {'compositive','demons'}
            acc_struct.function = 'accumulator_compositive_without_certainty';
        case {'compositive_certainty'}
            acc_struct.function = 'accumulator_compositive_with_certainty';
        case {'diffeomorphic'}
            acc_struct.function = 'accumulator_diffeomorphic_without_certainty';
        case {'diffeomorphic_certainty'}
            acc_struct.function = 'accumulator_diffeomorphic_with_certainty';
        case {'diffeomorphic_certainty_and_mask'}
            acc_struct.function = 'accumulator_diffeomorphic_with_certainty_and_mask';
        otherwise
            error(['--- reg_accumulation: Unknown accumulator method: ', acc_name]);
    end
end
