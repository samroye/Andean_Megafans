%Load DEM
DEM_SA = GRIDobj('DEM_SA_Projected.tif');
%% Flow and Stream calculation

%Flow direction
FD_SA = FLOWobj(DEM_SA, 'preprocess','carve');

%Flow Accumulation
FA_SA = flowacc(FD_SA);
logFA_SA = log10(FA_SA);

%FA_threshold = logFA_SA > 4;

%Streams
min_Area = 100e6;
S_SA = STREAMobj(FD_SA,'minarea',min_Area,'unit','map');

%S_SAselect = STREAMobj(FD_SA, FA_threshold);
%%
DB = drainagebasins(FD_SA, S_SA);
DB = shufflelabel(DB);
imageschs(DEM_SA,DB)   % go ahead and plot the DEM with drainage basin overlay
%%
imagesc(DEM_SA)
hold on
plot(S_SA)

%% Calculate Chi
chi = chitransform(S_SA, FA_SA,'mn',0.45);
chitransform()
chiMap = mapfromnal(FD_SA ,S_SA ,chi);  

h = figure(); 
set(h,'Units','normalized','Position',[0 0 1 1]); 
imageschs(DEM_SA ,chiMap,'colorbar',true)

%% Chi map
%TPI
TPI = localtopography(DEM_SA, 5000);

GRIDobj2geotiff(TPI, 'TR_SA')
%%
slope = gradient8(DEM_SA, 'deg');
GRIDobj2geotiff(slope, "Slope_SA")

%% Export Streams as GRID

S_SA_1 = modify(S_SA, 'streamorder', '>2');
S_SA_2 = modify(S_SA, 'streamorder', '>3');
S_SA_3 = modify(S_SA, 'streamorder', '>4');

S_SAGrid = STREAMobj2GRIDobj(S_SA);
S_SAGrid1 = STREAMobj2GRIDobj(S_SA_1);
S_SAGrid2 = STREAMobj2GRIDobj(S_SA_2);
S_SAGrid3 = STREAMobj2GRIDobj(S_SA_3);

GRIDobj2geotiff(S_SAGrid, 'S_SA');
GRIDobj2geotiff(S_SAGrid1, 'S_SA_1');
GRIDobj2geotiff(S_SAGrid2, 'S_SA_2');
GRIDobj2geotiff(S_SAGrid3, 'S_SA_3');


%%
%Export Stream objects
S_SAGrid = STREAMobj2GRIDobj(S_SA);

S_SAselectGrid = STREAMobj2GRIDobj(S_SAselect);

GRIDobj2geotiff(S_SAGrid, 'Streams')
GRIDobj2geotiff(S_SAselectGrid, 'Streams_Major')

%Export Chimap
GRIDobj2geotiff(chiMap, 'Chi_SA')

%% Calculate Stream Order and Drainage divides
so_SA = streamorder(S_SA,'strahler');

D = DIVIDEobj(FD_SA , S_SA);
Dorder = divorder(D,'topo');

%% Plot divides
imagesc(DEM_SA)
hold on
plot(D) % plot divides

%% 





