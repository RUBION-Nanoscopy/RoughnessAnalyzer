function onRenameMask(self, k, l)
% ONRENAMEMASK Callback for contextmenu of Mask-node in tree
    name = inputdlg({'New name:'}, 'Rename mask', [1 30], {self.Session.Scans{k}.Masks{l}.Name});
    if ~isempty(name)
        self.Session.Scans{k}.Masks{l}.Name = name{1};
        self.GUI.Tree.Root.Children(k).Children(l).Name = name{1};
    end
    self.IsDirty = true;