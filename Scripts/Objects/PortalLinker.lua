include("Scripts/Objects/Equipable.lua")
include("Scripts/Mixins/Usable.lua")

-------------------------------------------------------------------------------
PortalLinker = Equipable.Subclass("PortalLinker")

-------------------------------------------------------------------------------
function PortalLinker:Constructor(args)
	self.linkID = nil
end

-------------------------------------------------------------------------------
function PortalLinker:SecondaryAction(args)
	if args.targetObj and args.targetObj:NKGetName() == "Portal Stone" then
		local Stone = args.targetObj:NKGetInstance()
		if self.linkID then
			if not (Stone:GetLinkID() == self.linkID) then
				if Stone and Stone.SetTargetID then
					self.linkID = Stone:SetTargetID(self.linkID)
					self.linkID = nil
					self:ModifyStackSize(-1)
				end
			end
		else
			if Stone and Stone.GetLinkID then
				self.linkID = Stone:GetLinkID()
			end
		end
		-- Don't drop Linker if it was a Portal Stone.
		return true
	else
		return false
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalLinker)

