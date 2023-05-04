%% Testing

SE = ones(1,7);
%%
BW2 = imclose(BW1,SE);
figure(5);imshow(BW2)

%%

BW3 = bwareaopen(BW2,200);
imshow(BW3)

