include("Scripts/Objects/Equipable.lua")
include("Scripts/Mixins/Usable.lua")

-------------------------------------------------------------------------------
PortalLinker = Equipable.Subclass("PortalLinker")

-------------------------------------------------------------------------------
function PortalLinker:Constructor(args)
	self.StonePos = nil
end

-------------------------------------------------------------------------------
function PortalLinker:SecondaryAction(args)
	if args.targetObj and args.targetObj:NKGetName() == "Portal Stone" then
		local Stone = args.targetObj:NKGetInstance()
		local StoneTele = args.targetObj:NKGetWorldPosition() + 
			vec3.new(0.0, 0.0, 2.0):mul_quat(args.targetObj:NKGetWorldOrientation())

		if self.StonePos then
			if not (self.StonePos == StoneTele) then
				Stone:RaiseClientEvent("ClientEvent_SetLink", {
					toPosition = self.StonePos})
				self.StonePos = nil
				self:ModifyStackSize(-1)
			end
		else
			self.StonePos = StoneTele
		end
	else
		return false
	end
	-- Don't drop Linker if it was a Portal Stone.
	return true
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalLinker)

