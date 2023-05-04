%% Script Video Writer UpStream
%% Clearing Images
clear all
close all
clc

makeVid = false; % set to true to save a video

%% Read Files and Set up Variables
mainDir = 'G:\Shared drives\NSF WEC Project\Experiment_Data\March 2023 Experiments(includes data)\Camera Data\Downstream Camera 544';
flder = 'FASTEC-TS5-522_2023-02-07_000000';

% Define the starting and ending numbers
start_num = 0;
end_num = 488;

% Define the number of digits in each string
num_digits = 7;

% Initialize the array to store the strings
file_names = string(zeros(end_num+1, 1));

% Loop over the numbers and generate the file names
for ii = start_num:end_num
    % Convert the number to a string with the desired number of digits
    file_name = sprintf('%0*d.tif', num_digits, ii);

    % Add the file name to the array
    file_names(ii+1) = file_name;
end

for i = 1:1:length(file_names)
    Images(i).Data = imread(file_names(i));
    disp("Reading Images")
end

TimePerFrame = 1/30;
frmRte = 1/TimePerFrame;

%% Basic Edge Detection Testing and Cropping

%Cropping Rectangle
Imsize = [0, 0, 2560, 800] ; 
rectangle = [400,0,2160,800] ;
X_Offset = Imsize(3) - rectangle(3);
Y_Offset = Imsize(4) - rectangle(4);

%Morphology Structuring Element
SE = ones(1,25);

if makeVid
    v = VideoWriter('UpstreamVideo.mp4','MPEG-4');
    v.FrameRate = frmRte;
    open(v)
end

x_plot = linspace(rectangle(1),rectangle(3),1000);

for i = 1:1:length(file_names)
    Data = imread(file_names(i));
    disp(['Reading Image: ' num2str(i)])
    
    
    %When Cropping
    ImSurf(i).Data = im2gray(imcrop(Images(i).Data,rectangle));% Turn to Gray
   
    BW1(i).Data = edge(ImSurf(i).Data,'sobel',[],'horizontal'); % Detect Edges
    BW2(i).Data = imclose(BW1(i).Data,SE); %Closing Long Lines
    BW3(i).Data = medfilt2(BW2(i).Data); %Median Filter for Salt and Pepper Noise
    [y,x] = find(BW3(i).Data); %Extract Points from Curve
    [p,s,mu] = polyfit(x,y,5);
    y_plot = polyval(p,(x_plot-mu(1))/mu(2)); %Grab the Y-Replotted Values
    
    
    
    fig = figure(1); clf
    set(fig,'Position',[81.6667   81.0000  715.3333  524.0000])
    %show Original
    subplot(2,2,1:2)
    imshow(Data)
    title('Up Stream Surface Detection and Characterization')
    hold on
    plot(x_plot+400, y_plot, '-m','Linewidth',2);
    subplot(2,2,3:4)
    hold on
    plot(x, y, '.b','Linewidth',0.25);
    plot(x_plot, y_plot, '-m','Linewidth',1);
    set(gca,'YDir','reverse')
    xlabel('X Position (Pixels)')
    ylabel('Y Position (Pixels)')
    legend('Detected Points', 'Curve Fit')
    axis([0 inf 500 750])
    drawnow
    if makeVid
        frame = getframe(fig);
        writeVideo(v,frame);
    end
end


if makeVid
    close(v);
end
