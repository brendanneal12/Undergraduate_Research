%% Script that Analyzes each of the all 380 Foot UpStream Camera Images

%% Clearing Images
clear all
close all
clc

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


%% Saving Data

for i = 1:1:length(file_names)
    disp("Formulating Data")
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
     else
         X_Center = NaN;
         Y_Center = NaN;
     end

    
    if save_data==1
        %Left of Cylinder
        MidCamData.polynomial.Left.Coeffs(count,1).frame = i;
        MidCamData.polynomial.Left.Time(count,1).Time = i*TimePerFrame;
        MidCamData.polynomial.Left.Coeffs(count,:).data = p_left; % store polynomial coefficients here
        
        MidCamData.polyProcessed(count).Left.frame = i;
        MidCamData.polyProcessed(count).Left.Time = i*TimePerFrame;
        MidCamData.polyProcessed(count).Left.points = [x_plot_left ; y_plot_left ; ones(1,length(x_plot_left))]; %store fitted points here.
        
        %Right of Cylinder
        MidCamData.polynomial.Right.Coeffs(count,1).frame = i;
        MidCamData.polynomial.Right.Time(count,1).Time = i*TimePerFrame;
        MidCamData.polynomial.Right.Coeffs(count,:).data = p_right; % store polynomial coefficients here
        
        MidCamData.polyProcessed(count).Right.frame = i;
        MidCamData.polyProcessed(count).Right.Time = i*TimePerFrame;
        MidCamData.polyProcessed(count).Right.points = [x_plot_right ; y_plot_right ; ones(1,length(x_plot_right))]; %store fitted points here.
        
        %April Tag Data
        MidCamData.AprilTag(count).frame = i;
        MidCamData.AprilTag(count).time = i*TimePerFrame;
        MidCamData.AprilTag(count).Location = [X_Center, Y_Center];

    end
    
    count = count + 1;

end


if save_data == 1
    save('MidCamData.mat', 'MidCamData') %Save the specified data to a variable.
end

