%% save_Indicators
% Save to disk a treatment indicators.
% The format of the file can be specified
%
%% Syntax
% |save_Indicators(indicators,outname,format)|
%
%% Description
% |save_Indicators(indicators,outname,format)| Save the indicators in file at specified format
%
%% Input arguments
% |indicators| - _STRUCTURE_ - Description of the treatment indicators. See |convert_Indicators| for details
%
% |outname| - _STRING_ - Name of the file in which the indicators should be saved
%
% |format| - _INTEGER_ -   Format to use to save the file. The options are: 
%
% * 'json' : JSON  File
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function save_Indicators(indicators,outname,format)

switch format
    
    case 'json'
        
        % convert indicators structure into json string
        output = '{"indicators":[[';
        for i=1:length(indicators)
            output = [output,'{'];
            tags = fieldnames(indicators{i});
            for t=1:length(tags)
                value = indicators{i}.(tags{t});
                if(not(isempty(value)))
                    if(ischar(value))
                        output = [output,'"',tags{t},'":"',value,'",,'];
                    elseif(isnumeric(value))
                        value(isnan(value)) = -10000;
                        if(sum(size(value))>2)
                            output = [output,'"',tags{t},'":'];
                            output = [output,'['];
                            for j=1:size(value,1)
                                for k=1:size(value,2)
                                    output = [output,num2str(value(j,k)),';;'];
                                end                                
                            end
                            output = [output(1:end-2),'];;'];
                            output = [output(1:end-2),',,'];
                        else
                            output = [output,'"',tags{t},'":',num2str(value),',,'];
                        end
                    else
                        disp(['Cannot write indicator tag ',tags{t}]);
                    end
                end
            end
            output = [output(1:end-2),'},,'];
        end
        output = [output(1:end-2),']}'];% end
        
        % write json to file
        outname = strrep(outname,'.json','');
        fid = fopen([outname,'.json'],'w');
        output = strrep(output,'\','\\\\');
        output = strrep(output,'%','%%');
        output = strrep(strrep(strrep(strrep(output,':{',':\n{\n'),':[[',':\n[\n'),',,',',\n'),';;',',');
        fprintf(fid,output);
        fclose(fid);
            
    otherwise        
        error('Invalid type. Available output formats are: json.')
        
end
