%% Hausdorff_distance
% Compute the Hausdorff distances between two structures (using Euclidian distance).
%
%% Syntax
% |dist = Hausdorff_distance(im1,im2,handles)|
%
%
%% Description
% |dist = Hausdorff_distance(im1,im2,handles)| describes the function
%
%
%% Input arguments
% |im1| - _STRING_ -  Name of the binary mask in |handles.images| of the first structure
%
% |im2| - _STRING_ -  Name of the binary mask in |handles.images| of the second structure
%
% |handles| - _STRUCTURE_ -  REGGUI data structure with the data to be processed. The following data must be present in the structure:
%
% * |handles.images.name| - _STRING_ - Name of the image
% * |handles.images.data| - _SCALAR MATRIX_ - |data(x,y,z)| Intensity of the voxel at coordinate (x,y,z)
% * |handles.size| - _INTEGER VECTOR_ - Dimension (x,y,z) (in pixels) of the displayed images in GUI
% * |handles.spacing| - _SCALAR VECTOR_ - Pixel size (|mm|) of the displayed images in GUI
%
%
%% Output arguments
%
% |dist| - _SCALAR_ - Hausdorff distance between structures
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function dist = Hausdorff_distance(im1,im2,handles,type)

% Authors : G.Janssens

if(nargin<4)
    type = '95_percentile';
end

dist = NaN;

try
    
    if(strcmp(type,'mean_slicewise_max'))
        
        m1 = Get_reggui_data(handles,im1,'images');
        m2 = Get_reggui_data(handles,im2,'images');
        
        dist = [];
        
        for i=1:size(m1,3)
            
            if(sum(sum(m1(:,:,i)))>0 && sum(sum(m2(:,:,i)))>0)
                
                b1 = bwboundaries(m1(:,:,i));
                p1 = [];
                for j=1:length(b1)
                    p1 = [p1;b1{j}];
                end
                b2 = bwboundaries(m2(:,:,i));
                p2 = [];
                for j=1:length(b2)
                    p2 = [p2;b2{j}];
                end
                
                p1(:,1) = p1(:,1)*handles.spacing(1);
                p1(:,2) = p1(:,2)*handles.spacing(2);
                p2(:,1) = p2(:,1)*handles.spacing(1);
                p2(:,2) = p2(:,2)*handles.spacing(2);
                
                for j = 1:size(p1,1)
                    P = ones(size(p2,1),1) * p1(j,:);
                    D = (P-p2).*(P-p2);
                    D = sqrt(D*ones(2,1));
                    dist12(j) = min(D);
                end
                for j = 1:size(p2,1)
                    P = ones(size(p1,1),1) * p2(j,:);
                    D = (P-p1).*(P-p1);
                    D = sqrt(D*ones(2,1));
                    dist21(j) = min(D);
                end
                dist(end+1) = max([abs(dist12(:));abs(dist21(:))]);
                
            end
        end
        
        dist = mean(dist);
        disp(['Slice-wise mean Hausdorff distance [mm] between ',im1,' and ',im2,' = ',num2str(dist)])
        
    else
        
        disp('Computing mesh from binary masks...')
        m1 = struct;
        [m1.faces,m1.vertices] = Compute_mesh(im1,handles,0);
        [m2.faces,m2.vertices] = Compute_mesh(im2,handles,0);
        
        if(isempty(m2.vertices) || isempty(m1.vertices))
            disp('Empty contour. Abort');
            return
        end
        
        disp('Computing closest points...')
        %     dist12 = point2trimesh(m2, 'QueryPoints', m1.vertices);
        %     dist21 = point2trimesh(m1, 'QueryPoints', m2.vertices);
        if(length(m1.vertices(:,1))*length(m2.vertices(:,1))*8 > 8e9) % when too many points, loop along blocks
            bl = 1e3;
            dist12 = Inf(length(m1.vertices(:,1)),1);
            dist21 = Inf(length(m2.vertices(:,1)),1);
            for i=1:bl:length(m1.vertices(:,1))
                dist12(i:min(i+bl,end)) = min(sqrt(...
                    (repmat(m1.vertices(i:min(i+bl,end),1),1,length(m2.vertices(:,1)))-repmat(m2.vertices(:,1)',length(m1.vertices(i:min(i+bl,end),1)),1)).^2+...
                    (repmat(m1.vertices(i:min(i+bl,end),2),1,length(m2.vertices(:,2)))-repmat(m2.vertices(:,2)',length(m1.vertices(i:min(i+bl,end),2)),1)).^2+...
                    (repmat(m1.vertices(i:min(i+bl,end),3),1,length(m2.vertices(:,3)))-repmat(m2.vertices(:,3)',length(m1.vertices(i:min(i+bl,end),3)),1)).^2),[],2);
            end
            for i=1:bl:length(m2.vertices(:,1))
                dist21(i:min(i+bl,end)) = min(sqrt(...
                    (repmat(m2.vertices(i:min(i+bl,end),1),1,length(m1.vertices(:,1)))-repmat(m1.vertices(:,1)',length(m2.vertices(i:min(i+bl,end),1)),1)).^2+...
                    (repmat(m2.vertices(i:min(i+bl,end),2),1,length(m1.vertices(:,2)))-repmat(m1.vertices(:,2)',length(m2.vertices(i:min(i+bl,end),2)),1)).^2+...
                    (repmat(m2.vertices(i:min(i+bl,end),3),1,length(m1.vertices(:,3)))-repmat(m1.vertices(:,3)',length(m2.vertices(i:min(i+bl,end),3)),1)).^2),[],2);
            end
        else
            D = sqrt(...
                (repmat(m1.vertices(:,1),1,length(m2.vertices(:,1)))-repmat(m2.vertices(:,1)',length(m1.vertices(:,1)),1)).^2+...
                (repmat(m1.vertices(:,2),1,length(m2.vertices(:,2)))-repmat(m2.vertices(:,2)',length(m1.vertices(:,2)),1)).^2+...
                (repmat(m1.vertices(:,3),1,length(m2.vertices(:,3)))-repmat(m2.vertices(:,3)',length(m1.vertices(:,3)),1)).^2);
            dist12 = min(D,[],2);
            dist21 = min(D,[],1);
        end
        abs_dists = [abs(dist12(:));abs(dist21(:))];
        
        switch type
            case 'max'
                disp('Finding maximum distance among closest points...')
                dist = max(abs_dists);
            case 'mean'
                disp('Finding mean distance among closest points...')
                dist = mean(abs_dists);
            case '95_percentile'
                disp('Finding 95th percentile distance among closest points...')
                dist = compute_prctile(abs_dists,95);
        end
        
        disp(['3D Hausdorff distance [mm] between ',im1,' and ',im2,' = ',num2str(dist)])
        
    end
    
catch
    disp('Error : images not found or uncorrect size!')
    err = lasterror;
    disp(['    ',err.message]);
    disp(err.stack(1));
end

