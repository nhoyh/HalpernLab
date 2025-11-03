function [] = plot_image_impedances_NV_v1(impedances, params)
% PLOT_IMAGE_IMPEDANCES_NV makes a figure to quickly visualize the
% impedances of each channel.
% 
% + Inputs +
% -----------
% 
% [>]   impedances  : arrray with impedance values as reported by the g.tec (in kOhm)
%
% [>]   params      : struct with misc parameters to configure the plot
%   [*] nChans      : number of channels across all headboxes
%   [*] labels      : channel labels; must be equal to nChans


%% Input parser - TODO: Fix this

nChans = params.nChans; % params.nChans
labels = params.labels; % params.labels;


%%
% Colormap definition
cmap = zeros(4,3);
% cmap(1,:) = hex2rgb('#2B2D42'); % blacks for "unknown" impedances
% cmap(2,:) = hex2rgb('#8DDBE0'); % blues for "best" impedances
cmap(1,:) = hex2rgb('#00AFF5'); % blues for "best" impedances
cmap(2,:) = hex2rgb('#00CC9C'); % greens for "good" impedances
cmap(3,:) = hex2rgb('#D90429'); % reds for "bad" impedances

% Colorbars
cbmin = -1;
cbmax = 10; % kOhms
cbres = 0.1;

% Adjusted colormap
cmap_bounds = [2, 8, cbmax+1e-6];  % The upper bounds of each range
cmap_labs = [ "good\newline(<1 kOhm)", "okay\newline(2-8 kOhm)", "bad\newline(>8kOhm)"];
cbar_axs = (cbmin:cbres:cbmax)';
cmap_adj = zeros(length(cbar_axs), 3);
for idx = 1:numel(cmap_bounds)
    cmap_idxs_curr = all(cmap_adj == 0, 2) & (cbar_axs < cmap_bounds(idx));
    cmap_adj(cmap_idxs_curr, 1) = cmap(idx,1);
    cmap_adj(cmap_idxs_curr,2) = cmap(idx,2);
    cmap_adj(cmap_idxs_curr,3) = cmap(idx,3);
end

% Outline of the plot
nRows = 2;
nCols = 2;

% Total headboxes and number of channels
nHeadbox = ceil(nChans/64); % Number of headboxes used based on nChans
val = round(sqrt(256) / 2); % split the rows/columns in half

% figure(1)
% imagesc(C)
% clim([cbmin, cbmax])
% colorbar
% axis xy

% Random data
% C = randi([1,30], nChans,1); % Random data to plot
% C = linspace(0, 10, nChans)';
C = impedances;
if size(C,1) < size(C,2)
    C=C';
end
Cext = [C; zeros(256-nChans,1)];
labelsext = [labels cell(1,256-nChans)];

% Make the figure
fig = figure('Name', 'sEEG Impedances');
fig.Position = [100 10 1200 1000];

% Set up a tiled layout
t = tiledlayout(nRows, nCols, ...
                "TileSpacing", "compact", ...
                "Padding", "loose");

% Actually plot
headbox_cnt = 1;
for rowidx = 1:nRows
    for colidx = 1:nCols

        % PlotIdx
        plotidx = (rowidx-1)*nCols + colidx;

        % Stop if we've reached the last headbox
        if plotidx > nHeadbox
            break
        end

        % Plot only relevant area
        % col_start = (colidx-1)*val + 1;
        % col_end = (colidx-1)*val + val;
        % row_start = (rowidx-1)*val + 1;
        % row_end = (rowidx-1)*val + val;1
        % (row_start:row_end, col_start:col_end)
        % [col_start, col_end; row_start, row_end] % Print column/row lims for debugging

        % chunks of 64 elements
        % first, 1:64; then 65:128; then 129:192; then 193:256;

        % Subplot for this headbox
        % subplot(nRows, nCols, plotidx)
        nexttile(plotidx)

        % Plot the image
        idx_start = plotidx + (plotidx-1).*(64-1);
        idx_end = plotidx*64;
        Cplot = round(reshape(Cext(idx_start:idx_end), [val, val])',1);
        imagesc(Cplot)
        % set(gca,'box','off') % top/right ticks off
        set(gca, 'color', 'none');

        % set(gca,'xaxisLocation','top')
        % if colidx == 2
        %     set(gca, 'YAxisLocation', 'right')
        % else
        %     set(gca, 'YAxisLocation', 'left')
        % end
        % 
        % if rowidx == 1
        %     set(gca, 'XAxisLocation', 'top')
        % else
        %     set(gca, 'XAxisLocation', 'bottom')
        % end

        % Adjust limits and axes
        colormap(cmap_adj)
        clim([cbmin, cbmax])
        xticks(gca, [])
        yticks(gca, [])

        % % Colorbar settings here
        % % cb = colorbar;
        % cb = colorbar();
        % % 'Ticks', cmap_ticks, ...
        %         % 'TickLabels', []);
        % cb.Ticks = [0, 2, 4, 6, 8, 12];
        % cb.Limits = [cbmin, cbmax];

        % Add the title of the axis
        title(sprintf('Headbox %d', plotidx))
        
        % Add the electrode labels for this area
        curr_labels = labelsext(idx_start:idx_end);
        labidx = 0;
        for ridx = 1:val
            for cidx = 1:val

                % Get the current label index
                labidx = labidx + 1;
                chanlabel = curr_labels{labidx};
                if isempty(chanlabel); chanlabel = ''; end
                labtext = text(cidx, ridx, sprintf('%d:%s\n%.1fk', labidx+(headbox_cnt-1)*64, chanlabel, round(Cplot(ridx, cidx),1)), ...
                            'FontSize', 8, 'FontWeight', 'bold', ...
                            'Color', 'white', ...'BackgroundColor', 0.9*ones(1,3), ...
                            'HorizontalAlignment', 'center', ...
                            'VerticalAlignment', 'middle');
            end
        end
        headbox_cnt = headbox_cnt+1; % increment so that channel numbers match
    end % Columns
end % Rows

h = axes(fig,'visible','off'); 
% h.Title.Visible = 'on';
% h.XLabel.Visible = 'on';
% h.YLabel.Visible = 'on';
% ylabel(h,'yaxis','FontWeight','bold');
% xlabel(h,'xaxis','FontWeight','bold');
% title(h,'title');

cb = colorbar(h,'Position', [0.93 0.168 0.018 0.6]);  % attach colorbar to h
% cb.Ticks = [0; mean([cmap_bounds(1:end-1)' cmap_bounds(2:end)'], 2)]; % Add a colorbar with discrete ticks
% cb.Ticks = -1:0.5:10
cb.Ticks = mean([cbmin, cmap_bounds(1); cmap_bounds(1:end-1)' cmap_bounds(2:end)'; cmap_bounds(end), cbmax], 2);
% cb.TickLabels = {'0-1', '1-2', '2-8', '>8'};
cb.TickLabels = cmap_labs;
% colormap(cb, cmap)
clim(h,[cbmin, cbmax]);             % set colorbar limits
% linkaxes
cbtitle = get(cb, 'Title');
set(cbtitle, 'HorizontalAlignment', 'center')
set(cbtitle, 'String', 'Impedance\newline[kOhm]')
set(cb, 'Fontsize', 8)
% set(cb, 'TickLabelInterpreter', 'latex');

fdate = datetime("now", 'Format', 'dd-MMM-uuuu HH:mm:ss');
sgtitle(sprintf('Impedances %s', string(fdate)))
time = fix(clock);
fprintf('Impedance checking at %d/%d/%d %d:%d:%d\n',time(2),time(3),time(1),time(4),time(5),time(6))
saveas(fig,sprintf('impedance_figure/%d-%d-%d_%d-%d-%d.png',time(2),time(3),time(1),time(4),time(5),time(6)))
end