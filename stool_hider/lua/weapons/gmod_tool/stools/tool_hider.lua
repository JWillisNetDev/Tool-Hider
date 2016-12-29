TOOL.Category = "Construction"
TOOL.Name = "Hider"
TOOL.Command = "tool_hider"
TOOL.ConfigName = ""

TOOL.ClientConVar = {
	["show_hidden"]		= "0"
}

// Initialization Stuff //
if CLIENT then
	hidden_entities = { }
	
	
end

if SERVER then
	hidden_entities = { }
	
end

// Tool Functionality Stuff //

if SERVER then
	function TOOL:SetEntityHidden( ent )
		
	end
end

// Tool Handling Stuff //
function TOOL:LeftClick( trace )
	if !trace.Entity then return false end

	if CLIENT then
		
	end
	
end

function TOOL:RightClick( trace )
	if CLIENT then
		
	end
end