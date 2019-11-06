function renameScan(self, n)
    name = inputdlg({'New name:'}, 'Rename scan', [1 30], {self.Session.Scans{n}.Name});
    if ~isempty(name)
        self.Session.Scans{n}.Name = name{1};
        self.GUI.Tree.Root.Children(n).Name = name{1};
    end
end