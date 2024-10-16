%% timeConverter
% Convert a string (from machine logs) with the time stamp into a time and date variable
%
%% Syntax
% |[time,date] = timeConverter(timeString, version)|
%
%
%% Description
% |[time,date] = timeConverter(timeString, version)| Description
%
%
%% Input arguments
% |im1| - _STRING_ -  Name
%
%
%% Output arguments
%
% |res| - _STRUCTURE_ -  Description
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [time,date] = timeConverter(timeString, version)

if(strcmp(timeString,'-'))
   time = NaN;
   date = NaN;
   return
end

index = strfind(timeString,' ');

switch version
    case '2.6'
        date = datestr(datetime(timeString(1:index(1)-1),'InputFormat','MMM-dd-yyyy'),'yyyymmdd');
        timeString = timeString(index(1)+1:index(2)-1);
        index = strfind(timeString,':');
        h = timeString(1:index(1)-1);
        m = timeString(index(1)+1:index(2)-1);
        s = timeString(index(2)+1:index(3)-1);
        ms = timeString(index(3)+1:end);
    case '2.7'
        try
            date = datestr(datetime(timeString(1:index(1)-1),'InputFormat','MMM-dd-yyyy'),'yyyymmdd');
        catch
            date = datestr(datetime(timeString(1:index(1)-1),'InputFormat','dd/MM/yyyy'),'yyyymmdd');
        end
        timeString = timeString(index(1)+1:length(timeString));
        index = strfind(timeString,':');
        h = timeString(1:index(1)-1);
        m = timeString(index(1)+1:index(2)-1);
        index = strfind(timeString,'.');
        s = timeString(index(1)-2:index(1)-1);
        ms = timeString(index(1)+1:end);
    case 'dekimo'
        [time,date] = timeConverterDekimo(timeString);
        return
    case 'event'
        index = strfind(timeString,':');
        h = timeString(1:index(1)-1);
        m = timeString(index(1)+1:index(2)-1);
        index = strfind(timeString,'.');
        s = timeString(index(1)-2:index(1)-1);
        ms = timeString(index(1)+1:index(1)+3);
        time = 1000*(3600000*str2double(h) + 60000*str2double(m) + 1000*str2double(s) + str2double(ms)); % in [us]
    otherwise
        try
            date = datestr(datetime(timeString(1:index(1)-1),'InputFormat','MMM-dd-yyyy'),'yyyymmdd');
        catch
            try
                date = datestr(datetime(timeString(1:index(1)-1),'InputFormat','dd/MM/yyyy'),'yyyymmdd');
            catch
                try
                    index2 = strfind(timeString,':');
                    date = datestr(datetime(timeString(1:index2(1)-4),'InputFormat','yyyy-MM-dd'),'yyyymmdd');
                catch
                    date = datestr(now,'yyyymmdd');
                end
            end
        end
        try
            timeString2 = timeString(index(1)+1:index(2)-1);
            index = strfind(timeString2,':');
            h = timeString2(1:index(1)-1);
            m = timeString2(index(1)+1:index(2)-1);
            s = timeString2(index(2)+1:index(3)-1);
            ms = timeString2(index(3)+1:end);
        catch
            try
                timeString = timeString(index(1)+1:length(timeString));
                index = strfind(timeString,':');
                h = timeString(1:index(1)-1);
                m = timeString(index(1)+1:index(2)-1);
                index = strfind(timeString,'.');
                s = timeString(index(1)-2:index(1)-1);
                ms = timeString(index(1)+1:end);
            catch
                try
                    timeString3 = timeString(index2(1)-2:index2(2)+6);
                    index = strfind(timeString3,':');
                    h = timeString3(1:index(1)-1);
                    m = timeString3(index(1)+1:index(2)-1);
                    s = timeString3(index(2)+1:index(2)+2);
                    ms = timeString3(index(2)+3:end);
                catch
                    h=0;
                    m=0;
                    s=0;
                    ms = timeString;
                end
            end
        end
end

time = 1000*(3600000*str2double(h) + 60000*str2double(m) + 1000*str2double(s) + str2double(ms)); % in [us]

if(isnan(time))
    time = 0;
end

end


% ----------------------------------------------------------------------
function [time,date] = timeConverterDekimo(timeString)

if(contains(timeString,' UTC')) % 2021-10-20 23:02:04.144 UTC
    timeString = strrep(strrep(timeString,'-',''),' UTC','');
    index = strfind(timeString,' ');
    date = timeString(1:index(1)-1);
    timeString = timeString(index(1)+1:length(timeString));
    index = strfind(timeString,':');
    h = timeString(1:index(1)-1);
    m = timeString(index(1)+1:index(2)-1);
    index = strfind(timeString,'.');
    s = timeString(index(1)-2:index(1)-1);
    ms = timeString(index(1)+1:end);
elseif(not(contains(timeString,'T'))) % 20170423-20:07:38.788
    index = strfind(timeString,'-');
    date = timeString(1:index(1)-1);
    timeString = timeString(index(1)+1:length(timeString));
    index = strfind(timeString,':');
    h = timeString(1:index(1)-1);
    m = timeString(index(1)+1:index(2)-1);
    index = strfind(timeString,'.');
    s = timeString(index(1)-2:index(1)-1);
    ms = timeString(index(1)+1:end);
else % 2018-06-11T11:59:54.846+02:00
    index = strfind(timeString,'T');
    date = timeString(1:index(1)-1);
    date = [date(1:4),date(6:7),date(9:10)];
    timeString = timeString(index(1)+1:length(timeString));
    index = strfind(timeString,':');
    h = timeString(1:index(1)-1);
    m = timeString(index(1)+1:index(2)-1);
    if contains(timeString,'.')
        index = strfind(timeString,'.');
        s = timeString(index(1)-2:index(1)-1);
        ms = timeString(index(1)+1:index(1)+3);
    else
        s = timeString(index(2)+1:index(2)+2);
        ms = '0';
    end
end

time = 1000*(3600000*str2double(h) + 60000*str2double(m) + 1000*str2double(s) + str2double(ms)); % in [us]

if(isnan(time))
    time = 0;
end

end
