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
rectangle = [0,300,2560,500] ;
X_Offset = Imsize(3) - rectangle(3);
Y_Offset = Imsize(4) - rectangle(4);

%Morphology Structuring Element
SE = ones(1,50);

x_plot = linspace(rectangle(1),rectangle(3),1000);


for i = 1:1:length(fileNames)
    %When Cropping
    ImSurf(i).Data = im2gray(imcrop(Images(i).Data,rectangle));% Turn to Gray
    
%     BW1(i).Data = edge(ImSurf(i).Data,'sobel',[],'horizontal'); % Detect Edges
%     BW2(i).Data = imclose(BW1(i).Data,SE); %Closing Long Lines
%     BW3(i).Data = medfilt2(BW2(i).Data); %Median Filter for Salt and Pepper Noise

    BW1(i).Data = edge(ImSurf(i).Data,'sobel',[],'horizontal'); % Detect Edges
    BW2(i).Data = medfilt2(BW1(i).Data); %Median Filter for Salt and Pepper Noise
    BW3(i).Data = imclose(BW2(i).Data,SE); %Closing Long Lines

    
    
    
    
    [y,x] = find(BW3(i).Data); %Extract Points from Curve
    [p,s,mu] = polyfit(x,y,5);
    y_plot = polyval(p,(x_plot-mu(1))/mu(2));

    [id,loc] = readAprilTag(ImSurf(i).Data, 'tag36h11');
    for idx = 1:length(id)
        % Insert markers to indicate the locations
        markerRadius = 8;
        numCorners = size(loc,1);
        markerPosition = [loc(:,:,idx),repmat(markerRadius,numCorners,1)];
        I = insertShape(ImSurf(i).Data,"FilledCircle",markerPosition,Color="red",Opacity=1);
    end

    figure(i)
    %show BW
%     imshow(BW3(i).Data)
    %show Original
    
    imshow(ImSurf(i).Data)
    hold on
    plot(x_plot, y_plot + Y_Offset, '-m','Linewidth',2);
end


