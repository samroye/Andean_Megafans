% Precipitation_Stats.m
LGM = GRIDobj('LGM_Precipitation.tif');
precip = GRIDobj('Ann_Precipitation_2.tif');

Megafan_Stats.Mean_Ann_Precipitation = zeros(numPolygons, 1);
Megafan_Stats.Mean_LGM_Precipitation = zeros(numPolygons, 1);

for k = 1:numPolygons
    X = megafans(k).X;
    Y = megafans(k).Y;
    
    validIdx = ~isnan(X) & ~isnan(Y);
    X = X(validIdx);
    Y = Y(validIdx);
    
    if isempty(X) || isempty(Y)
        continue;
    end
    
    [row, col] = coord2sub(precip, X, Y);
    polyMask = poly2mask(col, row, precip.size(1), precip.size(2));
    
    precValues = precip.Z(polyMask);
    Megafan_Stats.Mean_Ann_Precipitation(k) = mean(precValues, 'omitnan');
    
    [row, col] = coord2sub(LGM, X, Y);
    polyMask = poly2mask(col, row, LGM.size(1), LGM.size(2));
    lgmValues = LGM.Z(polyMask);
    Megafan_Stats.Mean_LGM_Precipitation(k) = mean(lgmValues, 'omitnan');
end
