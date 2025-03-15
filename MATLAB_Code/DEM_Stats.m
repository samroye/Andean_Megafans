% DEM_Stats.m
DEM = GRIDobj('D:\THESIS\DEM_Megafans_150m.tif');
filled_DEM = GRIDobj('Filled_DEM_Clip.tif');
TR = localtopography(DEM, 1000);
slope = gradient8(filled_DEM, "deg");

Megafan_Stats.Area_km2x1000 = zeros(numPolygons, 1);
Megafan_Stats.TR = zeros(numPolygons, 1);
Megafan_Stats.Slope = zeros(numPolygons, 1);

cellSize = DEM.cellsize;
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
    
    [row, col] = coord2sub(DEM, X, Y);
    polyMask = poly2mask(col, row, DEM.size(1), DEM.size(2));
    
    area_m2 = polyarea(X, Y);
    Megafan_Stats.Area_km2x1000(k) = (area_m2 / 1e6) / 1000;
    
    Megafan_Stats.TR(k) = mean(TR.Z(polyMask), 'omitnan');

    Megafan_Stats.Slope(k) = mean(slope.Z(polyMask), 'omitnan');
end
