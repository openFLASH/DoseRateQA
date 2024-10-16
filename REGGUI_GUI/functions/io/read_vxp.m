%% read_vxp
% Read Varian RPM vxp files.
%
%% Syntax
% |X=read_vxp(filename)|
%
%
%% Description
% |X=read_vxp(filename)| Read Varian RPM vxp files.
%
%
%% Input arguments
% |filename| - _STRING_ - File name (including path) of the Varian RPM vxp files containing the breathing signal
%
%
%% Output arguments
%
% |X| - _STRUCTURE_ - Structure with the recording of the breathing signal
%
% % |X.totalStudyTime| - _STRING_ - Study time
% % |X.amplitude| - _SCALAR VECTOR_ - |amplitude(t)| Breathing amplitude (mm) at sampling point t
% % |X.phase| - _SCALAR_ - |phase(t)| Breathing phase  at sampling point t
% % |X.timestamp| - _SCALAR VECTOR_ - |timestamp(t)| Time stamp (ms) at sampling point t
% % |X.mark| - _INTEGER_ - |mark(t)| Indicator of extremum of breathing amplitude at time t. 1 marks end-inhalation; -1 marks end-exhalation; 0 otherwise.
% % |X.nCycle| - _INTEGER_ - Number of full cycles
% % |X.T| - _SCALAR VECTOR_ - |T(c)| Period (s) for c-th breathing cycle.
% % |X.A| - _SCALAR VECTOR_ - |A(c)| Amplitude span from end-inhalations to end-exhalations for c-th breathing cycle.
%
%
%% Contributors
% Author: Chuan Zeng, 2013 (open.reggui@gmail.com)

function X=read_vxp(filename)

fid=fopen(filename,'r');
for i=1:6, fgetl(fid); end
X.totalStudyTime=sscanf(fgetl(fid),'Total_study_time=%f');	%s
samplingRate=sscanf(fgetl(fid),'Samples_per_second=%d');
scaleFactor=sscanf(fgetl(fid),'Scale_factor=%f');
fgetl(fid);
C=textscan(fid,'%f%f%d%d%d%s%d','Delimiter',',');
fclose(fid);
X.amplitude=C{1}*scaleFactor;	%mm
X.phase=C{2};
%	X.phase=mod(floor(C{2}*4/pi-3.5),8)/8;
X.timestamp=double(C{3});	%ms
X.validflag=C{4};
X.ttlin=C{5};
X.mark=cellfun(@parsemark,C{6});	%1 marks end-inhalation; -1 marks end-exhalation; 0 otherwise.
X.ttlout=C{7};

%Post processing:
X.nCycle=min(sum(X.mark==-1),sum(X.mark==1));	%Number of full cycles.
t0=X.timestamp(X.mark==1)/1000;	%Timestamps at end-inhalations / s.
X.T=t0(2:end)-t0(1:end-1);	%Period for each cycle / s.
amplitude0=X.amplitude(X.mark==1);	%``Amplitudes" at end-inhalations / mm.
t50=X.timestamp(X.mark==-1)/1000;	%Timestamps at end-exhalations / s.
amplitude50=X.amplitude(X.mark==-1);	%``Amplitudes" at end-exhalations / mm.
%Find full cycles starting with end-inhalation and ending with end-exhalation:
if t50(1)>t0(1)
    if t50(end)>t0(end)
        X.A=amplitude0-amplitude50;	%X.A's span from end-inhalations to end-exhalations.
    else
        X.A=amplitude0(1:end-1)-amplitude50;	%X.A's span from end-inhalations to end-exhalations.
    end
else	%t50(1)<t0(1)
    if t50(end)>t0(end)
        X.A=amplitude0-amplitude50(2:end);	%X.A's span from end-inhalations to end-exhalations.
    else
        X.A=amplitude0(1:end-1)-amplitude50(2:end);	%X.A's span from end-inhalations to end-exhalations.
    end
end

    function mark_num=parsemark(mark_str)
        
        if strcmp(mark_str,'')
            mark_num=0;
            return;
        end
        
        if strcmp(mark_str,'P')
            mark_num=1;
            return;
        end
        
        if strcmp(mark_str,'Z')
            mark_num=-1;
            return;
        end
        
        error('read_vxp:unrecognized_mark','Mark unrecognized');
        
    end

end
