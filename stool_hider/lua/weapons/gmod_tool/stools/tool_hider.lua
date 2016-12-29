TOOL.Category = "Construction"
TOOL.Name = "Hider"
TOOL.Command = "tool_hider"
TOOL.ConfigName = ""

TOOL.ClientConVar = {
	["show_hidden"]		= "0"
}

// Initialization Stuff //
hidden_entities = hidden_entities or { }

// Tool Functionality Stuff //

function contains( tbl, trg )
	for k, v in pairs( tbl ) do
		if v == trg then return true end
	end
	return false
end

if CLIENT then
	function printHidden( )
		for k, v in pairs( hidden_entities ) do
			print( k.." : "..v:GetModel() )
		end
	end

	concommand.Add( "tool_hider_printhidden", function( )
		for k, v in pairs( hidden_entities ) do
			print( k.." : "..v:GetModel() )
		end
	end )
end

if SERVER then
	function TOOL:SetEntityHidden( ent, ply )
		if contains( hidden_entities, ent ) then return end
		table.insert( hidden_entities, ent )
		
	end
end

// Tool Handling Stuff //
function TOOL:LeftClick( trace )
	if !trace.Entity then return false end
	if trace.Entity:IsWorld() then return false end
	if CLIENT then
		print( trace.Entity )
		return true
	end
	
	if !IsValid( trace.Entity ) then
		return false
	elseif !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then
		return false
	end
	
	local ent = trace.Entity
	local ply = self:GetOwner()

	self:SetEntityHidden( ent, ply )
end

function TOOL:RightClick( trace )
	if CLIENT then
		
	end
end
