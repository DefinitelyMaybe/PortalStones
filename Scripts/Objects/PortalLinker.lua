include("Scripts/Objects/Equipable.lua")
include("Scripts/Objects/Crystal.lua")
include("Scripts/Objects/Consumable.lua")

-------------------------------------------------------------------------------
PortalLinker = EternusEngine.Class.Subclass("PortalLinker")

-------------------------------------------------------------------------------
function PortalLinker:Constructor(args)
	self.m_linkID = nil
end

-------------------------------------------------------------------------------
function PortalLinker:Spawn()
	self:NKSetEmitterActive(false)
end

-------------------------------------------------------------------------------
function PortalLinker:SecondaryAction(args)
	if args.targetObj and args.targetObj:NKGetName() == "Portal Stone" then
		-- Bonus emitter on the crystal to indicate linking
		self:NKSetEmitterActive(true)

		local Stone = args.targetObj:NKGetInstance()
		if self.m_linkID then
			if not (Stone:GetLinkID() == self.m_linkID) then
				if Stone and Stone.SetTargetID then
					self.m_linkID = Stone:SetTargetID(self.m_linkID)
					self.m_linkID = nil
					self:ModifyStackSize(-1)
					self:NKSetEmitterActive(false)
				end
			end
		else
			if Stone and Stone.GetLinkID then
				self.m_linkID = Stone:GetLinkID()
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