%% RIVER INCISION AND BIODIVERSITY
% Load Table
Zones_Stats = readtable('Zones_Stats.xls');

% Create a 1x3 grid of subplots for horizontal adjacency
figure;
chartColors = [
    0.2, 0.6, 0.8; % Blue (Precipitation)
    0.8, 0.4, 0.2; % Orange (River Incision)
    0.2, 0.7, 0.3; % Green (Biodiversity)
];

% Adjust layout spacing
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% Extract Zone names and numerical data
zoneNames = Zones_Stats.Zone; % Assuming Zone contains categorical labels A-V
avgIncision = Zones_Stats.Mean_River_Inc;
avgBiodiversity = Zones_Stats.Mean_Biodiv;
avgPrecipitation = Zones_Stats.Mean_Prec;

% Convert zoneNames to categorical to handle sorting
zoneNames = categorical(zoneNames);
% Sort data by Zone (A to V) and then reverse order (V at bottom, A at top)
[sortedZones, sortIdx] = sort(zoneNames, 'descend'); 
sortedIncision = avgIncision(sortIdx); 
sortedBiodiversity = avgBiodiversity(sortIdx); 
sortedPrecipitation = avgPrecipitation(sortIdx); 

% 1. Precipitation Plot (First)
nexttile;
barh(sortedPrecipitation, 'FaceColor', chartColors(1, :), 'EdgeColor', 'k', 'LineWidth', 1.5, 'BarWidth', 1);
set(gca, 'YTick', 1:length(sortedZones), 'YTickLabel', sortedZones, ...
    'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Tahoma');
xlabel('Mean Annual Precipitation (kg m^{-2} month^{-1})', 'FontSize', 11, 'FontWeight', 'bold', 'FontName', 'Tahoma');
ylabel('Zone', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Tahoma');
title('Mean Annual Precipitation Across Zones', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Tahoma');
grid on;
ax1 = gca; % Store axis handle
ax1.XGrid = 'on'; ax1.YGrid = 'on'; 
ax1.XMinorGrid = 'on'; ax1.YMinorGrid = 'on'; 

% 2. River Incision Plot (Second)
nexttile;
barh(sortedIncision, 'FaceColor', chartColors(2, :), 'EdgeColor', 'k', 'LineWidth', 1.5, 'BarWidth', 1);
set(gca, 'YTick', 1:length(sortedZones), 'YTickLabel', [], ... % Keep Y-ticks, but hide labels
    'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Tahoma');
xlabel('Average River Incision (m)', 'FontSize', 11, 'FontWeight', 'bold', 'FontName', 'Tahoma');
title('Average River Incision Across Zones', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Tahoma');
grid on;
ax2 = gca;
ax2.XGrid = 'on'; ax2.YGrid = 'on'; % Ensure both grids are enabled
ax2.XMinorGrid = 'on'; ax2.YMinorGrid = 'on'; 

% 3. Biodiversity Plot (Third)
nexttile;
barh(sortedBiodiversity, 'FaceColor', chartColors(3, :), 'EdgeColor', 'k', 'LineWidth', 1.5, 'BarWidth', 1);
set(gca, 'YTick', 1:length(sortedZones), 'YTickLabel', [], ... % Keep Y-ticks, but hide labels
    'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Tahoma');
xlabel('Mean Residual Biodiversity', 'FontSize', 11, 'FontWeight', 'bold', 'FontName', 'Tahoma');
title('Mean Residual Biodiversity Across Zones', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Tahoma');
grid on;
ax3 = gca;
ax3.XGrid = 'on'; ax3.YGrid = 'on'; % Ensure both grids are enabled
ax3.XMinorGrid = 'on'; ax3.YMinorGrid = 'on'; 
 

