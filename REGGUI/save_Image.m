%% save_Image
% Save to disk an image. The image can be stored as a DICOM file on the local disk or on the Orthanc PACS if |format = 'pacs'|.
% The format of the file can be specified.
%
%% Syntax
% |info = save_Image(outdata,info,outname,format)|
%
% |info = save_Image(outdata,info,outname,format,automode)|
%
% |info = save_Image(outdata,info,outname,format,automode,input_dicom_tags)|
%
%
%% Description
% |info = save_Image(outdata,info,outname,format)|
%
% |info = save_Image(outdata,info,outname,format,automode)|   Save the image on disk at the specified format and manully/automatically select the image modality
%
% |info = save_Image(outdata,info,outname,format,automode,input_dicom_tags)|   Save the image with additional DICOM tags on disk at the specified format and manully/automatically select the image modality
%
%
%% Input arguments
% |outdata| - _SCALAR MATRIX_ - |data{i}(x,y,z)| Intensity of the voxel at coordinate (x,y,z) in the image
%
% |info| - _STRUCTURE_ - Meta information from the DICOM file that will be saved to the file
%
% * |info.OriginalHeader.Modality| - __ -
% * |info.OriginalHeader.SOPClassUI| - __ -
% * |info.StudyInstanceUID| - __ -
% * |info.Spacing| - __ -
% * |info.PatientID| - __ -
% * |info.OriginalHeader.PatientID| - __ -
% * |info.OriginalHeader.PatientName| - __ -
% * |info.OriginalHeader.PatientBirthDate| - __ -
% * |info.OriginalHeader.PatientSex| - __ -
% * |info.ImagePositionPatient| - __ -
% * |info.FrameOfReferenceUID| - __ -
%
% |outname| - _STRING_ - Name of the file in which the image should be saved
%
% |format| - _STRING_ -   Format to use to save the file. The options are:
%
% * 'pacs' : Send the image to Orthanc PACS
% * 'dcm' : DICOM File
% * 'mat' : Matlab File
% * 'mhd' : META File
% * 'img' : Raw binary file (tomo format)
% * 'png' : PNG File (only 2D images)
% * 'txt' : TXT File
%
% |automode| - _INTEGER_ - [OPTIONAL Default =0] If not null and if |info.OriginalHeader.Modality| is absent, then a dialog box is displayed to manually choose the image modality.
%
% |input_dicom_tags| - _CELL VECTOR_ -  [OPTIONAL] If provided and non-empty, additioanl DICOM tags to be saved in the file
%
% * |input_dicom_tags{i,1}| - _STRING_ - DICOM Label of the tag
% * |input_dicom_tags{i,2}| - _ANY_ Value of the tag
%
%
%% Output arguments
%
% |info| - _STRUCTURE_ - Meta information from the DICOM file. The information is updated
%
%
%% Contributors
% Authors : G.Janssens, J.Orban (open.reggui@gmail.com)


function info = save_Image(outdata,info,outname,format,automode,input_dicom_tags)

current_dir = pwd;
if(strcmp(format,'pacs'))
    [~,reggui_config_dir] = get_reggui_path();
    dirname = fullfile(reggui_config_dir,'temp_dcm_data');
    if(not(exist(dirname,'dir')))
        mkdir(dirname);
    end
    imname = outname;
else
    [dirname,imname] = fileparts(outname);
end
try
    cd(dirname);
catch
    disp('Unknown path directory. Writing image in current folder...')
    dirname = current_dir;
end
imname = strrep(imname,' ','_');

try
    switch format
        case {'dcm','pacs'} % Export as DICOM

            modality = '';
            if(isfield(info,'OriginalHeader'))
                if(isfield(info.OriginalHeader,'Modality'))
                    modality = info.OriginalHeader.Modality;
                end
            end
            if(isempty(modality))
                if(nargin>4)
                    if(not(automode))
                        Choice = questdlg('In which modality do you wish to store this image?', ...
                            'Choose', ...
                            'CT', 'MR','Other','Other');
                        if(strcmp(Choice,'CT'))
                            modality = 'CT';
                        end
                        if(strcmp(Choice,'MR'))
                            modality = 'MR';
                        end
                    end
                else
                    Choice = questdlg('In which modality do you wish to store this image?', ...
                        'Choose', ...
                        'CT', 'MR','Other','Other');
                    if(strcmp(Choice,'CT'))
                        modality = 'CT';
                    end
                    if(strcmp(Choice,'MR'))
                        modality = 'MR';
                    end
                end
            end

            if isfield(info,'OriginalHeader')
                if( not(isempty(info.OriginalHeader)) && isfield(info.OriginalHeader,'SOPClassUID') )
                    disp(['Using original header information. Exporting in ',modality,' modality']);
                    myMeta = info.OriginalHeader;
                else
                    if(strcmp(modality,'CT'))
                        dicomwrite(int16(outdata(:,:,1))',strcat(imname,'_001.dcm'),'ObjectType','CT Image Storage');
                        myMeta = dicominfo(strcat(imname,'_001.dcm'));
                        myMeta.ImageType = 'DERIVED\SECONDARY\AXIAL';
                    elseif(strcmp(modality,'MR'))
                        dicomwrite(int16(outdata(:,:,1))',strcat(imname,'_001.dcm'),'ObjectType','MR Image Storage');
                        myMeta = dicominfo(strcat(imname,'_001.dcm'));
                    else
                        dicomwrite(int16(outdata(:,:,1))',strcat(imname,'_001.dcm'));
                        myMeta = dicominfo(strcat(imname,'_001.dcm'));
                    end
                    delete(strcat(imname,'_001.dcm'));
                end
            else
                if(strcmp(modality,'CT'))
                    dicomwrite(int16(outdata(:,:,1))',strcat(imname,'_001.dcm'),'ObjectType','CT Image Storage');
                    myMeta = dicominfo(strcat(imname,'_001.dcm'));
                    myMeta.ImageType = 'DERIVED\SECONDARY\AXIAL';
                elseif(strcmp(modality,'MR'))
                    dicomwrite(int16(outdata(:,:,1))',strcat(imname,'_001.dcm'),'ObjectType','MR Image Storage');
                    myMeta = dicominfo(strcat(imname,'_001.dcm'));
                else
                    dicomwrite(int16(outdata(:,:,1))',strcat(imname,'_001.dcm'));
                    myMeta = dicominfo(strcat(imname,'_001.dcm'));
                end
                delete(strcat(imname,'_001.dcm'));
            end

            if(strcmp(modality,'PT') && isfield(myMeta,'SuvBodyWeightCoef')) % PET specific processing of SUV values
                if(isfield(myMeta,'SuvBodyWeightCoef'))
                    myMeta = rmfield(myMeta,'SuvBodyWeightCoef');
                end
                if(isfield(myMeta,'DecayCorrection'))
                    myMeta = rmfield(myMeta,'DecayCorrection');
                end
                %                 try
                %                     if strcmp(myMeta.DecayCorrection,'ADMIN')
                %                         disp(['using SuvBodyWeightCoef : ',num2str(myMeta.SuvBodyWeightCoef)]);
                %                         outdata  = outdata ./ myMeta.SuvBodyWeightCoef;
                %                     end
                %                     if strcmp(myMeta.DecayCorrection,'START')
                %                         disp(['using SuvBodyWeightCoefs']);
                %                         if isempty(strfind(myMeta.SeriesType,'DYNAMIC'))
                %                             for i=1:size(outdata,3)
                %                                 slice = (i-1)*info.Spacing(3)+info.ImagePositionPatient(3); % position in the current image
                %                                 corr_factor = interp1(myMeta.SuvBodyWeightCoef(:,1),myMeta.SuvBodyWeightCoef(:,2),slice);
                %                                 if(isnan(corr_factor) || (corr_factor==0))
                %                                     corr_factor = mean(myMeta.SuvBodyWeightCoef(:,2));
                %                                 end
                %                                 outdata(:,:,i)     = outdata(:,:,i) ./ corr_factor;
                %                             end
                %                         end
                %                     end
                %                 catch
                %                     disp('Warning : failed to process SUV values (SubBodyWeightCoef).')
                %                     err = lasterror;
                %                     disp(['    ',err.message]);
                %                     disp(err.stack(1));
                %                 end
            end

            % Grid scaling for Dose image
            if isDoseOrDoseRate(modality)
                if (isfield(myMeta,'DoseGridScaling'))
                    outdata = outdata/myMeta.DoseGridScaling;
                end

                while max(abs(outdata(:)))>=2^16
                    disp('Dose values are too large to be stored in INT16. Entire image is divided by 2...');
                    myMeta.DoseGridScaling = myMeta.DoseGridScaling*2;
                    outdata = outdata/2;
                end
                if(max(abs(outdata(:)))<2^15)
                    myMeta.DoseGridScaling = myMeta.DoseGridScaling / ((2^15) / max(outdata(:)));
                    outdata = outdata * (2^15) / max(outdata(:));
                end
                if(min(outdata(:))<0)
                   pixel_representation = 1;
                else
                   pixel_representation = 0;
                end
            else
                % Rescale image intensities
                RescaleSlope = 1;
                RescaleIntercept = floor(min(outdata(:)));
                if(isfield(myMeta,'RescaleSlope')&&isfield(myMeta,'RescaleIntercept'))
                    RescaleSlope = myMeta.RescaleSlope;
                    RescaleIntercept = myMeta.RescaleIntercept;
                elseif(isfield(myMeta,'RescaleSlope'))
                    RescaleSlope = myMeta.RescaleSlope;
                else
                    outdata(isinf(outdata))=min(outdata(:));
                    while max(abs(outdata(:)))>=2^15
                        disp('Pixel values are too large to be stored in INT16. Entire image is divided by 2...');
                        RescaleSlope = RescaleSlope/2;
                        outdata = outdata/2;
                    end
                    if max(abs(outdata(:)))<2^6
                        disp('Intensity range is too small. Entire image is rescaled...');
                        RescaleSlope = (max(outdata(:))-RescaleIntercept)/2^12;
                    end
                end
                if(not(RescaleSlope))
                    RescaleSlope = 1;
                end
                outdata = (outdata-RescaleIntercept)/RescaleSlope;
                % Reduce 'rounding' errors...
                if(not(strcmp(modality,'CT')))
                    [outdata,RescaleSlope] = roundsdm(outdata,4,2,14);
                    outdata = outdata/RescaleSlope;
                    myMeta.RescaleSlope = RescaleSlope;
                end
                if(not(RescaleSlope==1))
                    disp(['RescaleSlope of ',num2str(RescaleSlope),' (max value: ',num2str(max(abs(outdata(:)))),')'])
                end
                outdata = round(outdata);
                % Update dicom tags
                myMeta.RescaleSlope = RescaleSlope;
                myMeta.RescaleIntercept = RescaleIntercept;
            end

            Date = datestr(now,'yyyymmdd');
            Time = datestr(now,'HHMMSS');

            % study info
            myMeta.StudyDate            = Date;
            myMeta.StudyTime            = Time;
            if not(isfield(myMeta,'StudyDescription'))
                myMeta.StudyDescription = 'reggui_simulation';
            end
            if not(isfield(myMeta,'StudyInstanceUID'))
                myMeta.StudyInstanceUID = info.StudyInstanceUID;
            end

            % series info
            if not(isfield(info,'SeriesDescription'))
                myMeta.SeriesDescription = imname;
                myMeta.SeriesDescription = imname;
            else
                myMeta.SeriesDescription = info.SeriesDescription;
            end

            myMeta.SeriesInstanceUID    = dicomuid;
            myMeta.SeriesNumber         = '';
            myMeta.SeriesDate           = Date;
            myMeta.SeriesTime           = Time;
            myMeta.InstanceCreationDate = Date;
            myMeta.InstanceCreationTime = Time;

            % Image properties
            if(info.Spacing(1)~=info.Spacing(2))
                myMeta.PixelAspectRatio = [round(1e4*info.Spacing(2))/1e4 round(1e4*info.Spacing(1))/1e4];
                info.Spacing(1)         = round(1e4*info.Spacing(1))/1e4;
                info.Spacing(2)         = round(1e4*info.Spacing(2))/1e4;
            end
            myMeta.PixelSpacing(1)      = double(info.Spacing(2));
            myMeta.PixelSpacing(2)      = double(info.Spacing(1));
            if isDoseOrDoseRate(modality)
                myMeta.SliceThickness = info.Spacing(3);
                myMeta.GridFrameOffsetVector = 0:info.Spacing(3):info.Spacing(3)*(size(outdata,3)-1);
                myMeta.FrameIncrementPointer = [12292 12]; % points to tag (3004,00C) GridFrameOffsetVector
                if(isfield(myMeta,'SpacingBetweenSlices'))
                    myMeta = rmfield(myMeta,'SpacingBetweenSlices');
                end
            end
            if (not(isDoseOrDoseRate(modality) && not(isfield(myMeta,'SpacingBetweenSlices'))))
                myMeta.SpacingBetweenSlices = info.Spacing(3); % can be negative => different from spacing(3)? Normaly not, as slices exported in ascending order from reggui
            end
            if(isfield(myMeta,'SliceThickness'))
                if(isempty(myMeta.SliceThickness))
                    myMeta.SliceThickness = info.Spacing(3);
                end
            end
            myMeta.Width                = size(outdata,1);
            myMeta.Columns              = size(outdata,1);
            myMeta.Height               = size(outdata,2);
            myMeta.Rows                 = size(outdata,2);
            if(isfield(myMeta,'PixelPaddingValue'))
                myMeta = rmfield(myMeta,'PixelPaddingValue');
            end

            % reset content info
            myMeta.ContentLabel = '';
            myMeta.ContentDescription = '';

            % patient info
            myMeta.PatientID = info.PatientID;
            if isfield(info,'OriginalHeader')
                try
                    myMeta.PatientID = info.OriginalHeader.PatientID;
                    myMeta.PatientName = info.OriginalHeader.PatientName;
                    myMeta.PatientBirthDate = info.OriginalHeader.PatientBirthDate;
                    myMeta.PatientSex = info.OriginalHeader.PatientSex;
                catch
                end
            end
            myMeta.ImagePositionPatient = info.ImagePositionPatient;
            if (isempty(info.FrameOfReferenceUID))
                myMeta.FrameOfReferenceUID = dicomuid;
                info.FrameOfReferenceUID = myMeta.FrameOfReferenceUID;
            else
                myMeta.FrameOfReferenceUID = info.FrameOfReferenceUID;
            end
            myMeta.ImageOrientationPatient = info.PatientOrientation;

            % Default mandatory information
            give_default_name = 0;
            if(not(isfield(myMeta,'PatientName')))
                give_default_name = 1;
            elseif(isempty(myMeta.PatientName))
                give_default_name = 1;
            elseif(isstruct(myMeta.PatientName))
                give_default_name = 1;
                names = fieldnames(myMeta.PatientName);
                for n=1:length(names)
                    if(not(isempty(myMeta.PatientName.(names{n}))))
                       give_default_name = 0;
                    end
                end
            end
            if(not(isfield(myMeta,'PatientPosition')))
                myMeta.PatientPosition = 'HFS';
            elseif(isempty(myMeta.PatientPosition))
                myMeta.PatientPosition = 'HFS';
            end
            if(give_default_name)
                myMeta.PatientName = 'unknown';
            end
            if(not(isfield(myMeta,'Manufacturer')))
                myMeta.Manufacturer = 'reggui';
            elseif(isempty(myMeta.Manufacturer))
                myMeta.Manufacturer = 'reggui';
            end

            % additional input dicom tags
            if(nargin>5)
                for i=1:size(input_dicom_tags,1)
                    try
                        myMeta.(input_dicom_tags{i,1}) = input_dicom_tags{i,2};
                    catch
                    end
                end
            end

            % check that TransferSyntaxUID exists
            if(not(isfield(myMeta,'TransferSyntaxUID')))
                myMeta.TransferSyntaxUID = '1.2.840.10008.1.2';
            end

            % Dicom export
            try
                rmdir(fullfile(dirname,imname),'s');
                disp('Warning: dicom serie already exists! This will be replaced by the new image.')
            catch
            end

            % Create output directory
            if not(isDoseOrDoseRate(modality))
                mkdir(fullfile(dirname,imname));
                cd(fullfile(dirname,imname));
            end

            % Write dicom files to disk
            if isDoseOrDoseRate(modality)
                outdata = permute(outdata,[2 1 4 3]);
                exported_file = strcat(imname,'.dcm');
                if(pixel_representation)
                    myMeta.PixelRepresentation = pixel_representation;
                    dicomwrite(int16(outdata),exported_file,myMeta,'CreateMode','copy');
                else
                    dicomwrite(uint16(outdata),exported_file,myMeta,'CreateMode','copy');
                end
                exported_file = fullfile(dirname,exported_file);
            else
                exported_file = fullfile(dirname,imname);
                for slice = 1:size(outdata,3)
                    myMeta.ImagePositionPatient(3) = (slice-1)*info.Spacing(3)+info.ImagePositionPatient(3);
                    myMeta.SliceLocation = (slice-1)*info.Spacing(3)+info.ImagePositionPatient(3);
                    myMeta.InstanceNumber = slice;
                    myMeta.SmallestImagePixelValue = min(min(outdata(:,:,slice)));
                    myMeta.LargestImagePixelValue  = max(max(outdata(:,:,slice)));
                    % write output dicom file
                    output_filename = strcat(imname,sprintf('_%04i',slice),'.dcm');
                    try
                        dicomwrite(int16(outdata(:,:,slice))',output_filename,myMeta,'CreateMode','copy');
                    catch
                        % if 'copy' mode failed, try to re-generate missing data values
                        if(slice==1)
                            disp('Warning: ''copy'' mode failed. Re-generating missing data values...');
                        end
                        dicomwrite(int16(outdata(:,:,slice))',output_filename,myMeta);
                    end
                    dcmInfo = dicominfo(output_filename);
                    info.SOPInstanceUID(slice).SOPInstanceUID = dcmInfo.SOPInstanceUID;
                end
            end

            % keep new dicom header if needed
            info.OriginalHeader = myMeta;

            % send to PACS if needed
            if(strcmp(format,'pacs'))
                disp('Sending dicom files to PACS...')
                orthanc_import_from_disk('instances',exported_file);
                cd(current_dir)
                if(isdir(exported_file))
                    try
                        rmdir(exported_file,'s');
                    catch
                        disp(['Warning: cannot delete folder ',exported_file]);
                    end
                else
                    try
                        delete(exported_file);
                    catch
                        disp(['Warning: cannot delete folder ',exported_file]);
                    end
                end
            end


        case 'mat' % Export as .mat
            out = struct;
            out.data = outdata;
            out.info = info;
            save(outname,'out','-v7.3');

        case 'mhd'
            % raw file name
            imname_raw = [imname,'.raw'];
            imname = [imname,'.mhd'];
            % data type
            outdata = single(outdata);
            % shortcuts
            dims = [size(outdata)';1;1];
            spas = info.Spacing;
            % offsets
            offs = info.ImagePositionPatient;
            % write header file
            fid = fopen(imname,'wt');
            fprintf(fid, 'ObjectType = Image \n');
            % true 4D array
            spas = [spas;1.0];
            offs = [offs;0.0];
            % 2D/3D/4D
            ndims = max(find(dims>1));
            fprintf(fid, 'NDims = %i\n',ndims);
            fprintf(fid, 'BinaryData = %s\n','True');
            fprintf(fid,['DimSize = ',repmat('%i ',1,ndims),'\n'],dims(1:ndims));
            fprintf(fid, 'ElementNumberOfChannels = %i\n',1);
            fprintf(fid, 'ElementType = %s\n','MET_FLOAT');
            fprintf(fid,['ElementSpacing = ',repmat('%f ',1,ndims),'\n'],spas(1:ndims));
            fprintf(fid,['Offset = ',repmat('%f ',1,ndims),'\n'],offs(1:ndims));
            fprintf(fid,'ElementByteOrderMSB = %s\n','False');
            fprintf(fid,'ElementDataFile = %s\n',imname_raw);
            fclose(fid);
            % write data file
            fid = fopen(imname_raw,'wb');
            for fval = 1:dims(4)
                for zval = 1:dims(3)
                    tmp = outdata(:,:,zval,fval);
                    fwrite(fid,tmp,'float');
                end
            end
            fclose(fid);

        case 'img' % export as binary file
            % raw file name
            imname_raw = [imname,'.img'];

            modality = '';
            if(isfield(info,'OriginalHeader'))
                if(isfield(info.OriginalHeader,'Modality'))
                    modality = info.OriginalHeader.Modality;
                end
            end
            if(isempty(modality))
                if(nargin>4)
                    if(not(automode))
                        Choice = questdlg('In which modality do you wish to store this image?', ...
                            'Choose', ...
                            'CT','Other','Other');
                        if(strcmp(Choice,'CT'))
                            modality = 'CT';
                        end
                    end
                else
                    modality = 'Other';
                end
            end

            % shortcuts
            dims = size(outdata)';
            % write data file
            fid = fopen(imname_raw,'wb','b');

            if(strcmp(modality,'CT'))
                % convert data to fit in unsigned short
                outdata = round(outdata)+1024;
                outdata(outdata<0) = 0;
                outdata = uint16(outdata);
                disp('Exporting as CT image (uint16 format)...')
                for zval = dims(3):-1:1
                    tmp = outdata(:,:,zval);
                    fwrite(fid,tmp,'uint16');
                end
                fclose(fid);
            else
                % check data range for selecting format (HEURISTIC !!!)
                range = max(max(max(outdata)))-min(min(min(outdata)));
                is_float = sum(sum(sum(outdata-round(outdata))));
                if(is_float)
                    outformat = 'float32';
                    outdata = single(outdata);
                else
                    if(range<2^8)
                        if(min(min(min(outdata)))<0)
                            outformat = 'int8';
                        else
                            outformat = 'uint8';
                        end
                    elseif(range<2^16)
                        if(min(min(min(outdata)))<0)
                            outformat = 'int16';
                        else
                            outformat = 'uint16';
                        end
                    else
                        if(min(min(min(outdata)))<0)
                            outformat = 'int32';
                        else
                            outformat = 'uint32';
                        end
                    end
                    eval(['outdata = ',outformat,'(outdata);'])
                end
                disp(['Exporting in ',outformat,' format...'])
                for zval = dims(3):-1:1
                    tmp = outdata(:,:,zval);
                    fwrite(fid,tmp,outformat);
                end
                fclose(fid);
            end

            % Export header in .mat format
            out = struct;
            out.data = imname_raw;
            out.info = info;
            out.info.Size = size(outdata);
            save([imname,'_hdr.mat'],'out');

        case 'png' % Export as 2D .png image
            imwrite(uint8(outdata(:,:,1)/(max(max(outdata(:,:,1)))+eps)*255),[strrep(outname,'.png',''),'.png'],'png');

        case 'txt' % Export in txt format
            try
                nb_elements_per_line = 1;
                fid = fopen(strcat(outname,'.txt'),'w');
                fprintf(fid,' # IMAGE ');fprintf(fid,'\n');
                fprintf(fid,num2str(info.Spacing(1)));fprintf(fid,' ');
                fprintf(fid,num2str(info.Spacing(2)));fprintf(fid,' ');
                fprintf(fid,num2str(info.Spacing(3)));fprintf(fid,'\n');
                fprintf(fid,int2str(size(outdata,1)));fprintf(fid,' ');
                fprintf(fid,int2str(size(outdata,2)));fprintf(fid,' ');
                fprintf(fid,int2str(size(outdata,3)));fprintf(fid,'\n');
                index = 0;
                for i=1:size(outdata,3)
                    for j=1:size(outdata,2)
                        for k=1:size(outdata,1)
%                             if(not(index))
%                                 fprintf(fid,'     ');
%                             end
%                             s = int2str(outdata(k,j,i));
%                             if(length(s)==1)
%                                 s = ['0',s];
%                             end
%                             fprintf(fid,s);
%                             index = index+1;
%                             if(index>=nb_elements_per_line)
%                                 fprintf(fid,' \n');
%                                 index=0;
%                             else
%                                 fprintf(fid,' ');
%                             end
                            fprintf(fid,'%d',outdata(k,j,i));
                            index = index+1;
                            if(index>=nb_elements_per_line)
                                fprintf(fid,' \n');
                                index=0;
                            else
                                fprintf(fid,' ');
                            end
                        end
                    end
                end
                fclose(fid);
            catch ME
                disp('Error occured !')
                cd(current_dir)
                rethrow(ME);
            end

        otherwise
            error('Invalid type. Available output formats are: dcm, mat, mhd, img, png and txt.')
    end
catch ME
    disp('Error occured !')
    rethrow(ME);
end
cd(current_dir)

end
