function redraw( self, varargin )
% REDRAW redraws the GUI components

    if nargin == 1
        args = {'menu', 'tree', 'display', 'roughness', 'result', ...
            'toolbar', 'toolbar_mode', 'mask', 'toolbar_type', ...
            'tree_node_selection' };
    else
        args = varargin;
    end

    for arg = args
        switch arg{1}
            case 'toolbar'
                local_draw_toolbar( self );
            case 'toolbar_mode'
                local_draw_toolbar_mode( self );
            case 'menu'
                local_draw_menu( self );
            case 'tree'
                local_draw_tree ( self );
            case 'display'
                local_draw_display( self );
            case 'roughness'    
                local_draw_roughness( self );
            case 'result'
                local_draw_result( self );
            case 'mask'
                local_draw_mask( self );
            case 'toolbar_type'
                local_draw_toolbar_type( self );
            case 'tree_node_selection'
                local_update_selected_tree_node( self );
        end
    end
end


% Local functions that do the update

function local_draw_toolbar( self )
    % First, disable all
    for field = fieldnames(self.Toolbar)'
            self.Toolbar.(field{1}).Enable = 'off';
            self.Toolbar.(field{1}).Visible = 'off';
    end
    if self.Session.isMaskSelected()
        for field = fieldnames(self.Toolbar)'
            self.Toolbar.(field{1}).Enable = 'on';
            self.Toolbar.(field{1}).Visible = 'on';
        end
    elseif ~isempty(self.Session.CurrentScan)
        for field = {'NewMask', 'ModeAdd', 'ModeDelete'}
            self.Toolbar.(field{1}).Enable = 'on';
            self.Toolbar.(field{1}).Visible = 'on';
        end
            
    end
    local_draw_toolbar_mode(self);
    local_draw_toolbar_type(self);
end
function local_draw_toolbar_mode( self )
    self.Toolbar.ModeAdd.State = strcmp(self.Settings.Mode, 'add');
    self.Toolbar.ModeDelete.State = strcmp(self.Settings.Mode, 'subtract');
end
function local_draw_toolbar_type( self )
    self.IsRedrawing = true;
    self.Toolbar.Rectangle.State = strcmp(self.Settings.ROIType, 'rectangle');
    self.Toolbar.Ellipse.State = strcmp(self.Settings.ROIType, 'ellipse');
    self.Toolbar.Polygon.State = strcmp(self.Settings.ROIType, 'polygon');
    self.Toolbar.Pixel.State = strcmp(self.Settings.ROIType, 'pixel');
    self.IsRedrawing = false;
end
function local_draw_menu( self )
    self.Menu.Display.Height.Checked = strcmp(self.Settings.Display, 'height');
    self.Menu.Display.Slope.Checked = strcmp(self.Settings.Display, 'slope');
end


function local_draw_tree( self )
% Draws the tree
    k = 0;
    for c1 = 1: numel(self.Session.Scans)
        if isempty(self.Session.Scans{c1}.TreeNode)
            k = k+1;
            tn = uiw.widget.TreeNode( ...
                'Parent', self.GUI.Tree.Root, ...
                'Name', self.Session.Scans{c1}.Name ...
            );  
  
            tn.UIContextMenu = self.getScanNodeContextMenu(c1);
            
            self.Session.Scans{c1}.TreeNode = numel(self.GUI.Tree.Root);
            setIcon(tn, fullfile(matlabroot,'toolbox','matlab','icons','unknownicon.gif'));
        
            for c2 = 1:numel(self.Session.Scans{c1}.Masks)
                if isempty(self.Session.Scans{c1}.Masks{c2}.TreeNode)
                    %%% Add mask.
                end
            end
        end
    end
    local_update_selected_tree_node( self );
end

function local_update_selected_tree_node( self )
    scan = self.Session.getCurrentScan();
    if isempty(scan)
        self.GUI.Tree.SelectedNodes = [];
        return
    end
    if self.Session.isMaskSelected()
        self.GUI.Tree.SelectedNodes = self.GUI.Tree.Root.Children(self.Session.CurrentScan).Children(scan.CurrentMask);
    else
        self.GUI.Tree.SelectedNodes = self.GUI.Tree.Root.Children(self.Session.CurrentScan);
    end
end
function local_draw_display(self)
    scan = self.Session.getCurrentScan();
    
    if isempty(scan)
        return 
    end
    
    switch self.Settings.Display
        case 'height'
            self.DisplayIntensityImage = imagesc(self.GUI.DisplayAxis, scan.SICMScan.zdata_grid);
            colormap(self.GUI.DisplayAxis, self.HeightCM);
            if ~isempty(self.HeightCLim)
                self.GUI.DisplayAxis.CLim = self.HeightCLim;
                
            end
        case 'slope'
            self.DisplayIntensityImage = imagesc(self.GUI.DisplayAxis, scan.SICMScan.slope());
            colormap(self.GUI.DisplayAxis, self.SlopeCM);
            if ~isempty(self.SlopeCLim)
                self.GUI.DisplayAxis.CLim = self.SlopeCLim;
                
            end
    end
    self.GUI.DisplayAxisTB.Visible = true;
    local_draw_mask(self);
    
end

function local_draw_mask( self )
    scan = self.Session.getCurrentScan();
    if isempty(scan); return; end
    mask = scan.getCurrentMask();
    
    if isempty(mask)
        return
    end
    
    oldnextplot = self.GUI.DisplayAxis.NextPlot;
    self.GUI.DisplayAxis.NextPlot = 'add';
    delete(self.DisplayMask);
    switch self.Settings.Display
        case 'slope'
            color = mask.SlopeColor;
            opacity = mask.SlopeOpacity;
        case 'height'
            color = mask.HeightColor;
            opacity = mask.HeightOpacity;
    end
    maskdata = ones(size(scan.SICMScan.zdata_grid, 1), size(scan.SICMScan.zdata_grid, 2), 3);
    
    for k = 1:3
        maskdata(:,:,k) = maskdata(:,:,k) * color(k);
    end
    self.DisplayMask = image(self.GUI.DisplayAxis, maskdata);
    self.DisplayMask.AlphaData = mask.Mask * opacity;
    self.GUI.DisplayAxis.NextPlot = oldnextplot;
    
    if ~self.RoughnessIsDirty
        oldnextplot = self.GUI.RoughnessAxis.NextPlot;
        self.GUI.RoughnessAxis.NextPlot = 'add';
        color = mask.RoughnessColor;
        maskdata = ones(size(scan.SICMScan.zdata_grid, 1), size(scan.SICMScan.zdata_grid, 2), 3);
        for k = 1:3
            maskdata(:,:,k) = maskdata(:,:,k) * color(k);
        end
        delete(self.RoughnessMask);
        self.RoughnessMask = image(self.GUI.RoughnessAxis, maskdata);
        self.RoughnessMask.AlphaData = mask.Mask * mask.RoughnessOpacity;
        self.GUI.RoughnessAxis.NextPlot = oldnextplot;
    end
end

function local_draw_roughness(self)
    scan = self.Session.getCurrentScan();
    if isempty(scan); return; end
    if self.RoughnessIsDirty
        img = roughnessanalyzer.app.icons.get_icon('clock');
        himg = image(self.GUI.RoughnessAxis, img);
        cm = uicontextmenu(self.Figure);
        uimenu(cm, 'Text', 'Compute Roughness', 'Callback', @(~,~) local_compute_roughness(self));
        himg.UIContextMenu = cm;
        self.GUI.RoughnessAxisTB.Visible = false;
    else 
       self.RoughnessIntensityImage = imagesc(self.GUI.RoughnessAxis, scan.Roughness);
       colormap(self.GUI.RoughnessAxis, self.RoughnessCM);
       if ~isempty(self.RoughnessCLim)
           self.GUI.RoughnessAxis.CLim = self.RoughnessCLim;
       end
       self.GUI.RoughnessAxisTB.Visible = true;
    end
end

function local_draw_result( self )
end



function local_compute_roughness(self)
    scan = self.Session.getCurrentScan();
    if isempty(scan); return; end
    scan.Roughness = ones(size(scan.SICMScan.zdata_grid)).*NaN;
    halfwidth = ceil((self.Settings.RoughnessWidth-1)/2);
    pb = phutils.gui.ProgressBar();
    scan.Roughness(halfwidth+1:end-halfwidth,:) = scan.SICMScan.roughness1D(...
        self.Settings.RoughnessWidth, ...
        self.Settings.RoughnessDegreePolynomial, ...
        'Callback', @(c,t) local_setfrac(pb, c/t) ...
    );
    delete(pb);
    self.RoughnessIsDirty = false;
    self.redraw('mask');
end

function local_setfrac(pb, f)
    pb.Fraction = f;
    pb.IncbarColor = [(1-f)*.65, f*0.65, 0];
end