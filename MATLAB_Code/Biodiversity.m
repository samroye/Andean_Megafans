%% Climate and Biodiversity rasters

% Load rasters
biodiversity = GRIDobj('Terrestrial_Biodiv.tif');
temperature = GRIDobj('Ann_Temperature.tif');
precipitation = GRIDobj('Ann_Precipitation.tif');

% Reference
referenceRaster = biodiversity;
temperatureAligned = resample(temperature, referenceRaster);
precipitationAligned = resample(precipitation, referenceRaster);

% Extract data
bio_data = biodiversity.Z;        
temp_data = temperatureAligned.Z; 
precip_data = precipitationAligned.Z; 

% Vectorize
bio_vector = bio_data(:);
temp_vector = temp_data(:);
precip_vector = precip_data(:);

% Remove NaN
valid_idx = ~isnan(bio_vector) & ~isnan(temp_vector) & ~isnan(precip_vector);
bio_vector = bio_vector(valid_idx);
temp_vector = temp_vector(valid_idx);
precip_vector = precip_vector(valid_idx);

% Fitlm
T = table(temp_vector, precip_vector, bio_vector, 'VariableNames', ...
    {'Temperature', 'Precipitation', 'Biodiversity'});
lm = fitlm(T, 'Biodiversity ~ Temperature + Precipitation', 'RobustOpts', 'ols');

% Residuals 
bio_predicted = lm.Fitted; 
residuals = bio_vector - bio_predicted; 

residual_raster = nan(size(bio_data)); 
residual_raster(valid_idx) = residuals; 

residual_map = biodiversity; 
residual_map.Z = residual_raster; % Assign residuals

GRIDobj2geotiff(residual_map, 'residual_Biodiv')

figure;
imagesc(residual_map)
colormap('landcolor')

