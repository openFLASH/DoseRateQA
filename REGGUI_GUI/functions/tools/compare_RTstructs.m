%% compare_RTstructs
% Compare DICOM RT structure in tow different file and determine whether they are identical
%
%% Syntax
% |[RT_comp,rt1,rt2] = compare_RTstructs(filename1,filename2)|
%
% |[RT_comp,rt1,rt2] = compare_RTstructs(filename1,filename2,c_list_1)|
%
% |[RT_comp,rt1,rt2] = compare_RTstructs(filename1,filename2,c_list_1,c_list_2)|
%
%
%% Description
% |[RT_comp,rt1,rt2] = compare_RTstructs(filename1,filename2)| Compare all contours of the first file with all contours of second file
%
% |[RT_comp,rt1,rt2] = compare_RTstructs(filename1,filename2,c_list_1)| Compare specified contours of the first file with all contours of second file
%
% |[RT_comp,rt1,rt2] = compare_RTstructs(filename1,filename2,c_list_1,c_list_2)| Compare specified contours of the first file with specified contours of second file
%
%
%% Input arguments
% |filename1| - _STRING_ - File name (with path) of the first DICOM RT struct file
%
% |filename2| - _STRING_ - File name (with path) of the first DICOM RT struct file
%
% |c_list_1| - _SCALAR VECTOR_ -  [OPTIONAL] Index of the contour to be compared in the first file
%
% |c_list_2| - _SCALAR VECTOR_ -  [OPTIONAL] Index of the contour to be compared in the second file
%
%
%% Output arguments
%
% |RT_comp| - _STRUCTURE_ - description for 1st syntax
%
% * |RT_comp.ReferencedSOPInstanceUID_first{j}| - _STRING_ - ReferencedSOPInstanceUID of the first referenced image in the jth file (j=1,2) 
% * |RT_comp.ReferencedSOPInstanceUID_first{3}| - _SCALAR_ - -1 if the  ReferencedSOPInstanceUID of the first referenced image of the 2 files are differents. Field is absent otherwise
% * |RT_comp.ReferencedSOPInstanceUID_last{j}| - _STRING_ - ReferencedSOPInstanceUID of the last referenced image in the jth file (j=1,2) 
% * |RT_comp.ReferencedSOPInstanceUID_last{3}| - _SCALAR_ - -1 if the  ReferencedSOPInstanceUID of the last referenced image of the 2 files are differents. Field is absent otherwise
% * |RT_comp.ContourX.ReferencedSOPInstanceUID_first{j}| - _STRING_ - ReferencedSOPInstanceUID of the first contour in the jth file (j=1,2) 
% * |RT_comp.ContourX.ReferencedSOPInstanceUID_first{3}| - _SCALAR_ - -1 if the  ReferencedSOPInstanceUID of the contours of the 2 files are differents. Field is absent otherwise
% * |RT_comp.ContourX.ReferencedSOPInstanceUID_last{j}| - _STRING_ - ReferencedSOPInstanceUID of the last contour in the jth file (j=1,2) 
% * |RT_comp.ContourX.ReferencedSOPInstanceUID_last{3}| - _SCALAR_ - -1 if the  ReferencedSOPInstanceUID of the last contours of the 2 files are differents. Field is absent otherwise
% * |RT_comp.ContourX.Zcoord_first{i,j}| - _SCALAR_ Z coordinate (mm, DICOM system) of the first contour in the jth file (j=1,2)
% * |RT_comp.ContourX.Zcoord_first{3}| - _SCALAR_ - -1 if the  Z coordinate of the first contours of the 2 files are differents. Field is absent otherwise
% * |RT_comp.ContourX.Zcoord_last{i,j}|  - _SCALAR_ Z coordinate (mm, DICOM system) of the last contour in the jth file (j=1,2)
% * |RT_comp.ContourX.Zcoord_last{3}| - _SCALAR_ - -1 if the  Z coordinate of the last contours of the 2 files are differents. Field is absent otherwise
%
% |rt1| - _STRUCTURE_ - DICOM data of the first RT struct
%
% |rt2| - _STRUCTURE_ - DICOM data of the second RT struct
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function [RT_comp,rt1,rt2] = compare_RTstructs(filename1,filename2,c_list_1,c_list_2)

RT_comp = struct;

rt1 = dicominfo(filename1);
rt2 = dicominfo(filename2);

nItems1 = 1;
while isfield(rt1.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence,['Item_',num2str(nItems1+1)])
    nItems1 = nItems1+1;
end
nItems2 = 1;
while isfield(rt2.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence,['Item_',num2str(nItems2+1)])
    nItems2 = nItems2+1;
end

nCont1 = 1;
while isfield(rt1.ROIContourSequence,['Item_',num2str(nCont1+1)])
    nCont1 = nCont1+1;
end
nCont2 = 1;
while isfield(rt2.ROIContourSequence,['Item_',num2str(nCont2+1)])
    nCont2 = nCont2+1;
end

eval('RT_comp.ReferencedSOPInstanceUID_first{1} = rt1.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPInstanceUID;');
eval('RT_comp.ReferencedSOPInstanceUID_first{2} = rt2.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPInstanceUID;');

eval(['RT_comp.ReferencedSOPInstanceUID_last{1} = rt1.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_',num2str(nItems1),'.ReferencedSOPInstanceUID;']);
eval(['RT_comp.ReferencedSOPInstanceUID_last{2} = rt2.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_',num2str(nItems2),'.ReferencedSOPInstanceUID;']);

if(not(strcmp(RT_comp.ReferencedSOPInstanceUID_first{1},RT_comp.ReferencedSOPInstanceUID_first{2})))
    eval(['RT_comp.ReferencedSOPInstanceUID_first{3} = -1;']);
end
if(not(strcmp(RT_comp.ReferencedSOPInstanceUID_last{1},RT_comp.ReferencedSOPInstanceUID_last{2})))
    eval(['RT_comp.ReferencedSOPInstanceUID_last{3} = -1;']);
end
    

if(nargin<3)
    c_list_1 = 1:nCont1;    
end
if(nargin<4)
    c_list_2 = 1:nCont2;
end
c_list_1 = c_list_1(1:min(length(c_list_1),length(c_list_2)));
c_list_2 = c_list_2(1:min(length(c_list_1),length(c_list_2)));

c_index = 1;
for c=c_list_1
    
    nItems1 = 1;
    eval(['current = rt1.ROIContourSequence.Item_',num2str(c),'.ContourSequence;']);
    while isfield(current,['Item_',num2str(nItems1+1)])
        nItems1 = nItems1+1;
    end
    
    eval(['RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_first{1} = rt1.ROIContourSequence.Item_',num2str(c),'.ContourSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPInstanceUID;']);   
    eval(['RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_last{1} = rt1.ROIContourSequence.Item_',num2str(c),'.ContourSequence.Item_',num2str(nItems1),'.ContourImageSequence.Item_1.ReferencedSOPInstanceUID;']);    
    eval(['RT_comp.Contour',num2str(c_index),'.Zcoord_first{1} = rt1.ROIContourSequence.Item_',num2str(c),'.ContourSequence.Item_1.ContourData(3);']);   
    eval(['RT_comp.Contour',num2str(c_index),'.Zcoord_last{1} = rt1.ROIContourSequence.Item_',num2str(c),'.ContourSequence.Item_',num2str(nItems1),'.ContourData(3);']);
    
    c_index = c_index + 1;
    
end

c_index = 1;
for c=c_list_2
    
    nItems2 = 1;
    eval(['current = rt2.ROIContourSequence.Item_',num2str(c),'.ContourSequence;']);
    while isfield(current,['Item_',num2str(nItems2+1)])
        nItems2 = nItems2+1;
    end

    eval(['RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_first{2} = rt2.ROIContourSequence.Item_',num2str(c),'.ContourSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPInstanceUID;']);
    eval(['isdiff = not(strcmp(RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_first{1},RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_first{2}));']);
    if(isdiff)
        eval(['RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_first{3} = -1;']);
    end
    eval(['RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_last{2} = rt2.ROIContourSequence.Item_',num2str(c),'.ContourSequence.Item_',num2str(nItems2),'.ContourImageSequence.Item_1.ReferencedSOPInstanceUID;']);
    eval(['isdiff = not(strcmp(RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_last{1},RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_last{2}));']);
    if(isdiff)
        eval(['RT_comp.Contour',num2str(c_index),'.ReferencedSOPInstanceUID_last{3} = -1;']);
    end
    eval(['RT_comp.Contour',num2str(c_index),'.Zcoord_first{2} = rt2.ROIContourSequence.Item_',num2str(c),'.ContourSequence.Item_1.ContourData(3);']);
    eval(['isdiff = not(RT_comp.Contour',num2str(c_index),'.Zcoord_first{1}==RT_comp.Contour',num2str(c_index),'.Zcoord_first{2});']);
    if(isdiff)
        eval(['RT_comp.Contour',num2str(c_index),'.Zcoord_first{3} = -1;']);
    end
    eval(['RT_comp.Contour',num2str(c_index),'.Zcoord_last{2} = rt2.ROIContourSequence.Item_',num2str(c),'.ContourSequence.Item_',num2str(nItems2),'.ContourData(3);']);
    eval(['isdiff = not(RT_comp.Contour',num2str(c_index),'.Zcoord_last{1}==RT_comp.Contour',num2str(c_index),'.Zcoord_last{2});']);
    if(isdiff)
        eval(['RT_comp.Contour',num2str(c_index),'.Zcoord_last{3} = -1;']);
    end
    
    c_index = c_index + 1;
    
end




