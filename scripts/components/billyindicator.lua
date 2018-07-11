local BillyIndicator = Class(function(self, inst)
    self.inst = inst

    self.max_range = TUNING.MAX_INDICATOR_RANGE * 1.5
    self.OffScreenBilly = {}
    self.OnScreenBillyLastTick = {}

    inst:StartUpdatingComponent(self)
end)

function BillyIndicator:ShouldShowIndicator(target)
    return not self:ShouldRemoveIndicator(target) and (table.contains(self.OnScreenBillyLastTick, target))
end

function BillyIndicator:ShouldRemoveIndicator(target)
    return 	not target:IsValid() or
            not target:IsNear(self.inst, self.max_range) or
            target.entity:FrustumCheck()
end

function BillyIndicator:OnUpdate()
	if not self.inst or not self.inst.HUD then return end

    local checked = {}

    --Check which indicators' billys have moved within view or too far
    for i, v in ipairs(self.OffScreenBilly) do
        checked[v] = true

        while self:ShouldRemoveIndicator(v) do
            self.inst.HUD:RemoveBillyIndicator(v)
            table.remove(self.OffScreenBilly, i)
            v = self.OffScreenBilly[i]
            if v == nil then
                break
            end
            checked[v] = true
        end
    end

    --Check which billys have moved outside of view
    for i, v in ipairs(BILLY) do
        if not (checked[v] or v == self.inst) and self:ShouldShowIndicator(v) then
            self.inst.HUD:AddBillyIndicator(v)
            table.insert(self.OffScreenBilly, v)
        end
    end

    --Make a list of the billys who are on screen so we can know who left the screen next update
    self.OnScreenBillyLastTick = {}
    for i, v in ipairs(BILLY) do
        if v ~= self.inst then
            table.insert(self.OnScreenBillyLastTick, v)
        end
    end
end

function BillyIndicator:OnRemoveFromEntity()
    if self.OffScreenBilly ~= nil then
        for i, v in ipairs(self.OffScreenBilly) do
            self.inst.HUD:RemoveBillyIndicator(v)
        end
        self.OffScreenBilly = nil
    end
end

BillyIndicator.OnRemoveEntity = BillyIndicator.OnRemoveFromEntity

return BillyIndicator