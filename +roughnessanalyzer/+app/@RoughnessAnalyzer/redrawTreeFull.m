function redrawTreeFull(self)
%REDRAWTREEFULL Clears and redraws the tree
if ~self.IsConstructed; return; end
delete(self.GUI.Tree.Root.Children);
for k = 1:numel(self.Session.Scans)
    tn = uiw.widget.TreeNode('Parent', self.GUI.Tree.Root, ...
        'Name', self.Session.Scans{k}.Name );
    tn.setIcon(fullfile(matlabroot,'toolbox','matlab','icons','unknownicon.gif'));
    tn.UIContextMenu = self.getScanNodeContextMenu(k);
    for l = 1:numel(self.Session.Scans{k}.Masks)
        masknode = uiw.widget.TreeNode('Parent', tn, ...
            'Name', self.Session.Scans{k}.Masks{l}.Name);
        masknode.UIContextMenu = self.getMaskNodeContextMenu(k, l);
        masknode.setIcon(fullfile(matlabroot, 'toolbox', 'images', 'icons', 'DrawPolygon_16.png'));
    end
end