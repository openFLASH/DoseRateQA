%% open_meta
% Load a Meta Image Files ('*.mha' format).
% The image can has up to 5 dimensions (x,y,z,t,J). (x,y,z) are 3 spatial dimension. t is the time. The last dimensions can be used to can be used to store the 3 components of the vectors of a vector field (J=1 for X composnent of the vector, J=2 for Y component, etc.) 
%
%% Syntax
% |img = open_meta(sel_path,sel_file)|
%
%
%% Description
% |img = open_meta(sel_path,sel_file)| Load a Meta Image Files ('*.mha' format).
%
%
%% Input arguments
% |sel_path| - _STRING_ - Name of the folder containing the image
%
% |sel_file| - _STRING_ - Name of the header file '*.mha'
%
%
%% Output arguments
%
% |img| - _STRUCTURE_ - Data structure of the 'meta' image
%
% * |img.dval| - _SCALAR MATRIX_ - |data(x,y,z,t,J)| representing the image.
% * |img.name| - _STRING_ - Image name
% * |img.ddim| - _SCALAR VECTOR_ - |ddim(x,y,z,t)| Size of each dimension
% * |img.dext| - _SCALAR MATRIX_ - |dext(t,J,1)| minimum intensity at time t and vector component J. |dext(t,J,2)| Maximum intensity at time t and vector component J. 
% * |img.dspa| - _SCALAR VECTOR_ - (x,y,z) Pixel size (mm)
% * |img.zoff| - _SCALAR VECTOR_ Coordinates (x,y,z) (in mm) of the first voxel of the image
% * |img.dpcx| - _SCALAR VECTOR_ - |img.dpcx(i)| Absices (mm) of the i-th voxels along the X axis
% * |img.dpcy| - _SCALAR VECTOR_ - |img.dpcy(i)| Absices (mm) of the i-th voxels along the Y axis
% * |img.dpcz| - _SCALAR VECTOR_ - |img.dpcz(i)| Absices (mm) of the i-th voxels along the Z axis
% * |img.dfra| - _SCALAR MATRIX_  |fras(t,2)| Frame start times and lengths
% * |img.dmod| - _STRING_ - Define the colour modality of the image (see function |newcolors|)
% * |img.units| - _STRUCTURE_ - See function |newunits|
% * |img.poscur| - _SCALAR VECTOR_ - |poscur(x,y,z,t,J)|
% * |img.type| - _STRING_ - Type of image = 'meta';
% * |img.file| - _STRING_ - Name of the header file '*.mha'
% * |img.path| - _STRING_ - Name of the folder containing the image
%
%
%% Contributors
% Authors : J.A. Lee, G.Janssens (open.reggui@gmail.com)

function img = open_meta(sel_path,sel_file)

% default output
img = struct([]);

% check file
try
    % get file title (name without extension)
    [sel_path,sel_name,sel_xten] = fileparts(fullfile(sel_path,sel_file));
catch ME
    % warning
    disp('An error occurred when processing the specified path and file name.');
    rethrow(ME);
end

% open header
try
    fid = fopen(fullfile(sel_path,[sel_name,sel_xten]),'rt');
catch ME
    % warning
    disp(['Could not open MetaImage file ',fullfile(sel_path,sel_file)]);
    rethrow(ME);
end

nels = 1;
spas = [1;1;1;1;1];
offs = [0;0;0;0;0];

% analyze header
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end;
    %disp(tline);
    idx = strfind(tline,'=');
    if strfind(tline(1:idx-1),'ObjectType'),
        otype = sscanf(tline(idx+1:end),'%s');
    elseif strfind(tline(1:idx-1),'NDims'),
        ndims = sscanf(tline(idx+1:end),'%i');
    elseif strfind(tline(1:idx-1),'DimSize'),
        dims = (sscanf(tline(idx+1:end),repmat(' %i ',1,ndims)))';
    elseif strfind(tline(1:idx-1),'ElementSpacing'),
        spas = (sscanf(tline(idx+1:end),repmat(' %f ',1,ndims)))';
    elseif strfind(tline(1:idx-1),'Offset'),
        offs = (sscanf(tline(idx+1:end),repmat(' %f ',1,ndims)))';
    elseif strfind(tline(1:idx-1),'ElementNumberOfChannels'),
        nels = sscanf(tline(idx+1:end),'%i');
    elseif strfind(tline(1:idx-1),'ElementType'),
        dtype = sscanf(tline(idx+1:end),'%s');
    elseif strfind(tline(1:idx-1),'ElementByteOrderMSB'),
        dbyte = sscanf(tline(idx+1:end),'%s');
    elseif strfind(tline(1:idx-1),'ElementDataFile'),
        dfile = tline(idx+1:end);
        if(strcmp(dfile(1),' '))
            dfile=dfile(2:end);
        end
        while(strcmp(dfile(end),' '))
            dfile=dfile(1:end-1);
        end
    else
        disp(['Warning : unrecognized keyword: ',tline(1:idx-1)]);
    end
end
fclose(fid);

if ~exist('spas','var'), offs = [1;1;1]; end;
if ~exist('offs','var'), offs = [0;0;0]; end;

if nels>1, dims(length(dims)+1) = nels; end;
if length(dims)<3, dims(3) = 1; end;
if length(dims)<4, dims(4) = 1; end;
if length(dims)<5, dims(5) = 1; end;
if length(spas)<3, spas(3) = 1; end;
if length(offs)<3, offs(3) = 1; end;
if dims(3)<1, dims(3) = 1; end;
dims = [dims(1);dims(2);dims(3);dims(4);dims(5)];
spas = [spas(1);spas(2);spas(3)];
offs = [offs(1);offs(2);offs(3)];

% return if not an image
if ~strcmpi(otype,'image'), return; end;

% open data file
fid = [];
[dpath,dname,dxten] = fileparts(dfile);
if isempty(dpath), dfile = fullfile(sel_path,dfile); end;
try
    fid = fopen(dfile,'rb');
catch
    % warning
    disp(['Could not open file ',dfile]);
end


% If problem of spaces replaced and underscores... TO BE REMOVED!
if(fid==-1)
    dfile = strrep(dfile,' ','_');
    fid = [];
    [dpath,dname,dxten] = fileparts(dfile);
    if isempty(dpath), dfile = fullfile(sel_path,dfile); end;
    try
        fid = fopen(dfile,'rb');
    catch
        % warning
        disp(['Could not open file ',dfile]);
    end
end


if isempty(fid)
    try
        fid = fopen(fullfile(sel_path,[sel_name,'.raw']),'rb');
    catch
        % warning
        disp(['Could not open file ',fullfile(sel_path,[sel_name,'.raw'])]);
    end
end

if(fid==-1)
    error(['Could not open file ',fullfile(sel_path,[sel_name,'.raw'])]);
end

% read data
if nels>1
    if(dims(5)>1)
        data = repmat(single(0),[dims(1),dims(2),dims(3),dims(4),dims(5)]);
        for tval = 1:dims(4)
            for zval = 1:dims(3)
                switch dtype
                    case 'MET_FLOAT'
                        tmp = single(fread(fid,dims(5)*dims(1)*dims(2),'float'));
                    case 'MET_DOUBLE'
                        tmp = single(fread(fid,dims(5)*dims(1)*dims(2),'double'));
                    case 'MET_SHORT'
                        tmp = single(fread(fid,dims(5)*dims(1)*dims(2),'int16'));
                    case 'MET_USHORT'
                        tmp = single(fread(fid,dims(5)*dims(1)*dims(2),'uint16'));
                    otherwise
                        error('Impossible to open meta image: unknown data type');
                end
                data(:,:,zval,tval,:) = flipdim(permute(reshape(tmp,[dims(5),dims(1),dims(2)]),[2,3,4,5,1]),2);
            end
        end
    else
        data = repmat(single(0),[dims(1),dims(2),dims(3),dims(4)]);
        for zval = 1:dims(3)
            switch dtype
                case 'MET_FLOAT'
                    tmp = single(fread(fid,dims(4)*dims(1)*dims(2),'float'));
                case 'MET_DOUBLE'
                    tmp = single(fread(fid,dims(4)*dims(1)*dims(2),'double'));
                case 'MET_SHORT'
                    tmp = single(fread(fid,dims(4)*dims(1)*dims(2),'int16'));
                case 'MET_USHORT'
                    tmp = single(fread(fid,dims(4)*dims(1)*dims(2),'uint16'));
                otherwise
                    error('Impossible to open meta image: unknown data type');
            end
            data(:,:,zval,:) = flipdim(permute(reshape(tmp,[dims(4),dims(1),dims(2)]),[2,3,4,1]),2);
        end
    end
else
    data = repmat(single(0),[dims(1),dims(2),dims(3),dims(4)]);
    for tval = 1:dims(4)
        for zval = 1:dims(3)
            switch dtype
                case 'MET_FLOAT'
                    tmp = single(fread(fid,dims(1)*dims(2),'float'));
                case 'MET_DOUBLE'
                    tmp = single(fread(fid,dims(1)*dims(2),'double'));
                case 'MET_SHORT'
                    tmp = single(fread(fid,dims(1)*dims(2),'int16'));
                case 'MET_USHORT'
                    tmp = single(fread(fid,dims(1)*dims(2),'uint16'));
                case 'MET_UCHAR'
                    tmp = single(fread(fid,dims(1)*dims(2),'uint8'));
                otherwise
                    error('Impossible to open meta image: unknown data type');
            end
            data(:,:,zval,tval) = flipdim(reshape(tmp,[dims(1),dims(2)]),2);
        end
    end
end
fclose(fid);

% pixel centers
xpcs = offs(1) + spas(1)*(0:dims(1)-1)';
ypcs = offs(2) + spas(2)*(0:dims(2)-1)';
zpcs = offs(3) + spas(3)*(0:dims(3)-1)';

% frame start times and lengths
fras = zeros(dims(4),2);

% modality
imod = 'OT';

% allocate a new image
img = newimage(dims,data,imod);

% fill in the new image
img.name = ['MetaImage (',imod,', ',sel_file,')'];
img.ddim = dims;
img.dext = double([reshape(min(min(min(img.dval,[],1),[],2),[],3),dims(4),[]),reshape(max(max(max(img.dval,[],1),[],2),[],3),dims(4),[])]);
img.dspa = spas;
img.zoff = offs;
img.dpcx = xpcs;
img.dpcy = ypcs;
img.dpcz = zpcs;
img.dfra = fras;
img.dmod = imod;
%img.units = units;
img.poscur = ceil(dims./[2;2;2;1;1]);
img.type = 'meta';
img.file = sel_file;
img.path = sel_path;
%img.dicom = 
%img.header = 
%img.patient = patient;
