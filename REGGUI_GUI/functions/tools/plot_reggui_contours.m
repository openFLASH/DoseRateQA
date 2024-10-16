function plot_reggui_contours(mask,color)

if(nargin<2)
    color = 'y';
end

boundCell = find_contour(mask,1);
if(~isempty(boundCell))
    for ireg = 1:length(boundCell)
        bound = cell2mat(boundCell(ireg,1));
        eval(['plot(bound(:,1),bound(:,2),''Color'',',color,');']);
    end
end
