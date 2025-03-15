% CALCULATE ASYMMETRY ACROSS DRAINAGE DIVIDES (V1.1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script computes divide asymmetry metrics for a given DEM.
% 
% METRICS:
%   - hillslope gradient
%   - chi
%   - local relief (standard or catchment-limited)
%   - ksn
%
% WARNINGS: 
% * Make sure that your DEM area can accommodate your chosen base-level.
%   Double-check base-level if you encounter an error calculating 'D'.
%
% * To calculate divide asymmetry from catchment-restricted relief, 
%   you must load a pre-calculated grid generated using this script:
%      - 'catchment_restricted_relief.m'
%
% * All input grids must have identical coverage, grid size, and be in the 
%   same UTM coordinate system. This script will align and resample grids:
%      - 'reproject_or_align.m'
%
% OUTPUTS:
%   - Divide asymmetry map structures (points, lines):
%       - hillslope gradient (MS_sl, MS_sl_line)
%       - chi (MS_chi, MS_chi_line)
%       - local relief (MS_lr, MS_lr_line)
%       - ksn (MS_ksn, MS_ksn_line)
%   - Grids
%       - Hillslope gradient (slope)
%       - chi (chi_map)
%       - local relief (loc_relief)
%       - ksn (ksn map)
%
% EXPORTS (optional):
%   - .mat file (v7.3) updated at frequent checkpoints throughout script
%   - line and point shapefiles containing asymmetries for each metric 
%     (see "help" for TopoToolbox asymmetry function for attribute info)
%   - grids of each metric as geoTIFF (.tif) files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEPENDENT SCRIPTS & PACKAGES
%   - Topotoolbox (& its dependencies)
%   - Navigation Toolbox
%   - Mapping Toolbox
%   - asymmetry_mod.m
%   - asymmetry_line_mod.m
%   - bconfgrid.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by K.D. Gelwick & R.F. Ott in 2021
%   updated to Version 1.1 in 2022

%%
clc         % clear command window
clear       % clear workspace
close all   % close all figure windows

%% USER CHOICE ---------------------------------------------------------- %

% EXPORT RESULTS?
export =  0;        % 1 = export results; 0 = do not export results
%%
% STANDARD INPUTS
DEM = GRIDobj('DEM_SA_Projected.tif');  % load DEM in UTM projection
minArea = 100e6;                                  % minimum drainage area for stream initiation in m^2
mn = 0.45;                                       % set concavity (m/n ratio from Stream Power Law)                                    % baselevel (m) for chi calculation

% SITUATIONAL INPUTS (based on choice of asymmetry metrics/corrections)
% Comment-out unused lines!
seglength = 500;          % [if export = 1] line segment length (m) for shapefile export
radius = 1000;            % [if relief_asymmetry = 0] radius (m) for local relief calculation

%% EXPORT SETTINGS -------------------------------------------------------%
if export
    disp('Select your output folder location in the pop-up window.')
    path = uigetdir;                                   % navigate to output folder location (generates pop-up window)
    filename = input('Enter desired file name: ','s'); % set output file name
    save([path '\' filename],'-v7.3');
end

%% CALCULATE STREAM AND DIVIDE NETWORKS ----------------------------------%

% GENERATE STREAM NETWORK
FD = FLOWobj(DEM,'preprocess','carve');
A = flowacc(FD); % flow accumulation
S = STREAMobj(FD,'minarea',minArea,'unit','map');
%%
figure;
imagesc(DEM);
hold on
plot(S, 'r.')
hold off
%%

so = streamorder(S,'strahler'); % calculate Strahler order for stream segments

if export
    save([path '\' filename],'-append');
    disp('Stream network saved to .mat file.');
end

% GENERATE DRAINAGE DIVIDE NETWORK
D = DIVIDEobj(FD,S);
D = cleanedges(D,FD);   % remove divides along the edges
D = divorder(D,'strahler');

if export
    save([path '\' filename],'-append');
    disp('Drainage divides saved to .mat file.');
end

%% make raster of bconfluences to label divide sides in asymmmetry_mod function

map_bcons_ix = bconfgrid(S,DEM,FD);

%% CALCULATE ASYMMETRY METRICS -------------------------------------------%

% CALCULATE CHI
chi = chitransform(S,A,'mn',mn,'plot',0); % calculate chi
chi_map = mapfromnal(FD,S,chi);   % project chi onto hillslopes


if export
        save([path '\' filename],'-append');
        disp('.mat file updated.');
end

%% CALCULATE ACROSS-DIVIDE DIFFERENCES -----------------------------------%


[MS_chi, ~] = asymmetry_mod(D,chi_map,map_bcons_ix,'mean');
[MS_chi_line, ~] = asymmetry_line_mod(D,chi_map,map_bcons_ix,'mean');

if export
    save([path '\' filename],'-append');
    disp('.mat file updated.');
end

%% CORRECT CHI ASYMMETRY DIRECTIONS ------------------------------------- %
% this is necessary because we assume that a lower chi value indicates
% higher erosional power. Therefore all divide asymmetry directions of chi
% are being reversed
for i = 1:length(MS_chi)
    if MS_chi(i).theta <= 180
        MS_chi(i).theta = MS_chi(i).theta+180;
    else
        MS_chi(i).theta = MS_chi(i).theta-180;
    end
    MS_chi(i).u = MS_chi(i).u * (-1);
    MS_chi(i).v = MS_chi(i).v * (-1);
    if MS_chi(i).m_theta <= 180
        MS_chi(i).m_theta = MS_chi(i).m_theta+180;
    else
        MS_chi(i).m_theta = MS_chi(i).m_theta-180;
    end
end
for i = 1:length(MS_chi_line)
    if MS_chi_line(i).theta <= 180
        MS_chi_line(i).theta = MS_chi_line(i).theta+180;
    else
        MS_chi_line(i).theta = MS_chi_line(i).theta-180;
    end
    MS_chi_line(i).u = MS_chi_line(i).u * (-1);
    MS_chi_line(i).v = MS_chi_line(i).v * (-1);
    if MS_chi_line(i).m_theta <= 180
        MS_chi_line(i).m_theta = MS_chi_line(i).m_theta+180;
    else
        MS_chi_line(i).m_theta = MS_chi_line(i).m_theta-180;
    end
end
%%

MS_chi_high_order = MS_chi_line([MS_chi_line.order] > 1);

shapewrite(MS_chi_high_order,'chi_asymmetry_high_order.shp');
%% EXPORT FILES --------------------------------------------------------- %
export = 1;
if export
    
    %GRIDobj2geotiff(chi_map, 'Chi_Map_SA.tif');
    %disp ('Finished exporting chi map.');
%         MS_chi = STREAMobj2mapstruct(S,'seglength',seglength,'attributes',{'chi' chi @mean 'strahler' so @mean},'parallel',true);
    %shapewrite(MS_chi, 'MS_chi_shp');
    %disp('Finished exporting chi shapefile.');
    shapewrite(MS_chi_line,'chi_lines.shp');
   
    
  
    
   % export divides and asymm
     MS_Dmod = DIVIDEobj2mapstruct(D,DEM,seglength,{'lr_min' relief_averaged_mod 'min'},{'lr_max' relief_averaged_mod 'max'},{'lr_diff' relief_averaged_mod 'diff'},...
         {'slope_min' slope_averaged_mod 'min'},{'slope_max' slope_averaged_mod 'max'},{'slope_diff' slope_averaged_mod 'diff'}...
         ,{'chi_min' chi_map_mod 'min'},{'chi_max' chi_map_mod 'max'},{'chi_diff' chi_map_mod 'diff'});
     for i = 1:length(MS_Dmod) % compute asymmetry indices
         MS_Dmod(i).daiLR      = MS_Dmod(i).lr_diff   /(MS_Dmod(i).lr_min   +MS_Dmod(i).lr_max);
         MS_Dmod(i).daiSlope = MS_Dmod(i).slope_diff/(MS_Dmod(i).slope_min+MS_Dmod(i).slope_max);
         MS_Dmod(i).daichi   = MS_Dmod(i).chi_diff  /(MS_Dmod(i).chi_min  +MS_Dmod(i).chi_max);
         MS_Dmod(i).diffchi   = MS_Dmod(i).chi_diff;
         if isinf(MS_Dmod(i).daiLR) % divison can cause infinities and below zeor values, these need to be reset for all indices
             MS_Dmod(i).daiLR = nan;
         end
         if MS_Dmod(i).daiLR < 0
             MS_Dmod(i).daiLR = 0;
         end
         if isinf(MS_Dmod(i).daiSlope) 
             MS_Dmod(i).daiSlope = nan;
         end
         if MS_Dmod(i).daiSlope < 0
             MS_Dmod(i).daiSlope = 0;
         end
         if isinf(MS_Dmod(i).daichi) 
             MS_Dmod(i).daichi = nan;
         end
         if MS_Dmod(i).daichi < 0
             MS_Dmod(i).daichi = 0;
         end
     end
     shapewrite(MS_Dmod,'Divide_mod.shp')
disp('.mat file updated.');

end
