function storePanelPositions(self)
% STOREPANELPOSITIONS computes the positions of the panels and stores them
% as properties of the class
    self.DisplayPanelPosition = local_get_pos_relative_to(self.Layout.DisplayPanel, self.Figure);
    self.RoughnessPanelPosition = local_get_pos_relative_to(self.Layout.RoughnessPanel, self.Figure);

end


function p = local_get_pos_relative_to( obj, target )
    p = local_get_pos_in_px(obj);   
    if obj == target
        p(1:2) = [0 0];
        return
    end
    while obj.Parent ~= target
        obj = obj.Parent;
        p2 = local_get_pos_in_px(obj);
        p(1) = p(1) + p2(1);
        p(2) = p(2) + p2(2);
    end
end
function p = local_get_pos_in_px(obj)
    ou = obj.Units;
    obj.Units = 'pixel';
    p = obj.Position;
    obj.Units = ou;
end