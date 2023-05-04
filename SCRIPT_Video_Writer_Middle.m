%% Script Video Writer
%% Clearing Images
clear all
close all
clc

makeVid = false;

%% Read Files and Set up Variables
mainDir = 'G:\Shared drives\NSF WEC Project\Experiment_Data\March 2023 Experiments(includes data)\Camera Data\Middle Camera Run 544';
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



TimePerFrame = 1/30;
frameRate = 1/TimePerFrame;

%% Basic Edge Detection Testing and Cropping

%Cropping Rectangle Left Side
Imsize = [0, 0, 2560, 800] ; 
rectangle_left = [5,0,950,800] ;
X_Offset_Left = Imsize(3) - rectangle_left(1);
Y_Offset_Left = Imsize(4) - rectangle_left(2);
x_plot_left = linspace(rectangle_left(1),rectangle_left(3),1000);

%Cropping Rectangle Right Side
rectangle_right = [1800,0,2450,800] ;
X_Offset_right = Imsize(3) - rectangle_right(1);
Y_Offset_right = Imsize(4) - rectangle_right(2);
x_plot_right = linspace(rectangle_right(1),rectangle_right(3),1000);

%Morphology Structuring Element
SE = ones(1,25);

if makeVid
    v = VideoWriter('middle_video.mp4','MPEG-4');
    v.FrameRate = frameRate;
    open(v)
end

for i = 1:1:length(file_names)

    Data = imread(file_names(i));
    disp(['Reading Image: ' num2str(i)])

    %When Cropping Left of Cylinder
    ImSurf_Left = im2gray(imcrop(Data,rectangle_left));% Turn to Gray
    %When Cropping Right of Cylinder
    ImSurf_Right = im2gray(imcrop(Data,rectangle_right));% Turn to Gray
    
    
    %No Cropping for April Tags
    ImSurf = im2gray(Data);% Turn to Gray
    
  
    %Left of Cylinder
    BW1 = edge(ImSurf_Left,'sobel',[],'horizontal'); % Detect Edges
    BW2 = imclose(BW1,SE); %Closing Long Lines
    BW3 = medfilt2(BW2); %Median Filter for Salt and Pepper Noise
    
    %Right of Cylinder
    BW4= edge(ImSurf_Right,'sobel',[],'horizontal'); % Detect Edges
    BW5 = imclose(BW4,SE); %Closing Long Lines
    BW6 = medfilt2(BW5); %Median Filter for Salt and Pepper Noise

    %Left of Cylinder
    [y_left,x_left] = find(BW3); %Extract Points from Curve
    [p_left,s_left,mu_left] = polyfit(x_left,y_left,5);
    y_plot_left = polyval(p_left,(x_plot_left-mu_left(1))/mu_left(2));
    
    %Right of Cylinder
    [y_right,x_right] = find(BW6); %Extract Points from Curve
    [p_right,s_right,mu_right] = polyfit(x_right,y_right,5);
    y_plot_right = polyval(p_right,(x_plot_right-x_plot_right(1)-mu_right(1))/mu_right(2));
    
    
    [id,loc] = readAprilTag(Data, 'tag36h11');
    if isempty(loc) ~= 1
        X_Center = mean(loc(:,1));
        Y_Center = mean(loc(:,2));
        for idx = 1:length(id)
            % Insert markers to indicate the locations
            markerRadius = 8;
            numCorners = size(loc,1);
            markerPosition = [loc(:,:,idx),repmat(markerRadius,numCorners,1)];
            I = insertShape(Data,"FilledCircle",markerPosition,Color="red",Opacity=1);
            I = insertShape(I,"FilledCircle",[x_plot_left(400), y_plot_left(400),20],Color="yellow",Opacity=1);
            I = insertShape(I,"FilledCircle",[x_plot_right(50), y_plot_right(50),20],Color="yellow",Opacity=1);
        end
    end
    
    fig = figure(1); clf
    set(fig,'Position',[81.6667   81.0000  715.3333  524.0000])
    %show BW
    subplot(2,2,1:2)
    imshow(I)
    title('Middle Camera Surface Detection and Characterization')
    hold on
    plot(x_plot_left, y_plot_left, '-m','Linewidth',2);
    plot(x_plot_right, y_plot_right, '-g','Linewidth',2);
    rectangle('position',rectangle_right,'EdgeColor',[1 0 0])
    rectangle('position',rectangle_left,'EdgeColor',[1 0 0])
    subplot(2,2,3)
    hold on
    plot(x_left+5, y_left, '.b','Linewidth',0.25);
    plot(x_plot_left, y_plot_left, '-m','Linewidth',1);
    set(gca,'YDir','reverse')
    xlabel('X Position (Pixels)')
    ylabel('Y Position (Pixels)')
    legend('Detected Points', 'Curve Fit')
    axis([0 inf 400 700])
    subplot(2,2,4)
    hold on
    plot(x_right+1800, y_right, '.r','Linewidth',0.25);
    plot(x_plot_right, y_plot_right, '-g','Linewidth',1);
    set(gca,'YDir','reverse')
    xlabel('X Position (Pixels)')
    ylabel('Y Position (Pixels)')
    legend('Detected Points', 'Curve Fit')
    axis([1800 inf 400 700])
    drawnow

    if makeVid
        frame = getframe(fig);
        writeVideo(v,frame)
    end
end

if makeVid
    close(v)
end