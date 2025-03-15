%Load in DEM
DEM = GRIDobj('DEM_SA_Projected.tif');

windowSize = [2 2]; % Define median filter window
DEM_SA = DEM;
DEM_SA.Z = medfilt2(DEM.Z, windowSize);

%% Import all transect points and create SWATHs per Section and LineID
transects = readtable('SWATH_Transect_Pts.xls');

if iscell(transects.Section)
    transects.Section = string(transects.Section);
end

%Subset Data
Tdata = transects;

%Loop through LineID to create SWATHs

lineIDs = 1:10; 
swathArray = cell(1, length(lineIDs)); %Store the SWATH objects

for j = lineIDs
    Tdata_line = Tdata(Tdata.LineID == j, :);
   
    if ~isempty(Tdata_line)
        x = Tdata_line.x;
        y = Tdata_line.y;
        
        swathArray{j} = SWATHobj(DEM, x, y, 'width', 10000);
    end
end

%% PLOT SWATHS
profileNum = 6;  % Choose the swath profile to plot
figure;
plotdz(swathArray{profileNum});  % Plot the profile using plotdz()

% Find all line objects
hLines = findobj(gca, 'Type', 'Line'); 

% Set all lines to light gray first
set(hLines, 'Color', [0.7, 0.7, 0.7]); % RGB for light gray


% Identify and set the mean line to black
hMeanLine = hLines(3); % Typically, the mean profile is the first line
set(hMeanLine, 'Color', 'k', 'LineWidth', 1); % Set mean line to black with thicker width

% Convert x-axis to kilometers
xticks = get(gca, 'XTick'); % Get current x-axis ticks
set(gca, 'XTickLabel', xticks / 1000); % Convert to km

%ylim([0 600]); % Set y-axis limits from 0 to 500

% Enhance plot appearance
grid on;
set(gca, 'FontSize', 14, 'LineWidth', 1.5, 'FontWeight', 'bold'); % Scientific styling
xlabel('Distance along profile (km)'); % Update label to km
ylabel('Elevation (m)');
title(['Swath Profile ', num2str(profileNum)]);


%% Smoothing Window

SW_3 = swathArray{6}; 

aggTable = SWATHobj2table(SW_3, @mean, {'MeanElevation'});

distance = aggTable.distx; 
meanElevation = aggTable.MeanElevation; 

%Smoothing filter
windowSize = 200; 
smoothedElevation = movmean(meanElevation, windowSize);

% Local minima
localMinimaIdx = islocalmin(smoothedElevation, 'MinSeparation', 1000); 

localMinimaDistance = distance(localMinimaIdx); %Extract distance LM
localMinimaElevation = smoothedElevation(localMinimaIdx); %Extract elevation LM

%Table for storing LM points
localMinimaCoordinates = [localMinimaDistance, localMinimaElevation]; 
localMinimaTable = array2table(localMinimaCoordinates, 'VariableNames', {'Distance', 'Mean_Elevation'});

%Plot smoothed elevation with mean elevation
figure;
plot(distance, meanElevation, 'k', 'LineWidth', 1.5, 'DisplayName', 'Original Mean Elevation');
hold on;

plot(distance, smoothedElevation, 'b', 'LineWidth', 1.5, 'DisplayName', 'Smoothed Elevation');

plot(localMinimaDistance, localMinimaElevation, 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'Local Minima');

xlabel('Distance (m)'); 
ylabel('Elevation (m)'); 
title('Elevation Profiles with Local Minima'); 
grid on; 
legend('show'); 
hold off;

%% Polynomial Fitting
SW_3 = swathArray{6}; 

aggTable = SWATHobj2table(SW_3, @mean, {'MeanElevation'});

% Extract distance and elevation 
distance = aggTable.distx; 
meanElevation = aggTable.MeanElevation; 

% Polynomial fitting 
polyDegree = 20; % Degree of fitting
coefficients = polyfit(distance, meanElevation, polyDegree);

fittedElevation = polyval(coefficients, distance);

% Find LM of fitted data
localMinimaIdx = islocalmin(fittedElevation, 'MinSeparation', 1000); 

localMinimaDistance = distance(localMinimaIdx); % Extract distance LM
localMinimaElevation = fittedElevation(localMinimaIdx); % Extract elevation LM

% Store LM in table
localMinimaCoordinates = [localMinimaDistance, localMinimaElevation]; 
localMinimaTable = array2table(localMinimaCoordinates, 'VariableNames', {'Distance', 'Mean_Elevation'});

% Plot results
figure;
plot(distance, meanElevation, 'k', 'LineWidth', 1.5, 'DisplayName', 'Original Mean Elevation');
hold on;

plot(distance, fittedElevation, 'b', 'LineWidth', 1.5, 'DisplayName', 'Polynomial Fit');

plot(localMinimaDistance, localMinimaElevation, 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'Local Minima');

xlabel('Distance (m)'); 
ylabel('Elevation (m)'); 
title('Elevation Profiles with Polynomial Fitting and Local Minima'); 
grid on; 
legend('show'); 
hold off;


%% Extract LM coordinates local minima from SWATH

originalDistances = aggTable.distx;  
X_co = SW_3.X';                   
Y_co = SW_3.Y'; 

%Select middle point of SWATH
X_coords = X_co(:,32);   
Y_coords = Y_co(:,32);

% Store LM coords
minimaX = [];
minimaY = [];
minimaDist = [];

% Extract LM points from distance along SWATH
for i = 1:length(localMinimaDistance)
    [~, idx] = min(abs(originalDistances - localMinimaDistance(i)));
    
    minimaX(i) = X_coords(idx);  
    minimaY(i) = Y_coords(idx);  
    minimaDist(i) = originalDistances(idx); 
end

minimaTable = table(minimaDist', minimaX', minimaY', 'VariableNames', {'LocalMinimaDistance', 'X', 'Y'});

figure;
imagesc(DEM_SA); 
colormap('landcolor'); 
colorbar; 
title('DEM with Minima Points');

hold on;
plot(SW_3)
plot(minimaTable.X, minimaTable.Y, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'Local Minima');

xlabel('X Coordinate');
ylabel('Y Coordinate');

hold off;




















