log.info("Successfully loaded ".._ENV["!guid"]..".")

local object_id_to_item_id = nil

function addsprite()
	local path = _ENV._PLUGIN.plugins_mod_folder_path .. "/graphics/ArtifactAssembly.png"
	return gm.sprite_add(path, 3, false, false, 16, 16)
end

local custom_init = false
local artifact_id = nil
local sprite = nil
gm.pre_script_hook(gm.constants.__input_system_tick, function()
	if not custom_init then
		custom_init = true
		artifact_id = gm.artifact_create("SkyeTheFoxyFox", "drone_artifact")
		local class_arti = gm.variable_global_get("class_artifact")[artifact_id + 1]
		if(not sprite) then
			sprite = addsprite()
		end
		gm.array_set(class_arti, 2, "Assembly")
		gm.array_set(class_arti, 3, "Artifact of Assembly")
		gm.array_set(class_arti, 4, "Makes most items become drones.")
		gm.array_set(class_arti, 5, sprite)
		gm.array_set(class_arti, 6, 0)
		gm.array_set(class_arti, 7, 0)
	end
end)

local enable_assembly = false
gm.post_script_hook(gm.constants.run_create, function(self, other, result, args)
	enable_assembly = gm.array_get(gm.variable_global_get("class_artifact")[artifact_id + 1], 8)
end)

gm.pre_script_hook(gm.constants.instance_create, function(self, other, result, args)
	if not enable_assembly then return end
	if(object_id_to_item_id == nil) then
		object_id_to_item_id = {}
		for index, item in ipairs(gm.variable_global_get("class_item")) do
			if(item[9] >= 0 and item[9] <= 795) then
				object_id_to_item_id[tostring(item[9])] = index
			end
		end
	end
	if(object_id_to_item_id[tostring(args[3].value)] ~= nil) then
		local drones = {"oDroneGolem", "oDroneGolemS", "oDrone1", "oDrone1B", "oDrone2", "odrone2B", "oDrone2S", "oDrone3", "oDrone4", "oDrone5", "oDrone6", "oDrone7", "oDrone7S", "oDrone8", "oDrone8S", "oDrone9", "oDrone9S", "oDrone10", "oDrone10S"}
	
		local white = {"oDroneGolem", "oDrone1", "oDrone1B", "oDrone4"}
		local green = {"oDrone2", "oDrone2B", "oDrone3", "oDrone5", "oDrone6", "oDrone7"}
		local red = {"oDrone8", "oDrone9", "oDrone10"}
		local yellow = {"oDrone7S", "oDrone2S", 'oDroneGolemS'}

		local rarity = gm.variable_global_get("class_item")[object_id_to_item_id[tostring(args[3].value)]][7]
	
		if(rarity == 0) then
			args[3].value = gm.constants[white[math.random(#white)]]
		elseif(rarity == 1) then
			args[3].value = gm.constants[green[math.random(#green)]]
		elseif(rarity == 2) then
			args[3].value = gm.constants[red[math.random(#red)]]
		elseif(rarity == 3) then
			args[3].value = gm.constants[yellow[math.random(#yellow)]]
		end
 	end
end)