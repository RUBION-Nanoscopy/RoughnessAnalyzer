function onMouseIn(self, ax)
% ONMOUSEIN Fired, when the mouse enters the area of the panel around an
% axis

    % Check if the mouse is over the roughness axis but no roughness has
    % been computed
    
    if ax == self.GUI.RoughnessAxis & self.RoughnessIsDirty
        return
    end

    if self.Session.isMaskSelected() ...
            && strcmp(self.Zoom.Enable, 'off') ...
            && strcmp(self.Pan.Enable, 'off') ...
            && ~strcmp(self.Settings.ROIType, 'none')
        switch self.Settings.ROIType
            case 'polygon'
                mkroi = @drawpolygon;
            case 'rectangle'
                mkroi = @drawrectangle;
            case 'ellipse'
                mkroi = @drawellipse;
            case 'pixel'
                mkroi = @drawpoint;
        end
        roi = mkroi(ax, 'Tag', 'CurrentROI');
        if isvalid(roi)
            roi.Tag = '';
            self.Session.changeMask(roi, self.Settings.Mode);
            delete(roi);
            self.onMouseIn(ax); % Recursion!
        end
    end
end