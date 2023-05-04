%% Middle Camera Left Half Analysis

%% Script that Analyzes each of the 380 Foot Images

%% Clearing Images
clear all
close all
clc

%% Read Files and Set up Variables
mainDir = 'G:\Shared drives\NSF WEC Project\Experiment_Data\March 2023 Experiments(includes data)\Camera Data\Middle Camera Run Camera 544';
flder = 'FASTEC-TS5-522_2023-02-07_000000';
load('MIDCameraParams.mat')
fileNames = ["0000000.tif" "0000018.tif" "0000036.tif" "0000054.tif" "0000072.tif" "0000090.tif"...
            "0000108.tif" "0000126.tif" "0000144.tif" "0000162.tif" "0000180.tif" "0000198.tif" ...
            "0000216.tif" "0000234.tif" "0000252.tif" "0000270.tif" "0000288.tif" "0000306.tif" ...
            "0000324.tif" "0000342.tif" "0000360.tif" "0000378.tif" "0000396.tif" "0000414.tif" ...
            "0000432.tif" "0000450.tif" "0000468.tif" "0000486.tif"];

for i = 1:1:length(fileNames)
    Images(i).Data = imread(fileNames(i));
end

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


for i = 1:1:length(fileNames)
    %When Cropping Left of Cylinder
    ImSurf_Left(i).Data = im2gray(imcrop(Images(i).Data,rectangle_left));% Turn to Gray
    %When Cropping Right of Cylinder
    ImSurf_Right(i).Data = im2gray(imcrop(Images(i).Data,rectangle_right));% Turn to Gray
    
    
    %No Cropping for April Tags
    ImSurf(i).Data = im2gray(Images(i).Data);% Turn to Gray
    
  
    %Left of Cylinder
    BW1(i).Data = edge(ImSurf_Left(i).Data,'sobel',[],'horizontal'); % Detect Edges
    BW2(i).Data = imclose(BW1(i).Data,SE); %Closing Long Lines
    BW3(i).Data = medfilt2(BW2(i).Data); %Median Filter for Salt and Pepper Noise
    
    %Right of Cylinder
    BW4(i).Data = edge(ImSurf_Right(i).Data,'sobel',[],'horizontal'); % Detect Edges
    BW5(i).Data = imclose(BW4(i).Data,SE); %Closing Long Lines
    BW6(i).Data = medfilt2(BW5(i).Data); %Median Filter for Salt and Pepper Noise

    %Left of Cylinder
    [y_left,x_left] = find(BW3(i).Data); %Extract Points from Curve
    [p_left,s_left,mu_left] = polyfit(x_left,y_left,5);
    y_plot_left = polyval(p_left,(x_plot_left-mu_left(1))/mu_left(2));
    
    %Right of Cylinder
    [y_right,x_right] = find(BW6(i).Data); %Extract Points from Curve
    [p_right,s_right,mu_right] = polyfit(x_right,y_right,5);
    y_plot_right = polyval(p_right,(x_plot_right-x_plot_right(1)-mu_right(1))/mu_right(2));
    
    
    [id,loc] = readAprilTag(ImSurf(i).Data, 'tag36h11');
    if isempty(loc) ~= 1
        X_Center = mean(loc(:,1));
        Y_Center = mean(loc(:,2));
        for idx = 1:length(id)
            % Insert markers to indicate the locations
            markerRadius = 8;
            numCorners = size(loc,1);
            markerPosition = [loc(:,:,idx),repmat(markerRadius,numCorners,1)];
            I = insertShape(Images(i).Data,"FilledCircle",markerPosition,Color="red",Opacity=1);
            I = insertShape(I,"FilledCircle",[x_plot_left(400), y_plot_left(400),20],Color="yellow",Opacity=1);
            I = insertShape(I,"FilledCircle",[x_plot_right(50), y_plot_right(50),20],Color="yellow",Opacity=1);
        end
    end
    
    fig = figure(i);
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
    subplot(2,2,4)
    hold on
    plot(x_right+1800, y_right, '.r','Linewidth',0.25);
    plot(x_plot_right, y_plot_right, '-g','Linewidth',1);
    set(gca,'YDir','reverse')
    xlabel('X Position (Pixels)')
    ylabel('Y Position (Pixels)')
    legend('Detected Points', 'Curve Fit')
    pause
end


