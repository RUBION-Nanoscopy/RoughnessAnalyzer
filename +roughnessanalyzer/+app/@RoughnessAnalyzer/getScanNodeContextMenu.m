function cm = getScanNodeContextMenu(self, nscan)
    cm = uicontextmenu(self.Figure);
    uimenu(cm, 'Text', 'Rename Scan', 'Callback', @(~,~) self.onRenameScan(nscan));
    uimenu(cm, 'Text', 'Inspect Masks', 'Callback', @(~,~) self.onInspectMasks(nscan));
end