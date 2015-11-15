include("Scripts/Objects/Equipable.lua")

PortalLinker = EternusEngine.Mixin.Subclass("PortalLinker")

PortalLinker.__mixinoverrides =
	{
		"AffectObject",
		"CanToolAffectObject"
	}

-------------------------------------------------------------------------------
local cConstr = Equipable.Constructor

Equipable.Constructor = function(args)
	cConstr(args)
	if self:GetName() == "Crude Axe" then
		self:Mixin(PortalLinker, args)
	end
end

-------------------------------------------------------------------------------
function PortalLinker:Constructor( args )
	self.m_linkID = nil
end
-------------------------------------------------------------------------------
--function PortalLinker:Spawn()
--	self:NKSetEmitterActive(false)
--end

-------------------------------------------------------------------------------
function PortalLinker:CanToolAffectObject( args )
	NKPrint("PortalLinker CanToolAffectObject function called")
	if args then
		if args:NKGetName() == "Portal Stone" then
			return true
		end
	end
	return false
end

-------------------------------------------------------------------------------
-- The default Primary Action that an equipable object should execute
function PortalLinker:AffectObject( args )
	NKPrint("PortalLinker AffectObject function called")
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
	else
		return
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PortalLinker)