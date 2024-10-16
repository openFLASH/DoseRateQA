function display_indicators(indicator_list,tab,name_list)

if(nargin<2)
    tab = gcf;
end

if(nargin<3)
    name_list = {};
    for n=1:length(indicator_list)
        name_list{end+1} = '';
    end
end

title_color = [0;0;0];
txt_color = [0.2;0.2;0.2];
report_txt = {};

for n=1:length(indicator_list)
    
    indicators = indicator_list{n};   
    
    report_txt{end+1,1} = sprintf(['<html><pre><b><font color="#',color2hex(title_color),'">',...
        name_list{n},...
        '</font></b></pre></html>']);
    report_txt{end+1,1} = sprintf(['<html><pre><b><font color="#',color2hex(txt_color),'">',...
        strpad('Structure',24),...
        strpad('Indicator',32),...
        strpad('Constraint',16),...
        strpad('Evaluation',16),...
        '</font></b></pre></html>']);
    
    for i=1:length(indicators)
        
        %     indicators{i}.struct
        %     indicators{i}.beam
        %     indicators{i}.type
        %     indicators{i}.value
        %     indicators{i}.unit
        %     indicators{i}.param
        %     indicators{i}.param_unit
        %     indicators{i}.acceptance_test
        %     indicators{i}.acceptance_level
        %     indicators{i}.acceptance_unit
        %     indicators{i}.acceptance_tolerance
        %     indicators{i}.prescription
        %     indicators{i}.evaluation
        %     indicators{i}.acceptance_evaluation
        
        if(isfield(indicators{i},'evaluation') && isfield(indicators{i},'acceptance_evaluation'))
            
            switch indicators{i}.acceptance_evaluation
                case 'pass'
                    flag_color = [0;192;0];
                case 'fail'
                    flag_color = [240;0;0];
                otherwise
                    flag_color = [255;128;0];
            end
            
            report_txt{end+1,1} = sprintf(['<html><pre>',...
                '<font color="#',color2hex(indicators{i}.struct_color),'">&#x25a0;</font>',...
                '<font color="#',color2hex(txt_color),'"> ',...
                strpad(indicators{i}.struct,24),...
                strpad([indicators{i}.type,'_',indicators{i}.value,num2str(indicators{i}.param),strrep(indicators{i}.param_unit,'[]','')],32),...
                strpad([indicators{i}.acceptance_test,num2str(indicators{i}.acceptance_level),strrep(indicators{i}.acceptance_unit,'[]','')],16),...
                '</font><font color="#',color2hex(flag_color),'"> ',strpad([strrep(num2str(indicators{i}.evaluation),'NaN',''),strrep(indicators{i}.unit,'[]','')],16),...
                '</font></pre></html>']);
            
        end
        
    end
    
    report_txt{end+1,1} = '';
    
end

uicontrol('Parent',tab,'Style','list','Units','normalized','Position',[0,0,1,1],'String',report_txt);

