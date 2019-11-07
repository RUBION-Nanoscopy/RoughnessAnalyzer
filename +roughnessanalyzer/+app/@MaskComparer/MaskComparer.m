classdef MaskComparer < uiw.mixin.AssignPVPairs
    % App that allows to compare a set of masks
    % I'll try this as an uifigure...
    properties (Access = public)
        Data
        CLim
        CM
        Masks
        onApply
    end
    properties(Constant, Access=protected)
        AppName = 'Mask Cleanup'
    end
    properties (SetAccess = protected, GetAccess = public)
        GUI = struct()
        Layout = struct()
        
        CurrMask1
        CurrMask2
        
        DataImg
        Mask1Img
        Mask2Img
        OverlapImg
        Figure
        
        IsConstructing
        IsDirty = false
        
        
    end
    
    methods 
        %% Constructor
        function self = MaskComparer( varargin )
            self.Figure = uifigure('visible','off','Name', self.AppName);
            self.Figure.Position(3:4) = [1200 600];
            self.assignPVPairs(varargin{:});
            if numel(self.Masks) < 2
                warndlg('At least two masks must be given to compare them. Will not launch Mask Comparison GUI.', 'Warning');
                delete(self);
                return
            end
            self.IsConstructing = true;
            self.create();
            self.draw_data();
            self.assign_callbacks();
            self.IsConstructing = false;
            self.Figure.Visible = 'on';
            
        end
    end
    
    methods (Access = protected)
        
        %% GUI-Related methods
        function create(self)
            % CREATE creates the GUI
            
            % Main Layout is a grid with three columns and two rows
            self.Layout.MainGrid = uigridlayout(self.Figure, [2,3]);
            self.Layout.MainGrid.RowHeight = {'1x', 60};
            self.Layout.MainGrid.ColumnWidth= {'1x', '1x', 150};
            
            % The last row only contains the buttons for cancel etc., lets
            % do this first
            
            self.Layout.MainButtonsGrid = uigridlayout(self.Layout.MainGrid, [1,4]);
            self.Layout.MainButtonsGrid.RowHeight = {'1x'};
            self.Layout.MainButtonsGrid.ColumnWidth = {'1x',150,150,150};
            self.Layout.MainButtonsGrid.Layout.Row = 2;
            self.Layout.MainButtonsGrid.Layout.Column = [1,3];
            
            % add the buttons
            
            self.GUI.Buttons.Main.Cancel = uibutton(self.Layout.MainButtonsGrid, 'Text', 'Cancel');
            self.GUI.Buttons.Main.Cancel.Layout.Column = 2;
            self.GUI.Buttons.Main.Apply = uibutton(self.Layout.MainButtonsGrid, 'Text', 'Apply');
            self.GUI.Buttons.Main.Apply.Layout.Column = 3;
            self.GUI.Buttons.Main.OK = uibutton(self.Layout.MainButtonsGrid, 'Text', 'OK');
            self.GUI.Buttons.Main.OK.Layout.Column = 4;
            
            % Next, the buttons on the right 
            
            self.Layout.ActionButtonsGrid = uigridlayout(self.Layout.MainGrid,[2,1]);
            self.Layout.ActionButtonsGrid.Layout.Column = 3;
            self.Layout.ActionButtonsGrid.Layout.Row = 1;
            self.Layout.ActionButtonsGrid.ColumnWidth = {'1x'};
            self.Layout.ActionButtonsGrid.RowHeight = {150, '1x'};
            
            % add panel to upper row
            
            self.GUI.ActionButtonPanel = uipanel(self.Layout.ActionButtonsGrid, 'Title', 'Remove overlap from');
            
            
            % make a grid of three rows and one column for the buttons
            
            self.Layout.ActionButtonsInnerGrid = uigridlayout(self.GUI.ActionButtonPanel,[3,1]);
            
            % add buttons
            
            self.GUI.Buttons.Action.M1 = uibutton(self.Layout.ActionButtonsInnerGrid);
            self.GUI.Buttons.Action.M2 = uibutton(self.Layout.ActionButtonsInnerGrid);
            self.GUI.Buttons.Action.M1M2 = uibutton(self.Layout.ActionButtonsInnerGrid, 'Text','both');
            
            % next, the axis with the display buttons
            
            self.GUI.AxPanel = uipanel(self.Layout.MainGrid, 'Title', 'Data display');
            self.GUI.AxPanel.Layout.Row = 1;
            self.GUI.AxPanel.Layout.Column = 2;
            
            % add a 2-row grid to the panel, 3 cols (for three buttons)
            
            self.Layout.AxGrid = uigridlayout(self.GUI.AxPanel, [2,3]);
            self.Layout.AxGrid.RowHeight = {'1x', 30};
            % add ax
            
            self.GUI.Axes = uiaxes(self.Layout.AxGrid);
            self.GUI.Axes.Layout.Row = 1;
            self.GUI.Axes.Layout.Column = [1,3];
            
            % Add buttons
            
            
            
            self.GUI.Buttons.Display.M1 = uibutton( self.Layout.AxGrid, 'state' );
            self.GUI.Buttons.Display.M1.Layout.Row = 2;
            self.GUI.Buttons.Display.M1.Layout.Column = 1;
            self.GUI.Buttons.Display.M2 = uibutton( self.Layout.AxGrid, 'state' );
            self.GUI.Buttons.Display.M2.Layout.Row = 2;
            self.GUI.Buttons.Display.M2.Layout.Column = 2;
            self.GUI.Buttons.Display.Overlap = uibutton( self.Layout.AxGrid, 'state', 'Text', 'Overlap', 'Value', true); 
            self.GUI.Buttons.Display.Overlap.Layout.Row = 2;
            self.GUI.Buttons.Display.Overlap.Layout.Column = 3;
            
            
            % Complicated thing: The cross table :)
            self.GUI.CrossPanel = uipanel(self.Layout.MainGrid, 'Title', 'Masks cross table');
            self.GUI.CrossPanel.Layout.Column = 1;
            self.GUI.CrossPanel.Layout.Row = 1;
            n = numel(self.Masks);
            
            self.Layout.CrossGrid = uigridlayout(self.GUI.CrossPanel, [n n]);
            
            
            % I will plot Mask 1 .. end-1 in the rows
            rows = 1:n-1;
            % and Mask 2 .. end in the cols
            cols = 2:n;
            
            % First, do the labels
            for k = 1:n-1
                % Label in column
                l = uilabel(self.Layout.CrossGrid, 'Text', self.Masks{k+1}.Name);
                l.Layout.Row = 1;    
                l.Layout.Column = k+1;    
                l.HorizontalAlignment = 'center';
                l.VerticalAlignment = 'bottom';   
                % Label in row
                l = uilabel(self.Layout.CrossGrid, 'Text', self.Masks{k}.Name);
                l.Layout.Row = k+1;    
                l.Layout.Column = 1;    
                l.HorizontalAlignment = 'right';
                l.VerticalAlignment = 'center';   
            end
            
            for r = rows
                for c = cols
                    
                    if r < c
                        m1 = self.Masks{r}.Mask;
                        m2 = self.Masks{c}.Mask;
                        b = uibutton('Parent', self.Layout.CrossGrid, 'Text', 'Compare');
                        b.Layout.Row = r+1;
                        b.Layout.Column = c;
                        if any(any(m1 & m2))
                            b.BackgroundColor = [.8 0 0];
                        else
                            b.BackgroundColor = [0 .8 0];
                        end
                        self.GUI.Buttons.CrossPanel.(sprintf('Pr%gc%g',r,c)) = b;
                    end
                    
                end
            end
            
            
        end
        
        function assign_callbacks(self)
            % ASSIGN_CALLBACKS Assigns callbacks to clickable GUI elements
            
            self.Figure.CloseRequestFcn = @(~,~) self.on_cancel();
            self.GUI.Buttons.Main.Cancel.ButtonPushedFcn = @(~,~) self.on_cancel();
            self.GUI.Buttons.Main.Apply.ButtonPushedFcn =  @(~,~) self.on_apply();
            self.GUI.Buttons.Main.OK.ButtonPushedFcn =     @(~,~) self.on_OK();
            
            self.GUI.Buttons.Action.M1.ButtonPushedFcn =   @(~,~) self.on_remove(1);
            self.GUI.Buttons.Action.M2.ButtonPushedFcn =   @(~,~) self.on_remove(2);
            self.GUI.Buttons.Action.M1M2.ButtonPushedFcn = @(~,~) self.on_remove(0);
            
            
            self.GUI.Buttons.Display.M1.ValueChangedFcn =       @self.on_display;
            self.GUI.Buttons.Display.M2.ValueChangedFcn =       @self.on_display;
            self.GUI.Buttons.Display.Overlap.ValueChangedFcn =  @self.on_display;
            
            n = numel(self.Masks);
            
            rows = 1:n-1;
            cols = 2:n;
            
            for r = rows
                for c = cols
                    self.GUI.Buttons.CrossPanel.(sprintf('Pr%gc%g',r,c)).ButtonPushedFcn = @(~,~) self.compare_masks(r, c);
                end
            end
        end
        
        function draw_data(self)
            % DRAW_DATA draws the Data
            if ~isempty(self.Data)
                self.DataImg = imagesc(self.GUI.Axes, self.Data);
                axis(self.GUI.Axes, 'image');
                if ~isempty(self.CLim)
                    self.GUI.Axes.CLim = self.CLim;
                end
                if ~isempty(self.CM)
                    colormap(self.GUI.Axes, self.CM);
                end
            end
        end
        
        function redraw(self)
            self.GUI.Buttons.Display.M1.Text = self.Masks{self.CurrMask1}.Name;
            self.GUI.Buttons.Display.M2.Text = self.Masks{self.CurrMask2}.Name;
            
            self.GUI.Buttons.Action.M1.Text = self.Masks{self.CurrMask1}.Name;
            self.GUI.Buttons.Action.M2.Text = self.Masks{self.CurrMask2}.Name;
            
            n = numel(self.Masks);
            
            rows = 1:n-1;
            cols = 2:n;
            
            for r = rows
                for c = cols
                    if any(any(self.Masks{r}.Mask & self.Masks{c}.Mask))
                        self.GUI.Buttons.CrossPanel.(sprintf('Pr%gc%g',r,c)).BackgroundColor = [.8 0 0];
                    else
                        self.GUI.Buttons.CrossPanel.(sprintf('Pr%gc%g',r,c)).BackgroundColor = [0 .8 0];
                    end
                end
            end
        end
        
        function redraw_masks(self)
            self.Mask1Img.Visible = 'off';
            self.Mask2Img.Visible = 'off';
            self.OverlapImg.Visible = 'off';
            for n = fieldnames(self.GUI.Buttons.Display)'
                if self.GUI.Buttons.Display.(n{1}).Value
                    switch n{1}
                        case 'M1'
                            self.Mask1Img.Visible = 'on';
                        case 'M2'
                            self.Mask2Img.Visible = 'on';
                        case 'Overlap'
                            self.OverlapImg.Visible = 'on';
                    end
                    break
                end
            end
        end
        
        
        %% Button Callbacks
        function on_cancel(self)
            % ON_CANCEL Callback for Cancel button and winCloseReq
            if (self.IsDirty & self.prompt_for_cancel()) | ~self.IsDirty
                self.close();
            end
        end
        
        function on_apply(self)
            % ON_APPLY Callback for Apply Button
            if self.IsDirty
                self.apply()
            end
        end
        
        function on_OK( self )
            % ON_OK Callback for OK Button
            if self.IsDirty
                self.apply()
            end
            self.close();
        end
        
        function on_display(self, h, e)
            if ~e.Value 
                h.Value = true;
                return
            end
            for b = fieldnames(self.GUI.Buttons.Display)'
                if self.GUI.Buttons.Display.(b{1}) ~= h
                    self.GUI.Buttons.Display.(b{1}).Value = false;
                end
            end
            self.redraw_masks();
        end
        
        function on_remove( self, which )
            m1 = self.Masks{self.CurrMask1}.Mask;
            m2 = self.Masks{self.CurrMask2}.Mask;
            
            overlap = m1 & m2;
            
            if ~any(overlap(:))
                return
            end
            
            if which == 0 || which == 1
                self.Masks{self.CurrMask1}.Mask = m1 - overlap;
            end
            if which == 0 || which == 2
                self.Masks{self.CurrMask2}.Mask = m2 - overlap;
            end   
            self.IsDirty = true;
            self.redraw();
            
            % generate masks from scratch

            self.compare_masks(self.CurrMask1,self.CurrMask2);
        end
        
        %% App Controls
        function apply(self)
            % APPLY Apply the data
            self.onApply(self.Masks);
            self.IsDirty = false;
        end
        
        function close(self)
            % CLOSE Close the app
            delete(self.Figure);
            delete(self);
        end
        
        function tf = prompt_for_cancel(self)
            
            options = {...
                'Apply changes and quit', ...
                'Quit App', ...
                'Abort cancelation' ...
            };
            selection = uiconfirm(self.Figure,...
                'The masks have been changed. If your cancel the app now, the changes will get lost.', ...
                'Confirm cancelation', ...
                'Options', options, ...
                'DefaultOption', 1, 'CancelOption', 3, ...
                'Icon', 'warning' ...
            );
        
            switch selection
                case options{1}
                    self.apply();
                    tf = true;
                case options{2}
                    tf = true;
                case options{3}
                    tf = false;
            end
            
        end
        %% Showing and editing the masks
        
        function compare_masks(self, r, c)
            % COMPAREMASK assigns the masks with number r and c as the
            % current data
            self.CurrMask1 = r;
            self.CurrMask2 = c;
            
            try
                delete(self.Mask1Img);
                delete(self.Mask2Img);
                delete(self.OverlapImg);
            catch
            end
            
            sz = size(self.Masks{self.CurrMask1}.Mask);
            
            maskdata = ones(sz(1), sz(2), 3);
    
            color = [.8 0 0];
            for k = 1:3
                maskdata(:,:,k) = maskdata(:,:,k) * color(k);
            end
            
            onp = self.GUI.Axes.NextPlot;
            self.GUI.Axes.NextPlot = 'add';
            
            self.Mask1Img = image(self.GUI.Axes, maskdata, 'Visible','off');
            self.Mask2Img = image(self.GUI.Axes, maskdata, 'Visible','off');            
            self.OverlapImg = image(self.GUI.Axes, maskdata, 'Visible','off');    
            
            self.GUI.Axes.NextPlot = onp;
            
            self.Mask1Img.AlphaData = (self.Masks{self.CurrMask1}.Mask) * .5;
            self.Mask2Img.AlphaData = (self.Masks{self.CurrMask2}.Mask) * .5;
            self.OverlapImg.AlphaData = (self.Masks{self.CurrMask1}.Mask & self.Masks{self.CurrMask2}.Mask) * .5;
            
            self.redraw();
            self.redraw_masks();
        end
        
        
    end
end