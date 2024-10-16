%% DVH_computation
% Compute a dose volume histogram (DVH) for the specified structures and dose maps
%
%% Syntax
% |handles = DVH_computation(handles,display,doses,volumes)|
%
% |handles = DVH_computation(handles,display,doses,volumes,styles)|
%
% |handles = DVH_computation(handles,display,doses,volumes,styles,prescriptions)|
%
% |handles = DVH_computation(handles,display,doses,volumes,styles,prescriptions,sampling)|
%
%
%% Description
% |handles = DVH_computation(handles,display,doses,volumes,styles,prescriptions,sampling)| Description
%
%
%% Input arguments
% |handles| -_STRUCT_- REGGUI structure
%   * |handles.images| -_STRUCTURE_- The dose map and the RT structs to used to compute the DVH
%
% |display| -_BOOL_- true : display results in GUI. false = silently store results in |handles| and no GUI display
%
% |doses| -_CELL VECTOR of STRING_- List of image names in |handles.images| containing the dose maps on which the DVH should be computed
%
% |volumes| -_CELL VECTOR of STRING_- List of image names in |handles.images| containing the RT struct mask tp be used to devine the volumes
%
% |styles| -_CELL VECTOR of STRING_- [OPTIONAL] List of line style to use to display lines of DVH
%
% |prescriptions| -_DOUBLE VECTOR_- [OPTIONAL] If present, must have smae length  as |volumes|. |prescriptions(s)| is the dose prescribed to the structure |volumes{s}|
%
% |sampling| -_DOUBLE_- [OPTIONAL] Reoslution of the dose axis in the histogram
%
%% Output arguments
%
% |handles| -_STRUCT_- Updated REGGUI structure
%   * |handles.dvhs| -_CELL VECTOR of STRUCTURE_- The dose volume histogram on the dose maps for all defined structures
%         * |handles.dvhs.dose| -_STRING_- names of the dose map in |handles.images|
%         * |handles.dvhs.volume| -_STRING_- names of the sturcture in |handles.images|
%         * |handles.dvhs.Dp| -_DOUBLE_- Prescribed dose
%         * |handles.dvhs.color| -_INTEGER VECTOR_- RGB Color of the line in DVH plat
%         * |handles.dvhs.hexcolor| -_STRING_- Hexadecimal Color of the line in DVH plat
%         * |handles.dvhs.style| -_STRING_ line style to use to display lines of DVH
%         * |handles.dvhs.dvh| -_DOUBLE VECTOR_- Volume of the corresponding dose bin in the histogram
%         * |handles.dvhs.dvh_X| -_DOUBLE VECTOR_- Value of the dose bin of the histogram
%         * |handles.dvhs.dmin| -_DOUBLE_- Minimum dose
%         * |handles.dvhs.dmax| -_DOUBLE_- M%aximum dose
%         * |handles.dvhs.dmean|-_DOUBLE_- Mean dose
%         * |handles.dvhs.dmedian| -_DOUBLE_- Median dose
%         * |handles.dvhs.geud| -Double_
%         * |handles.dvhs.contour| -_STRING_- Name of the RT contour
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function handles = DVH_computation(handles,display,doses,volumes,styles,prescriptions,sampling)

if(nargin<5)
    styles = {};
end
if(isempty(styles))
    styles = {'-',':','--','-.'};
end
if(nargin<6)
    prescriptions = [];
end
if(nargin<7)
    sampling = 0;
end

% default display parameters
default_colors = [  1.0 0.0 0.0;...
    0.0 1.0 0.0;...
    0.0 0.0 1.0;...
    0.9 0.9 0.0;...
    0.9 0.0 0.9;...
    0.0 0.9 0.9;...
    0.0 0.0 0.0;...
    0.5 0.5 0.5;...
    0.8 0.6 0.3;...
    0.6 0.8 0.3;...
    0.3 0.6 0.8;...
    0.3 0.8 0.6;...
    0.8 0.3 0.6;...
    0.6 0.3 0.8;...
    0.9 0.5 0.1;...
    0.5 0.9 0.1;...
    0.1 0.5 0.9;...
    0.1 0.9 0.5;...
    0.9 0.1 0.5;...
    0.5 0.1 0.9];

% Create DVHs
dvhs = cell(length(doses)*length(volumes),1);
for d=1:length(dvhs)
    dvhs{d} = struct;
end
for i=1:length(doses)
    for j=1:length(volumes)
        dvhs{(i-1)*length(volumes)+j}.dose = doses{i};
        dvhs{(i-1)*length(volumes)+j}.volume = volumes{j};
        if(length(prescriptions)>=j)
            dvhs{(i-1)*length(volumes)+j}.Dp = prescriptions{j};
        else
            dvhs{(i-1)*length(volumes)+j}.Dp = 0;
        end
        current_color = default_colors(mod(j-1,size(default_colors,1))+1,:);
        dvhs{(i-1)*length(volumes)+j}.color = current_color;
        dvhs{(i-1)*length(volumes)+j}.hexcolor = [dec2hex(round(255*current_color(1)),2),dec2hex(round(255*current_color(2)),2),dec2hex(round(255*current_color(3)),2)];
        dvhs{(i-1)*length(volumes)+j}.style = styles{mod(i-1,length(styles))+1};
        dvhs{(i-1)*length(volumes)+j}.dvh = [];
    end
end

% Compute DVHs
for d=1:length(dvhs)
    if(isempty(dvhs{d}.dvh))
        myDose = Get_reggui_data(handles,dvhs{d}.dose);
        [myMask,myMaskInfo] = Get_reggui_data(handles,dvhs{d}.volume);
        if(sum(size(myDose)~=size(myMask)))
            disp('Dose and structure must have the same size. Skip.')
            continue
        end
        try
            if(sum(myMask(:)))
                myDose(myMask<max(myMask(:))/2) = NaN;
            else
                myDose = [];
            end
            myDose = myDose(not(isnan(myDose)));
            myDose(myDose<0) = 0;
            if(sampling>0)
                number_of_bins = round((max(myDose)-min(myDose))/sampling);
            else
                number_of_bins = 1024;
            end
            if(isempty(myDose) || number_of_bins<1)
                h = 0;
                Xd = 0;
            elseif(length(unique(myDose))==1)
                h = length(myDose);
                Xd = unique(myDose);
            else
                [h,Xd] = hist(myDose,number_of_bins);
                h = h(end:-1:1);
                h = cumsum(h);
                h = h(end:-1:1);
                h = [h(1),h]; Xd = [0,Xd];% add 0 index
            end
            dvhs{d}.dvh = h./max(h)*100;
            dvhs{d}.dvh_X = Xd;
            dvhs{d}.dmin = min(myDose(:));
            dvhs{d}.dmax = max(myDose(:));
            dvhs{d}.dmean = mean(myDose(:));
            dvhs{d}.dmedian = median(myDose(:));
            dvhs{d}.geud = (mean(myDose(:).^(-10)))^(-1/10);
            if(isfield(myMaskInfo,'Color'))
                current_color = myMaskInfo.Color/255;
                dvhs{d}.color = current_color;
                dvhs{d}.hexcolor = [dec2hex(round(255*current_color(1)),2),dec2hex(round(255*current_color(2)),2),dec2hex(round(255*current_color(3)),2)];
            end
            if(isfield(myMaskInfo,'Contour_name'))
                dvhs{d}.contour = myMaskInfo.Contour_name;
            else
                dvhs{d}.contour = dvhs{d}.volume;
            end
        catch
            disp('Error in DVH computation.')
            err = lasterror;
            disp(['    ',err.message]);
            disp(err.stack(1));
        end
    end
end

% Remove empty dvhs
for d=length(dvhs):-1:1
    if(isempty(dvhs{d}.dvh))
       dvhs = dvhs([1:d-1,d+1:end]); 
    end
end

% Add dvhs to handles
if(not(isfield(handles,'dvhs')))
    handles.dvhs = dvhs;
elseif(isempty(handles.dvhs))
    handles.dvhs = dvhs;
else
    handles.dvhs(end+1:end+length(dvhs)) = dvhs;
end

% Display if required
if(display)
    dose_volume_histograms(handles);
end
