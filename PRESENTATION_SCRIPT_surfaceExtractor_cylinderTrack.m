%% SCRIPT_parseVideoFile.m imports an experimental trial video and extracts
% the cylinder position, wave profile, and other quantities of interest.
% Requires a calibrated camera model.
clear all
close all
clc

%% read video file and load camera calibration parameters
mainDir = 'G:\Shared drives\NSF WEC Project\Experiment_Data\March 2022 Experiment\TrialVideos';
flder = 'SideCamera';
fileName = 'MVI_0098.MP4';

v = VideoReader([flder filesep fileName]);

load('canonEOS6D_camParams.mat')

%% SE

SE = ones(1,7); %Structuring element matrix

%% Initialize Time Vector

TimePerFrame = 1/v.FrameRate;

%%
saveGif = 0; % if set to 1 a gif of the animation is saved
saveVideo = 0;

giffilename = 'surfaceCylinderTracker_PRESENTATION.gif';
vidFilename = 'surfaceCylinderTracker_PRESENTATION.mp4';

if saveVideo==1
    vSaver = VideoWriter(vidFilename,'MPEG-4');
    open(vSaver)
end
ind1 = 200;
ind2 = 800;
%% analyze frames from video object

% crop rectangle
rectangle = (1.0e+03)*[0.0045    0.3305    1.8260    0.2050];
x_plot = linspace(rectangle(1),rectangle(3),1000);

% initialize variable for circle centers and radius
circMat = zeros(v.NumFrames,3);
% if computer has parallel computing toolbox, use a parfor for speed
% parpool('local')
% parfor mm = 1:v.NumFrames

% if computer does not have parallel computing toolbox, use regular for
% loop
count = 1;
for mm = 500:4:v.NumFrames
    %     tic
    % read frame from video
    frame = read(v,mm);

    % undistort the image using the camera calibration parameters
    [im, newOrigin] = undistortImage(frame, cameraParams, 'OutputView', 'full');

    % % % % CYLINDER TRACKING % % % % % % %
    % find center and radius of cylinder
    [centers,radii] = imfindcircles(im,[160 195],'ObjectPolarity','dark');
    if ~isempty(centers)
        tmp = [centers,radii];
    else
        disp('Failed to find circle center...')
        tmp = nan(1,3);
    end
    circMat(count,1:3) = tmp;
    frms(count,1) = mm;
    


    % % % % FREE SURFACE ANALYSIS % % % % % % 
    % crop image to extract region around free surface
    %     [I,rect] = imcrop(im); % use to recrop if needed
    ImSurf = rgb2gray(imcrop(im,rectangle));

    BW1 = edge(ImSurf,'sobel',[],'horizontal');
    BW2 = imclose(BW1,SE); %Closes binary image using a preset structuring element matrix.
    BW3 = bwareaopen(BW2,500); %removes all connected components that have fewer than 500 pixels.
    [y,x] = find(BW3); %Extract Points from Curve
    [p,s,mu] = polyfit(x,y,5);
    y_plot = polyval(p,(x_plot-mu(1))/mu(2));
    point1val(count) = y_plot(ind1)+rectangle(2);
    point2val(count) = y_plot(ind2)+rectangle(2);
    timevector(count) = mm*TimePerFrame;
    %     disp(p)
    %     Pixel_Error = table(x,y,y_plot,y-y_plot,'VariableNames',{'X','Y','Fit','FitError'}); %Table displaying fit error

    if mm==500
        %         imFig = figure(1);
        %         cdf = imshow(BW3);
        %         hold on
        %         pl = plot(x_plot,y_plot,'-m', 'LineWidth',2);
        

        % Plot overlay of cylinder tracking and surface tracking
        fullFig = figure(2); clf
        set(fullFig,'Position',1.0e+03*[0.0257 0.1923 1.1453 0.3753])
        subplot(3,3,[1 2 4 5 7 8])
        orig = imshow(frame);
        hold on
        pl2 = plot(x_plot+rectangle(1),y_plot+rectangle(2),'-m','Linewidth',2);
        pl3 = plot(x_plot(ind1)+rectangle(1),y_plot(ind1)+rectangle(2),'ok','MarkerSize',6,'MarkerFaceColor','k');
        tx1 = text(x_plot(ind1)+rectangle(1)-150,y_plot(ind1)+rectangle(2)-30,['(' num2str(x_plot(ind1)+rectangle(1)) ',' num2str(round(y_plot(ind1)+rectangle(2),1)) ')']);
        pl4 = plot(x_plot(ind2)+rectangle(1),y_plot(ind2)+rectangle(2),'ok','MarkerSize',6,'MarkerFaceColor','k');
        tx2 = text(x_plot(ind2)+rectangle(1)+10,y_plot(ind2)+rectangle(2)-30,['(' num2str(x_plot(ind2)+rectangle(1)) ',' num2str(round(y_plot(ind2)+rectangle(2),1)) ')']);
        plc = plot(circMat(count,1),circMat(count,2),'og','MarkerSize',6,'MarkerFaceColor','g');
        plc_tr = plot(circMat(1:count,1),circMat(1:count,2),'-g');
        plc2 = plot(circMat(count,1)+circMat(count,3)*cos(0:pi/40:2*pi),circMat(count,2)+circMat(count,3)*sin(0:pi/40:2*pi),'r','LineWidth',2);
        tstr = text(1200,100,['Frame: ' num2str(1)],'Color','w','FontSize',14);

        % plot free surface
        subplot(3,3,3)
        hold on
        pl22 = plot(x_plot+rectangle(1),y_plot+rectangle(2),'-m','Linewidth',2);
        pl32 = plot(x_plot(ind1)+rectangle(1),y_plot(ind1)+rectangle(2),'ok','MarkerSize',6,'MarkerFaceColor','k');
%         tx12 = text(x_plot(ind1)+rectangle(1)-150,y_plot(ind1)+rectangle(2)-30,['(' num2str(x_plot(ind1)+rectangle(1)) ',' num2str(round(y_plot(ind1)+rectangle(2),1)) ')']);
        pl42 = plot(x_plot(ind2)+rectangle(1),y_plot(ind2)+rectangle(2),'ok','MarkerSize',6,'MarkerFaceColor','k');
%         tx22 = text(x_plot(ind2)+rectangle(1)+10,y_plot(ind2)+rectangle(2)-30,['(' num2str(x_plot(ind2)+rectangle(1)) ',' num2str(round(y_plot(ind2)+rectangle(2),1)) ')']);
        box on
        axis([0 max(x_plot) 0 800])
        ylabel('Free Surface Profile')
        set(gca,'YDir','Reverse','XTickLabel',{''},'YTickLabel',{''})


        % Plot cylinder position 
        subplot(3,3,6)
        hold on
        plx = plot(1:2,circMat(1:2,1),'-b');
        ply = plot(1:2,circMat(1:2,2),'-g');
        xlabel('Frame')
        ylabel('Cylinder position (pixels)')
        axis([500 3400 700 1100])
        leg = legend('Surge','Heave');
        set(leg,'Location','southeast')
        set(leg, 'FontSize', 4)
        box on
        
        subplot(3,3,9)
        hold on
        plpoint1 = plot(timevector(1), point1val(1),'-b');
        plpoint2 = plot(timevector(1), point2val(1),'-r');
        xlabel('Time (s)')
        ylabel('Y (Pixels)')
        axis([TimePerFrame*500 60 250 520])
        leg2 = legend('X = 371.8','X = 1465.8');
        set(leg2, 'Location','southwest')
        set(leg2, 'FontSize', 4)
        box on
        

    else
        % update figure 1 (just the image processing
%         set(cdf,'CData',BW3);
%         set(pl,'XData',x,'YData',y_plot);

        % udpate figure 2 ( the complete image with image processing result
        % overlaid
        set(orig,'CData',frame);
        set(pl2,'XData',x_plot+rectangle(1),'YData',y_plot+rectangle(2))
        set(pl3,'XData',x_plot(ind1)+rectangle(1),'YData',y_plot(ind1)+rectangle(2))
        set(pl4,'XData',x_plot(ind2)+rectangle(1),'YData',y_plot(ind2)+rectangle(2))
        set(tx1,'Position',[x_plot(ind1)+rectangle(1)-150 y_plot(ind1)+rectangle(2)-30 0],'String',['(' num2str(round(x_plot(ind1)+rectangle(1),1)) ',' num2str(round(y_plot(ind1)+rectangle(2),1)) ')'])
        set(tx2,'Position',[x_plot(ind2)+rectangle(1)+10 y_plot(ind2)+rectangle(2)-30 0],'String',['(' num2str(round(x_plot(ind2)+rectangle(1),1)) ',' num2str(round(y_plot(ind2)+rectangle(2),1)) ')'])
        set(tstr,'String',['Frame: ' num2str(mm)]);
        set(plc,'XData',circMat(count,1),'YData',circMat(count,2));
        set(plc_tr,'XData',circMat(1:count,1),'YData',circMat(1:count,2));
        set(plc2,'XData',circMat(count,1)+circMat(count,3)*cos(0:pi/40:2*pi),'YData',circMat(count,2)+circMat(count,3)*sin(0:pi/40:2*pi));


        % Update free surface plot
        set(pl22,'XData',x_plot+rectangle(1),'YData',y_plot+rectangle(2))
        set(pl32,'XData',x_plot(ind1)+rectangle(1),'YData',y_plot(ind1)+rectangle(2))
        set(pl42,'XData',x_plot(ind2)+rectangle(1),'YData',y_plot(ind2)+rectangle(2))
%         set(tx12,'Position',[x_plot(ind1)+rectangle(1)-150 y_plot(ind1)+rectangle(2)-30 0],'String',['(' num2str(round(x_plot(ind1)+rectangle(1),1)) ',' num2str(round(y_plot(ind1)+rectangle(2),1)) ')'])
%         set(tx22,'Position',[x_plot(ind2)+rectangle(1)+10 y_plot(ind2)+rectangle(2)-30 0],'String',['(' num2str(round(x_plot(ind2)+rectangle(1),1)) ',' num2str(round(y_plot(ind2)+rectangle(2),1)) ')'])

        % Update cylinder plot
        set(plx,'XData',frms,'YData',circMat(1:count,1))
        set(ply,'XData',frms,'YData',circMat(1:count,2))
        
        %Update Virtual Wave Probes
        set(plpoint1,'XData', timevector(1:count), 'YData', point1val(1:count))
        set(plpoint2,'XData', timevector(1:count), 'YData', point2val(1:count))
        


    end
    drawnow
    

    if saveGif==1
        if mm == 500
            imwrite(fullFig.CData,giffilename,'gif','LoopCount',Inf,'DelayTime',1/120);
        else
            imwrite(fullFig.CData,giffilename,'gif','WriteMode','append','DelayTime',1/120);
        end
    end

    if saveVideo==1
        currFrame = getframe(fullFig);
        writeVideo(vSaver,currFrame);
    end
    
    count = count+1;
    mm;
end

if saveVideo==1
    close(vSaver)
end

