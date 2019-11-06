function onMouseOut(self, ax)
% ONMOUSEIN Fired, when the mouse leaves the area of the panel around an
% axis
    hRoi = findobj(self.Figure, 'Tag', 'CurrentROI');
    if ~isempty(hRoi)
        delete(hRoi);
        uiresume();
    end
end