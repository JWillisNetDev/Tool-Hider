TOOL.Category = "Construction"
TOOL.Name = "Hider"
TOOL.Command = "tool_hider"
TOOL.ConfigName = ""
TOOL.CanDeploy = true

TOOL.ClientConVar = {
	["show_hidden"]		= "0"
}

-- Tool Necessary Stuff --

local function contains( tbl, trg )
	for k, v in pairs( tbl ) do
		if v == trg then return k end
	end
	return -1
end

if CLIENT then
	cl_hidden_entities = { }

	-- Console commands and net functions --
	concommand.Add( "tool_hider_printhidden", function( )
		net.Start( "printhidden" )
		net.SendToServer()
	end )
	
	concommand.Add( "tool_hider_cleanlist", function( )
		net.Start( "cleanhidden" )
		net.SendToServer()
	end )
	
	net.Receive( "printhidden", function( bits )
		print( "Hidden entities: " )
		local tbl = net.ReadTable()
		PrintTable( tbl )
	end )
	
	net.Receive( "gethidden", function( bits )
		local tbl = net.ReadTable()
		cl_hidden_entities = tbl
	end )
	
	-- Make it look pretty --
	language.Add( "tool.tool_hider.name", "Hider Tool" )
	language.Add( "tool.tool_hider.desc", "Hide and unhide entities for building purposes." )
	language.Add( "tool.tool_hider.0", "Primary: Hide an entity, Secondary: Unhide an entity, Reload: Unhide all entities")
end

if SERVER then
	util.AddNetworkString( "printhidden" )
	util.AddNetworkString( "cleanhidden" )
	util.AddNetworkString( "gethidden" )
	
	hidden_entities = { }
	
	net.Receive( "cleanhidden", function( bits, ply )
		if hidden_entities == nil then return end
		hidden_entities = { }
	end )
	
	net.Receive( "printhidden", function( bits, ply ) 
		if hidden_entities == nil then return end;
		net.Start( "printhidden" )
			net.WriteTable( hidden_entities )
		net.Send( ply )
	end )
	
	net.Receive( "gethidden", function( bits, ply )
		if hidden_entities == nil then return end
		net.Start( "gethidden" )
			net.WriteTable( hidden_entities )
		net.Send( ply )
	end )
end

-- Tool Functionality Stuff --

if SERVER then
	function TOOL:AddEntityHidden( ent, ply )
		if !hidden_entities then hidden_entities = { } end
		--if contains( ply.hidden_entities, ent ) >= 0 then return end
		local entdata = { }
		entdata.entity			= ent
		entdata.owner			= ply
		entdata.model			= ent:GetModel()
		entdata.pos				= ent:GetPos()
		entdata.angle			= ent:GetAngles()
		entdata.solid			= ent:GetSolid()
		entdata.move			= ent:GetMoveType()
		table.insert( hidden_entities, entdata )
		--ent:SetNoDraw( true )
		--ent:SetCollisionBounds( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) ) POSSIBLE WORKAROUND IF SETSOLID NO LONGER WORKS
		ent:SetMoveType( MOVETYPE_NONE )
		ent:SetSolid( SOLID_NONE )
		local phys = ent:GetPhysicsObject()
		phys:Sleep()
		--ent:SetVelocity( Vector( 0, 0, 0 ) )
		net.Start( "gethidden" )
			net.WriteTable( hidden_entities )
		net.Broadcast()
	end
	
	function TOOL:RemoveEntityHidden( ent, ply )
		for k, v in pairs( hidden_entities ) do
			if v['entity'] == ent and v['owner'] == ply then
				ent:SetNoDraw( false )
				ent:SetPos( v['pos'] )
				ent:SetAngles( v['angle'] )
				ent:SetMoveType( v['move'] )
				ent:SetSolid( v['solid'] )
				local phys = ent:GetPhysicsObject()
				phys:Wake()
				table.remove( hidden_entities, k )
				net.Start( "gethidden" )
					net.WriteTable( hidden_entities )
				net.Broadcast()
				return k
			end
		end
		return -1
	end
	
	function TOOL:RemoveEntityHiddenByKey( key, ply )
		if hidden_entities[key] == nil then return -1 end
		if hidden_entities[key]['owner'] != ply then return -1 end
		local val = hidden_entities[key]
		local ent = val['entity']
		ent:SetNoDraw( false )
		ent:SetPos( val['pos'] )
		ent:SetAngles( val['angle'] )
		ent:SetMoveType( val['move'] )
		ent:SetSolid( val['solid'] )
		local phys = ent:GetPhysicsObject()
		phys:Wake()
		table.remove( hidden_entities, key )
		net.Start( "gethidden" )
			net.WriteTable( hidden_entities )
		net.Broadcast()
		return key
	end
end

-- Tool Hooks Stuff --

function TOOL:LeftClick( trace )
	if !trace.Entity then return false end
	if trace.Entity:IsWorld() then return false end
	
	if CLIENT then
		print( trace.Entity )
		return true
	end
	
	if !IsValid( trace.Entity ) then return false end
	
	local ent = trace.Entity
	local ply = self:GetOwner()
	
	self:AddEntityHidden( ent, ply )
	
	return true
end

function TOOL:RightClick( trace )
	if CLIENT then return true end
	
	if hidden_entities[1] == nil then return false end
	
	local val = hidden_entities[1]
	local ply = self:GetOwner()
	
	self:RemoveEntityHiddenByKey( 1, ply )
end

function TOOL:Deploy( )
	return true
end

if CLIENT then
	function TOOL:DrawHUD( )
		surface.SetFont( "Default" )
		for k, v in pairs( cl_hidden_entities ) do
			if !v['entity']:IsValid() then return end
			local pos = v['entity']:GetPos():ToScreen()
			surface.SetTextPos( pos.x, pos.y )
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.DrawText( v['model'] )
		end
	end
end

-- Entity Specific Functions --

--function ENT:Hide( )
	
--end

-- Gamemode Hooks -- 

hook.Add( "EntityRemoved", "hook_hider_autoclean", function( ent )
	if SERVER then
		for k, v in pairs( hidden_entities ) do
			if v.entity == ent or !v.entity:IsValid() then
				table.remove( hidden_entities, k )
				net.Broadcast( "gethidden" )
			end
		end
	end
	
end )
