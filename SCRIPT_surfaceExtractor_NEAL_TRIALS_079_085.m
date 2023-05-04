%% SCRIPT_parseVideoFile.m imports an experimental trial video and extracts
% the cylinder position, wave profile, and other quantities of interest.
% Requires a calibrated camera model.
clear all
close all
clc

%% read video file and load camera calibration parameters
mainDir = 'G:\Shared drives\NSF WEC Project\Experiment_Data\March 2022 Experiment\TrialVideos';
flder = 'SideCamera';
fileName = 'MVI_0081.MP4';

v = VideoReader([flder filesep fileName]);

load('canonEOS6D_camParams.mat')

%% SE

SE = ones(1,7); %ORIGINAL Structuring element matrix

%% Initialize Time Vector

TimePerFrame = 1/v.FrameRate;

%% Saving Data
save_data = 1; % Change to 1 if you want to save the data for a specific Trial



%%
saveGif = 0; % if set to 1 a gif of the animation is saved
saveVideo = 0;
giffilename = 'SurfaceTracker_v1.gif';
vidFilename = 'SurfaceTracker_v1.mp4';

if saveVideo==1
    vSaver = VideoWriter(vidFilename,'MPEG-4');
    open(vSaver)
end
ind1 = 200;
ind2 = 800;
%% analyze frames from video object

% crop rectangle
rectangle = (1.0e+03)*[0.0045    0.200    1.8260    0.2050];
x_plot = linspace(rectangle(1),rectangle(3),1000);

% initialize variable for circle centers and radius
circMat = zeros(v.NumFrames,3);
% if computer has parallel computing toolbox, use a parfor for speed
% parpool('local')
% parfor mm = 1:v.NumFrames

% if computer does not have parallel computing toolbox, use regular for
% loop
startFrame = 500;
frameSkip = 5;
count = 1;
for mm = startFrame:frameSkip:v.NumFrames
    %     tic
    % read frame from video
    frame = read(v,mm);

    % undistort the image using the camera calibration parameters
    [im, newOrigin] = undistortImage(frame, cameraParams, 'OutputView', 'full');

    % crop image to extract region around free surface
    %     [I,rect] = imcrop(im); % use to recrop if needed
    ImSurf = rgb2gray(imcrop(im,rectangle));

    BW1 = edge(ImSurf,'sobel',[],'horizontal');
    BW2 = imclose(BW1,SE); %Closes binary image using a preset structuring element matrix.
    BW3 = bwareaopen(BW2,500); %removes all connected components that have fewer than 500 pixels.
    [y,x] = find(BW3); %Extract Points from Curve
    [p,s,mu] = polyfit(x,y,5);
    y_plot = polyval(p,(x_plot-mu(1))/mu(2));
    y_fit_raw = polyval(p,(x-mu(1))/mu(2));
    %     disp(p)
    %     Pixel_Error = table(x,y,y_plot,y-y_plot,'VariableNames',{'X','Y','Fit','FitError'}); %Table displaying fit error
    if save_data==1
        fittingPolyData.polynomial.Coeffs(count,1).frame = mm;
        fittingPolyData.polynomial.Coeffs(count,1).Time = mm*TimePerFrame;
        fittingPolyData.polynomial.Coeffs(count,:).data = p; % store polynomial coefficients here
        
        fittingPolyData.SinglePoint(count).frame = mm;
        fittingPolyData.SinglePoint(count).Time = mm*TimePerFrame;
        fittingPolyData.SinglePoint(count).P1Index = x_plot(ind1)+rectangle(1);
        fittingPolyData.SinglePoint(count).P1Data = y_plot(ind1)+rectangle(2);
        fittingPolyData.SinglePoint(count).P2Index = x_plot(ind2)+rectangle(1);
        fittingPolyData.SinglePoint(count).P2Data = y_plot(ind2)+rectangle(2);

        fittingPolyData.raw(count).frame = mm;
        fittingPolyData.raw(count).Time = mm*TimePerFrame;
        fittingPolyData.raw(count).points = [x,y]; % store raw image processing points.

        fittingPolyData.polyProcessed(count).frame = mm;
        fittingPolyData.polyProcessed(count).Time = mm*TimePerFrame;
        fittingPolyData.polyProcessed(count).points = [x_plot;y_plot]; %store fitted points here.
        fittingPolyData.polyProcessed(count).rawfitpoints = [x,y_fit_raw]; %store fitted points here.

        % Maybe talk to CAPT Severson about this.
        fittingPolyData.Error(count).frame = mm;
        fittingPolyData.Error(count).Time = mm*TimePerFrame;
        fittingPolyData.Error(count).NRMSE = mean((y_fit_raw - y).^2)./(max(y)-min(y)); % Calculation of the nrmse


        % iterate loop counter
        count = count+1;
    end
    if mm==500
                 imFig = figure(1);
                 cdf = imshow(BW3);
                 hold on
                 pl = plot(x_plot,y_plot,'-m', 'LineWidth',2);

        fullFig = figure(2); clf
        orig = imshow(frame);
        hold on
        pl2 = plot(x_plot+rectangle(1),y_plot+rectangle(2),'-m','Linewidth',2);
        pl3 = plot(x_plot(ind1)+rectangle(1),y_plot(ind1)+rectangle(2),'ok','MarkerSize',6,'MarkerFaceColor','k');
        tx1 = text(x_plot(ind1)+rectangle(1)-150,y_plot(ind1)+rectangle(2)-30,['(' num2str(x_plot(ind1)+rectangle(1)) ',' num2str(round(y_plot(ind1)+rectangle(2),1)) ')']);
        pl4 = plot(x_plot(ind2)+rectangle(1),y_plot(ind2)+rectangle(2),'ok','MarkerSize',6,'MarkerFaceColor','k');
        tx2 = text(x_plot(ind2)+rectangle(1)+10,y_plot(ind2)+rectangle(2)-30,['(' num2str(x_plot(ind2)+rectangle(1)) ',' num2str(round(y_plot(ind2)+rectangle(2),1)) ')']);


    else
        % update figure 1 (just the image processing
         set(cdf,'CData',BW3);
         set(pl,'XData',x,'YData',y_plot);

        % udpate figure 2 ( the complete image with image processing result
        % overlaid
        set(orig,'CData',frame);
        set(pl2,'XData',x_plot+rectangle(1),'YData',y_plot+rectangle(2))
        set(pl3,'XData',x_plot(ind1)+rectangle(1),'YData',y_plot(ind1)+rectangle(2))
        set(pl4,'XData',x_plot(ind2)+rectangle(1),'YData',y_plot(ind2)+rectangle(2))
        set(tx1,'Position',[x_plot(ind1)+rectangle(1)-150 y_plot(ind1)+rectangle(2)-30 0],'String',['(' num2str(round(x_plot(ind1)+rectangle(1),1)) ',' num2str(round(y_plot(ind1)+rectangle(2),1)) ')'])
        set(tx2,'Position',[x_plot(ind2)+rectangle(1)+10 y_plot(ind2)+rectangle(2)-30 0],'String',['(' num2str(round(x_plot(ind2)+rectangle(1),1)) ',' num2str(round(y_plot(ind2)+rectangle(2),1)) ')'])
    end
    drawnow

    if saveGif==1
        if mm == 500
            imwrite(cdf.CData,giffilename,'gif','LoopCount',Inf,'DelayTime',1/120);
        else
            imwrite(cdf.CData,giffilename,'gif','WriteMode','append','DelayTime',1/120);
        end
    end

    if saveVideo==1
        currFrame = getframe(fullFig);
        writeVideo(vSaver,currFrame);
    end

    mm;
end

if save_data == 1
        save([fileName(1:end-4) '.mat'], 'fittingPolyData') %Save the specified data to a variable.
end

if saveVideo==1
    close(vSaver)
end

