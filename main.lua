log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

local temp_drone_despawn_time = 4800

local function add_chat_message(text)
    gm.chat_add_message(gm["@@NewGMLObject@@"](gm.constants.ChatMessage, text))
    log.info("chat message: "..text)
end

function addsprite()
	local path = _ENV._PLUGIN.plugins_mod_folder_path .. "/ArtifactAssembly.png"
	return gm.sprite_add(path, 3, false, false, 16, 16)
end

local custom_init = false
local artifact_id = nil
local sprite = nil
local function init_artifact()
	artifact_id = gm.artifact_create("SkyeTheFoxyFox", "drone_artifact")
	local class_arti = gm.variable_global_get("class_artifact")[artifact_id + 1]
	if(not sprite) then
		sprite = addsprite()
	end
	if(sprite == -1) then
		sprite = 1221
	end
	gm.array_set(class_arti, 2, "Assembly")
	gm.array_set(class_arti, 3, "Artifact of Assembly")
	gm.array_set(class_arti, 4, "Makes most items become drones.")
	gm.array_set(class_arti, 5, sprite)
	gm.array_set(class_arti, 6, 0)
	gm.array_set(class_arti, 7, 0)
end

local enable_assembly = false
gm.post_script_hook(gm.constants.run_create, function(self, other, result, args)
	enable_assembly = gm.array_get(gm.variable_global_get("class_artifact")[artifact_id + 1], 8)
end)

local item_array = {}

gm.post_script_hook(gm.constants.item_spawn_init, function(self, other, result, args)
	if not enable_assembly then return end
	table.insert(item_array, self)
end)

local function get_drone_by_rarity(rarity)
	local drones = {"oDroneGolem", "oDroneGolemS", "oDrone1", "oDrone1B", "oDrone2", "odrone2B", "oDrone2S", "oDrone3", "oDrone4", "oDrone5", "oDrone6", "oDrone7", "oDrone7S", "oDrone8", "oDrone8S", "oDrone9", "oDrone9S", "oDrone10", "oDrone10S"}
	
	local white = {"oDroneGolem", "oDrone1", "oDrone1B", "oDrone4"}
	local green = {"oDrone2", "oDrone2B", "oDrone3", "oDrone5", "oDrone6", "oDrone7"}
	local red = {"oDrone8", "oDrone9", "oDrone10"}
	local yellow = {"oDrone7S", "oDrone2S", 'oDroneGolemS'}
	
	if(rarity == 0) then
		return(gm.constants[white[math.random(#white)]])
	elseif(rarity == 1) then
		return(gm.constants[green[math.random(#green)]])
	elseif(rarity == 2) then
		return(gm.constants[red[math.random(#red)]])
	elseif(rarity == 4) then
		return(gm.constants[yellow[math.random(#yellow)]])
	end
	return(nil)
end

local function evaluate_item_array()
	local items = item_array
	item_array = {}
	for index, item in ipairs(items) do
		if(gm.variable_global_get("class_item")[item.item_id+1] ~= nil) then
			local rarity = gm.variable_global_get("class_item")[item.item_id+1][7]
			local drone = get_drone_by_rarity(rarity)
			if(drone ~= nil) then
				if Helper.get_client_player().m_id < 2.0 then
					drone_instance = gm.instance_create_depth(item.x, item.y, item.depth, drone)
					drone_instance.assembly_drone_timeout = "custom"
	
					-- if temp, schedule death
					if item.item_stack_kind == 1 then
						local method = gm.method(drone_instance, gm.constants.function_dummy)
						local _handle = gm.call_later(temp_drone_despawn_time, 1, method, false) -- (nb of frames, time unit (frames), the method you just created, loop=false)
					end
				end
				gm.instance_destroy(item.id)
			end
		end
	end
end

-- kill the drones
gm.post_script_hook(gm.constants.function_dummy, function(self, other, result, args)
    --self is the instance of the drone you gave earlier
    if self.assembly_drone_timeout == "custom" then --the second part is just security and since custom values disapear from the object after it's deleted, it also filters that
    	if self.object_name == "oDroneGolem" then
    		gm.instance_create_depth(self.x, self.y, self.layer, gm.constants["oEfDroneGolemDeath"])
    		gm.sound_play_at(gm.constants.wDroneDeath, 1, 1, self.x, self.y, 1)
    	else
    		gm.instance_create_depth(self.x, self.y, self.layer, gm.constants["oEfExplosion"])
    		gm.sound_play_at(gm.constants.wDroneDeath, 1, 1, self.x, self.y, 1)
    	end
    	gm.instance_destroy(self)
    	return false
    end
end)

-- every tick
gm.pre_script_hook(gm.constants.__input_system_tick, function()
	if not custom_init then
		custom_init = true
		init_artifact()
	end
	if enable_assembly then
		evaluate_item_array()
	end
end)

