--PortalStonesMod
-------------------------------------------------------------------------------
if PortalStonesMod == nil then
	PortalStonesMod = EternusEngine.ModScriptClass.Subclass("PortalStonesMod")
end

-------------------------------------------------------------------------------
function PortalStonesMod:Constructor()
	NKPrint("Portal Stones Mod.")
	PortalStonesMod.LinkManager = include( "Scripts/Core/LinkManager.lua").new(self)
end

 -------------------------------------------------------------------------------
 -- Called once from C++ at engine initialization time
function PortalStonesMod:Initialize()
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/PortalStone_recipe.txt", "Magic Items")
end

-------------------------------------------------------------------------------
function PortalStonesMod:Save()
	PortalStonesMod.LinkManager:Save()
end

-------------------------------------------------------------------------------
function PortalStonesMod:Restore()
	PortalStonesMod.LinkManager:Restore()
end

-------------------------------------------------------------------------------
function PortalStonesMod:Enter()
	include("Scripts/Objects/ReturnStone.lua")
	include("Scripts/Mixins/PortalLinker.lua")

	local ReturnStoneConstructor = ReturnStone.Constructor

	ReturnStone.Constructor = function(self, args)
		ReturnStoneConstructor(self, args)
		self:Mixin(PortalLinker, args)
	end
end
-------------------------------------------------------------------------------
-- Called from C++ when the current game enters 
function PortalStonesMod:Save()
	PortalStonesMod.LinkManager:Save()
end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function PortalStonesMod:Restore()
	PortalStonesMod.LinkManager:Restore()
end

-------------------------------------------------------------------------------
EntityFramework:RegisterModScript(PortalStonesMod)