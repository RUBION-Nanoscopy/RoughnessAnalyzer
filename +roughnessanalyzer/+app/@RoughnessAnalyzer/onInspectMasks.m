function onInspectMasks(self, nscan)
    data = self.DisplayIntensityImage.CData;
    
    switch self.Settings.Display
        case 'slope'
            CM = self.SlopeCM;
            CLim = self.SlopeCLim;
            
            % data is one pixel smaller...
            sz = size(self.Session.Scans{nscan}.SICMScan.zdata_grid);
            if size(data,1) < sz(1) 
                data(end+1,:) = data(end,:);
            elseif size(data,2) < sz(2)
                data(:, end+1) = data(:, end);
            end
            
        case 'height'
            CM = self.HeightCM;
            CLim = self.heightCLim;
    end
    
    rc = roughnessanalyzer.app.MaskComparer(...
        'Masks', self.Session.Scans{nscan}.Masks, ...
        'onApply',@(m)local_assign_masks(self, nscan, m), ...
        'CLim', CLim, 'CM', CM, 'Data', data ...
    );

    waitfor(rc);
end

function local_assign_masks(obj, nscan, m)
    obj.Session.Scans{nscan}.Masks = m;
    obj.IsDirty = true;
end