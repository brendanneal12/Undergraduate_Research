%% Camera Calibration Testing

%% Setup
load('canonEOS6D_camParams.mat')

%syms Z_C P_F

X = 47;
Y = 22.2357;
Z_C = 1000;

R_C_F = cameraParams.RotationMatrices(:,:,1);

Intrinsics = cameraParams.IntrinsicMatrix;

D_C_F = [cameraParams.TranslationVectors(1);cameraParams.TranslationVectors(2);cameraParams.TranslationVectors(3)];

rectangle = (1.0e+03)*[0.0045    0.3305    1.8260    0.2050];

%E = [rectangle*P_F == 0, P_F == transpose(R_C_F)*(inv(Intrinsics)*[Z_C*X;Z_C*Y;Z_C]-D_C_F)];

%S = solve(E,P_F,Z_C)

%P_F = transpose(R_C_F)*(inv(Intrinsics)*[Z_C*X;Z_C*Y;Z_C]-D_C_F);

pp = 1;

for i = 1:1:length(x)
    PF.raw(pp).Data = transpose(R_C_F)*(inv(Intrinsics)*[Z_C*x(i);Z_C*y_fit_raw(i);Z_C]-D_C_F);
    pp = pp + 1;
end


