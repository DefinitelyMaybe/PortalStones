--PortalStonesMod
-------------------------------------------------------------------------------
if PortalStonesMod == nil then
	PortalStonesMod = EternusEngine.ModScriptClass.Subclass("PortalStonesMod")
end

-------------------------------------------------------------------------------
function PortalStonesMod:Constructor()
end

 -------------------------------------------------------------------------------
 -- Called once from C++ at engine initialization time
function PortalStonesMod:Initialize()
	Eternus.CraftingSystem:ParseRecipeFile("Data/Crafting/PortalStone_recipe.txt")
end

-------------------------------------------------------------------------------
-- Called from C++ when the current game enters 
function PortalStonesMod:Enter()
end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function PortalStonesMod:Leave()
end

-------------------------------------------------------------------------------
-- Called from C++ every update tick
function PortalStonesMod:Process(dt)
end

-------------------------------------------------------------------------------
EntityFramework:RegisterModScript(PortalStonesMod)