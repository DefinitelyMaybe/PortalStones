include("Scripts/Objects/Equipable.lua")

-------------------------------------------------------------------------------
PortalLinker = Equipable.Subclass("PortalLinker")

-------------------------------------------------------------------------------
function PortalLinker:Constructor( args )
	self.referencePos = nil
end

-------------------------------------------------------------------------------
function PortalLinker:SecondaryAction( args )
	if args.targetObj and args.targetObj:NKGetName() == "Portal Stone" then
		local object = args.targetObj:NKGetInstance()
		if not self.referencePos then
			--Can change this value to the players position instead. 
			--This would be done in the case where the position clips through surfaces.
			self.referencePos = object:NKGetWorldPosition() + vec3.new(0.0, 0.0, 2.0):mul_quat(object:NKGetWorldOrientation())
		elseif not (self.referencePos == object.linkedPosition) then
			object:RaiseClientEvent("ClientEvent_SetLink", {
				toPosition = self.referencePos
				})
			self.referenceObject = nil
			self:ModifyStackSize(-1)
		end
	else
		return false
	end
	-- Don't drop Linker if it was a Portal Stone.
	return true
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalLinker)

