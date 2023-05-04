%% Script that Analyzes each of the 380 Foot Images

%% Clearing Images
clear all
close all
clc

%% Read Files and Set up Variables
mainDir = 'G:\Shared drives\NSF WEC Project\Experiment_Data\March 2023 Experiments(includes data)\Camera Data\Middle Camera Run Camera 544';
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
rectangle = [0, 200, 2560, 800] ;
SE = ones(1,25);


for i = 1:1:length(fileNames)
    %When Cropping
    ImSurf(i).Data = im2gray(imcrop(Images(i).Data,rectangle));% Turn to Gray
    
    %When not Cropping
    %ImSurf(i).Data = im2gray(Images(i).Data);% Turn to Gray
    
    BW1(i).Data = edge(ImSurf(i).Data,'sobel',[],'horizontal'); % Detect Edges
    BW2(i).Data = imclose(BW1(i).Data,SE); %Closing Long Lines
    BW3(i).Data = medfilt2(BW2(i).Data); %Median Filter for Salt and Pepper Noise
    [y,x] = find(BW3(i).Data); %Extract Points from Curve
    [p,s,mu] = polyfit(x,y,5);
    y_plot = polyval(p,(x-mu(1))/mu(2));
    figure(i)
    %show BW
    imshow(BW3(i).Data)
    
    %show Original
    %imshow(Images(i).Data)
    hold on
    plot(x, y_plot, '-m','Linewidth',2);
end


