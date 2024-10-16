function t = timestr_us(time_in_seconds)

try
    t = [datestr(seconds(time_in_seconds),'HHMMSS.FFF'),strrep(sprintf('%3i',round(mod(time_in_seconds*1e6,1e3))),' ','0')];% in [us]
catch
    warning(['Could not convert time ',num2str(time_in_seconds)]);
    t = 'NaN';
end