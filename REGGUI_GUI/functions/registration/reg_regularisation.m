%% reg_regularisation
% Creates a structure with the necessary function names and parameters to regularize the displacement estimation fields.
%
%% Syntax
% |regmod = reg_regularisation(regmod_name, regmod_data)|
%
%% Description
% |regmod = reg_regularisation(regmod_name, regmod_data)| describes the function
%
%% Input arguments
% |regmod_name| - _STRING_ - Algorithm to use to resample the image. The following strings are possible: 
%
% * 'none': regularization function is 'regularisation_none.m'
% * 'gauss': regularization function is 'regularisation_gauss.m'
% * 'default', 'normgauss': regularization function is 'regularisation_normgauss.m' [DEFAULT]
% * 'affine': regularization function is 'regularisation_affine.m'
% * 'gauss_discontinuous': regularization function is 'regularisation_gauss_discontinuous.m'
% * 'normgauss_discontinuous': regularization function is 'regularisation_normgauss_discontinuous.m'
% * 'elastic': regularization function is 'regularisation_normgauss.m'
% * OTHERWISE : If the string is none of the above, it is interpreted as the name of an *.mat file saved on disk. The file contains a variable 'regmod_function' which define the name of the *.m file with the implementation of the regularization function.
%
% |regmod_data| - _TYPE_ -  Regulariser parameter. Data type depends on the type of regularizer function.
%
%% Output arguments
%
% |regmod| - _STRUCTURE_ - Structure describing the resampling function to resample an image
%
% * regmod.name - _STRING_ - Algorithm to use for the regularization (|regmod_name|). 
%
% * regmod.function - _STRING_ String of the name of the '*.m' file containing the implementation of the regularization function. See description of |regmod_name|
%
% * regmod.data : Data that will be given to the regularization function
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function regmod = reg_regularisation(regmod_name, regmod_data)

regmod = struct;
regmod.name = regmod_name;

% First check if the model is predefined in this file
switch lower(regmod.name)
    case {'none'}
            regmod.data = regmod_data;
            regmod.function = 'regularisation_none';
    case {'gauss'}
        if(isnumeric(regmod_data))
            regmod.data = regmod_data;
            regmod.function = 'regularisation_gauss';
        else
            error('--- reg_regularisation: Invalid regularisation model parameters');
        end
    case {'default', 'normgauss'}
        if(isnumeric(regmod_data))
            regmod.data = regmod_data;
            regmod.function = 'regularisation_normgauss';
        else
            error('--- reg_regularisation: Invalid regularisation model parameters');
        end
    case 'affine'
        if(isnumeric(regmod_data))
            regmod.data = regmod_data;
            regmod.function = 'regularisation_affine';
        else
            error('--- reg_regularisation: Invalid regularisation model parameters');
        end
     case 'gauss_discontinuous'
        if(isnumeric(regmod_data))
            regmod.data = regmod_data;
            regmod.function = 'regularisation_gauss_discontinuous';
        else
            error('--- reg_regularisation: Invalid regularisation model parameters');
        end
    case 'normgauss_discontinuous'
        if(isnumeric(regmod_data))
            regmod.data = regmod_data;
            regmod.function = 'regularisation_normgauss_discontinuous';
        else
            error('--- reg_regularisation: Invalid regularisation model parameters');
        end
    case 'elastic'
        if(isnumeric(regmod_data))
            regmod.data = regmod_data;
            regmod.function = 'regularisation_normgauss';
            regmod.elastic = 1;
        else
            error('--- reg_regularisation: Invalid regularisation model parameters');
        end
    otherwise
        % Check if there is such a function on disk
        if(exist(regmod_name) == 2)
            load(regmod_name);
            if(exist('regmod_function', 1))
                regmod.function = regmod_function;
                regmod.data = regmod_data;
            else
                regmod.name = '';
                error(['Invalid regularisation model file: ', regmod_name]);
            end
        else
            regmod.name = '';
            error(['Unknown regularisation model file: ',regmod_name]);
        end
end
