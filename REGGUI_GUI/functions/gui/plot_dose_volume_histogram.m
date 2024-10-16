function myLegend = plot_dose_volume_histogram(dvhs,show_items,interval,myLegend)
if(nargin<4)
    myLegend = cell(0);
end
% Compute DVH bands
bands = cell(0);
band_volumes = cell(0);
for d=1:length(dvhs)
    if(show_items(d) && strcmp(dvhs{d}.style,'band'))  
        new_band = 0;
        b = find(strcmp(band_volumes,dvhs{d}.volume));
        if(isempty(b))
            b = length(band_volumes)+1;
            new_band = 1;
        end
        band_volumes{b} = dvhs{d}.volume;
        bands{b}.color = dvhs{d}.color;
        dose = [interval(1):0.1:interval(2)];
        dvh_x = dvhs{d}.dvh_X;
        dvh_y = dvhs{d}.dvh;
        dvh_y = dvh_y/max(dvh_y)*100;
        dvh_y = interp1(dvh_x,dvh_y,dose);
        first_value = find(dvh_y>0,1,'first');
        if(first_value>1)
            dvh_y(1:first_value-1) = dvh_y(first_value);
        end
        dvh_y(isnan(dvh_y))=0;
        bands{b}.dose = dose;
        if(new_band)
            bands{b}.min = dvh_y;
            bands{b}.max = dvh_y;
        else
            bands{b}.min = min([bands{b}.min;dvh_y],[],1);
            bands{b}.max = max([bands{b}.max;dvh_y],[],1);
        end
    end
end
% display DVH bands
for b=1:length(bands)
    x = [bands{b}.dose,bands{b}.dose(end:-1:1)];
    y = [bands{b}.max,bands{b}.min(end:-1:1)];
    patch(x',y',bands{b}.color','EdgeColor','none','FaceAlpha', 0.2);
    hold on
    myLegend{length(myLegend)+1} = ['DVH band on <',strrep(band_volumes{b},'_',' '),'>'];
end
% display DVH curves
for d=1:length(dvhs)
    if(show_items(d) && not(strcmp(dvhs{d}.style,'band')))
        color = dvhs{d}.color;
        style = dvhs{d}.style;
        h = dvhs{d}.dvh;
        plot(dvhs{d}.dvh_X,h./(max(h))*100,'Color',color,'LineStyle',style,'LineWidth',2);
        hold on
        myLegend{length(myLegend)+1} = [strrep(dvhs{d}.dose,'_','\_'),' on <',strrep(dvhs{d}.volume,'_',' '),'>'];
    end
end
axis([interval(1) interval(2) 0 100])
if(not(isempty(myLegend)))
    legend(myLegend,'Location','SouthWest')
else
    legend('hide');
end
hold off
