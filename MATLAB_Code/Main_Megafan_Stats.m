%% Main_Megafan_Stats.m
% Load Megafans
megafans = shaperead('Andean_Megafans_3.shp'); 

% Initiate table 
numPolygons = length(megafans);
Megafan_Stats = table;
Megafan_Stats.Name = strings(numPolygons, 1);

for k = 1:numPolygons
    Megafan_Stats.Name(k) = megafans(k).Name;
end
%%
% Add Megafan_ID, Period, and Region
for k = 1:numPolygons
    if isfield(megafans, 'Megafan_ID')
        Megafan_Stats.Megafan_ID(k) = megafans(k).Megafan_ID;  
    else
        Megafan_Stats.Megafan_ID(k) = NaN;  
    end
    
    if isfield(megafans, 'Period')
        Megafan_Stats.Period(k) = string(megafans(k).Period);
    else
        Megafan_Stats.Period(k) = "N/A";
    end
    
    if isfield(megafans, 'Region')
        Megafan_Stats.Region(k) = string(megafans(k).Region);
    else
        Megafan_Stats.Region(k) = "N/A";
    end
end
% Call scripts
Biodiversity_Stats;
DEM_Stats;
River_Incision_Stats;
Precipitation_Stats;

disp('Final Updated Megafan Statistics:');
disp(Megafan_Stats);

%% Export Table 
writetable(Megafan_Stats, 'Megafan_Statistics.xlsx');