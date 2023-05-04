%% This Script will Convert Pixel Coordinates to World Coordinates

%% Loading Files
load('USCameraParams.mat')
load('UpStreamData.mat')

%% Extracting Intrinsic Parameters
K = DScameraParams.IntrinsicMatrix;
K = transpose(K);
R = DScameraParams.RotationMatrices(:,:,1);
T = transpose(DScameraParams.TranslationVectors(1,:));
KnownDist = 7000;
ProjMatrix = K* [R, T];


%% Performing Conversion

for i = 1:1:489 %Frame
    disp("Analyzing a New Frame")
    for jj = 1:1:1000 %Points
        WorldPoint = pinv(ProjMatrix) * DownStreamData.polyProcessed(i).points(:,jj);
        WorldPoint = WorldPoint(1:3)/WorldPoint(4);
        WorldPoints.polyProcessed(i).frame = i;
        WorldPoints.polyProcessed(i).points(1:3,jj) = WorldPoint;
        disp("Analyzing Points")
     
    end
    
end






    
        
        
        
        
        
        
        
        
