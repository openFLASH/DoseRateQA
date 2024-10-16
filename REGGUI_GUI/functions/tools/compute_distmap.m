%% compute_distmap
% Compute the distance map. The distance map d(X) gives for every voxel X its distance to the closest point belonging to a structure S. The distance map is signed, where values are negative inside the structure and positive outside the structure.
% See section "2.1.5 Distance maps" of reference [1] for more information
%
%% Syntax
% |distmap = compute_distmap(input)|
%
%
%% Description
% |distmap = compute_distmap(input)| Compute the distance map
%
%
%% Input arguments
% |input| - _SCALAR MATRIX_ - |input(x,y,z)| Mask defining the object. 0 = the voxel (x,y,z) does NOT belongs to the structure. If the voxel belongs to the structure than |input(x,y,z)~=0|
%
%
%% Output arguments
%
% |distmap| - _SCALAR MATRIX_ - |distmap(x,y,z)| distance (in voxel unit) of the voxel (x,y,z) to the closest point belonging to surface of the structure. The distance map is signed, where values are negative inside the structure and positive outside the structure.
%
%% Reference
%
% [1] Janssens, Guillaume. Registration models for tracking organs and tumors in highly deformable anatomies : applications to radiotherapy. Universite catholique Louvain (2010) http://hdl.handle.net/2078.1/33459
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function distmap = compute_distmap(input)

% Authors : G.Janssens

dims = length(size(input));
disp('Computing distance map...')
distmap = zeros(size(input),'single');
myMask = single(input~=0);
coplanar = 0;

try

    if(dims == 3)

            myStrel = ones(3,3,3);
            distmap = zeros(size(input));
            myMask = double(input~=0);
            myOutsideContour = imdilate(myMask,myStrel)-myMask;
            myInsideContour = myMask-imerode(myMask,myStrel);

%         myContour = matitk('FGM',[],double(myMask));
%         myInsideContour = single((myContour)&(myMask));
%         myOutsideContour = single((myContour)&(~myMask));

        [i j] = find(myInsideContour);
        [j k] = ind2sub([size(myInsideContour,2) size(myInsideContour,3)],j);
        incont_pts = [i j k];
        [i j] = find(myOutsideContour);
        [j k] = ind2sub([size(myOutsideContour,2) size(myOutsideContour,3)],j);
        outcont_pts = [i j k];
        [i j] = find(myMask);
        [j k] = ind2sub([size(myMask,2) size(myMask,3)],j);
        in_pts = [i j k];
        [i j] = find(~myMask);
        [j k] = ind2sub([size(myMask,2) size(myMask,3)],j);
        out_pts = [i j k];

        t = delaunayn(incont_pts);
        [np dist] = dsearchn(incont_pts,t,out_pts);
        distmap(out_pts(:,1)+(out_pts(:,2)-1)*size(input,1)+(out_pts(:,3)-1)*size(input,1)*size(input,2)) = -dist+0.5;
        t = delaunayn(outcont_pts);
        [np dist] = dsearchn(outcont_pts,t,in_pts);
        distmap(in_pts(:,1)+(in_pts(:,2)-1)*size(input,1)+(in_pts(:,3)-1)*size(input,1)*size(input,2)) = dist-0.5;
        
    elseif(dims == 2)

        myStrel = strel('square',3);
        myOutsideContour = imdilate(myMask,myStrel)-myMask;
        myInsideContour = myMask-imerode(myMask,myStrel);

        [i j] = find(myInsideContour);
        incont_pts = [i j];
        [i j] = find(myOutsideContour);
        outcont_pts = [i j];
        [i j] = find(myMask);
        in_pts = [i j];
        [i j] = find(~myMask);
        out_pts = [i j];

        t = delaunayn(incont_pts);
        [np dist] = dsearchn(incont_pts,t,out_pts);
        distmap(out_pts(:,1)+(out_pts(:,2)-1)*size(input,1)) = -(dist-0.5);
        t = delaunayn(outcont_pts);
        [np dist] = dsearchn(outcont_pts,t,in_pts);
        distmap(in_pts(:,1)+(in_pts(:,2)-1)*size(input,1)) = dist-0.5;

    end

catch

    disp('Warning : mask defined with co-planar boundary points.')
    distmap = zeros(size(input),'single');
    myMask = single(input~=0);
    coplanar = 1;

end

if(coplanar)
    
    try

        if(dims == 3)

            [i j s] = find(myMask);
            [j k] = ind2sub([size(myMask,2) size(myMask,3)],j);
            in_pts = [i j k];
            [i j s] = find(~myMask);
            [j k] = ind2sub([size(myMask,2) size(myMask,3)],j);
            out_pts = [i j k];

            plan = find(max(in_pts)<size(myMask)|max(out_pts)<size(myMask));
            if(isempty(plan))
                return;
            else
                plan = plan(1);
            end
            
            switch plan
                case 1
                    bnd = min(max(in_pts(:,1)),max(out_pts(:,1)))+0.5;
                    for n=1:size(myMask,1)
                        dist = n-bnd;
                        distmap(n,:,:) = abs(dist);
                    end

                case 2
                    bnd = min(max(in_pts(:,2)),max(out_pts(:,2)))+0.5;
                    for n=1:size(myMask,2)
                        dist = n-bnd;
                        distmap(:,n,:) = -abs(dist);
                    end

                case 3
                    bnd = min(max(in_pts(:,3)),max(out_pts(:,3)))+0.5;
                    for n=1:size(myMask,3)
                        dist = n-bnd;
                        distmap(:,:,n) = -abs(dist);
                    end
            end

            distmap(find(myMask)) = -distmap(find(myMask));
            

        elseif(dims == 2)

            [i j] = find(myInsideContour);
            incont_pts = [i j];
            [i j] = find(myOutsideContour);
            outcont_pts = [i j];
            [i j] = find(myMask);
            in_pts = [i j];
            [i j] = find(~myMask);
            out_pts = [i j];
            
            plan = find(max(in_pts)<size(myMask)|max(out_pts)<size(myMask));

            switch plan
                case 1
                    bnd = min(max(in_pts(:,1)),max(out_pts(:,1)))+0.5;
                    for n=1:size(myMask,1)
                        dist = n-bnd;
                        distmap(n,:) = -abs(dist);
                    end

                case 2
                    bnd = min(max(in_pts(:,2)),max(out_pts(:,2)))+0.5;
                    for n=1:size(myMask,2)
                        dist = n-bnd;
                        distmap(:,n) = -abs(dist);
                    end

            end

            distmap(find(myMask)) = -distmap(find(myMask));

        end

    catch
        
        disp('Error while computing distance map !')
        err = lasterror;
        disp(['    ',err.message]);
        disp(err.stack(1));
        
    end
end
