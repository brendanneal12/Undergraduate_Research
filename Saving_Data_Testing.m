%% 
j = 1;
M = [];
for i = 1:size(fittingData.polynomial.Coeffs,1)
    if fittingData.polynomial.Coeffs(i,6) ~= 0
        M(j,:) = [i fittingData.polynomial.Coeffs(i,:)];
        j = j+1;
    end
end

%% 
j = 1;
M = [];
for i = 1:size(fittingData.raw,2)
    if length(fittingData.raw(1,i).points) > 0
        M(j).points = fittingData.raw(1,i).points;
        M(j).frame = i;
        j = j+1;
    end
end

    
    
    