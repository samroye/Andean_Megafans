function map_bcons_ix = bconfgrid(S,DEM,FD)
%
% BCONFGRID a grid labelled by b-confluence IX
%
% SYNTAX
%       map_bcons_ix = bconfgrid(S)
% 
% Description
%   This script computes a raster of subbasins, where every subbasin is
%   labelled by the IX index of it's downstream-end b-confluence.
%
% Input
% 
%       S - instance of class STREAMobj
%       DEM - instance of class GRIDobj
%       FD - instance of class FLOWobj
%
% Output
%
%       map_bcons_ix - instance of class GRIDobj with values representing
%                      b-confluence indices of subbasin
%
% Richard Ott, 2023


% get outlets and bconfluences
bcons_ix = streampoi(S, 'bconfluences' ,'ix');       % IX indices of b-confluences
bcons    = streampoi(S, 'bconfluences' ,'logical');  % nal of b-confluences
outlets_ix = streampoi(S,'outlets','ix');
outlets    = streampoi(S,'outlets','logical');

% -------------------------------------------------------------------------
% because some neighboring catchments share b confluences, move one edge
% upwards in STREAMobj to ensure that rivers do not share a confluence
[~,inds_bcons_ixc] = ismember(bcons_ix,S.IXgrid);     % get edge IDs of bconfluences
[~,receivers_bcons] = ismember(inds_bcons_ixc,S.ixc); % get receiver edge IDs for bconfluence
receivers_bcons(receivers_bcons == 0) = 1;
givers_bcons    = S.ix(receivers_bcons);              % get donor edge ID
givers_ix =S.IXgrid(givers_bcons);                    % get donor IX
givers_ix(receivers_bcons==1) = bcons_ix(receivers_bcons==1); % give short streams that dont have upstream edge their original b confluence ix back
bcons_ix = givers_ix;
bcons = false(size(bcons));
[~,giver_labels] = ismember(givers_ix,S.IXgrid);
bcons(giver_labels) = true;                           % nal with labeled b-confluences (if long stream, then moved up one node)
% -------------------------------------------------------------------------

% map bconfluences and outlets onto node-attribute-list
labeled_bcons = zeros(size(bcons));    % set up empty nal
try
    labeled_bcons(bcons)   = bcons_ix;     % label bconfluences in nal
catch % in case there are more pxels that still share bcons
    [~, unique_indices] = unique(giver_labels, 'stable'); % sever
    % Create a logical mask that keeps only unique values
    mask = false(size(giver_labels));
    mask(unique_indices) = true;
    bcons_ix(~mask) = [];               % remove duplicates
    labeled_bcons(bcons)   = bcons_ix;     % label bconfluences in nal
end
labeled_bcons(outlets) = outlets_ix;   % label ouetls in nal

aggregated_bcons = aggregate(S,labeled_bcons,'seglength',1e6*DEM.cellsize,'aggfun',@max);  % label reaches according to their b-confluence IX
map_bcons_ix = mapfromnal(FD,S,aggregated_bcons);  % generate map of sub-basins labelled by b-confluence IX
end