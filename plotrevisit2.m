%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   plotrevisit2.m
%   Miles DeWaele 11/14/2020
%
%   This script plots coverage maps for I and P-band frequencies
%   and calculates the percentage coverage for land coverage
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 8240 land cells
close all; clear; clc;

%% PARAMETERS
nGrid = 3; % Number of grids
nRx = 12; % Number of receivers
flag_combineRx = 1; % Set 1 if receivers are in a single constellation, 0 otherwise
RxName = 'GAEA';
TxName = {'I-Band','P-Band'}; % Name of transmitters
nTx = size(TxName, 2); % Number of transmitters

scatterStyle = {'r.', 'g.'};

%% CONSTANTS
M_TO_KM = 1E-3;

%% GET DIRECTORIES
dir_parent = fileparts(pwd);
dir_out = strcat(dir_parent, '/Revisit Scripts/GAEA2/');
dir_static = strcat(dir_parent, '/Revisit Scripts/earthdata/static/');
dir_figure = strcat(pwd, '/figure/');

%% READ GRIDS
opts = delimitedTextImportOptions('Delimiter', ' ', 'VariableTypes', 'double');
for iGrid = 1 : nGrid
    filename = sprintf('Grid%d_lat.out', iGrid);
    Grid{iGrid}.lat = readmatrix(strcat(dir_out, filename), opts);
    Grid{iGrid}.nRow = length(Grid{iGrid}.lat)-1;
    filename = sprintf('Grid%d_lon.out', iGrid);
    Grid{iGrid}.lon = readmatrix(strcat(dir_out, filename), opts);
    Grid{iGrid}.nCol = length(Grid{iGrid}.lon)-1;
end

%% READ DATA
data = cell(nRx, nTx);
for iRx = 1 : nRx
    for iTx = 1 : nTx
        filename = sprintf('%s%d_%s.out', RxName, iRx-1, TxName{iTx});
        temp = readmatrix(strcat(dir_out, filename), opts);
        
        % Indices of data on land
        ind_land = temp(:,5) == 1;
        
        % Date
        data{iRx,iTx}.date = datetime(temp(ind_land,1)+1E-6, 'ConvertFrom', 'juliandate');

        % Latitude and longitude of specular points
        data{iRx,iTx}.latSp = temp(ind_land,2);
        data{iRx,iTx}.lonSp = temp(ind_land,3);
    end
end

if(flag_combineRx)
    for iTx = 1 : nTx
        for iRx = 2 : nRx
            data{1,iTx}.date = cat(1, data{1,iTx}.date, data{iRx,iTx}.date);
            data{1,iTx}.latSp = cat(1, data{1,iTx}.latSp, data{iRx,iTx}.latSp);
            data{1,iTx}.lonSp = cat(1, data{1,iTx}.lonSp, data{iRx,iTx}.lonSp);
        end
        % Sort dates in ascending order
        [data{1,iTx}.date, ind_ascend] = sort(data{1,iTx}.date);
        data{1,iTx}.latSp = data{1,iTx}.latSp(ind_ascend);
        data{1,iTx}.lonSp = data{1,iTx}.lonSp(ind_ascend);
    end
    nRx = 1;
end

%% COUNT NUMBER OF CELLS PLACED ON LAND
filename = 'LandMask_1km_EASE2.uint8';
fileID = fopen(strcat(dir_static,filename),'r');
landmask = fread(fileID, inf, 'uint8');
fclose(fileID);
landmask = reshape(landmask,34704,14616)';

for iGrid = 1 : nGrid
    Grid{iGrid}.lat_mid = Grid{iGrid}.lat(1:end-1) + diff(Grid{iGrid}.lat)/2;
    Grid{iGrid}.lon_mid = Grid{iGrid}.lon(1:end-1) + diff(Grid{iGrid}.lon)/2;
    landmaskGrid = zeros(Grid{iGrid}.nRow, Grid{iGrid}.nCol);
    for iRow = 1 : Grid{iGrid}.nRow
        for iCol = 1 : Grid{iGrid}.nCol
            [row, col] = geo2easeGridV2(Grid{iGrid}.lat_mid(iRow), Grid{iGrid}.lon_mid(iCol), 1);
            landmaskGrid(iRow,iCol) = landmask(row,col);
        end
    end   
    Grid{iGrid}.nCellLand = nnz(landmaskGrid); % Number of cells placed on land in a grid
end

%% CALCULATE PERCENTAGE COVERAGE
% coverage = cell(nRx, nTx, nGrid);
% for iRx = 1 : nRx
%     for iTx = 1 : nTx
%         for iGrid = 1 : nGrid
%             % Initialization
%             nSp = zeros(Grid{iGrid}.nRow, Grid{iGrid}.nCol);
%             nRow = length(data{iRx,iTx}.latSp);
%             percentage = zeros(nRow,1);
%             % Calculate percentage coverage as a function of time
%             for iRow = 1:nRow
%                 nSp_next = histcounts2(data{iRx,iTx}.latSp(iRow), data{iRx,iTx}.lonSp(iRow), Grid{iGrid}.lat, Grid{iGrid}.lon);   
%                 nSp = nSp + nSp_next;
%                 percentage(iRow) = nnz(nSp)/Grid{iGrid}.nCellLand*100;
%             end
%             coverage{iRx,iTx,iGrid}.percentage = percentage;
%         end
%     end
% end

%% CALCULATE REVISIT TIME
revisit_cell = cell(nRx, nTx, nGrid);
revisit = cell(nRx, nTx, nGrid);
counter = 0;
for iRx = 1: nRx
    for iTx = 1 : nTx
        for iGrid = 3 : 3
            ind_row = discretize(data{iRx,iTx}.latSp, Grid{iGrid}.lat);
            ind_col = discretize(data{iRx,iTx}.lonSp, Grid{iGrid}.lon);
            j = 0;
            for i = 1:length(ind_row)
                if (~isnan(ind_row(i)) && ~isnan(ind_col(i)))
                         j = j + 1;
                        meas(j, (iTx-1)*3+1) = ind_row(i);
                        meas(j, (iTx-1)*3+2) = ind_col(i);
                        meas(j, (iTx-1)*3+3) = datenum(data{iRx,iTx}.date(i,1));
%                     end
                    
                    %fprintf("(%d, %d) ", ind_row(i), ind_col(i));
                    %fprintf("%s\n", data{iRx,iTx}.date(i,1));
                end
            end
            % Calculate and average time difference of measurements in each cells
%             for iRow = 1: Grid{iGrid}.nRow
%                 for iCol = 1: Grid{iGrid}.nCol
%                     t_meas = data{iRx,iTx}.date(ind_row == iRow & ind_col == iCol);
%                     interval = diff(t_meas);
%                     interval = interval(interval>duration(0,1,0));
%                     revisit_cell{iRx,iTx,iGrid}(iRow,iCol) = mean(interval);
%                 end
%             end
%             revisit_cell{iRx,iTx,iGrid}(isnan(revisit_cell{iRx,iTx,iGrid})) = 0;
%             revisit{iRx,iTx,iGrid} = mean(mean(revisit_cell{iRx,iTx,iGrid}));
            lengths(iTx) = j;
        end
    end
end
% revisit = squeeze(revisit);
% revisit_cell = squeeze(revisit_cell);
a=1; %x=1;


% Time zero = 7.385220056840000e+05
% Time after 4 days = 7.385260056840000e+05
% Finding pairs within 12 hours
pairs = double.empty(0,2);
for i = 1:lengths(1)
    iCoord1 = meas(i,1); iCoord2 = meas(i,2); iTime = meas(i,3);
    for j = 1:lengths(2)
        pCoord1 = meas(j,4); 
        pCoord2 = meas(j,5); 
        pTime = meas(j,6);
        timeCheck = (pTime < (iTime+0.5) && pTime > (iTime-0.5)); %&& (pTime < 7.385265056840000e+05));
        if (iCoord1 == pCoord1 && iCoord2 == pCoord2 && timeCheck)
            %fprintf("Pair found at (%d, %d)\n", iCoord1, iCoord2);
            %pairs2(x,1) = iCoord1; pairs2(x,2) = iCoord2;
            checker = 1;
            if isempty(pairs)
                checker = 1;
            end
            for ind = 1:length(pairs(:,1))
                if pairs(ind,1) == iCoord1 && pairs(ind,2) == iCoord2
                    checker = 0;
                end
            end
            if checker
                pairs(a,1) = iCoord1; pairs(a,2) = iCoord2;
                a = a+1;
            end
            %x = x+1;
            break;
        end
    end
end

coverage = ind / 8240.0;

figure;
scatter(pairs(:,2),pairs(:,1), 150, '.');
grid on;
xlim([0 100]);
ylim([0 100]);
title("Grid 3 Root Zone Coverage - 4 days");
xlabel("Grid 3 X-Cells");
ylabel("Grid 3 Y-Cells");

%figure;
%scatter(

% figure;
% scatter(pairs2(:,1),pairs2(:,2), 150, '.');
% grid on;
% xlim([0 100]);
% ylim([0 100]);
% title("pairs2");
fprintf("Land Coverage Percentage: %f\n", coverage);
fprintf("Done!\n");



% %% PLOT
% % Entire coverage over grids
% load coastlines
% hf = figure('visible','on'); hold on; grid on;
% axesm('MapProjection','robinson','MapLatLimit',[-90 90],'MapLonLimit',[-180 180],...
%  'Frame','on','Grid','on','MeridianLabel','on','ParallelLabel','on');
% plotm(coastlat,coastlon,'k')
% for iGrid = 1 : nGrid
%     [latMesh, lonMesh] = meshgrid(Grid{iGrid}.lat, Grid{iGrid}.lon);
%     plotm(latMesh, lonMesh, 'b')
%     plotm(latMesh',lonMesh','b')
% end
% for iRx = 1 : nRx
%     for iTx = 1 : nTx
%         scatterm(data{iRx,iTx}.latSp, data{iRx,iTx}.lonSp, [], scatterStyle{iTx});
%     end
% end
% 
% % Percentage coverage v.s. time
% for iGrid = 1 : nGrid
%     for iRx = 1 : nRx
%         hf = figure('visible','off'); hold on; grid on;
%         for iTx = 1 : nTx
%             hp(iTx) = plot(data{iRx,iTx}.date, coverage{iRx,iTx,iGrid}.percentage, 'LineStyle', '-', 'LineWidth', 1);
%         end
%         xlabel('Date'); ylabel('Coverage (%)');
%         legend(hp, TxName, 'Location', 'northwest');
%         s_title = sprintf('Grid %d', iGrid);
%         title(s_title);
%         filename = sprintf('PercentCover_Rx%d_Grid%d', iRx, iGrid);
%         print(hf, strcat(dir_figure,filename), '-dpng');
%     end
% end