%% extract_phase_from_breathing
% Determine the breathing phase p(t) at time t from a breathing signal s(t) using Hilbert transform. See [1] for more information
% This function re-implements the RTK method for extracting breathing phase.
%
%% Syntax
% |[phase,p] = extract_phase_from_breathing(s)|
%
% |[phase,p] = extract_phase_from_breathing(s,flip)|
%
%
%% Description
% |[phase,p] = extract_phase_from_breathing(s)| Extract the breathing phase
%
% |[phase,p] = extract_phase_from_breathing(s,flip)| Extract the breathing phase with change of the sign of the derivative of the Hilbert transform
%
%
%% Input arguments
% |s| - _SCALAR VECTOR_ - Respiratory signal as a function of time |s(t)|.
%
% |flip| - _INTEGER_ - [OPTIONAL. Default = 0] 1 = Shift the breathing signal by 1/2 phase. 0 = do not shift 
%
%
%% Output arguments
%
% |phase| - _SCALAR VECTOR_ -  Phase signal at time t: |phase(t)| in multiple of 2*pi
%
% |p| - _SCALAR VECTOR_ - +1 = End of the period. -1 = half period. 0 otherwise 
%
%% Reference
%
% [1] http://www.physik.uni-halle.de/Fachgruppen/kantel/83-10-ESGCO_53.pdf
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function p = extract_extrema_from_breathing(s,flip)

if(nargin<2)
    flip = 0;
end

% Signal smoothing
s1 = norm_conv(s,[1 2 3 2 1]/9,ones(size(s)));

% Hilbert transform
L = 20;
n = -L:L;
h = (1-(-1).^n)./(pi*n); % impulse response of Hilbert Transform
h(L+1) = 0;
p = [diff(angle(conv(s1,h,'same')))/pi;0];
if(flip)
    p = -p;
end

% % -----------------------
% figure
% plot(s,'b')
% hold on
% plot(p*5,'c')

