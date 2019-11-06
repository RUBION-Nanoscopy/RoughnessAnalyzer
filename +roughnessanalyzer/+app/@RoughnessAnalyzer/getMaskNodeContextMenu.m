function cm = getMaskNodeContextMenu(self, nscan, nmask)
% GETMASKNODECONTEXTMENU returns the context menu for mask node nmask of
% scan nscan
    cm = uicontextmenu(self.Figure);
    uimenu(cm, 'Text', 'Rename Mask', 'Callback', @(~,~) self.onRenameMask(nscan, nmask));
    uimenu(cm, 'Text', 'Invert', 'Callback', @(~, ~) local_onInvertMask(self, nscan, nmask));
    uimenu(cm, 'Separator', 'on', 'Text', 'Change Properties', 'Callback', @(~, ~) self.onChangeMaskProperties(nscan, nmask));
    
end


function local_onInvertMask(self, nscan, nmask)
    mask = self.Session.Scans{nscan}.Masks{nmask};
    self.Session.Scans{nscan}.Masks{nmask}.Mask = ~mask.Mask;
    self.redraw('mask');
end