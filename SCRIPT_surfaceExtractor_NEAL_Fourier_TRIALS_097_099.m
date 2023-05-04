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

%% Saving Data
save_data = 0; % Change to 1 if you want to save the data for a specific Trial


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
rectangle = (1.0e+03)*[0.0045    0.3305    1.8260    0.2050];
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
jj1 = 1;
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
    
    
    % downsample to only include unique x values
    x_new = x;
    y_new = y-mean(y);
%     [x_new,ind_new] = unique(x); % apply "test" scaling of 1m/2000 pixels
%     y_new = y(ind_new);%*1/2000;
%     y_new = y_new - mean(y_new);
    %Fourier Fit
    N = numel(x_new);
    if mod(N,2)==1 % odd number of points
        N = N-1; % delete last data point
    end
    w_spatial = mean(diff(x_new(1:N)));
    f_spatial = 1./w_spatial;
    fou = fft(y_new(1:N)); % fourier weights (complex numbers)
    P2 = abs(fou/N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1); % single sided power spectrum
    frar = f_spatial*(0:(N/2))/N;
    wts = 2*fou(1:N/2+1)/N;
    
    N_components = 20; % take top 10
    [max_P1s,max_inds] = maxk(P1,N_components);
    max_wts = wts(max_inds);
    max_freqs = frar(max_inds);
    pause(0.5)
    
    % Reconstructing the output function from fft
    [freqs_sorted,indSort] = sort(abs(max_freqs));
    freqs_sorted = freqs_sorted(end:-1:1);
    wts_sorted = max_wts(indSort);
    wts_sorted = wts_sorted(end:-1:1);
%     wts_sorted2 = max_wts(fliplr(indSort))
    y_plot = zeros(size(x));
    
    jj2 = 1;
    for n_component = 1:N_components
        amplitude = abs(wts_sorted(n_component));
        amplitude_store(jj2) = amplitude;
        phase_angle = angle(wts_sorted(n_component));
        PA_store(jj2) = phase_angle;
        omega_plot = 2*pi*freqs_sorted(n_component);
        Omega_store(jj2) = omega_plot;
        y_plot = y_plot+amplitude*cos(omega_plot*x+phase_angle);
        jj2 = jj2 + 1;
    end
    y_plot = y_plot+mean(y); % add mean back in after recreation
    
    fittingFouData.Fourier.MaxFreqs(jj1,1).frame = mm;
    fittingFouData.Fourier.MaxFreqs(jj1,1).Time = mm*TimePerFrame;
    fittingFouData.Fourier.MaxFreqs(jj1,:).data = abs(max_freqs); % store max frequencies here
    
    fittingFouData.Fourier.Amplitudes(jj1,1).frame = mm;
    fittingFouData.Fourier.Amplitudes(jj1,1).Time = mm*TimePerFrame;
    fittingFouData.Fourier.Amplitudes(jj1,:).data = amplitude_store; % store amplitudes here
    
    fittingFouData.Fourier.Omegas(jj1,1).frame = mm;
    fittingFouData.Fourier.Omegas(jj1,1).Time = mm*TimePerFrame;
    fittingFouData.Fourier.Omegas(jj1,:).data = Omega_store; % store omegas here
    
    fittingFouData.Fourier.PhaseShift(jj1,1).frame = mm;
    fittingFouData.Fourier.PhaseShift(jj1,1).Time = mm*TimePerFrame;
    fittingFouData.Fourier.PhaseShift(jj1,:).data = PA_store; % store phase shifts here
    
    fittingFouData.raw(jj1).frame = mm;
    fittingFouData.raw(jj1).Time = mm*TimePerFrame;
    fittingFouData.raw(jj1).points = [x,y]; % store raw image processing points. 
   
    fittingFouData.FourierProcessed(jj1).frame = mm;
    fittingFouData.FourierProcessed(jj1).Time = mm*TimePerFrame;
    fittingFouData.FourierProcessed(jj1).points = [x,y_plot]; %store fitted points here.
    
    
    % Maybe talk to CAPT Severson about this.
    fittingFouData.Error(jj1).frame = mm;
    fittingFouData.Error(jj1).Time = mm*TimePerFrame;
    fittingFouData.Error(jj1).NRMSE = mean((y_plot - y).^2)./(max(y)-min(y)); % Calculation of the nrmse
    
    jj1 = jj1+1;

    if mm==startFrame
                 imFig = figure(1);
                 cdf = imshow(BW3);
                 hold on
                 pl = plot(x, y_plot, '-m', 'LineWidth',2);

        fullFig = figure(2); clf
        orig = imshow(frame);
        hold on
        pl2 = plot(x+rectangle(1),y_plot+rectangle(2),'-m','Linewidth',2);
        pl3 = plot(x(ind1)+rectangle(1),y_plot(ind1)+rectangle(2),'ok','MarkerSize',6,'MarkerFaceColor','k');
        tx1 = text(x(ind1)+rectangle(1)-150,y_plot(ind1)+rectangle(2)-30,['(' num2str(x(ind1)+rectangle(1)) ',' num2str(round(y_plot(ind1)+rectangle(2),1)) ')']);
        pl4 = plot(x(ind2)+rectangle(1),y_plot(ind2)+rectangle(2),'ok','MarkerSize',6,'MarkerFaceColor','k');
        tx2 = text(x(ind2)+rectangle(1)+10,y_plot(ind2)+rectangle(2)-30,['(' num2str(x(ind2)+rectangle(1)) ',' num2str(round(y_plot(ind2)+rectangle(2),1)) ')']);
        hold off
        
        Freq_Plot = figure(3);
        F_P_Spec = loglog(frar,P1,'-k');
        hold on
        F_P_MAX = loglog(max_freqs,abs(max_wts),'*');
    else
        % update figure 1 (just the image processing
         set(cdf,'CData',BW3);
         set(pl,'XData',x,'YData',y_plot);

        % udpate figure 2 ( the complete image with image processing result
        % overlaid
        set(orig,'CData',frame);
        set(pl2,'XData',x+rectangle(1),'YData',y_plot+rectangle(2))
        set(pl3,'XData',x(ind1)+rectangle(1),'YData',y_plot(ind1)+rectangle(2))
        set(pl4,'XData',x(ind2)+rectangle(1),'YData',y_plot(ind2)+rectangle(2))
        set(tx1,'Position',[x(ind1)+rectangle(1)-150 y_plot(ind1)+rectangle(2)-30 0],'String',['(' num2str(round(x(ind1)+rectangle(1),1)) ',' num2str(round(y_plot(ind1)+rectangle(2),1)) ')'])
        set(tx2,'Position',[x(ind2)+rectangle(1)+10 y_plot(ind2)+rectangle(2)-30 0],'String',['(' num2str(round(x(ind2)+rectangle(1),1)) ',' num2str(round(y_plot(ind2)+rectangle(2),1)) ')'])
        % update figure 3
        set(F_P_Spec,'XData',frar,'YData',P1)
        set(F_P_MAX,'XData',max_freqs,'YData',abs(max_wts))
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
        save([filename(1:end-4) '.mat'], 'fittingFouData') %Save the specified data to a variable.
end

if saveVideo==1
    close(vSaver)
end

