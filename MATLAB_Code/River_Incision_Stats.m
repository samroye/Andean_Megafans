% River_Incision_Stats.m
river_incision = GRIDobj('River_Incision.tif');  

Megafan_Stats.Avg_River_Incision_Depth = zeros(numPolygons, 1);
Megafan_Stats.Total_Volume_River_Incision_km3 = zeros(numPolygons, 1);

cellSize = river_incision.cellsize;  
cellArea = cellSize^2;  

for k = 1:numPolygons
    X = megafans(k).X;
    Y = megafans(k).Y;
    
    validIdx = ~isnan(X) & ~isnan(Y);
    X = X(validIdx);
    Y = Y(validIdx);
    
    if isempty(X) || isempty(Y)
        continue;
    end
    
    [row, col] = coord2sub(river_incision, X, Y);
    polyMask = poly2mask(col, row, river_incision.size(1), river_incision.size(2));
    
    riverIncisionValues = river_incision.Z(polyMask);
    
    nonZeroValues = riverIncisionValues(riverIncisionValues > 0);
    
    Megafan_Stats.Avg_River_Incision_Depth(k) = mean(nonZeroValues, 'omitnan');
    
    Megafan_Stats.Total_Volume_River_Incision_km3(k) = (sum(nonZeroValues, 'omitnan') * cellArea) / 1e9;  % Convert to km^3
end

