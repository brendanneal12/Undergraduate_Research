%% Script that Analyzes each of the 380 Foot Images

%% Clearing Images
clear all
close all
clc

%% Read Files and Set up Variables
mainDir = 'G:\Shared drives\NSF WEC Project\Experiment_Data\March 2023 Experiments(includes data)\Camera Data\Upstream Camera Run 544';
flder = 'FASTEC-TS5-522_2023-02-07_000000';

fileNames = ["0000000.tif" "0000018.tif" "0000036.tif" "0000054.tif" "0000072.tif" "0000090.tif"...
            "0000108.tif" "0000126.tif" "0000144.tif" "0000162.tif" "0000180.tif" "0000198.tif" ...
            "0000216.tif" "0000234.tif" "0000252.tif" "0000270.tif" "0000288.tif" "0000306.tif" ...
            "0000324.tif" "0000342.tif" "0000360.tif" "0000378.tif" "0000396.tif" "0000414.tif" ...
            "0000432.tif" "0000450.tif" "0000468.tif" "0000486.tif"];

for i = 1:1:length(fileNames)
    Images(i).Data = imread(fileNames(i));
end

%% Basic Edge Detection Testing and Cropping

%Cropping Rectangle
Imsize = [0, 0, 2560, 800] ; 
rectangle = [400,0,2160,800] ;
X_Offset = Imsize(3) - rectangle(3);
Y_Offset = Imsize(4) - rectangle(4);

%Morphology Structuring Element
SE = ones(1,25);

x_plot = linspace(rectangle(1),rectangle(3),1000);

for i = 1:1:length(fileNames)
    %When Cropping
    ImSurf(i).Data = im2gray(imcrop(Images(i).Data,rectangle));% Turn to Gray
   
    BW1(i).Data = edge(ImSurf(i).Data,'sobel',[],'horizontal'); % Detect Edges
    BW2(i).Data = imclose(BW1(i).Data,SE); %Closing Long Lines
    BW3(i).Data = medfilt2(BW2(i).Data); %Median Filter for Salt and Pepper Noise
    [y,x] = find(BW3(i).Data); %Extract Points from Curve
    [p,s,mu] = polyfit(x,y,5);
    y_plot = polyval(p,(x_plot-mu(1))/mu(2)); %Grab the Y-Replotted Values
    
    
    
    fig = figure(i);
    %show Original
    set(fig,'Position',[81.6667   81.0000  715.3333  524.0000])
    subplot(2,2,1:2)
    imshow(Images(i).Data)
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
    pause
end


