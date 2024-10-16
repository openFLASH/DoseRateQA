%% poisson
% Draw one random sample out of a Poisson distribution
%
%% Syntax
% |k = poisson(lambda)|
%
%
%% Description
% |k = poisson(lambda)| Draw a sample out of the Poisson distribution
%
%
%% Input arguments
% |lambda| - _SCALAR_ -  Average number of events per interval
%
%
%% Output arguments
%
% |k| - _SCALAR_ -  Value of one random draw from a Poisson distribution
%
%
%% Contributors
% http://www.johndcook.com/blog/2010/06/14/generating-poisson-random-values/

function k = poisson(lambda)

format longe

if lambda < 30
    k = 1;
    p = log(rand());
    while p>-lambda
        k = k + 1;
        p = p+log(rand());
    end
    k=k-1;
else
    c = 0.767-3.36/lambda;
    beta = pi/sqrt(3.0*lambda);
    alpha = beta*lambda;
    k = log(c)-lambda-log(beta);
    nb_loops = 0;
    while true
        nb_loops = nb_loops+1;
        u = rand();
        x = (alpha-log((1.0-u)/u))/beta;
        n = floor(x+0.5);
        if n < 0 
            continue
        end
        v = rand();
        y = alpha-beta*x;
        lhs = y+log(v/(1.0+exp(y))^2);
        rhs = k+n*log(lambda)-gammaln(n+1);
        if lhs<=rhs || nb_loops>10
            break;
        end
    end
    k=n;
end

format
