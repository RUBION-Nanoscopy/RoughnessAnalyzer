function onRenameScan(self, k)
% ONRENAMESCAN Callback for contextmenu of Scan-node in tree
    name = inputdlg({'New name:'}, 'Rename scan', [1 30], {self.Session.Scans{k}.Name});
    if ~isempty(name)
        self.Session.Scans{k}.Name = name{1};
        self.GUI.Tree.Root.Children(k).Name = name{1};
    end
    self.IsDirty = true;