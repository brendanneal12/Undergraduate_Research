%% SCRIPT_parseVideoFile.m imports an experimental trial video and extracts
% the cylinder position, wave profile, and other quantities of interest.
% Requires a calibrated camera model.
clear all
close all
clc

%% read video file and load camera calibration parameters
flder = 'SideCamera';
fileName = 'MVI_0098.MP4';

v = VideoReader([flder filesep fileName]);

load('canonEOS6D_camParams.mat')


%%
saveGif = 0; % if set to 1 a gif of the animation is saved
filename = 'SurfaceTracker_v1.gif';

%% analyze frames from video object

% crop rectangle
rectangle = (1.0e+03)*[0.0045    0.3305    1.8260    0.2050];

% initialize variable for circle centers and radius
circMat = zeros(v.NumFrames,3);
% if computer has parallel computing toolbox, use a parfor for speed
% parpool('local')
% parfor mm = 1:v.NumFrames

    % if computer does not have parallel computing toolbox, use regular for
    % loop
    for mm = 500:5:v.NumFrames
    %     tic
    % read frame from video
    frame = read(v,mm);

    % undistort the image using the camera calibration parameters
    [im, newOrigin] = undistortImage(frame, cameraParams, 'OutputView', 'full');

    % crop image to extract region around free surface
%     [I,rect] = imcrop(im); % use to recrop if needed
    ImSurf = rgb2gray(imcrop(im,rectangle));
    
    BW1 = edge(ImSurf,'sobel',[],'horizontal');
    
    if mm==500
        fig = figure(1);
        cdf = imshow(BW1);
    else
        set(cdf,'CData',BW1);
    end
    drawnow
        
    if saveGif==1
        if mm == 500
            imwrite(cdf.CData,filename,'gif','LoopCount',Inf,'DelayTime',1/120);
        else
            imwrite(cdf.CData,filename,'gif','WriteMode','append','DelayTime',1/120);
        end
    end

    mm
    %     toc
end
% delete(gcp('nocreate'))

% % %% replay images with circle and trajectory overlaid
% % 
% % 
% % fig = figure(2); clf
% % subplot(2,3,[1 2 4 5])
% % % read frame from video
% % frame = read(v,1);
% % % undistort the image using the camera calibration parameters
% % [im, newOrigin] = undistortImage(frame, cameraParams, 'OutputView', 'full');
% % 
% % % Establish plot on first frame
% % figIm = imshow(im);
% % hold on
% % pl = plot(circMat(1,1),circMat(1,2),'og','MarkerSize',6,'MarkerFaceColor','g');
% % pl_tr = plot(circMat(1:2,1),circMat(1:2,2),'-g');
% % pl2 = plot(circMat(1,1)+circMat(1,3)*cos(0:pi/40:2*pi),circMat(1,2)+circMat(1,3)*sin(0:pi/40:2*pi),'r','LineWidth',2);
% % tstr = text(1200,400,['Frame: ' num2str(1)],'Color','w','FontSize',14);
% % 
% % subplot(2,3,3)
% % plx = plot(1:2,circMat(1:2,1),'-b');
% % xlabel('Frame')
% % ylabel('X-position (pixels)')
% % axis([500 3400 900 1050])
% % subplot(2,3,6)
% % ply = plot(1:2,circMat(1:2,2),'-g');
% % xlabel('Frame')
% % ylabel('Y-position (pixels)')
% % axis([500 3400 700 1000])
% % 
% % for mm = 500:4:size(circMat,1)
% %     % read frame from video
% %     frame = read(v,mm);
% % 
% %     % undistort the image using the camera calibration parameters
% %     [im, newOrigin] = undistortImage(frame, cameraParams, 'OutputView', 'full');
% % 
% %     set(figIm,'CData',im);
% %     set(pl,'XData',circMat(mm,1),'YData',circMat(mm,2));
% %     set(pl_tr,'XData',circMat(1:mm,1),'YData',circMat(1:mm,2));
% %     set(pl2,'XData',circMat(mm,1)+circMat(mm,3)*cos(0:pi/40:2*pi),'YData',circMat(mm,2)+circMat(mm,3)*sin(0:pi/40:2*pi));
% %     set(tstr,'String',['Frame: ' num2str(mm)]);
% %     set(plx,'XData',1:mm,'YData',circMat(1:mm,1))
% %     set(ply,'XData',1:mm,'YData',circMat(1:mm,2))
% %     drawnow
% %     
% %     
% %     
% %     if mm==2
% %         pause
% %     end
% %     frm2 = getframe(fig);
% %     [A,map] = rgb2ind(frm2.cdata,256,'nodither');
% %     if saveGif==1
% %         if mm == 500
% %             imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1/120);
% %         else
% %             imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1/120);
% %         end
% %     end
% % end