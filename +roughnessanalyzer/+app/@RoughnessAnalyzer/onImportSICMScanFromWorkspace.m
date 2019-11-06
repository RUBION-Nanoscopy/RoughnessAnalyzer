function onImportSICMScanFromWorkspace(self)
% ONIMPORTSCANFROMWORKSPACE Imports a scan from the workspace

    vars = evalin('base','whos');
    scanvars = {};
    for var = vars'
        if strcmp(var(1).class, 'SICM.SICMScan')
            scanvars{end+1} = var(1).name; %#ok<AGROW>
        end
    end
    
    if isempty(scanvars)
        warndlg('The workspace does not contain variables from the class SICM.SICMScan.', 'No suitable variables');
        return
    end
    
    [idx, tf] = listdlg(...
        'Name', 'Select a variable', ...
        'OKString', 'Select', ...
        'CancelString', 'Cancel', ...
        'SelectionMode', 'single', ...
        'ListString', scanvars);
    
    if ~tf; return; end
    
    scan = evalin('base', scanvars{idx});
    self.addScanToSession(scan);
end