%% roundsd
% Round with fixed significant digits.
% See also Matlab's function ROUND.
%
%% Syntax
% |y=roundsd(x,n)|
%
% |y=roundsd(x,n,method)|
%
% |y=roundsd(x,n,method,m)|
%
%
%% Description
% |y=roundsd(x,n)| Rounds the elements of X towards the nearest number with N significant digits.
%
% |y=roundsd(x,n,method)| Rounds the elements of X towards the nearest number with significant digits using the specified method
%
% |y=roundsd(x,n,method,m)| Round using the Matlab function and m significative digits
%
%% Input arguments
% |x| - _SCALAR VECTOR_ - Input vector 
%
% |n| - _INTEGER_ -  Number of significant digits
%
% |method| - _STRING_ -   uses following methods for rounding:
%
% * 'round' - nearest (default)
% * 'floor' - towards minus infinity
% * 'ceil'  - towards infinity
% * 'fix'   - towards zero
%
% |m| - _INTEGER_ -  round(y*10^m)/10^m
%
%
%% Output arguments
%
% |res| - _STRUCTURE_ -  Description
%
%
%% Contributors
% Franois Beauducel <beauducel@ipgp.fr>
% Institut de Physique du Globe de Paris
% Acknowledgments: Edward Zechmann, Daniel Armyr
% Created: 2009-01-16
% Updated: 2010-03-17
% Copyright (c) 2010, Franois Beauducel, covered by BSD License.
% All rights reserved.

function y=roundsd(x,n,method,m)

%ROUNDSD Round with fixed significant digits
%	ROUNDSD(X,N) rounds the elements of X towards the nearest number with
%	N significant digits.
%
%	ROUNDS(X,N,METHOD) uses following methods for rounding:
%		'round' - nearest (default)
%		'floor' - towards minus infinity
%		'ceil'  - towards infinity
%		'fix'   - towards zero
%
%	Examples:
%		roundsd(0.012345,3) returns 0.0123
%		roundsd(12345,2) returns 12000
%		roundsd(12.345,4,'ceil') returns 12.35
%
%	See also Matlab's function ROUND.
%
%	Author: Franois Beauducel <beauducel@ipgp.fr>
%	  Institut de Physique du Globe de Paris
%	Acknowledgments: Edward Zechmann, Daniel Armyr
%	Created: 2009-01-16
%	Updated: 2010-03-17
%
%	Copyright (c) 2010, Franois Beauducel, covered by BSD License.
%	All rights reserved.


narginchk(2,4);

if ~isnumeric(x)
		error('X argument must be numeric.')
end

if ~isnumeric(n) | numel(n) ~= 1 | n < 0 | mod(n,1) ~= 0
	error('N argument must be a scalar positive integer.')
end

opt = {'round','floor','ceil','fix'};

if nargin < 3
	method = opt{1};
else
	if ~ischar(method) | ~ismember(opt,method)
		error('METHOD argument is invalid.')
	end
end

og = 10.^(floor(log10(abs(x)) - n + 1));
y = feval(method,x./og).*og;
y(find(x==0)) = 0;

if(nargin>3)
    y = round(y*10^m)/10^m;
end
