function [myImage,myInfo] = load_OPG(myImageDir,myImageFilename,rotCorr,xCorr,yCorr)

if(nargin<3)
    rotCorr = 0;
end
if(nargin<3)
    xCorr = 0;
end
if(nargin<3)
    yCorr = 0;
end

fileStruct=newMatriXXstruct(struct);
% read header
fid=fopen(fullfile(myImageDir,myImageFilename),'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if contains(tline,"<opimrtascii>")
        while 1
            tline = fgetl(fid);
            if ~ischar(tline), break, end
            if contains(tline,'</opimrtascii>'), break, end
            
            if contains(tline,"<asciiheader>")
                while 1
                    tline =fgetl(fid);
                    if ~ischar(tline), break, end
                    if contains(tline,'</asciiheader>'), break, end
                    fileStruct.header= fillASCIIHeader(fileStruct.header,tline);
                end
            end
        end
    end
end
fclose(fid);

% read body
col=fileStruct.header.cols;
row=fileStruct.header.rows;
bodynumb=fileStruct.header.bodies;
fileStruct=createBodies(fileStruct,col,row,bodynumb);

currentBody=0;
actualPos=0;

fid=fopen(fullfile(myImageDir,myImageFilename),'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if contains(tline,"<opimrtascii>")
        while 1
            tline = fgetl(fid);
            if ~ischar(tline), break, end
            if contains(tline,'</opimrtascii>'), break, end
            
            if contains(tline,"<asciibody>")
                currentBody=currentBody+1;
                while 1
                    tline =fgetl(fid);
                    if ~ischar(tline), break, end
                    if contains(tline,'</asciibody>')
                        actualPos=0;
                        break
                    end
                    [fileStruct.body{currentBody}, actualPos]= fillASCIIBody(fileStruct.body{currentBody},tline,fileStruct.header.separator,col,row,actualPos);
                end
                fileStruct.body{currentBody}.data=(fileStruct.body{currentBody}.data)*fileStruct.header.dataFactor;
                
            end
        end
    end
end

% invert y-direction
fileStruct.body{1}.data=double(flipud(fileStruct.body{1}.data));
fileStruct.body{1}.position2 = -fileStruct.body{1}.position2(end:-1:1);

% conversion to mm
factor = 1;
if strcmp(fileStruct.header.lengthUnit, 'cm')
    factor = 10;
end
fileStruct.body{1}.position1 = fileStruct.body{1}.position1*factor;
fileStruct.body{1}.position2 = fileStruct.body{1}.position2*factor;

% apply X, Y and Rot correction
if rotCorr==90
    fileStruct.body{1}.position1 = -fliplr(fileStruct.body{1}.position2);
    fileStruct.body{1}.position2 = fileStruct.body{1}.position1;
elseif rotCorr == 180 || rotCorr==-180
    fileStruct.body{1}.position1 = -fliplr(fileStruct.body{1}.position1);
    fileStruct.body{1}.position2 = -fliplr(fileStruct.body{1}.position2);
elseif rotCorr==-90
    fileStruct.body{1}.position1 = fileStruct.body{1}.position2;
    fileStruct.body{1}.position2 = -fliplr(fileStruct.body{1}.position1);
end
fileStruct.body{1}.data = imrotate(fileStruct.body{1}.data,rotCorr);
fileStruct.body{1}.position1 = fileStruct.body{1}.position1+xCorr;
fileStruct.body{1}.position2 = fileStruct.body{1}.position2+yCorr;

% conversion to Gy or percent
if(ischar(fileStruct.header.dataUnit))
   fileStruct.header.dataUnit = {fileStruct.header.dataUnit}; 
end
switch strrep(fileStruct.header.dataUnit{1},'%','')
    case 'uGy'
        fileStruct.body{1}.data = fileStruct.body{1}.data/1e6;
    case 'mGy'
        fileStruct.body{1}.data = fileStruct.body{1}.data/1e3;
    case 'cGy'
        fileStruct.body{1}.data = fileStruct.body{1}.data/1e2;
    case '1/10'
        fileStruct.body{1}.data = fileStruct.body{1}.data/10;
end

% Output image and meta-info
myImage = fileStruct.body{1}.data;
myInfo.Spacing = [abs(mean(diff(fileStruct.body{1}.position2)));abs(mean(diff(fileStruct.body{1}.position1)));0];
myInfo.ImagePositionPatient = [fileStruct.body{1}.position2(1);fileStruct.body{1}.position1(1);0];
myInfo.FrameOfReferenceUID = dicomuid;
myInfo.SeriesInstanceUID = dicomuid;
myInfo.SOPClassUID = '1.2.840.10008.5.1.4.1.1.7';
myInfo.StudyInstanceUID = dicomuid;
myInfo.Type = 'image';
if(isfield(fileStruct.header,'plane'))
   myInfo.ImageOrientation = fileStruct.header.plane;
end
myInfo.OriginalHeader = fileStruct.header;

end

%% -----------------------------------------------------------------
function fileStruct=createBodies(fileStruct,col,row,bodiesNumb)
for i=1:bodiesNumb
    fileStruct.body{i}.planePos ='';
    fileStruct.body{i}.direction1='';
    fileStruct.body{i}.position1=zeros(1,col);
    fileStruct.body{i}.position2=zeros(1,row);
    fileStruct.body{i}.data=zeros(row,col);
end
end

%% -----------------------------------------------------------------
function fileStruct=newMatriXXstruct(fileStruct)
fileStruct.header.fileVersion='';
fileStruct.header.separator='[TAB]';
fileStruct.header.workspaceName='';
fileStruct.header.fileName='';
fileStruct.header.imageName='';
fileStruct.header.radiationType='';
fileStruct.header.energy='';
fileStruct.header.SSD='';
fileStruct.header.SID='';
fileStruct.header.fieldSizeCR='';
fileStruct.header.fieldSizeIn='';
fileStruct.header.dataType='Relative';
fileStruct.header.dataFactor=1;
fileStruct.header.dataUnit='';
fileStruct.header.lengthUnit='mm';
fileStruct.header.plane='XY';
fileStruct.header.cols='';
fileStruct.header.rows='';
fileStruct.header.bodies=1;
fileStruct.header.operatorsNote='';
fileStruct.header.spacing.value=1;
fileStruct.header.spacing.unit='mm';
fileStruct.header.gantryAngle='';
end

%% -----------------------------------------------------------------
function fileStruct=fillASCIIHeader(fileStruct,tline)
info=strsplit(tline,":");
label=info{1};
content=info{2:end};
content=strsplit(content,' ');
content=content(~cellfun(@isempty,content));

switch label
    case "File Version"
        fileStruct.fileVersion= str2num(content{1});
    case "Separator"
        content=strsplit(content{1},'"');
        content=content(~cellfun(@isempty,content));
        fileStruct = setfield(fileStruct,"separator",content{1});
    case "Workspace Name"
        if(~isempty(content))
            fileStruct.workspaceName=content{1};
        end
    case "File Name"
        if(~isempty(content))
            fileStruct.fileName=content{1};
        end
    case "Image Name"
        if(~isempty(content))
            fileStruct.imageName=content{1};
        end
    case "Radiation Type"
        if(~isempty(content))
            fileStruct.radiationType=content{1};
        end
    case "Energy"
        if(~isempty(content))
            fileStruct.energy=content{1};
        end
    case "SSD"
        if(~isempty(content))
            fileStruct.SSD=content{1};
        end
    case "SID"
        if(~isempty(content))
            fileStruct.SID=content{1};
        end
    case "Field Size Cr"
        if(~isempty(content))
            fileStruct.fieldSizeCR=content{1:end};
        end
    case "Field Size In"
        if(~isempty(content))
            fileStruct.fieldSizeIn=content{1:end};
        end
    case "Data Type"
        if(~isempty(content))
            fileStruct.dataType=content{1};
        end
    case "Data Factor"
        if(~isempty(content))
            fileStruct.dataFactor=str2num(content{1});
        end
    case "Data Unit"
        if(~isempty(content))
            fileStruct.dataUnit=content;
        end
    case "Length Unit"
        if(~isempty(content))
            fileStruct.lengthUnit=content{1};
        end
    case "Plane"
        if(~isempty(content))
            fileStruct.plane=content{1};
        end
    case "No. of Columns"
        fileStruct.cols=str2num(content{1});
    case "Columns"
        fileStruct.cols=str2num(content{1});
    case "Cols"
        fileStruct.cols=str2num(content{1});
    case "No. of Rows"
        fileStruct.rows=str2num(content{1});
    case "Rows"
        fileStruct.rows=str2num(content{1});
    case "No. of Bodies"
        fileStruct.bodies=str2num(content{1});
    case "Number of Bodies"
        fileStruct.bodies=str2num(content{1});
    case "Operators Note"
        if(~isempty(content))
            fileStruct.operatorsNote=content{1:end};
        end
    case "Spacing"
        if(~isempty(content))            
            fileStruct.spacing.value=str2num(content{1});
            fileStruct.spacing.unit=content{2};
        end
    case "Gantry Angle"
        if(~isempty(content))
            fileStruct.gantryAngle=str2num(content{1});
        end         
    case "No_of_Pixels"
        if(~isempty(content))
            fileStruct.pixels=str2num(content{1});
        end 
    case "Min"
        if(~isempty(content))
            fileStruct.min=str2num(content{1});
        end 
    case "Max"
        if(~isempty(content))
            fileStruct.max=str2num(content{1});
        end 
    case "Mean"
        if(~isempty(content))
            fileStruct.mean=str2num(content{1});
        end 
    case "Std"
        if(~isempty(content))
            fileStruct.std=str2num(content{1});
        end 
    case "Pass"
        if(~isempty(content))
            fileStruct.pass=str2num(content{1});
        end 
    case "Fail"
        if(~isempty(content))
            fileStruct.fail=str2num(content{1});
        end 
end

end

%% -----------------------------------------------------------------
function [fileStruct, actualPos]=fillASCIIBody(fileStruct,tline,separator,col,row,actualPos)
if(strcmp(separator,'[Tab]') || strcmp(separator,'[TAB]') )
    separator='\t';
end
info=strsplit(tline,":");

if length (info)>1
    label=info{1};
    content=info{2:end};
    content=strsplit(content,' ');
    content=content(~cellfun(@isempty,content));
    
    switch label
        case "Plane Position"
            fileStruct.planePos.value=str2double(content{1});
            fileStruct.planePos.unit=content{2};
    end
elseif ~(length(info)==1 && isempty(info{1}))
    info=strsplit(tline,' ');
    info=strjoin(info,'');
    info=strsplit(info,separator);
    if isempty(info{end})
        info=info(1:end-1);
    end
    
    if contains(info{1},"X")
        for i=1:col
            fileStruct.position1(i)=str2double(info{i+1});
        end
    elseif length(info)>1
        actualPos=actualPos+1;
        fileStruct.position2(actualPos)=str2double(info{1});
        for i=1:col
            fileStruct.data(actualPos,i)=str2num(info{i+1});
        end
    end
    
end
end
