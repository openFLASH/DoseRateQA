%% are_you_physician
% Display a GUI to define the Sigma of the Gaussian smoothing filer.
%
%% Syntax
% |res = are_you_physician()|
%
%% Description
% |res = are_you_physician()| Display a GUI to define the Sigma of the Gaussian smoothing filer.
%
%% Input arguments
% None
%
%% Output arguments
%
% |smooth_contours| - _INTEGER_ - |0<=smooth_contours<=100|. |smooth_contours| is proportional to the sigma of the Gaussian. Set |smooth_contours=0| not to apply any smoothing.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function res = are_you_physician()

% Authors : G.Janssens

fh = figure('Position',[250 250 500 170]);
res = 0;
sh = uicontrol(fh,'Style','slider',...
               'Max',100,'Min',0,'Value',0,...
               'SliderStep',[0.1 0.2],...
               'Position',[450 10 20 150],...
               'BackgroundColor','white',...
               'Callback',@slider_callback);
eth = uicontrol(fh,'Style','edit',...
               'String','No, please keep the contour as it is (with a pixel-shaped look).',...
               'Position',[30 75 380 20],...
               'BackgroundColor','white',...
               'Callback',@edittext_callback);
sth = uicontrol(fh,'Style','text',...
               'String','Smooth contour?',...
               'Position',[30 115 380 20],...
               'BackgroundColor','white');
plotButton = uicontrol(fh,'Style','pushbutton',...
                'Position',[30 10 80 30],...
                'String','OK',...
                'BackgroundColor',[0.71 0 0],...
                'Parent',fh,...
                'Callback',@plotButtonCallback);
val = 0;
% ----------------------------------------------------
% Set the value of the edit text component String property
% to the value of the slider.
    function slider_callback(hObject,eventdata)
        val = get(hObject,'Value');
        if(val<15)
            set(eth,'String','No, please keep the contour as it is (with a pixel-shaped look).');
        elseif(val<35)
            set(eth,'String','Yes, but very slightly.');
        elseif(val<65)
            set(eth,'String','Ok, let us smooth contour just a bit!');
        elseif(val<85)
            set(eth,'String','Fine, smooth it.');
        else
            set(eth,'String','Absolutely! I am physician and I need a very smooth contour...');
        end
    end
% ----------------------------------------------------
% Set the slider value to the number the user types in 
% the edit text or display an error message.
   function edittext_callback(hObject,eventdata)
%       previous_val = val;
%       val = str2double(get(hObject,'String'));
%       % Determine whether val is a number between the 
%       % slider's Min and Max. If it is, set the slider Value.
%       if isnumeric(val) && length(val) == 1 && ...
%          val >= get(sh,'Min') && ...
%          val <= get(sh,'Max')
%          set(sh,'Value',val);
%       else
%       % Increment the error count, and display it.
%          number_errors = number_errors+1;
%          set(hObject,'String',...
%              ['You have entered an invalid entry ',...
%              num2str(number_errors),' times.']);
%          val = previous_val;
%       end
   end

% ----------------------------------------------------
% Callback for plot button
    function plotButtonCallback(src,evt) 
        res = get(sh,'Value');
        delete(fh);
        return
    end % plotButtonCallback

    uiwait(fh);
    
end
