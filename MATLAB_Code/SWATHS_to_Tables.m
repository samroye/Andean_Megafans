% Store Tables in array
numSwaths = length(swathArray);
LM_Tables = cell(1, numSwaths);

figure;
hold on;

% Loop through swathArray
for i = 1:numSwaths
    currentSwath = swathArray{i};
    
    aggTable = SWATHobj2table(currentSwath, @mean, {'MeanElevation'});
    distance = aggTable.distx;
    meanElevation = aggTable.MeanElevation;

    % Polynomial fitting 
    polyDegree = 20; % Degree of fitting
    coefficients = polyfit(distance, meanElevation, polyDegree);

    fittedElevation = polyval(coefficients, distance);

    % Find LM
    localMinimaIdx = islocalmin(fittedElevation, 'MinSeparation', 500);
    localMinimaDistance = distance(localMinimaIdx);
    localMinimaElevation = fittedElevation(localMinimaIdx);

    % Table for LM
    localMinimaCoordinates = [localMinimaDistance, localMinimaElevation];
    localMinimaTable = array2table(localMinimaCoordinates, 'VariableNames', {'Distance', 'Mean_Elevation'});
    LM_Tables{i} = localMinimaTable; 

    subplot(3, 6, i);

    % Plot mean elevation SWATH
    plot(distance, meanElevation, 'k', 'LineWidth', 1.5, 'DisplayName', ['Original Mean Elevation (Swath ' num2str(i) ')']);

    % Plot smoothed SWATH
    plot(distance, fittedElevation, 'b', 'LineWidth', 1.5, 'DisplayName', ['Smoothed Elevation (Swath ' num2str(i) ')']);

    % Plot LM
    plot(localMinimaDistance, localMinimaElevation, 'ro', 'MarkerFaceColor', 'r', 'DisplayName', ['Local Minima (Swath ' num2str(i) ')']);
end

xlabel('Distance (m)');
ylabel('Elevation (m)');
title('Elevation Profiles with Local Minima for All Swaths');
grid on;
legend('show');
hold off;

%% Extract LM coordinates from SWATH
LM_TOTAL = table([], [], [], [], 'VariableNames', {'LocalMinimaDistance', 'X', 'Y', 'SwathNumber'});

for i = 1:length(swathArray)
    currentSwath = swathArray{i};
    
    X_co = currentSwath.X';
    Y_co = currentSwath.Y';
    X_coords = X_co(:, 7);
    Y_coords = Y_co(:, 7);
    
    %Transform SWATHs to table 
    aggTable = SWATHobj2table(currentSwath, @mean, {'MeanElevation'});
    originalDistances = aggTable.distx;
    
    localMinimaDistance = LM_Tables{i}.Distance;
    
    minimaX = [];
    minimaY = [];
    minimaDist = [];
    
    % Find LM coordinates
    for j = 1:length(localMinimaDistance)
        [~, idx] = min(abs(originalDistances - localMinimaDistance(j)));
        minimaX(j) = X_coords(idx);
        minimaY(j) = Y_coords(idx);
        minimaDist(j) = originalDistances(idx);
    end
    
    minimaTable = table(minimaDist', minimaX', minimaY', repmat(i, length(minimaDist), 1), ...
                        'VariableNames', {'LocalMinimaDistance', 'X', 'Y', 'SwathNumber'});
    
    LM_TOTAL = [LM_TOTAL; minimaTable];
end

%% Plot to check result

figure;
imagesc(DEM_SA); 
colormap('landcolor');
colorbar;
title('DEM with Swath Profiles and Local Minima Points');
hold on

% Plot all SWATHs
for i = 1:length(swathArray)
    plot(swathArray{i}); 
end

% Plot LM points
plot(LM_TOTAL.X, LM_TOTAL.Y, 'b.', 'MarkerSize', 6, 'DisplayName', 'Local Minima Points');


xlabel('X Coordinate');
ylabel('Y Coordinate');
legend('Local Minima', 'Location', 'best');
hold off;

%% Export LM table

writetable(LM_TOTAL, 'LocalMinimaCoords.xlsx');

%% Snap LM points to stream and plot
% Extract coordinates from the LM_TOTAL table
lmX = LM_TOTAL.X; % X coordinates of the points
lmY = LM_TOTAL.Y; % Y coordinates of the points

% Snap the points to the nearest stream in S_SA
[snappedX, snappedY, snappedIX] = snap2stream(S_SA, lmX, lmY);

Sorder = modify(S_SA, 'streamorder', '>3')

% Plot the DEM
figure;
imagesc(DEM_SA);
hold on;
colormap('landcolor');
colorbar;

% Plot the entire stream network in light gray for context
plot(Sorder, 'Color', [0.7, 0.7, 0.7]);

% Plot the snapped points
plot(snappedX, snappedY, 'ro', 'MarkerSize', 6, 'LineWidth', 1.5, 'DisplayName', 'Snapped Points');

title('Streams with Snapped Points');
xlabel('X Coordinate');
ylabel('Y Coordinate');
legend('show');
hold off;







