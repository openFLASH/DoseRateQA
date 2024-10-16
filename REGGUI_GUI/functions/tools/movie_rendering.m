%% movie_rendering
% Create a movie and save it on file.
%
%% Syntax
% |movie_rendering(images,outname)| Create a AVI movie with 12 fps, 1s image duration, 0.25s fading and no loop
%
% |movie_rendering(images,outname,fps)| Create a AVI movie with 1s image duration, 0.25s fading and no loop
%
% |movie_rendering(images,outname,fps,image_duration)| Create a AVI movie with 0.25s fading and no loop
%
% |movie_rendering(images,outname,fps,image_duration,fade_duration)| Create a AVI movie with no loop
%
% |movie_rendering(images,outname,fps,image_duration,fade_duration,frame_size)| Create a AVI movie with no loop
%
% |movie_rendering(images,outname,fps,image_duration,fade_duration,frame_size,loop)| Create a AVI movie with loop compatibility
%
% |movie_rendering(images,outname,fps,image_duration,fade_duration,frame_size,loop,format)| Create a movie with the specified format
%
%
%% Description
% |movie_rendering(images,outname,fps,image_duration,fade_duration,frame_size,loop)| describes the function
%
%
%% Input arguments
% |images| - _INTEGER MATRIX_ - |images|(x,y,J,t) Frame data. Defines the color of pixel at position (x,y) in the frame at time step t. |J=1,2,3|  is the RGB triplet value defining the colour. 
%
% |outname| - _STRING_ -  File name of the output file
%
% |fps| - _SCALAR_ -  Number of frames per second
%
% |image_duration| - _SCALAR_ - Time (in s) during which one image is displayed
%
% |fade_duration| - _SCALAR_ - Time (in s) during which the fading transition between two sucessive images take place
%
% |frame_size| - Not used
%
% |loop| - _INTEGER_ -  1 = the first image is copied again at theend of the movie.
%
%
%% Output arguments
%
% None.
%
%% Contributors
% Authors : G.Janssens (open.reggui@gmail.com)

function movie_rendering(images,outname,fps,image_duration,fade_duration,frame_size,loop,format)

if(isempty(images))
    disp('No image to render !!')
    return
end

if(nargin<3)
    fps = 12;
end
if(nargin<4)
    image_duration = 1;
end
if(nargin<5)
    fade_duration = 0.25;
end
if(fade_duration > image_duration/2)
    fade_duration = image_duration/2;
end
if(nargin<6)
    frame_size = [];
end
if(isempty(frame_size))
    frame_size = [size(images,1) size(images,2)];
end
% frame_size = round(frame_size/4)*4;
% frame_size(1) = max(frame_size(1),64);
% frame_size(2) = max(frame_size(2),64);
% if((frame_size(1)~=size(images,1))||(frame_size(2)~=size(images,2)))
%     disp(['Resampling frames to ',num2str(frame_size(1)),'x',num2str(frame_size(2))])
%     temp = [];
%     for i=1:size(images,4)
%         temp(:,:,:,i) = imresize(images(:,:,:,i),frame_size);
%     end
%     images = uint8(temp);
%     clear temp
% end
if(nargin<7)
    loop = 1;
end
if(nargin<8)
    format = '';
end

image_nb = ceil(image_duration*fps);
fade_nb = floor(fade_duration*fps);

if(loop)
    images(:,:,:,end+1) = images(:,:,:,1);
end

% Within a loop, plot each picture and save to MATLAB movie matrix:
for j=1:image_nb-2*fade_nb        % First image
    A(:,j)=im2frame(uint8(images(:,:,:,1)));
end
for i=2:size(images,4)-1         % Intermediate images
    for j=1:fade_nb       
        A(:,(i-1)*(image_nb-fade_nb)+j-fade_nb)=im2frame(uint8(double(images(:,:,:,i-1))*(fade_nb-j)/fade_nb + double(images(:,:,:,i))*j/fade_nb));
    end
    for j=fade_nb+1:image_nb
        A(:,(i-1)*(image_nb-fade_nb)+j-fade_nb)=im2frame(uint8(images(:,:,:,i)));
    end
end
for i=size(images,4)             % Last image
    for j=1:fade_nb
        A(:,(i-1)*(image_nb-fade_nb)+j-fade_nb)=im2frame(uint8(double(images(:,:,:,i-1))*(fade_nb-j)/fade_nb + double(images(:,:,:,i))*j/fade_nb));
    end
    for j=fade_nb+1:image_nb-fade_nb
        A(:,(i-1)*(image_nb-fade_nb)+j-fade_nb)=im2frame(uint8(images(:,:,:,i)));
    end
end

% Rendering movie
switch format
    case {'gif','GIF'}
        disp('Start animated gif export...');
        for i=1:size(A,2)
            im = frame2im(A(i)); 
            [imind,cm] = rgb2ind(im,256); 
            if i==1
                if(loop)
                    imwrite(imind,cm,outname,'gif','LoopCount',Inf,'DelayTime',1/fps)
                else
                    imwrite(imind,cm,outname,'gif','LoopCount',1,'DelayTime',1/fps)
                end
            else
                imwrite(imind,cm,outname,'gif','WriteMode','append','DelayTime',1/fps)
            end
        end
    otherwise
        disp('Start video rendering...');
        % movie2avi(A,outname,'fps',fps,'compression','none'); % movie2avi deprecated...
        vidObj = VideoWriter(outname,'Uncompressed AVI');
        vidObj.FrameRate = fps;
        open(vidObj);
        writeVideo(vidObj,A);
        close(vidObj);
end
disp('Rendering completed.');
