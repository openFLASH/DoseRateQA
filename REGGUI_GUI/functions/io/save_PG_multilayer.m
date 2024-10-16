%% save_PG_multilayer
% Save the promt gamma intensity profile in a text file.
%
%% Syntax
% |save_PG_multilayer(beam,outname,type)|
%
%
%% Description
% |save_PG_multilayer(beam,outname,type)| Save PG intensity profile in file
%
%
%% Input arguments
% |beam| - _STRUCTURE_ - Structure with proton beam information 
%
% * |beam(1).spots(j).simulation{s}(b)| - _SCALAR VECTOR_ - In the case of simulation,Prompt gamma intensity in the b-th measurement bin
% * |beam(1).spots(j).measure{s}(b)| - _SCALAR VECTOR_ - In the case of measure, Prompt gamma intensity in the b-th measurement bin
% * |beam.spots(j).xy(s,:)| - _SCALAR VECTOR_ - Position (x,y) (in mm) of the s-th spot in the j-th energy layer 
% * |beam.spots(j).nb_protons(s)| - _SCALAR_ - Number of proton in the s-th spot of the l-th energy layer
%
% |outname| - _STRING_ - Name of the file (including path) where the data will be saved
%
% |type| - _STRING_ - [OPTIONAL. Default = 'simulation'] Type of PG data. Options are: 'simulation', 'measurement'
%
%
%% Output arguments
%
% None
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function save_PG_multilayer(beam,outname,type)

if(nargin<3)
    type = 'simulation';
end

fid = fopen(outname,'w');
endl = java.lang.System.getProperty('line.separator').char;
fprintf(fid,['TIH',endl]);
fprintf(fid,['[]',endl]);

nb_layers = length(beam(1).spots);

switch type
    case 'simulation'
        for n = 1:nb_layers
            nb_spots = size(beam(1).spots(n).simulation,1);
            for s = 1:nb_spots
                xy = beam(1).spots(n).xy(s,:)';
                nb_protons = 1e9;%beam(1).spots(n).nb_protons(s);
                profile = nb_protons*beam(1).spots(n).simulation(s,:)';
                irradiation_time = NaN;
                fprintf(fid,'[Layer, Spot, Irradiation time, X, Y, Protons]:[%i,%i,%i,%f,%f,%f]',[n,s,irradiation_time,xy(1),xy(2),nb_protons]);fprintf(fid,endl);
                fprintf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,',profile);fprintf(fid,endl);
            end
        end
    case 'measurement'
        for n = 1:nb_layers
            nb_spots = length(beam(1).spots(n).measure);
            for s = 1:nb_spots
                xy = beam(1).spots(n).xy(s,:)';
                nb_protons = beam(1).spots(n).nb_protons(s);
                profile = nb_protons*beam(1).spots(n).measure{s}';
                irradiation_time = NaN;
                fprintf(fid,'[Layer, Spot, Irradiation time, X, Y, Protons]:[%i,%i,%i,%f,%f,%f]',[n,s,irradiation_time,xy(1),xy(2),nb_protons]);fprintf(fid,endl);
                fprintf(fid,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,',profile);fprintf(fid,endl);
            end
        end
end
fclose(fid);
