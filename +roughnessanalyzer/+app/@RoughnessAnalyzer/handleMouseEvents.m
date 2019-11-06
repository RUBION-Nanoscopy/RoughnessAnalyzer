function handleMouseEvents(self)
% HANDLEMOUSEEVENTS setup the mouse-over and mouse-out events for the two axes
    self.storePanelPositions();
    self.Figure.WindowButtonMotionFcn = @(~,~) local_fire_callbacks(self);
    
end

function local_fire_callbacks(self)
    cp = self.Figure.CurrentPoint;
    
    is_over_display_panel = cp(1) > self.DisplayPanelPosition(1) ...
        && cp(2) > self.DisplayPanelPosition(2) ... 
        && cp(1) < self.DisplayPanelPosition(1) + self.DisplayPanelPosition(3) ...
        && cp(2) < self.DisplayPanelPosition(2) + self.DisplayPanelPosition(4) - self.Layout.DisplayPanel.TitleHeight;
    is_over_roughness_panel = cp(1) > self.RoughnessPanelPosition(1) ...
        && cp(2) > self.RoughnessPanelPosition(2) ... 
        && cp(1) < self.RoughnessPanelPosition(1) + self.RoughnessPanelPosition(3) ...
        && cp(2) < self.RoughnessPanelPosition(2) + self.RoughnessPanelPosition(4) - self.Layout.RoughnessPanel.TitleHeight;
    
    if isempty(self.InMouseInEvent)
        if is_over_display_panel
            self.InMouseInEvent = self.GUI.DisplayAxis;
            self.onMouseIn(self.GUI.DisplayAxis);
        end
        if is_over_roughness_panel
            self.InMouseInEvent = self.GUI.RoughnessAxis;
            self.onMouseIn(self.GUI.RoughnessAxis);
        end
    else
        
       if ~is_over_display_panel & self.InMouseInEvent == self.GUI.DisplayAxis
           self.InMouseInEvent = [];
           self.onMouseOut(self.GUI.DisplayAxis);
       end
       if ~is_over_roughness_panel & self.InMouseInEvent == self.GUI.RoughnessAxis
            self.InMouseInEvent = [];
            self.onMouseIn(self.GUI.RoughnessAxis);
        end
    end
end