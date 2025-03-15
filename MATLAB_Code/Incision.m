%% River Incision Masked Rivers
DEM_1k = GRIDobj('DEM_SA_Projected.tif');
DEM = GRIDobj('D:\THESIS\DEM_Megafans_150m.tif');

%Flow direction
FD_SA = FLOWobj(DEM_1k);

%Flow Accumulation
FA_SA = flowacc(FD_SA);

%Streams
min_Area = 100e6;
S = STREAMobj(FD_SA,'minarea',min_Area,'unit','map');
%%
% Stream Objects for different stream orders
S1 = modify(S, 'streamorder', 2); % Stream order 2
S2 = modify(S, 'streamorder', '>2'); % Stream order > 2
S3 = modify(S, 'streamorder', '>3'); % Stream order > 3

% Convert Stream Objects to Binary Rasters
streamRasterS = STREAMobj2GRIDobj(S); 
streamRaster1 = STREAMobj2GRIDobj(S1); 
streamRaster2 = STREAMobj2GRIDobj(S2); 
streamRaster3 = STREAMobj2GRIDobj(S3); 

% Create Binary Rasters for Streams
streamBinaryS = resample(streamRasterS, DEM); 
streamBinaryS.Z = streamBinaryS.Z > 0; 

streamBinary1 = resample(streamRaster1, DEM); 
streamBinary1.Z = streamBinary1.Z > 0; 

streamBinary2 = resample(streamRaster2, DEM); 
streamBinary2.Z = streamBinary2.Z > 0; 

streamBinary3 = resample(streamRaster3, DEM); 
streamBinary3.Z = streamBinary3.Z > 0; 

% Create Buffers Around Streams Based on Stream Order
bufferDistS = 2000; 
bufferDist1 = 3000; 
bufferDist2 = 5000; 
bufferDist3 = 7000; 

% Convert buffer distances to grid cells
bufferCellsS = ceil(bufferDistS / DEM.cellsize); 
bufferCells1 = ceil(bufferDist1 / DEM.cellsize); 
bufferCells2 = ceil(bufferDist2 / DEM.cellsize); 
bufferCells3 = ceil(bufferDist3 / DEM.cellsize);

% Create buffers for each stream object
bufferedRasterS = dilate(streamBinaryS, true(bufferCellsS)); 
bufferedRaster1 = dilate(streamBinary1, true(bufferCells1)); 
bufferedRaster2 = dilate(streamBinary2, true(bufferCells2)); 
bufferedRaster3 = dilate(streamBinary3, true(bufferCells3)); 

% Combine Buffers from All Stream Objects
combinedBuffer = bufferedRasterS; 
combinedBuffer.Z = combinedBuffer.Z | bufferedRaster1.Z; 
combinedBuffer.Z = combinedBuffer.Z | bufferedRaster2.Z; 
combinedBuffer.Z = combinedBuffer.Z | bufferedRaster3.Z; 

% Mask the DEM with Combined Buffer
maskedDEM = DEM; 
maskedDEM.Z(combinedBuffer.Z > 0) = NaN; % Set values within the buffer to NaN
%%
% Visualize the result
figure;
imagesc(maskedDEM);
title('DEM with Rivers Masked (Including Normal Stream Object and Stream Orders)');
colorbar;
%% Export Buffered DEM
GRIDobj2geotiff(maskedDEM, 'Buffered_DEM')
