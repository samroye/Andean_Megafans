%% RIVER INCISION AND BIODIVERSITY
% Load Table
Megafan_Stats = readtable('Megafan_Statistics.xlsx');

% Extract biodiversity and river incision
meanBiodiversity = Megafan_Stats.TR;
meanRiverIncision = Megafan_Stats.Avg_River_Incision_Depth;

figure;
scatter(meanRiverIncision, meanBiodiversity, 50,[0.5, 0, 0], 'filled'); 
hold on;

% Labels
xlabel('Mean River Incision Depth (m)');
ylabel('Mean Topographic Roughness (m)');
title('Mean River Incision vs. Mean Topographic Roughness');

for k = 1:length(meanBiodiversity)
    megafanName = Megafan_Stats.Name{k}; 
    text(meanRiverIncision(k), meanBiodiversity(k), megafanName, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 8);
end

p = polyfit(meanRiverIncision, meanBiodiversity, 1); 
yfit = polyval(p, meanRiverIncision); 

% Trend line
plot(meanRiverIncision, yfit, '-black', 'LineWidth', 2); 

grid on;

%% (Non-)Megafan Biodiversity T test
biodiversityRaster = res_biodiv; 
megafanShape = megafans;  

% Mask Megafans
megafanMask = zeros(size(biodiversityRaster.Z)); 

for k = 1:length(megafanShape)
    X = megafanShape(k).X;
    Y = megafanShape(k).Y;
    
    validIdx = ~isnan(X) & ~isnan(Y);
    X = X(validIdx);
    Y = Y(validIdx);
    
    [row, col] = coord2sub(biodiversityRaster, X, Y);
    polyMask = poly2mask(col, row, size(megafanMask, 1), size(megafanMask, 2));
    
    megafanMask = megafanMask | polyMask;
end

biodiversityValues = biodiversityRaster.Z; 

megafanValues = biodiversityValues(megafanMask); % Biodiversity on megafans
nonMegafanValues = biodiversityValues(~megafanMask); % Biodiversity outside megafans
megafanValues = megafanValues(~isnan(megafanValues));
nonMegafanValues = nonMegafanValues(~isnan(nonMegafanValues));

% Mean Residual Biodiversity
meanMegafanBiodiv = mean(megafanValues);
meanNonMegafanBiodiv = mean(nonMegafanValues);

% T test
[h, p] = ttest2(megafanValues, nonMegafanValues);

disp('Statistical Test Results:');
disp(['Mean Biodiversity in Megafan Areas: ' num2str(meanMegafanBiodiv)]);
disp(['Mean Biodiversity in Non-Megafan Areas: ' num2str(meanNonMegafanBiodiv)]);

if h == 1
    disp(['Significant difference detected (p = ' num2str(p) ').']);
else
    disp(['No significant difference detected (p = ' num2str(p) ').']);
end
%% Bar Chart
figure;
b = bar([1, 2], [meanMegafanBiodiv, meanNonMegafanBiodiv], 0.6);
b.FaceColor = 'flat';
b.EdgeColor = 'k';
b.CData(1, :) = [0.1 0.1 0.1]; 
b.CData(2, :) = [0.7 0.7 0.7]; 

hold on;
errorbar([1, 2], [meanMegafanBiodiv, meanNonMegafanBiodiv], ...
    [std(megafanValues), std(nonMegafanValues)], 'k.', 'LineWidth', 1.5);

set(gca, 'XTick', [1 2], 'XTickLabel', {'Megafan', 'Non-Megafan'}, 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Mean Residual Biodiversity', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Region', 'FontSize', 14, 'FontWeight', 'bold');
title('Mean Residual Biodiversity', 'FontSize', 16);

set(gcf, 'Color', 'w');

%% Barchart River Incision
megafanNames = Megafan_Stats.Name; 
avgPrec = Megafan_Stats.Avg_River_Incision_Depth; 
megafanID = Megafan_Stats.Megafan_ID; 
periods = Megafan_Stats.Region; 

[sortedIDs, sortIdx] = sort(megafanID, 'descend'); 
sortedNames = megafanNames(sortIdx); 
sortedPrec = avgPrec(sortIdx); 
sortedPeriods = periods(sortIdx); 
sortedLabels = strcat(string(sortedIDs), ": ", sortedNames); 

uniquePeriods = unique(sortedPeriods); 

colours = [
    0.8, 0.6, 1;    % Light Purple
    0.6, 0.3, 0.8;  % Medium Purple
    0.4, 0.1, 0.6   % Dark Purple
];

figure;
hold on;

for i = 1:length(uniquePeriods)
    regionIdx = strcmp(sortedPeriods, uniquePeriods{i});
    
    barh(find(regionIdx), sortedPrec(regionIdx), 'FaceColor', colours(i, :), ...
        'EdgeColor', 'k', 'LineWidth', 1.5, 'BarWidth', 1);
end

set(gca, 'YTick', 1:length(sortedLabels), 'YTickLabel', sortedLabels, 'FontSize', 10, 'FontWeight', 'normal', ...
    'FontName', 'Times New Roman', 'LineWidth', 1);
xlabel('Average River Incision (m3/m2)', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('Megafan Name', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Average River Incision Across Megafans', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;

legend(uniquePeriods, 'FontSize', 12, 'Location', 'best', 'Box', 'on', 'FontName', 'Times New Roman');

ax = gca;
ax.YLim = [0, length(sortedLabels) + 1]; 

set(gca, 'Box', 'on', 'GridLineStyle', '--', 'MinorGridLineStyle', ':');
xtickformat('%.2f'); 
ax.YTickLabelRotation = 0;

hold off;

% Save the Figure (Optional)
%saveas(gcf, 'Average_River_Incision_Barchart.png');

%% Barchart Biodiversity
megafanNames = Megafan_Stats.Name; 
avgPrec = Megafan_Stats.Mean_Residual_Biodiversity; 
megafanID = Megafan_Stats.Megafan_ID; 
periods = Megafan_Stats.Region; 

[sortedIDs, sortIdx] = sort(megafanID, 'descend'); 
sortedNames = megafanNames(sortIdx); 
sortedPrec = avgPrec(sortIdx); 
sortedPeriods = periods(sortIdx); 
sortedLabels = strcat(string(sortedIDs), ": ", sortedNames); 

uniquePeriods = unique(sortedPeriods); 

greenShades = [
    0.6, 1, 0.6;    % Light Green
    0.3, 0.8, 0.3;  % Medium Green
    0.1, 0.5, 0.1   % Dark Green
];

figure;
hold on;

for i = 1:length(uniquePeriods)
    regionIdx = strcmp(sortedPeriods, uniquePeriods{i});
    
    barh(find(regionIdx), sortedPrec(regionIdx), 'FaceColor', greenShades(i, :), ...
        'EdgeColor', 'k', 'LineWidth', 1.5, 'BarWidth', 1);
end

set(gca, 'YTick', 1:length(sortedLabels), 'YTickLabel', sortedLabels, 'FontSize', 10, 'FontWeight', 'normal', ...
    'FontName', 'Times New Roman', 'LineWidth', 1);
xlabel('Mean Residual Biodiversity', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('Megafan Name', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Mean Residual Biodiversity Across Megafans', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;

legend(uniquePeriods, 'FontSize', 12, 'Location', 'best', 'Box', 'on', 'FontName', 'Times New Roman');

ax = gca;
ax.YLim = [0, length(sortedLabels) + 1]; 

set(gca, 'Box', 'on', 'GridLineStyle', '--', 'MinorGridLineStyle', ':');
xtickformat('%.2f'); 
ax.YTickLabelRotation = 0;

hold off;

% Save the Figure (Optional)
%saveas(gcf, 'Biodiversity_Barchart.png');

%% Barchart Precipitation
% Extract relevant data
megafanNames = Megafan_Stats.Name;
avgPrec = Megafan_Stats.Mean_Ann_Precipitation;
megafanID = Megafan_Stats.Megafan_ID;

% Sort data by Megafan ID (descending)
[sortedIDs, sortIdx] = sort(megafanID, 'descend');
sortedNames = megafanNames(sortIdx);
sortedPrec = avgPrec(sortIdx);
sortedLabels = strcat(string(sortedIDs), ": ", sortedNames);

% Create figure
figure;
plot(sortedPrec, 1:length(sortedLabels), '-o', 'Color', [0, 0.4, 0.8], 'LineWidth', 2, 'MarkerFaceColor', [0, 0.6, 1]);

% Formatting
set(gca, 'YTick', 1:length(sortedLabels), 'YTickLabel', sortedLabels, ...
    'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Times New Roman', 'LineWidth', 1);
xlabel('Mean Annual Precipitation', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('Megafan Name', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Mean Annual Precipitation Across Megafans', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;

% Adjust axis limits and formatting
ax = gca;
ax.YLim = [0, length(sortedLabels) + 1];
ax.XGrid = 'on';
ax.YGrid = 'on';
xtickformat('%.2f');


%% PLOT
% Create a 1x3 grid of subplots for horizontal adjacency
figure;
chartColors = [
    0.5, 0.0, 0.5; % Hard Purple (River Incision)
    0.0, 0.5, 0.0; % Hard Green (Biodiversity)
    0.0, 0.0, 0.8; % Hard Blue (Precipitation)
];

% Adjust layout spacing
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% 1. River Incision Plot
nexttile;
megafanNames = Megafan_Stats.Name; 
avgIncision = Megafan_Stats.Avg_River_Incision_Depth; 
megafanID = Megafan_Stats.Megafan_ID; 

[sortedIDs, sortIdx] = sort(megafanID, 'descend'); 
sortedNames = megafanNames(sortIdx); 
sortedIncision = avgIncision(sortIdx); 
sortedLabels = strcat(string(sortedIDs), ": ", sortedNames); 

barh(sortedIncision, 'FaceColor', chartColors(1, :), 'EdgeColor', 'k', 'LineWidth', 1.5, 'BarWidth', 1);
set(gca, 'YTick', 1:length(sortedLabels), 'YTickLabel', sortedLabels, ...
    'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Times New Roman');
xlabel('Average River Incision (m)', 'FontSize', 11, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('Megafan Name', 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Average River Incision Across Megafans', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;

% 2. Biodiversity Plot
nexttile;
avgBiodiversity = Megafan_Stats.Mean_Residual_Biodiversity;

sortedBiodiversity = avgBiodiversity(sortIdx); 

barh(sortedBiodiversity, 'FaceColor', chartColors(2, :), 'EdgeColor', 'k', 'LineWidth', 1.5, 'BarWidth', 1);
set(gca, 'YTick', [], 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Times New Roman');
xlabel('Mean Residual Biodiversity', 'FontSize', 11, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Mean Residual Biodiversity Across Megafans', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;

% 3. Precipitation Plot
nexttile;
avgPrecipitation = Megafan_Stats.Mean_Ann_Precipitation;

sortedPrecipitation = avgPrecipitation(sortIdx); 

barh(sortedPrecipitation, 'FaceColor', chartColors(3, :), 'EdgeColor', 'k', 'LineWidth', 1.5, 'BarWidth', 1);
set(gca, 'YTick', [], 'FontSize', 10, 'FontWeight', 'normal', 'FontName', 'Times New Roman');
xlabel('Mean Annual Precipitation (kg m-2 month-1)', 'FontSize', 11, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('Mean Annual Precipitation Across Megafans', 'FontSize', 16, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;

% Ensure consistent grid styling across all charts
set(findall(gcf, 'Type', 'Axes'), 'GridLineStyle', '-', 'MinorGridLineStyle', ':');

%% BoxPlots Region
% Load Data
Megafan_Stats = readtable('Megafan_Statistics.xlsx');

% Convert Region to categorical & reorder
Megafan_Stats.Region = categorical(Megafan_Stats.Region);
regionOrder = ["Orinoco Basin", "Amazon Basin", "Chaco-Plains"];
Megafan_Stats.Region = reordercats(Megafan_Stats.Region, regionOrder);

% Normalize (Z-scores)
biodiversity_Z = (Megafan_Stats.Mean_Residual_Biodiversity - mean(Megafan_Stats.Mean_Residual_Biodiversity)) ./ std(Megafan_Stats.Mean_Residual_Biodiversity);
incision_Z = (Megafan_Stats.Avg_River_Incision_Depth - mean(Megafan_Stats.Avg_River_Incision_Depth)) ./ std(Megafan_Stats.Avg_River_Incision_Depth);
precipitation_Z = (Megafan_Stats.Mean_Ann_Precipitation - mean(Megafan_Stats.Mean_Ann_Precipitation)) ./ std(Megafan_Stats.Mean_Ann_Precipitation);
roughness_Z = (Megafan_Stats.TR - mean(Megafan_Stats.TR)) ./ std(Megafan_Stats.TR);

% Assign numeric x-positions for spacing
regionNumeric = double(Megafan_Stats.Region);
biodiversity_X = regionNumeric - 0.2; % Shift left
incision_X = regionNumeric - 0.07; % Small left shift
precipitation_X = regionNumeric + 0.07; % Small right shift
roughness_X = regionNumeric + 0.2; % Shift right

% Custom colors
colorMap = containers.Map(["Biodiversity", "River Incision", "Precipitation", "Topographic Roughness"], ...
    {[0.20, 0.60, 0.30], [0.85, 0.33, 0.10], [0.00, 0.45, 0.74], [0.64, 0.08, 0.18]});

% Create figure
figure;
hold on;

% Plot with reduced width (BoxWidth = 0.15)
boxchart(biodiversity_X, biodiversity_Z, 'BoxFaceColor', colorMap("Biodiversity"), 'BoxWidth', 0.1);
boxchart(incision_X, incision_Z, 'BoxFaceColor', colorMap("River Incision"), 'BoxWidth', 0.1);
boxchart(precipitation_X, precipitation_Z, 'BoxFaceColor', colorMap("Precipitation"), 'BoxWidth', 0.1);
boxchart(roughness_X, roughness_Z, 'BoxFaceColor', colorMap("Topographic Roughness"), 'BoxWidth', 0.1);

% Improve Labels
xticks(1:length(regionOrder));
xticklabels(regionOrder);
xlabel('Region', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Z-score (Standardized)', 'FontSize', 14, 'FontWeight', 'bold');

% Enhance Aesthetics
set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'FontWeight', 'bold', 'Box', 'off'); 
grid on;  

% Add Legend
legend(["Mean Residual Biodiversity", "Mean River Incision Depth", "Mean Annual Precipitation", "Topographic Roughness"], ...
    'Location', 'northeastoutside', 'FontSize', 12, 'FontWeight', 'bold');

hold off;

%% Boxplots Period
% Load Data
Megafan_Stats = readtable('Megafan_Statistics.xlsx');

% Convert Period to categorical & reorder in custom order
Megafan_Stats.Period = categorical(Megafan_Stats.Period);
customOrder = ["Paleogene - Neogene", "Neogene", "Neogene - Quaternary", "Quaternary"]; % Modify as needed
Megafan_Stats.Period = reordercats(Megafan_Stats.Period, customOrder);

% Use raw River Incision Depth data (no Z-scores)
incision = Megafan_Stats.Avg_River_Incision_Depth;

% Convert Periods to numeric positions
periodNumeric = double(Megafan_Stats.Period);

% Custom color for River Incision
riverIncisionColor = [0.85, 0.33, 0.10]; % Dark Orange

% Create figure
figure;
hold on;

% Plot boxchart with reduced width (using raw data, no Z-scores)
boxchart(periodNumeric, incision, 'BoxFaceColor', riverIncisionColor, 'BoxWidth', 0.25);

% Improve Labels
xticks(1:length(customOrder));
xticklabels(customOrder);
xlabel('Period', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Mean River Incision Depth (m)', 'FontSize', 14, 'FontWeight', 'bold');

% Enhance Aesthetics
set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'FontWeight', 'bold', 'Box', 'off'); 
grid on;  

hold off;


