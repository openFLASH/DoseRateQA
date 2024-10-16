%% save_DVH
% Save the dose volume historgram (DVH) stored in |handles.dvhs| into a file at the specified format.
%
%% Syntax
% |save_DVH(dvhs,outname,format)|
%
%
%% Description
% |save_DVH(dvhs,outname,format)| Save the DVH to file
%
%
%% Input arguments
% |dvhs| - _CELL VECTOR of STRUCTURE_ - |dvhs{i}| Data structure describing the i-th curve of the dose volume histogram.
%
% * |dvhs{i}.dose| - _STRING_ - Dose name
% * |dvhs{i}.volume| - _STRING_ - Volume name
% * |dvhs{i}.Dp| - _SCALAR_ - Prescribed dose (Gy)
% * |dvhs{i}.dmin| - _SCALAR_ - Minimum dose (Gy)
% * |dvhs{i}.dmean| - _SCALAR_ - Mean dose (Gy)
% * |dvhs{i}.dmax| - _SCALAR_ - Maximum dose (Gy)
% * |dvhs{i}.hexcolor| - _SCALAR_ - Hexadecimal colour code used to display the i-th curve on the DVH plot
% * |dvhs{i}.dvh_X| - _SCALAR VECTOR_ - |dvh_X(d)| Coordinate of the d-th point on the DVH i-th curve
% * |dvhs{i}.dvh| - _SCALAR VECTOR_ - |dvh(d)| Abscice of the d-th point on the DVH i-th curve
%
% |outname| - _STRING_ - Name of the file in which the DVH should be saved
%
% |format| - _STRING_ - Format to use to save the file. The options are: '.mat', 'json'.
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function save_DVH(dvhs,outname,format,sampling,max_dose)

if(nargin<4)
    sampling = 0;
end
if(nargin<5)
    max_dose = [];
end

try
    switch format
        case 'mat' % Export as MAT file
            
            save([outname,'.mat'],'dvhs');
            
        case {'json','twiga'} % Export in json format
            try
                
                if(strcmp(format,'twiga'))
                    interp_type = 'nearest';
                else
                    interp_type = 'pchip';
                end
                
                % get max dose
                if(isempty(max_dose))
                    max_dose = 0;
                    for d=1:length(dvhs)
                        max_dose = max(max_dose,ceil(max(dvhs{d}.dvh_X)));
                    end
                end
                % create output text line
                output = '{"dvh":[';
                for d=1:length(dvhs)
                    output = [output,'{'];
                    output = [output,'"dose name":"',dvhs{d}.dose,'",'];
                    output = [output,'"dose unit":"Gy",'];
                    if(isfield(dvhs{d},'contour'))
                        output = [output,'"volume name":"',dvhs{d}.contour,'",'];
                    else
                        output = [output,'"volume name":"',dvhs{d}.volume,'",'];
                    end
                    output = [output,'"volume unit":"percent",'];
                    if(isfield(dvhs{d},'Dp'))
                        if(dvhs{d}.Dp>0)
                            output = [output,'"prescription":',num2str(dvhs{d}.Dp),','];
                        end
                    end                    
                    if(isfield(dvhs{d},'hexcolor'))
                        output = [output,'"hexcolor":"',dvhs{d}.hexcolor,'",'];
                    end
                    % extrapolate over the entire dose range
                    if(sampling<=0)
                        sampling = min(diff(dvhs{d}.dvh_X));
                    end
                    dose = [0:sampling:max_dose];
                    if(length(dvhs{d}.dvh_X)>1)
                        if(isfield(dvhs{d},'dmin'))
                            output = [output,'"dmin":',num2str(dvhs{d}.dmin),','];
                        end
                        if(isfield(dvhs{d},'dmean'))
                            output = [output,'"dmean":',num2str(dvhs{d}.dmean),','];
                        end
                        if(isfield(dvhs{d},'dmax'))
                            output = [output,'"dmax":',num2str(dvhs{d}.dmax),','];
                        end
                        volume = interp1(dvhs{d}.dvh_X,dvhs{d}.dvh,dose,interp_type,0);
                        first_value = find(volume>0,1,'first');
                        if(first_value>1)
                            volume(1:first_value-1) = volume(first_value);
                        end
                        volume = volume/max(volume)*100;
                    else
                        if(isfield(dvhs{d},'dmin'))
                            output = [output,'"dmin":NaN,'];
                        end
                        if(isfield(dvhs{d},'dmean'))
                            output = [output,'"dmean":NaN,'];
                        end
                        if(isfield(dvhs{d},'dmax'))
                            output = [output,'"dmax":NaN,'];
                        end
                        volume = zeros(size(dose)); % when only one value in the DVH, export all zeros
                    end
                    % remove unnecessary points                    
                    if(strcmp(format,'twiga'))
                        volume = round(round(volume,4,'significant'),4);
                        deriv = volume(3:end)-volume(1:end-2);
                        dose = [dose(1),dose(find(abs(deriv)>0)+1)];
                        volume = [volume(1),volume(find(abs(deriv)>0)+1)];
                    else
                        volume = round(volume,4,'significant');
                        deriv = volume(3:end)-volume(1:end-2);
                        dose = [dose(1),dose(find(abs(deriv)>0)+1),dose(end)];
                        volume = [volume(1),volume(find(abs(deriv)>0)+1),volume(end)];
                    end
                    % convert x and y vectors into lists of strings
                    dose = num2str(dose);
                    volume = num2str(volume);
                    for i=1:12
                        dose = strrep(dose,'  ',' ');
                    end
                    dose = strrep(dose,' ',',');
                    for i=1:4
                        dose = strrep(dose,',,',',');
                    end
                    for i=1:12
                        volume = strrep(volume,'  ',' ');
                    end
                    volume = strrep(volume,' ',',');
                    for i=1:4
                        volume = strrep(volume,',,',',');
                    end
                    output = [output,'"curve":{"dose":[',dose,'],"volume":[',volume,']}},'];
                end
                output = [output(1:end-1),']}'];
                
                % replace NaN by 'null'
                output = strrep(output,'NaN','null');
                
                % replace special characters
                output = strrep(output,'\','\\\\');
                output = strrep(output,'%','%%');
                output = strrep(strrep(output,':{',':\n{'),'},{','},\n{');
                
                % print to file
                fid = fopen(strcat(outname,'.json'),'w');
                fprintf(fid,output);
                fclose(fid);
                
            catch ME
                disp('Error occured !')
                rethrow(ME);
            end
        otherwise
            error('Invalid type. Available output formats are: mat and json.')
    end
catch
    disp('Error occured !')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end
