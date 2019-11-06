function onTreeSelectionChanged(self)
% ONTREESELECTIONCHANGED called, when the selection on the tree changes

    if self.GUI.Tree.SelectedNodes == self.GUI.Tree.Root
        self.Session.CurrentScan = [];
        return
    end
    
    % find index of selected node in parent
    idx = find(self.GUI.Tree.SelectedNodes.Parent.Children == self.GUI.Tree.SelectedNodes, 1, 'first');
    
    % if the parent is the root node, a scan was selected
    
    if self.GUI.Tree.SelectedNodes.Parent == self.GUI.Tree.Root
        self.Session.CurrentScan = idx;
    else % a mask was selected, we need to find out the corresponding scan
        sidx = find(self.GUI.Tree.Root.Children == self.GUI.Tree.SelectedNodes.Parent, 1, 'first');
        self.Session.Scans{sidx}.CurrentMask = idx;
        if self.Session.CurrentScan ~= sidx
            self.Session.CurrentScan = sidx;
        else
            self.redraw('mask');
        end
        
    end