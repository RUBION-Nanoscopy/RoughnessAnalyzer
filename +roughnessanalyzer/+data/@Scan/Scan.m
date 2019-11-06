classdef Scan < handle
    properties (AbortSet)
        SICMScan SICM.SICMScan
    end
    properties
        Masks cell = {};
        Name 
        TreeNode
        CurrentMask
        Roughness 
    end
    
   
    
    %% Constructor and public methods
    methods 
        function self = Scan()
            
        end
        
        function set.SICMScan(self, scan)
            self.SICMScan = scan;
            
        end
        function addMask(self, mask)
            self.Masks{end+1} = struct(...
                'Mask', mask );
            self.Masks{end}.Name = sprintf('Mask %g', numel(self.Masks));
            self.Masks{end}.DisplayColor = [0 0 0];
            self.Masks{end}.DisplayOpacity = .5;
            self.Masks{end}.SlopeColor = [.8 0 0];
            self.Masks{end}.SlopeOpacity = .5;
            self.Masks{end}.RoughnessColor = [1 1 0];
            self.Masks{end}.RoughnessOpacity = .5;
            self.CurrentMask = numel(self.Masks);
        end
        
        function deleteCurrentMask( self )
            if isempty(self.CurrentMask); return; end
            
            self.Masks = {self.Masks{1:self.CurrentMask-1} self.Masks{self.CurrentMask+1:end}};
            self.CurrentMask = self.CurrentMask - 1;
            if self.CurrentMask == 0
                self.CurrentMask = [];
            end
            
        end
        
        function mask = getCurrentMask( self )
            mask = [];
            if ~isempty(self.CurrentMask)
                mask = self.Masks{ self.CurrentMask };
            end
        end
    end
end