function create( self )
% CREATE creates the GUI

    % Menu first
    %
    %
    
    % File menu
    self.createFileMenu();
    
    % import menu    
    self.Menu.Import = struct();
    
    import = uimenu('Parent', self.Figure, 'Text', 'Import');
    self.Menu.Import.SICMScan =          uimenu(import, 'Text', 'Import SICM data');
    self.Menu.Import.FromWorkspace =     uimenu(import, 'Text', 'Data from workspace');
    self.Menu.Import.SICMDataAsMask =    uimenu(import, 'Text', 'SICM data as mask', 'Separator', 'on');
    self.Menu.Import.MaskFromFile =      uimenu(import, 'Text', 'Mask from file');
    self.Menu.Import.MaskFromWorkspace = uimenu(import, 'Text', 'Mask from workspace');
    
    
    % data menu
    data = uimenu('Parent', self.Figure, 'Text', 'Data');
    self.Menu.Data.Transpose =           uimenu(data, 'Text', 'Transpose');
    filter = uimenu('Parent', data, 'Text', 'Filter');
    self.Menu.Data.Filter.Median =       uimenu(filter, 'Text', 'Median');
    
    %display menu
    display = uimenu('Parent', self.Figure, 'Text', 'Display');
    self.Menu.Display.Height =           uimenu(display, 'Text', 'Height');
    self.Menu.Display.Slope  =           uimenu(display, 'Text', 'Slope');
    
    
    
    
    % layout components
    %
    %
    self.Layout.MainVBox = uix.VBox('Parent', self.Figure);
    self.Layout.MainHBox = uix.HBox('Parent', self.Layout.MainVBox);
    self.Layout.ProgressBarPanel = uix.Panel('Parent', self.Layout.MainVBox);
    self.Layout.TreePanel = uix.BoxPanel(...
        'Parent', self.Layout.MainHBox, ...
        'Title', 'Data Browser' );
    
    self.Layout.DisplayPanel = uix.BoxPanel(...
        'Parent', self.Layout.MainHBox, ...
        'Title', 'Data display' ...
    );
    
    self.Layout.RoughnessPanel = uix.BoxPanel(...
        'Parent', self.Layout.MainHBox, ...
        'Title', 'Roughness' );
    
    self.Layout.ResultPanel = uix.BoxPanel(...
        'Parent', self.Layout.MainHBox, ...
        'Title', 'Result' );
    
    self.Layout.MainHBox.Widths=[-1 -2 -2 -2];
    self.Layout.MainVBox.Heights=[-1 20];
    
    % Tree
    
    self.GUI.Tree = uiw.widget.Tree(...
        'Parent', self.Layout.TreePanel, ...
        'SelectionChangeFcn', @(~,~) self.onTreeSelectionChanged ...
    );
    self.GUI.Tree.Root.Name = 'SICM Scans';
    rootIcon = fullfile(matlabroot,'toolbox','matlab','icons','reficon.gif');
    setIcon(self.GUI.Tree.Root, rootIcon);
    
    
    % Display ax
    
    self.GUI.DisplayAxis = axes('Parent', uipanel(self.Layout.DisplayPanel));
    
    self.GUI.DisplayAxisTB = axtoolbar(self.GUI.DisplayAxis, {'pan','zoomin','zoomout', 'restoreview','export'});

    axbtn = axtoolbarbtn(self.GUI.DisplayAxisTB, 'push');
    axbtn.Icon = local_cmicon();
    axbtn.Tooltip = 'Change colormap and color limits';
    axbtn.ButtonPushedFcn = @(~,~) local_select_colormap(self, self.GUI.DisplayAxis);
    
    axbtn = axtoolbarbtn(self.GUI.DisplayAxisTB, 'push');
    axbtn.Tooltip = 'Change contrast';
    axbtn.ButtonPushedFcn = @(~,~) local_launch_imcontrast(self, self.GUI.DisplayAxis);
    axbtn.Icon = local_cticon();
    
    % Roughness ax
    
    self.GUI.RoughnessAxis = axes('Parent', uipanel(self.Layout.RoughnessPanel));
    
    self.GUI.RoughnessAxisTB = axtoolbar(self.GUI.RoughnessAxis, {'pan','zoomin','zoomout', 'restoreview','export'});
    
    axbtn = axtoolbarbtn(self.GUI.RoughnessAxisTB, 'push');
    axbtn.Icon = local_cmicon();
    axbtn.Tooltip = 'Change colormap and color limits';
    axbtn.ButtonPushedFcn = @(~,~) local_select_colormap(self, self.GUI.RoughnessAxis);
    
    axbtn = axtoolbarbtn(self.GUI.RoughnessAxisTB, 'push');
    axbtn.Tooltip = 'Change contrast';
    axbtn.ButtonPushedFcn = @(~,~) local_launch_imcontrast(self, self.GUI.RoughnessAxis);
    axbtn.Icon = local_cticon();
    
    % Result ax
    
    self.GUI.ResultAxis = axes('Parent', uipanel(self.Layout.ResultPanel));
    
    % Toolbar
    
    toolbar = uitoolbar(self.Figure);
    self.Toolbar.NewMask = uipushtool(toolbar, ...
        'CData', roughnessanalyzer.app.icons.get_icon('new'), ...
        'tooltip', 'New mask' ...
    );
    self.Toolbar.DeleteMask = uipushtool(toolbar, ...
        'CData', roughnessanalyzer.app.icons.get_icon('delete'), ...
        'tooltip', 'Delete mask' ...
    );
    self.Toolbar.ModeAdd = uitoggletool(toolbar, ...
        'CData', roughnessanalyzer.app.icons.get_icon('add'), ...
        'Separator', 'on', ...
        'tooltip', 'Additive mode', ...
        'OnCallback', @(~,~) local_onSetMode(self, 'add'), ...
        'OffCallback', @(~,~) local_onSetMode(self, 'subtract') ...
    );
    self.Toolbar.ModeDelete = uitoggletool(toolbar, ...
        'CData', roughnessanalyzer.app.icons.get_icon('subtract'), ...
        'OnCallback', @(~,~) local_onSetMode(self, 'subtract'), ...
        'OffCallback', @(~,~) local_onSetMode(self, 'add'), ...
        'tooltip', 'Subtractive mode' ...
    );
    self.Toolbar.Rectangle = uitoggletool(toolbar, ...
        'Separator','on', ...
        'CData', roughnessanalyzer.app.icons.get_icon('draw-rectangle'), ...
        'OnCallback', @(~,~) local_onSetROIType(self, 'rectangle'), ...
        'OffCallback', @(~,~) local_onSetROIType(self, 'none'), ...
        'tooltip', 'Draw Rectangle ROI' ...
    );
    self.Toolbar.Ellipse = uitoggletool(toolbar, ...
        'CData', roughnessanalyzer.app.icons.get_icon('draw-ellipse'), ...
        'OnCallback', @(~,~) local_onSetROIType(self, 'ellipse'), ...
        'OffCallback', @(~,~) local_onSetROIType(self, 'none'), ...
        'tooltip', 'Draw Ellipse ROI' ...
    );
    self.Toolbar.Polygon = uitoggletool(toolbar, ...
        'CData', roughnessanalyzer.app.icons.get_icon('draw-polygon'), ...
        'OnCallback', @(~,~) local_onSetROIType(self, 'polygon'), ...
        'OffCallback', @(~,~) local_onSetROIType(self, 'none'), ...
        'tooltip', 'Draw Polygon ROI' ...
    );
    self.Toolbar.Pixel = uitoggletool(toolbar, ...
        'CData', roughnessanalyzer.app.icons.get_icon('pixel'), ...
        'OnCallback', @(~,~) local_onSetROIType(self, 'pixel'), ...
        'OffCallback', @(~,~) local_onSetROIType(self, 'none'), ...
        'tooltip', 'Draw Pixel ROI' ...
    );
end

function local_onSetMode(self, mode)
    self.Settings.Mode = mode;
    self.redraw('toolbar_mode');
end

function cmicon = local_cmicon()
    cmicon = ones(16)*64;
    cmicon(1,  4:12) = 1;
    cmicon(16, 4:12) = 1;
    cmicon(1:16,  4) = 1;
    cmicon(1:16, 12) = 1;
    for i = 2:15
        cmicon(i, 5:11) = 64 - (i-2)*64/14;
    end
end

function cticon = local_cticon()
    [xg,yg] = meshgrid(1:8,1:8);
    cticon = xg.*yg;
end

function local_onSetROIType(self, what)
    if self.IsRedrawing; return; end
    self.Settings.ROIType = what;
    self.redraw('toolbar_type');
end

function local_launch_imcontrast(self, ax)
    switch ax
        case self.GUI.DisplayAxis
            if ~isempty(self.DisplayIntensityImage)
                win = imcontrast(self.DisplayIntensityImage);
                waitfor(win);
                switch self.Settings.Display
                    case 'slope'
                        self.SlopeCLim = self.GUI.DisplayAxis.CLim;
                    case 'height'
                        self.HeightCLim = self.GUI.DisplayAxis.CLim;
                end
            end
        case self.GUI.RoughnessAxis
            if ~isempty(self.RoughnessIntensityImage)
                win = imcontrast(self.RoughnessIntensityImage);
                waitfor(win);
                self.RoughnessCLim = self.GUI.RoughnessAxis.CLim;
            end
    end
end

function local_select_colormap(self, ax)
    phutils.colormaps.ColormapSelector('OnColormapSelected', @(cm) local_set_colormap(self, ax, cm));
end
function local_set_colormap(self, ax, cm)
    colormap(ax, cm.Map);
    switch ax
        case self.GUI.RoughnessAxis
            self.RoughnessCM = cm.Map;
        case self.GUI.DisplayAxis
            switch self.Settings.Display
                case 'slope'
                    self.SlopeCM = cm.Map;
                case 'height'
                    self.HeightCM = cm.Map;
            end
    end
end