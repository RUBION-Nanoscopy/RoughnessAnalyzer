classdef Data < handle & uiw.mixin.AssignPVPairs
    
    %% Events
    events
        ModelChanged %Triggered when relevant properties of the model are changed
    end
    
    %% Properties
    properties (AbortSet)
        Scans = {};
        CurrentScan int8 

        RoughnessWidth = 11;
        RoughnessPolynomialDegree = 5;
        
    end
    
    properties (SetAccess = protected, GetAccess = public)
        untitled_counter = 0;
    end
    
    
        
        
    
    
    
    %% Constructor
    methods
        function self = Data( varargin )
            self.assignPVPairs( varargin{ : } );
        end
    end
    
   
    
    %% Public methods (Getter, Setter and similar)
    methods
        function varargout = addScan( self, scan )
            sc = roughnessanalyzer.data.Scan();
            sc.SICMScan = scan;
            if isprop(scan, 'info') && isfield(scan.info, 'filename')
                [~, sc.Name, ~] = fileparts(scan.info.filename);
            else
                sc.Name = sprintf('untitled %g', self.untitled_counter);
                self.untitled_counter = self.untitled_counter + 1;
            end
            self.Scans{end + 1} = sc;
            
            if nargout == 1
                varargout{1} = sc;
            end
            %self.CurrentScan = numel(self.Scans);
        end
        
        function set.CurrentScan( self, curr )
            self.CurrentScan = curr;
            evt = uiw.event.EventData(...
                'EventType', 'ScansChanged',...
                'Property', 'CurrentScan',...
                'Model', self);
            self.notify('ModelChanged', evt);
        end
    end
    
    methods
        function tf = isMaskSelected(self)
            tf = ~(isempty(self.CurrentScan) || isempty(self.Scans{self.CurrentScan}.CurrentMask));
        end
        function scan = getCurrentScan(self)
            scan = [];
            if ~isempty(self.CurrentScan)
                scan = self.Scans{ self.CurrentScan };
            end
        end
        
        function changeMask(self, roi, mode)
            mask = self.Scans{self.CurrentScan}.Masks{self.Scans{self.CurrentScan}.CurrentMask}.Mask;
            if isa(roi, 'images.roi.Point')
                roimask = false(size(mask));
                roimask(floor(roi.Position(2)), floor(roi.Position(1))) = true;
            else
                roimask = roi.createMask(roi.Parent.Children(end));
            end
            
            
            if size(roimask, 1) < size(mask,1)
                % if the slope is displayed, the roi is one pixel smaller
                % than the mask
                roimask(end+1,:) = 1;
                
            end
            switch mode
                case 'add'
                    mask = mask | roimask;
                case 'subtract'
                    mask = mask & ~roimask;
            end
            self.Scans{self.CurrentScan}.Masks{self.Scans{self.CurrentScan}.CurrentMask}.Mask = mask;
            evt = uiw.event.EventData(...
                'EventType', 'MaskChanged',...
                'Property', 'CurrentMask',...
                'Model', self);
            self.notify('ModelChanged', evt);
        end
        
        function deleteCurrentMask(self)
            scan = self.getCurrentScan();
            if isempty(scan); return; end
            
            scan.deleteCurrentMask();
            evt = uiw.event.EventData(...
                'EventType', 'MaskDeleted',...
                'Property', 'CurrentMask',...
                'Model', self);
            self.notify('ModelChanged', evt);
        end
        
        function transposeCurrent(self)
            scan = self.getCurrentScan();
            if isempty(scan); return; end
            
            scan.SICMScan.transposeZ();
            scan.Roughness = [];
            for k = 1:numel(scan.Masks)
                scan.Masks{k}.Mask = scan.Masks{k}.Mask';
            end
            evt = uiw.event.EventData(...
                'EventType', 'ScansChanged',...
                'Property', 'CurrentScan',...
                'Model', self);
            self.notify('ModelChanged', evt);
        end
    end
end