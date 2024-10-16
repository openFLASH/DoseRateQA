%% save_4D
% Save a multidimensional image to file. The format can be specified. The image can has up to 5 dimensions (x,y,z,t,J). (x,y,z) are 3 spatial dimension. t is the time. The last dimensions can be used to can be used to store the 3 components of the vectors of a vector field (J=1 for X composnent of the vector, J=2 for Y component, etc.) 
%
%% Syntax
% |info = save_4D(outdata,info,outname,format)|
%
%
%% Description
% |info = save_4D(outdata,info,outname,format)| Save the image to file
%
%
%% Input arguments
% |outdata| - _SCALAR MATRIX_ - |data(x,y,z,t,J)| representing the image.
%
% |info| - _CELL VECTOR of STRUCTURE_ - Structure with image information
%
% * |info{1}.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the images
% * |info{1}.ImagePositionPatient| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
%
% |outname| - _STRING_ - Name of the file (including path) where to save the image
%
% |format| - _STRING_ - format of the image. Options are: 'raw', 'mhd'
%
%
%% Output arguments
%
% |info| - _CELL VECTOR of STRUCTURE_ - Structure with image information. Same as input
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function info = save_4D(outdata,info,outname,format)

current_dir = pwd;
[dirname,imname] = fileparts(outname);
try
    cd(dirname);
catch
    disp('Unknown path directory. Writing field in current folder...')
    dirname = current_dir;
end
imname = strrep(imname,' ','_');

try
    switch format            
        case 'mat' % Export as .mat
            out = struct;
            out.data = outdata;
            out.info = info;
            save(outname,'out');
        case 'mhd'
            % raw file name
            imname_raw = [imname,'.raw'];
            imname = [imname,'.mhd'];
            % data type
            outdata = single(outdata);
            % shortcuts
            dims = [size(outdata)';1;1];
            spas = [info{1}.Spacing;1];
            % offsets
            offs = [info{1}.ImagePositionPatient;0];
            % write header file
            fid = fopen(imname,'wt');
            fprintf(fid, 'ObjectType = Image \n');            
            fprintf(fid, 'NDims = %i \n',4);
            fprintf(fid, 'BinaryData = %s \n','True');
            ndims = max(find(dims>1));
            if(ndims==5) % 4D field                
                fprintf(fid,['DimSize = ',repmat('%i ',1,ndims)],dims(2:ndims));
                NumberOfChannels = 3;
            elseif(ndims==4) % 4D image
                fprintf(fid,['DimSize = ',repmat('%i ',1,ndims)],dims(1:ndims));
                NumberOfChannels = 1;
            end
            fprintf(fid,'\n');
            fprintf(fid, 'ElementNumberOfChannels = %i',NumberOfChannels);
            fprintf(fid,'\n');
            fprintf(fid, 'ElementType = %s \n','MET_FLOAT');
            fprintf(fid,['ElementSpacing = ',repmat('%f ',1,5)],spas(1:4));
            fprintf(fid,'\n');
            fprintf(fid,['Offset = ',repmat('%f ',1,5)],offs(1:4));
            fprintf(fid,'\n');
            fprintf(fid,'ElementByteOrderMSB = %s \n','False');
            %fprintf(fid,'ElementDataFile = %s \n',imname_raw);
            fprintf(fid,'ElementDataFile = %s \n',imname_raw);
            fclose(fid);
            % write data file
            fid = fopen(imname_raw,'wb');
            for k = 1:dims(5)
                for j = 1:dims(4)
                    for i = 1:dims(3)
                        tmp = outdata(:,:,i,j,k);
                        fwrite(fid,tmp,'float');
                    end
                end
            end
            fclose(fid);
        otherwise
            disp('Invalid format. Please choose mat or mhd.')
    end
catch ME
    disp('Error occured during 4D data export!')
    cd(current_dir)
    rethrow(ME);
end
cd(current_dir)
