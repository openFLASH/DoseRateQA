function f = reggui_message(msg)

% Authors : G.Janssens

wtitle='REGGUI';

if nargin<1
    msg='';
end
if ~iscell(msg)
    msg={msg};
end

% Set default sizes
DefFigPos=get(0,'DefaultFigurePosition');
MsgOff=7;
FigWidth=200;
FigHeight=100;
DefFigPos(3:4)=[FigWidth FigHeight];
MsgTxtWidth=FigWidth-2*MsgOff;
MsgTxtHeight=FigHeight-2*MsgOff;

% Initialize dialog window
f=dialog('Name',wtitle,'Units','points','WindowStyle','normal','Toolbar','none',...
         'DockControls','off','MenuBar','none','Resize','off','ToolBar','none',...
         'NumberTitle','off');%,'CloseRequestFcn','');

% Initialize message
msgPos=[MsgOff MsgOff MsgTxtWidth MsgTxtHeight];
msgH=uicontrol(f,'Style','text','Units','points','Position',msgPos,'String',' ',...
               'Tag','MessageBox','HorizontalAlignment','left','FontSize',10);
[WrapString,NewMsgTxtPos]=textwrap(msgH,msg,75);
set(msgH,'String',WrapString)
delete(msgH);

% Fix final message positions
MsgTxtWidth=max(MsgTxtWidth,NewMsgTxtPos(3));
MsgTxtHeight=min(MsgTxtHeight,NewMsgTxtPos(4));
MsgTxtXOffset=MsgOff;
MsgTxtYOffset=MsgOff;
FigWidth=MsgTxtWidth+2*MsgOff;
FigHeight=MsgTxtYOffset+MsgTxtHeight+MsgOff;

DefFigPos(3:4)=[FigWidth FigHeight];
set(f,'Position',DefFigPos);

% Create the message
AxesHandle=axes('Parent',f,'Position',[0 0 1 1],'Visible','off');
txtPos=[MsgTxtXOffset MsgTxtYOffset 0];
text('Parent',AxesHandle,'Units','points','HorizontalAlignment','left',...
     'VerticalAlignment','bottom','Position',txtPos,'String',WrapString,...
     'FontSize',12,'Tag','MessageBox');
 
% Move the window to the center of the screen
set(f,'Units','pixels')
screensize=get(0,'screensize');                       
winsize=get(f,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(f,'Position',winpos);

% Give priority to displaying this message
drawnow
