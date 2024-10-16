%% read_dicomrtstruct
% Read a DICOM file of a RT structure. The function check that the SOPInstanceUID of the CT scan matches the ReferencedSOPInstanceUID of the contour.
% The coordinate system information from the CT scan is used to define the slice index of the different contours in the RT-struct
%
%% Syntax
% |StructOUT = read_dicomrtstruct(FileNameIN,RefImageInfo)|
%
%
%% Description
% |StructOUT = read_dicomrtstruct(FileNameIN,RefImageInfo)| Read the RT-struct from file
%
%
%% Input arguments
% |FileNameIN| - _STRING_ - Name of the DICOM file containing the RT-struct.
%
% |RefImageInfo| - _STRUCTURE_ DICOM Information about the CT scan associated to the RT struct
%
% ---|RefImageInfo.ImagePositionPatient| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
% ---|RefImageInfo.Spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the images
% ---|RefImageInfo.SOPInstanceUID| - _STRING_ - |RefImageInfo.SOPInstanceUID(s).SOPInstanceUID| DICOM SOP Instance UID of the s-th slice of the CT scan
% ---|RefImageInfo.SeriesInstanceUID| - _STRING_ - Series instance UID of the CT scan
%
%
%% Output arguments
%
% |StructOUT| - _STRUCTURE_ -  Data structure defining the DICOM RT-struct
%
% * |StructOUT.FileName| - _STRING_ - Name of the file with the DICOM RT-struct
% * |StructOUT.DicomHeader| - _STRUCTURE_ - DICOM tags read from the RT-struct file
% * |StructOUT.StructNum| - _INTEGER_ - Number of contours described in the file
% * |StructOUT.Struct| - _VECTOR of STRUCTURE_ - ||StructOUT.Struct(i)|| Description of the i-th contour
% * ----|StructOUT.Struct(i).Name| - _STRING_ - Name of the i-th contour = ROIName
% * ----|StructOUT.Struct(i).Color| - _STRING_ - Colour of the i-th contour = ROIDisplayColor
% * ----|StructOUT.Struct(i).Slice(j)| - _STRUCTURE_ - Structure describing the j-th slice of the i-th contour
% * -------|StructOUT.Struct(i).Slice(j).X| - _SCALAR VECTOR_ - |X(k)| X-coordinate (in mm) of the k-th point of the j-th slice of the i-th contour
% * -------|StructOUT.Struct(i).Slice(j).Y| - _SCALAR VECTOR_ - |Y(k)| Y-coordinate (in mm) of the k-th point of the j-th slice of the i-th contour
% * -------|StructOUT.Struct(i).Slice(j).Z| - _SCALAR VECTOR_ - |Z(k)| Z-coordinate (in mm) of the k-th point of the j-th slice of the i-th contour
%
%
%% Contributors
% Authors : L.Persoon, G.Janssens

function StructOUT = read_dicomrtstruct(FileNameIN,RefImageInfo)


try
    DicomHeader             =   dicominfo(FileNameIN,'UseVRHeuristic',false); % Possible not to use 'UseVRHeuristic' (starting from 2015b)
catch
    disp('Warning: could not open RT struct without the VR heuristic. Now trying using the heuristic...')
    DicomHeader             =   dicominfo(FileNameIN);
end

StructOUT.FileName      =   FileNameIN;
StructOUT.DicomHeader   =   DicomHeader;
StructOUT.StructNum  =   length(fieldnames(DicomHeader.ROIContourSequence));%StructOUT.StructNum  =   length(fieldnames(DicomHeader.StructureSetROISequence));

SOP_error = 0;

for StructCur=1:StructOUT.StructNum

    StructCurItem   =   ['Item_',num2str(StructCur)];
    StructOUT.Struct(StructCur).Name    =   DicomHeader.StructureSetROISequence.(StructCurItem).ROIName;
    if(isfield(DicomHeader.ROIContourSequence.(StructCurItem),'ROIDisplayColor'))
      StructOUT.Struct(StructCur).Color   =   DicomHeader.ROIContourSequence.(StructCurItem).ROIDisplayColor;
    else
      %The optional tag (3006,002A) ROIDisplayColor is not defined
      %Set contout colr to zero by default.
      StructOUT.Struct(StructCur).Color = [255,255,255];
    end
    SliceCur        =   1;
    SliceCurItem    =   'Item_1';
    SOP_error = 0;

    if(isfield(DicomHeader.ROIContourSequence.(StructCurItem),'ContourSequence'))
        while isfield(DicomHeader.ROIContourSequence.(StructCurItem).ContourSequence,SliceCurItem)
            StructOUT.Struct(StructCur).Slice(SliceCur).X   =   DicomHeader.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(1:3:end);
            StructOUT.Struct(StructCur).Slice(SliceCur).Y   =   DicomHeader.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(2:3:end);
            StructOUT.Struct(StructCur).Slice(SliceCur).Z   =   DicomHeader.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourData(3:3:end);

            if(nargin>1)
                try
                    StructOUT.Struct(StructCur).Slice(SliceCur).Z(1);
                    slice_index = round((StructOUT.Struct(StructCur).Slice(SliceCur).Z(1)-RefImageInfo.ImagePositionPatient(3))/RefImageInfo.Spacing(3) + 1);
                    if(not(strcmp(DicomHeader.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourImageSequence.Item_1.ReferencedSOPInstanceUID,RefImageInfo.SOPInstanceUID(slice_index).SOPInstanceUID)))
                        if(isempty(RefImageInfo.SOPInstanceUID(slice_index).SOPInstanceUID))
                            disp(['SOPInstanceUID is missing for image slice ',num2str(slice_index)]);
                        else
                            % disp(['Slice ',num2str(slice_index),': ',DicomHeader.ROIContourSequence.(StructCurItem).ContourSequence.(SliceCurItem).ContourImageSequence.Item_1.ReferencedSOPInstanceUID,'  differs from  ',RefImageInfo.SOPInstanceUID(slice_index).SOPInstanceUID])
                        end
                        SOP_error = SOP_error+1;
                    end
                catch
                    SOP_error = SOP_error+1;
                    % disp(['Reference to incorrect SOPInstanceUID (image slice ',num2str(slice_index),'). Reference image might be incorrect.']);
                    % err = lasterror;
                    % disp(['    ',err.message]);
                    % disp(err.stack(1));
                end
            end

            SliceCur        =   SliceCur+1;
            SliceCurItem    =   ['Item_',num2str(SliceCur)];
        end
    end

    if(SOP_error>0 && SOP_error<SliceCur-1)
        disp(['Warning: ',num2str(SOP_error),'/',num2str(SliceCur-1),' SOPInstanceUIDs do not correspond. Reference image might be incorrect (',RefImageInfo.SeriesInstanceUID,')']);
    end

end

if(SOP_error)
    disp(['Warning: SOPInstanceUIDs do not correspond. Reference image  might be incorrect (',RefImageInfo.SeriesInstanceUID,')']);
end
