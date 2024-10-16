%% printpdf
% Save a figure to file at the pdf format
%
%% Syntax
% |printpdf(h,outfilename)|
%
%
%% Description
% |printpdf(h,outfilename)| Save a figure to file at the pdf format
%
%
%% Input arguments
% |h| - _INTEGER_ - Figure number
%
% |outfilename| - _STRING_ - Name of the pdf file where the figure will be saved 
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function printpdf(h,outfilename)

set(h, 'PaperUnits','centimeters');
set(h, 'Units','centimeters');
pos=get(h,'Position');
set(h, 'PaperSize', [pos(3) pos(4)]);
set(h, 'PaperPositionMode', 'manual');
set(h, 'PaperPosition',[0 0 pos(3) pos(4)]);
print(h,'-dpdf',outfilename);
