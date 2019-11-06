classdef RoughnessAnalyzer < uiw.abstract.SingleSessionApp
    properties (SetAccess = protected, GetAccess = public)
        Layout = struct()
        GUI = struct()
        Toolbar = struct()
        Settings = struct()
        Pan
        Zoom
        SlopeCLim
        HeightCLim
        RoughnessCLim
        SlopeCM
        HeightCM
        RoughnessCM
        SelectedScan
        SelectedMask
    end
    %% Listeners 
    properties (Transient, Access=private)
        ModelChangedListener event.listener %Listener to model changes
        
        InMouseInEvent 
        DisplayPanelPosition (1,4) double
        RoughnessPanelPosition (1,4) double
        
        DisplayIntensityImage
        RoughnessIntensityImage
        DisplayMask
        RoughnessMask
        IsRedrawing = false;
        
    end %properties
    
    properties(AbortSet, SetAccess = protected, GetAccess = public)
        RoughnessIsDirty = true; 
    end
    %% Application Settings
    properties (Constant, Access=protected)
        
        % Abstract in superclass
        AppName char = 'Roughness Analyzer'
        
    end
    
    %% Methods in separate files with custom permissions
    methods (Access=protected)
        create(self);
        assignMenuCBs(self)
        redraw(self, varargin);
        redrawTreeFull(self);
        handleMouseEvents(self);
        storePanelPositions(self);
        
        cm = getMaskNodeContextMenu(self, nscan, nmask);
        cm = getScanNodeContextMenu(self, nscan);
    end

    %% Menu Callbacks   
    methods (Access = protected)
        onImportSICMScan(self);
        onImportSICMScanFromWorkspace(self);   
        onImportSICMScanAsMask(self);
        onImportMaskFromFile(self);
        onImportMaskFromWorkspace(self);
        
        onRenameScan(self, k);
        onRenameMask(self, k, l);
    end
    
    %% Mouse Callbacks
    methods (Access = protected)
        onMouseIn(self, ax)
        onMouseOut(self, ax)
    end
    
    %% Widget callbacks
    methods (Access = protected)
        onTreeSelectionChanged(self);
    end
    
    %% Constructor
    methods
        function self = RoughnessAnalyzer( varargin )
            self@uiw.abstract.SingleSessionApp('Visible', 'off');
            self.SlopeCM = gray(256);
            self.HeightCM = parula(256);
            self.RoughnessCM = jet(256);
            
            self.SelectedMask = [];
            self.SelectedScan = [];
            
            self.FileSpec = {'*.ra.mat', 'Roughness Analyzer MAT files'};
            self.loadSettings();
            self.create();
            self.assignMenuCBs();
            self.assignPVPairs(varargin{:});
            self.IsConstructed = true;
            self.redraw();
            self.handleMouseEvents();
            self.Pan = pan(self.Figure);
            self.Zoom = zoom(self.Figure);
            self.Visible = 'on';
        end
        
        function set.RoughnessIsDirty(self, val)
            self.RoughnessIsDirty = val;
            self.redraw('roughness');
        end
    end
    
    methods
        function statusOk = saveSessionToFile(self,sessionPath,sessionObj)   
            [p, fn, ext] = fileparts(sessionPath);
            if strcmp(ext, '.mat')
                [~, ~, ext2] = fileparts(fn);
                if ~strcmp(ext2,'.ra')
                    sessionPath = fullfile(p, sprintf('%s.ra.mat', fn'));
                end
            end
            statusOk = self.saveSessionToFile@uiw.abstract.SingleSessionApp(sessionPath,sessionObj);
        end
    end
    
    %% protected methods
    methods ( Access = protected )
        
        function onSessionSet( self, ~ )
            self.ModelChangedListener = event.listener(self.Session,...
                'ModelChanged',@(h,e)onModelChanged(self,e));
            self.ModelChangedListener.Recursive = true;
            self.redrawTreeFull();
        end
        function session = createSession( self )
            session = roughnessanalyzer.data.Data();
        end
        
        function addScanToSession(self, scan)
            sc = self.Session.addScan(scan);
            tn = uiw.widget.TreeNode('Parent', self.GUI.Tree.Root, ...
                'Name', sc.Name);
            sc.TreeNode = numel(self.GUI.Tree.Root.Children);
            setIcon(tn, fullfile(matlabroot,'toolbox','matlab','icons','unknownicon.gif'));
            self.IsDirty = true;
            self.Session.CurrentScan = numel(self.Session.Scans);
            
            self.GUI.Tree.SelectedNodes = tn;
                
            %self.RoughnessIsDirty = isempty(sc.Roughness);
            %self.redraw('roughness');
        end
        
        function addMaskToScan(self, varargin)
            scan = [];
            mask = [];
            if nargin > 1
                for c1 = 1:2:numel(varargin)
                    if strcmp(varargin{c1}, 'Scan')
                        scan = varargin{c1+1};
                    end
                    if strcmp(varargin{c1}, 'Mask')
                        mask = varargin{c1+1};
                    end
                end
            end
            
            if isempty(scan)
                if ~isempty(self.GUI.Tree.SelectedNodes)
                    if self.GUI.Tree.SelectedNodes(1).Parent == self.GUI.Tree.Root
                        scan = self.getScanForNode(self.GUI.Tree.SelectedNodes(1));
                    else
                        scan = self.getScanForNode(self.GUI.Tree.SelectedNodes(1).Parent);
                    end
                end
            end
            
            if isempty(mask)
                switch self.Settings.Mode
                    case 'add'
                        mask = zeros(size(scan.SICMScan.zdata_grid));
                    case 'subtract'
                        mask = ones(size(scan.SICMScan.zdata_grid));
                end
            end
            scan.addMask(mask);
            tn = uiw.widget.TreeNode('Parent', self.GUI.Tree.Root.Children(scan.TreeNode), 'Name', scan.Masks{end}.Name);
            self.GUI.Tree.Root.Children(scan.TreeNode).expand();
            self.GUI.Tree.SelectedNodes = tn;
            tn.UIContextMenu = self.getMaskNodeContextMenu(scan.TreeNode, numel(scan.Masks));
            setIcon(tn, fullfile(matlabroot, 'toolbox', 'images', 'icons', 'DrawPolygon_16.png'));
            self.redraw('toolbar', 'display');
        end
        
        function onModelChanged( self, event )
            switch event.EventType
                case 'ScansChanged'
                    switch event.Property 
                        case 'ScanAdded'
                            self.redraw('tree');
                            self.GUI.Tree.SelectedNodes = self.GUI.Tree.Root.Children(end);
                            self.Session.CurrentScan = numel(self.Session.Scans);
                            
                        case 'CurrentScan'
                            self.redraw('display', 'toolbar');
                            scan = self.Session.getCurrentScan();
                            if isempty(scan); return; end
                            if isempty(scan.Roughness) 
                                if ~self.RoughnessIsDirty
                                    self.RoughnessIsDirty = true;
                                    % will trigger the redraw
                                else
                                    self.redraw('roughness');
                                end
                            else
                               if ~self.RoughnessIsDirty
                                   % manually trigger redraw
                                   self.redraw('roughness');
                               else
                                   self.RoughnessIsDirty = false;
                                   % will trigger redraw
                               end
                            end
                            
                    end
                case 'MaskChanged'
                    switch event.Property 
                        case 'CurrentMask'
                            self.redraw('mask');
                    end
                case 'MaskDeleted'
                    switch event.Property 
                        case 'CurrentMask'
                            % There might be a better way to implement
                            % this...
                            delete(self.GUI.Tree.SelectedNodes);
                            self.redraw('tree_node_selection');
                    end
            end
            
        end
        
        function loadSettings( self )
            [directory,~,~] = fileparts(mfilename('fullpath'));
            fn = [directory filesep 'settings.mat'];
            if exist(fn , 'file')
                filevars = load(fn);
                self.Settings = filevars.settings;
            else
                self.Settings = struct(...
                    'Display', 'slope', ...
                    'Mode', 'add', ...
                    'ROIType', 'polygon', ...
                    'RoughnessWidth', 11, ...
                    'RoughnessDegreePolynomial', 5 ...
                );
            end
        end
        function onResized(self)
            self.onResized@uiw.abstract.SingleSessionApp();
            self.storePanelPositions();
        end
        function scan = getScanForNode(self, node)
            for k = 1:numel(self.GUI.Tree.Root.Children)
                if self.GUI.Tree.Root.Children(k) == node
                    scan = self.Session.Scans{k};
                    return
                end
            end
            
        end
    end
end