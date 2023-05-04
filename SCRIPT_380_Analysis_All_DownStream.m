%% Script that Analyzes each of the all 380 Foot Downstream Camera Images

%% Clearing Images
clear all
close all
clc

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

%% Saving Data
save_data = 1; % Change to 1 if you want to save the data for a specific Trial

%% SaveData Setup
count = 1;
TimePerFrame = 1/30;

%% Image Analysis
%Cropping Rectangle
Imsize = [0, 0, 2560, 800] ; 
rectangle = [0,0,2100,800] ;
X_Offset = Imsize(3) - rectangle(3);
Y_Offset = Imsize(4) - rectangle(4);

x_plot = linspace(rectangle(1),rectangle(3),1000);

%Morphology Structuring Element
SE = ones(1,25);


%% Saving Data

for i = 1:1:length(file_names)
    disp("Formulating Data")
    ImSurf(i).Data = im2gray(imcrop(Images(i).Data,rectangle));% Turn to Gray and Crop
    BW1(i).Data = edge(ImSurf(i).Data,'sobel',[],'horizontal'); % Detect Edges
    BW2(i).Data = imclose(BW1(i).Data,SE); %Closing Long Lines
    BW3(i).Data = medfilt2(BW2(i).Data); %Median Filter for Salt and Pepper Noise
    [y,x] = find(BW3(i).Data); %Extract Points from Curve
    [p,s,mu] = polyfit(x,y,5); %Fit 5th Order Polynomial
    y_plot = polyval(p,(x_plot-mu(1))/mu(2)); %Grab the Y-Replotted Values
    
    if save_data==1
        DownStreamData.polynomial.Coeffs(count,1).frame = i;
        DownStreamData.polynomial.Time(count,1).Time = i*TimePerFrame;
        DownStreamData.polynomial.Coeffs(count,:).data = p; % store polynomial coefficients here
        
        DownStreamData.polyProcessed(count).frame = i;
        DownStreamData.polyProcessed(count).Time = i*TimePerFrame;
        DownStreamData.polyProcessed(count).points = [x_plot ; y_plot ; ones(1,length(x_plot))]; %store fitted points here.
    end
    
    count = count + 1;

end


if save_data == 1
    save('DownStreamData.mat', 'DownStreamData') %Save the specified data to a variable.
end

