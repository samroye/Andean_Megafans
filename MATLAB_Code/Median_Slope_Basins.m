%%
clc         % clear command window
clear       % clear workspace
close all   % close all figure windows

%% User choice ----------------------------------------------------------- %
filename = 'Median_Slope_Basins'; % name of export file without extension
export = 0;   % Do you want to export the raster 0-no, 1-yes
radius = 5000;% radius for local relief in map units
PP_mode = 3;  % how do you want to pick your pour points (catchment outlets)?
              % 1 - manually select them interactively from DEM
              % 2 - specify coordinates [x,y] in map units
              % 3 - all catchments within Strahler order range 
              %     (set range below)
minArea = 100e6; % minimum drainage area for stream initiation in map units
               % (used for initial STREAMobj generation)
DEM = GRIDobj('DEM_SA_Projected.tif'); % input your DEM

%%
if PP_mode == 3
    min_order = 2;   % minimum stream order for selected catchments
    max_order = 9;   % maximum stream order, if a single stream order is 
    %                  desired, then leave this same as min_order
    overwrite_mode = 2; % if 1 then the local topography of the higher order 
    % catchments will overwrite the ones from lower order, if 2 the other way
    % around. 
end
              
% flow routing -------------------------------------------------- %
FD  = FLOWobj(DEM);
S = STREAMobj(FD,'unit','mapunits','minarea',minArea);

%% Determine catchments ----------------------------------------------------- %
        
W  = flowacc(FD)> (minArea/DEM.cellsize^2);   % define streams
Outlets = streampoi(FD,W,'outlets','ix');      % river outlets from DEM
%         Bcon = streampoi(FD,W,'bconfluences','ix');   % b conlfuences

%         POIs = [Outlets; Bcon];                       % all our stream points of interest

% now classify streamPOIs by strahler order
so = streamorder(FD,W);  % stream order
maxSo = max(so);                       % find maximum stream order
if max_order > maxSo                   % make sure the code doesnt run for iterations that are not needed
    max_order = maxSo;
end
Outlet_order = so.Z(Outlets);

n = min_order : 1: max_order;
counter = 1;
for i = n
    DB1 = drainagebasins(FD,so,i);
    strahler_outlets = Outlets(Outlet_order == i);
    DB2 = drainagebasins(FD,strahler_outlets);
    DB2.Z(DB2.Z ~=0) = DB2.Z(DB2.Z ~=0) + max(DB1);
    D{counter}= DB1 + DB2;
    counter = counter+1;
end


%% Calculate local relief ----------------------------------------------- %

slope = gradient8(DEM,"deg");
    
locrel = cell(length(D),1); % make cell array storing the local relief rasters for every strahler order

h = waitbar(0,'calculating relief');
for i = 1:length(D)         % loop through strahler orders
    n = max(D{i}(:));       % number of catchments to calculate will be max value of drainage basin raster (every catchment gets an ID (1,2,3...))
    locrel{i} = DEM;        % again copy DEM for georef properties
    locrel{i}.Z = zeros(size(DEM.Z)); % zero raster
    for j = 1:n             % loop through catchments as in block 10 lines above
        basinslope = slope;
        basinslope.Z(D{i}.Z ~= j) = nan;
        basinslope.Z(D{i}.Z == j)  = median(basinslope.Z(:), 'omitnan');
        basinslope.Z(isnan(basinslope.Z)) = 0;
        
        locrel{i}.Z = locrel{i}.Z + basinslope.Z;
    end
    waitbar(i/length(D),h)
end
close(h)

% now we have local relief rasters for every strahler order, but we
% need to stack them for a full local relief raster
stacked_locrel = DEM;       % copy DEM for georef info
stacked_locrel.Z = zeros(size(DEM.Z)); % set zero
h = waitbar(0,'stacking relief');
for i = 1:length(locrel)    % loop through strahler orders
    if i > 1  % during first itertion this for-loop will only execute the last line, after the first iteration it will enter this if statement
        mask_old = stacked_locrel.Z ~= 0;   % areas where stacked locrel raster has values
        mask_new = locrel{i}.Z ~= 0;        % areas where new strahler order locrel raster has values
        setnull = and(mask_old, mask_new);  % the area where both have values is to one where we need to overwrite
        if overwrite_mode == 1              
            stacked_locrel.Z(setnull) = 0;  % because we're loop upwards in stream order, we need to set the previous locrel raster to zero if we want to add the new higher order locrel values
        elseif overwrite_mode == 2
            locrel{i}.Z(setnull) = 0; % if we want to keep the info from lower order streams, we need to set the overlapping areas to zero for the new higher order streams
        else
            dips('enter either 1 or 2 in "overwrite mode"')
        end
    end
    stacked_locrel.Z = stacked_locrel.Z + locrel{i}.Z; % add the old and new values together
    waitbar(i/length(locrel),h)
end
close(h)
locrel = stacked_locrel; % rename for consistency with other PP_mode's


%% visualize results
figure()
imageschs(locrel,[],'colormap',landcolor)
hold on
for i = 1:length(D) % plot catchment outlines
    try
        plot(x{i},y{i},'k-','LineWidth',1.5)
    catch
        continue
    end
end
title('median slope per catchment')

% export
if export
    GRIDobj2geotiff(locrel,[filename, '.tif'])
end


