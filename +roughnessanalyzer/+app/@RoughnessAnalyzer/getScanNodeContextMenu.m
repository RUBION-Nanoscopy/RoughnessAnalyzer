function cm = getScanNodeContextMenu(self, nscan)
    cm = uicontextmenu(self.Figure);
    uimenu(cm, 'Text', 'Rename Scan', 'Callback', @(~,~) self.onRenameScan(nscan));
end