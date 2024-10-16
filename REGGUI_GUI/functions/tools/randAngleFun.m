%% randAngleFun
% Construct a function |fun(a,b)| and return a pointer to this function.
% The function takes two angles |(a,b)| (degree) as input and return a number N between -1.5 <= N <=1.5
% The function |fun| is randomly created when calling |randAngleFun| by drawing random values on an evenly space grid of |sm * sm| coordinate points in the space (a=0:360, b=0:360). The function |fun| is then linearly interpolated for (a,b) points located in between the |sm * sm| grid points.
%
%% Syntax
% |fun = randAngleFun(sm)|
%
%
%% Description
% |fun = randAngleFun(sm)| Build a random function |fun(a,b)| by defining a |sm*sm| grid of random values over the (a,b) space
%
%
%% Input arguments
% |sm| - _INTEGER_ - The function |fun(a,b)| will be defined over a grid of |sm*sm| points in the (a,b) space
%
%
%% Output arguments
%
% |fun| - _FUNCTION POINTER_ -  Pointer to a function: 'fun(a,b)'
%
%
%% Contributors
% Authors : M.Taquet, G.Janssens (open.reggui@gmail.com)

function fun = randAngleFun(sm)

N=round(360/sm)+1;
pts = zeros(N,N,'single');
pts(1:(N-1),1:(N-1)) = 3*(rand(N-1,N-1)-0.5);
pts(N,:) = pts(1,:);
pts(:,N) = pts(:,1);
x=linspace(0,360,N);
y=x;
x_int=0:360;
y_int=0:360;
[XINT,YINT] = meshgrid(x_int,y_int);
pts_int = interp2(x,y,pts,XINT,YINT);

%     x_fil=floor(-2*sm):ceil(2*sm);
%     y=floor(-2*sm):ceil(2*sm);
%     [X,Y]=meshgrid(x,y);
%     kernel = exp(-(X.^2)/(2*sm^2)-(Y.^2)/(2*sm^2));
%     kernel = kernel/10;
%     pts_sm = conv2(pts,kernel,'same');
fun = @(a,b) interp2(0:1:360,0:1:360,pts_int,mod(a,360),mod(b,360));
