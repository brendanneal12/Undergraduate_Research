%% This script is to Extract Images for the Fall Research Poster Session

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
    
    BW2 = edge(ImSurf,'sobel',[],'horizontal');
    
    if mm==500
        fig = figure(1);
        fig2 = figure(2);
        cropBW = imshow(ImSurf);
        cdf = imshow(BW2);
    else
        %set(cropBW, 'CData', ImSurf);
        set(cdf,'CData',BW2);
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
    end
    