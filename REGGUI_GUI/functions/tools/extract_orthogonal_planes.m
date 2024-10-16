%% extract_orthogonal_planes
% Extract two orthogonal slices through a CT scan. The intersection line of the 2 slices is defined by the beam axis. The intensity are interpolated the slice pixels are not aligned with the volume pixels.
%
%% Syntax
% |[slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution)|
%
% |[slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution,beam)|
%
% |[slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution,beam,additional_pts)|
%
% |[slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution,beam,additional_pts,padding_value)|
%
%
%% Description
% |[slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution)| Extract 2 orthogonal slices with beam axis defined by points |pt_in| and |pt_out|.
% |[slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution,beam)| Extract 2 orthogonal slices with the beam axis defined by |beam|. |pt_in| and |pt_out| are used to define the length of the slices.
%
% |[slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution,beam,additional_pts)| Extract 2 orthogonal slices and additionally convert the coordinates of |additional_pts| into the slices coordinate system
%
% |[slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution,beam,additional_pts,padding_value)| Extract 2 orthogonal slices and use |padding_value| when interpolation fails or when needing to extrapolate the intensity
%
%
%% Input arguments
% |im| - _SCALAR MATRIX_ - |im(x,y,z)| Intensity of the voxel at coordinate (x,y,z)  
%
% |im_origin| - _SCALAR VECTOR_ - Coordinate (in |mm|) of the first pixel of the image in the coordinate system of the image
%
% |im_spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the image |im|
%
% |pt_in| - _SCALAR VECTOR_ - Coordinates (x,y,z) (in mm) of the start of the intersection line between slices
%
% |pt_out| - _SCALAR VECTOR_ - Coordinates (x,y,z) (in mm)  of the end of the intersection line between slices
%
% |out_resolution| - SCALAR_ - Size of the pixel (|mm|) of the extracted slices
%
% |beam| - _STRUCTURE or CELL_ - [OPTIONAL. Default: empty] Description of the proton beam geometry. See parameter |beam| or |data| or |geom| of function |get_beam_params| for more information. If absent of empty, then |pt_in| and |pt_out| define the beam axis and the couch yaw is null.
%
% |additional_pts| - _CELL VECTOR of SCALAR VECTOR_ - [OPTIONAL. If empty, |pts_list| is also empty] |additional_pts{i}(x,y,z)| Coordinate (in mm) of the i-th point for which the coordinates are to be computed in the slice CS.
%
% |padding_value| - _SCALAR_ -  [OPTIONAL. Defaul = 0] Value to use when the interpolation fails or for extrapolated pixels
%
%
%% Output arguments
%
% |slices| - _CELL VECTOR of SCALAR MATRIX_ -  |slices{i}(x,y)| Interpolated intensity of the pixel in the i-th slicing plan at coordinates (x,y)
%
% |pts_in| - _CELL VECTOR of SCALAR VECTOR_ -  |pts_in{i}| Coordinate (x,y) (in pixel) of the first point of the intersection line in the CS of the i-th slice
%
% |pts_out| - _CELL VECTOR of SCALAR VECTOR_ -  |pts_out{i}| Coordinate (x,y) (in pixel) of the last point of the intersection line in the CS of the i-th slice
%
% |pts_list| - _CELL VECTOR of SCALAR VECTOR_ - [Empty if |additional_pts| is empty] |additional_pts{i}{j}(x,y,z)| Coordinate (in pixel) of the i-th point (from |additional_pts|) in the coordinate system of the j-th slice.
%
% |views| - _CELL VECTOR of STRING_ - |views{i}| Type of the i-th slice. Can be 'axial', 'coronal' or 'sagittal'. If the beam is not parallel to the CT scan axis: 'axial'
%
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)


% TODO With 'orthog=[0,0,0]' hardcoded, a large part of the code of this function is never used

function [slices,pts_in,pts_out,pts_list,views] = extract_orthogonal_planes(im,im_origin,im_spacing,pt_in,pt_out,out_resolution,beam,additional_pts,padding_value)

if(not(size(pt_in,1)==3 && size(pt_out,1)==3))
    disp('Input points must be 3D (i.e. 3 rows)')
    return;
end

if(nargin<7)
    beam = [];
end

if(nargin<9)
    padding_value = 0;
end

slices = cell(0);
pts_in = cell(0);
pts_out = cell(0);
pts_list = cell(0);
if(nargin>7)
    for i=1:length(additional_pts)
        pts_list{i} = cell(0);
    end
else
    additional_pts = [];
end
views = cell(0);

% geometry in real space
pt_in = pt_in(:,1) - im_origin;
pt_out = pt_out(:,1) - im_origin;
beam_axis = pt_in - pt_out ;
for i=1:length(additional_pts)
   additional_pts{i} =  additional_pts{i} - im_origin;
end

% geometry in voxel space
beam_axis_pixel_space = round(beam_axis./im_spacing*1000)/1000;
pt1 = pt_in./im_spacing +1;
pt2 = pt_out./im_spacing +1;

orthog = [0;0;0];%(beam_axis_pixel_space == 0);

if(orthog(3))
    slices{end+1} = resampler3(im,linspace(1,size(im,1),ceil(size(im,1)*im_spacing(1)/out_resolution)+1),linspace(1,size(im,2),ceil(size(im,2)*im_spacing(2)/out_resolution)+1),pt1(3));
    pts_in{end+1} = pt_in(1:2)/out_resolution +1;
    pts_out{end+1} = pt_out(1:2)/out_resolution +1;
    for i=1:length(additional_pts)
        pts_list{i}{end+1} =  additional_pts{i}(1:2)/out_resolution +1;
    end
    views{end+1} = 'axial';
end
if(orthog(2))
    slices{end+1} = resampler3(im,linspace(1,size(im,1),ceil(size(im,1)*im_spacing(1)/out_resolution)+1),pt1(2),linspace(1,size(im,3),ceil(size(im,3)*im_spacing(3)/out_resolution)+1));
    pts_in{end+1} = pt_in([1;3])/out_resolution +1;
    pts_out{end+1} = pt_out([1;3])/out_resolution +1;
    for i=1:length(additional_pts)
        pts_list{i}{end+1} =  additional_pts{i}([1;3])/out_resolution +1;
    end
    views{end+1} = 'coronal';
end
if(orthog(1))
    slices{end+1} = resampler3(im,pt1(1),linspace(1,size(im,2),ceil(size(im,2)*im_spacing(2)/out_resolution)+1),linspace(1,size(im,3),ceil(size(im,3)*im_spacing(3)/out_resolution)+1));
    pts_in{end+1} = pt_in(2:3)/out_resolution +1;
    pts_out{end+1} = pt_out(2:3)/out_resolution +1;
    for i=1:length(additional_pts)
        pts_list{i}{end+1} =  additional_pts{i}(2:3)/out_resolution +1;
    end
    views{end+1} = 'sagittal';
end

switch sum(orthog)
    case 1 % orthogonal to 1 axis
        if(orthog(3))
            nb_pts = norm(pt_out-pt_in)/out_resolution;
            x = linspace(pt1(1),pt2(1),nb_pts+1)';
            y = linspace(pt1(2),pt2(2),nb_pts+1)';
            z = linspaceNDim(zeros(size(x))+1,zeros(size(x))+size(im,3),size(im,3)*im_spacing(3)+1);
            x = repmat(x,[1 size(z,2)]);
            y = repmat(y,[1 size(z,2)]);
            slices{end+1} = squeeze(interp3(im,single(y),single(x),single(z)));
            slices{end}(isnan(slices{end})) = padding_value;
            pts_in{end+1} = [1;(pt_in(3)/out_resolution +1)];
            pts_out{end+1} = [size(slices{end},1);(pt_in(3)/out_resolution +1)];
            for i=1:length(additional_pts)
                pts_list{i}{end+1} =  [(norm(additional_pts{i}-pt_in)/out_resolution +1);(pt_in(3)/out_resolution +1)];
            end
            views{end+1} = 'sagittal';
        elseif(orthog(2))
            nb_pts = norm(pt_out-pt_in)/out_resolution;
            x = linspace(pt1(1),pt2(1),nb_pts+1)';
            z = linspace(pt1(3),pt2(3),nb_pts+1)';
            y = linspaceNDim(zeros(size(x))+1,zeros(size(x))+size(im,2),size(im,2)*im_spacing(2)+1);
            x = repmat(x,[1 size(y,2)]);
            z = repmat(z,[1 size(y,2)]);
            slices{end+1} = squeeze(interp3(im,single(y),single(x),single(z)));
            slices{end}(isnan(slices{end})) = padding_value;
            pts_in{end+1} = [1;(pt_in(2)/out_resolution +1)];
            pts_out{end+1} = [size(slices{end},1);(pt_in(2)/out_resolution +1)];
            for i=1:length(additional_pts)
                pts_list{i}{end+1} =  [(norm(additional_pts{i}-pt_in)/out_resolution +1);(pt_in(2)/out_resolution +1)];
            end
            views{end+1} = 'coronal';
        elseif(orthog(1))
            nb_pts = norm(pt_out-pt_in)/out_resolution;
            y = linspace(pt1(2),pt2(2),nb_pts+1)';
            z = linspace(pt1(3),pt2(3),nb_pts+1)';
            x = linspaceNDim(zeros(size(y))+1,zeros(size(y))+size(im,1),size(im,1)*im_spacing(1)+1);
            y = repmat(y,[1 size(x,2)]);
            z = repmat(z,[1 size(x,2)]);
            slices{end+1} = squeeze(interp3(im,single(y),single(x),single(z)))';
            slices{end}(isnan(slices{end})) = padding_value;
            pts_in{end+1} = [(pt_in(1)/out_resolution +1);1];
            pts_out{end+1} = [(pt_in(1)/out_resolution +1);size(slices{end},1)];
            for i=1:length(additional_pts)
                pts_list{i}{end+1} =  [(pt_in(1)/out_resolution +1);(norm(additional_pts{i}-pt_in)/out_resolution +1)];
            end
            views{end+1} = 'axial';
        end
    case 0 % not orthogonal to any axis
        nb_pts = norm(pt_out-pt_in)/out_resolution;
        beam_axis = beam_axis/norm(beam_axis);
        
        % computing orthogonal vectors
        if(isempty(beam))
            [dc,min_dot] = min([dot(beam_axis,[1;0;0]),dot(beam_axis,[0;1;0]),dot(beam_axis,[0;0;1])]);
            switch min_dot
                case 1
                    v1 = cross(beam_axis,cross(beam_axis,[1;0;0]));
                case 2
                    v1 = cross(beam_axis,cross(beam_axis,[0;1;0]));
                case 3
                    v1 = cross(beam_axis,cross(beam_axis,[0;0;1]));
            end   
        else
            pt0 = compute_beam_isoplane([0;0],beam,2000);
            pt1 = compute_beam_isoplane([0;1],beam,2000);
            v1 = cross(beam_axis,cross(beam_axis,pt1 - pt0));
        end
        v1 = -v1;
        v2 = cross(beam_axis,v1);
        
        % nomalization
        beam_axis = beam_axis/norm(beam_axis);
        v1 = v1./norm(v1);
        v2 = v2./norm(v2);
        
        % convert additional points into new coordinate system
        additional_pts_new = additional_pts;
        for i=1:length(additional_pts)
            additional_pts_new{i} =  ([-beam_axis,v1,v2]\(additional_pts{i}-pt_in))/out_resolution;
        end
        
        % 2D grid
        [Gy,Gx] = meshgrid([1:nb_pts],[-nb_pts/2+1:nb_pts/2]);
        
        % first slice extraction        
        x = (Gx.*v1(1) - Gy.*beam_axis(1) + pt_in(1))./im_spacing(1)*out_resolution;
        y = (Gx.*v1(2) - Gy.*beam_axis(2) + pt_in(2))./im_spacing(2)*out_resolution;
        z = (Gx.*v1(3) - Gy.*beam_axis(3) + pt_in(3))./im_spacing(3)*out_resolution;
        
        slices{end+1} = squeeze(interp3(im,single(y),single(x),single(z)));
        slices{end}(isnan(slices{end})) = padding_value;           
        
        pts_in{end+1} = [size(slices{end},1)/2;1];
        pts_out{end+1} = [size(slices{end},1)/2;size(slices{end},1)];
        for i=1:length(additional_pts)
            %pts_list{i}{end+1} =  [size(slices{end},1)/2;(norm(additional_pts{i}-pt_in)/out_resolution +1)];
            pts_list{i}{end+1} =  ([size(slices{end},1)/2;1] + [additional_pts_new{i}(2);additional_pts_new{i}(1)]);
        end   
                     
        views{end+1} = 'axial';            
        
        % second slice extraction  
        x = (Gx.*v2(1) - Gy.*beam_axis(1) + pt_in(1))./im_spacing(1)*out_resolution;
        y = (Gx.*v2(2) - Gy.*beam_axis(2) + pt_in(2))./im_spacing(2)*out_resolution;
        z = (Gx.*v2(3) - Gy.*beam_axis(3) + pt_in(3))./im_spacing(3)*out_resolution;
        
        slices{end+1} = squeeze(interp3(im,single(y),single(x),single(z)));
        slices{end}(isnan(slices{end})) = padding_value;        
        
        pts_in{end+1} = [size(slices{end},1)/2;1];
        pts_out{end+1} = [size(slices{end},1)/2;size(slices{end},1)];
        for i=1:length(additional_pts)
%             pts_list{i}{end+1} =  [size(slices{end},1)/2;(norm(additional_pts{i}-pt_in)/out_resolution +1)];
            pts_list{i}{end+1} =  ([size(slices{end},1)/2;1] + [additional_pts_new{i}(3);additional_pts_new{i}(1)]);
        end          
        
        views{end+1} = 'axial';              
        
end

for i=1:length(slices)
    slices{i} = squeeze(slices{i});
end

