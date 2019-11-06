function assignMenuCBs(self)
% assignMenuCBs   assigns the menu callbacks
% NOTE: The File Menu is handled by the parent class
    self.Menu.Import.SICMScan.Callback = @(~,~) self.onImportSICMScan;
    self.Menu.Import.FromWorkspace.Callback = @(~,~) self.onImportSICMScanFromWorkspace;
    self.Menu.Import.SICMDataAsMask.Callback = @(~,~) self.onImportSICMScanAsMask;
    self.Menu.Import.MaskFromFile.Callback = @(~,~) self.onImportMaskFromFile;
    self.Menu.Import.MaskFromWorkspace.Callback = @(~,~) self.onImportMaskFromWorkspace;
    
    self.Menu.Display.Height.Callback = @(~, ~) local_onDisplay(self, 'height');
    self.Menu.Display.Slope.Callback = @(~, ~) local_onDisplay(self, 'slope');
    
    
    self.Toolbar.NewMask.ClickedCallback = @(~,~) self.addMaskToScan();
    self.Toolbar.DeleteMask.ClickedCallback = @(~,~) self.Session.deleteCurrentMask(); 

    self.Menu.Data.Transpose.Callback = @(~,~) local_on_transpose(self);
    self.Menu.Data.Filter.Median.Callback = @(~, ~) local_on_filter_median(self);
    
end

function local_onDisplay(self, dsp)
    self.Settings.Display = dsp;
    self.redraw('menu','display');
end

function local_on_transpose(self)
    self.Session.transposeCurrent();
    self.IsDirty = true;
    self.RoughnessIsDirty = true;
end
function local_on_filter_median(self)
    scan = self.Session.getCurrentScan();
    ok = false;
    oldval = {'3'};
    while ~ok
        w = inputdlg('Filter width in px:','Filter parameters', [1, 40], oldval);
        if isempty(w)
            return
        end
        width = str2double(w{1});
        if ~isnan(width)
            ok = true;
        else 
            oldval = w;
        end
    end
    scan.SICMScan.filter('median', width);
    scan.Roughness = [];
    self.redraw('display', 'roughness');
    self.IsDirty = true;
    self.RoughnessIsDirty = true;
end