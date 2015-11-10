include("Scripts/Objects/Crystal.lua")
include("Scripts/Objects/Equipable.lua")

-------------------------------------------------------------------------------
PortalLinker = EternusEngine.Mixin.Subclass("PortalLinker")

-------------------------------------------------------------------------------
function PortalLinker:Constructor(args)
	NKPrint("Froststone Shard Constructor.")
	self.m_linkID = nil

	local crystalConstructor = Crystal.Constructor
	Crystal.Constructor = function(self, args)
		crystalConstructor(self, args)
		if self:GetName() == "Froststone Shard" then
			NKPrint("Froststone Shard injecting mixin.")
			self:Mixin(self, args)
			NKPrint("Froststone Shard injecting end.")
		end
	end
end

-------------------------------------------------------------------------------
--function PortalLinker:Spawn()
--	self:NKSetEmitterActive(false)
--end

-------------------------------------------------------------------------------
-- The default Primary Action that an equipable object should execute
function PortalLinker:DefaultPrimaryAction( args )
	NKPrint("PortalLinker DefaultPrimaryAction function called")
	if args.targetObj and args.targetObj:NKGetName() == "Portal Stone" then
		-- Bonus emitter on the crystal to indicate linking
		--self:NKSetEmitterActive(true)

		local Stone = args.targetObj
		if self.m_linkID then
			if not (Stone:GetLinkID() == self.m_linkID) then
				if Stone and Stone.SetTargetID then
					self.m_linkID = Stone:SetTargetID(self.m_linkID)
					self.m_linkID = nil
					self:ModifyStackSize(-1)
					--self:NKSetEmitterActive(false)
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