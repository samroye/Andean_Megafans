% Biodiversity_Stats.m
res_biodiv = GRIDobj('Residual_Biodiversity.tif');

Megafan_Stats.Mean_Residual_Biodiversity = zeros(numPolygons, 1);
Megafan_Stats.Residual_Biodiversity_Variability = zeros(numPolygons, 1);
Megafan_Stats.Residual_Biodiv_Corrected_x1e9 = zeros(numPolygons, 1);

for k = 1:numPolygons
    X = megafans(k).X;
    Y = megafans(k).Y;
    
    validIdx = ~isnan(X) & ~isnan(Y);
    X = X(validIdx);
    Y = Y(validIdx);
    
    if isempty(X) || isempty(Y)
        continue;
    end
    
    [row, col] = coord2sub(res_biodiv, X, Y);
    polyMask = poly2mask(col, row, res_biodiv.size(1), res_biodiv.size(2));
    biodiversityValues = res_biodiv.Z(polyMask);
    
    Megafan_Stats.Mean_Residual_Biodiversity(k) = mean(biodiversityValues, 'omitnan');
    Megafan_Stats.Residual_Biodiversity_Variability(k) = std(biodiversityValues, 'omitnan');
    area_m2 = polyarea(X, Y);
    Megafan_Stats.Residual_Biodiv_Corrected_x1e9(k) = mean(biodiversityValues, 'omitnan') / area_m2 * 1e9;
end
