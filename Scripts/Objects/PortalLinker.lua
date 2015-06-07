include("Scripts/Core/Common.lua")
include("Scripts/Objects/Equipable.lua")
include("Scripts/Mixins/Usable.lua")

-------------------------------------------------------------------------------
PortalLinker = Equipable.Subclass("PortalLinker")

-- Mixins
PortalLinker.StaticMixin(Usable)

-------------------------------------------------------------------------------
function PortalLinker:Constructor( args )
	self.referenceObject = nil
end

-------------------------------------------------------------------------------
function PortalLinker:SecondaryAction( args )
	if args.targetObj and args.targetObj:NKGetName() == "Portal Stone" then
		local objInstance = args.targetObj:NKGetInstance()
		if not self.referenceObject then
			self.referenceObject = objInstance
			
		--Checking that it's not the same Portal Stone.
		elseif not(self.referenceObject == objInstance) then
			objInstance:RaiseClientEvent("ClientEvent_SetLink", {
				toObject = self.referenceObject,
				toPosition = self.referenceObject:NKGetWorldPosition()
				})
			self.referenceObject:RaiseClientEvent("ClientEvent_SetLink", {
				toObject = objInstance,
				toPosition = objInstance:NKGetWorldPosition()
				})
			self:ModifyStackSize(-1)
			self.referenceObject = nil
		end
	else
		return false
	end
	-- Don't drop Linker if it was a Portal Stone.
	return true
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalLinker)

