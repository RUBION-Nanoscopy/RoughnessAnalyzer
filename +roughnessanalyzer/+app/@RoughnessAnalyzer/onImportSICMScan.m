function onImportSICMScan(self)
% ONIMPORTSICMSCAN Opens a file dialog and imports the selected scan

try
    scan = SICM.SICMScan.FromFile();
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:unassignedOutputs')
        rethrow(ME);
        return
    end
end

self.addScanToSession(scan);