max_search_distance = 8
min_search_distance = 2
search_item = 'default:stone'

-- All type detector

minetest.register_node("mineral_detector:detector", {
	description = "Mineral Detector",
	tile_images = {"mineral_detector.png", "default_steel_block.png"},
	inventory_image = "mineral_detector.png",
	is_ground_content = true,
	groups = {cracky=1, level=2},
	drop = 'mineral_detector:detector 1',
	metadata_name = "generic",
	on_construct = function(pos)
		--local n = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[text;;${text}]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		fields.text = fields.text or ""
		if fields.text == "" then
			return
		end
		meta:set_string("search_item", fields.text)
		UpdateDetectorAll(pos, tonumber(meta:get_string("search_distance")), meta:get_string("search_item"))
	end
})

minetest.register_craft({
	output = 'mineral_detector:detector 1',
	recipe = {
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
		{'default:steelblock', 'default:coalblock', 'default:steelblock'},
		{'default:steelblock', 'default:coalblock', 'default:steelblock'},
	}
})

function UpdateDetectorAll(pos, search_distance, search_item)
	local found = 0

	for p_x=(pos.x-search_distance), (pos.x+search_distance) do
		for p_y=(pos.y-search_distance), (pos.y+search_distance) do
			for p_z=(pos.z-search_distance), (pos.z+search_distance) do
				local search_n = minetest.env:get_node({x=p_x, y=p_y, z=p_z})

				if search_n.name == search_item then
					found = found + 1
				end
			end
		end
	end
	
	info_text = ("Range: " .. tostring(search_distance) .. " | Found " .. search_item .. " x " .. found)

	local newmeta = minetest.env:get_meta(pos)
	newmeta:set_string("infotext",info_text)
	newmeta:set_string("search_distance", tostring(search_distance))
	newmeta:set_string("search_item", search_item)
end

function UpdateMaterializerAll(pos, search_item)
	info_text = ("Now producing "..search_item)
	local newmeta = minetest.get_meta(pos)
	newmeta:set_string("infotext",info_text)
	newmeta:set_string("search_item", search_item)
end

function UpdateSensorAll(pos, search_item)
	local found = 0
	local dist = 10000

	for dx=-10,10 do
		for dy=-10,10 do
			for dz=-10,10 do
				local search_n = minetest.env:get_node({x=pos.x+dx, y=pos.y+dy, z=pos.z+dz})
				if search_n.name == search_item then
					found = 1
					dist = math.min(dist, math.max(math.abs(dx),math.abs(dy),math.abs(dz)))
				end
			end
		end
	end
	
	if found > 0 then
		info_text = ("Found " .. search_item .. " @ Distance " .. tostring(dist))
	else
		info_text = (search_item .. " is not found nearby")
	end

	local newmeta = minetest.get_meta(pos)
	newmeta:set_string("infotext",info_text)
	newmeta:set_string("search_item", search_item)
end

minetest.register_on_punchnode(function(pos, node, puncher)
	if string.match(node.name, "mineral_detector:detector") ~= nil then

		local meta = minetest.env:get_meta(pos)
		local search_distance = tonumber(meta:get_string("search_distance"))
		local search_item = meta:get_string("search_item")

		if search_distance < max_search_distance then
			search_distance = search_distance + 1
		else
			search_distance = min_search_distance
		end

		if string.match(node.name, "mineral_detector:detector") ~= nil then
			UpdateDetectorAll(pos, search_distance, search_item)
		end
	end
end)

minetest.register_on_placenode(
function(pos, newnode, placer)
	if string.match(newnode.name, "mineral_detector:") ~= nil then
		if newnode.name == "mineral_detector:detector" then
			UpdateDetectorAll(pos, min_search_distance, search_item)
		end
		if newnode.name == "mineral_detector:materializer" or newnode.name == "mineral_detector:materializer2" then
			UpdateMaterializerAll(pos, search_item)
		end
		if newnode.name == "mineral_detector:sensor" then
			UpdateSensorAll(pos, search_item)
		end
	end
end
)

-- Materializer

minetest.register_node("mineral_detector:materializer", {
	description = "Item Materializer",
	tile_images = {"mineral_materializer.png", "default_steel_block.png"},
	inventory_image = "mineral_materializer.png",
	is_ground_content = true,
	groups = {cracky=1, level=2},
	drop = 'mineral_detector:materializer 1',
	metadata_name = "generic",
	on_construct = function(pos)
		--local n = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[text;;${text}]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		fields.text = fields.text or ""
		if fields.text == "" then
			return
		end
		UpdateMaterializerAll(pos, fields.text);
	end
})

minetest.register_craft({
	output = 'mineral_detector:materializer 1',
	recipe = {
		{'default:diamondblock', 'default:obsidian', 'default:diamondblock'},
		{'default:diamondblock', 'default:mese', 'default:diamondblock'},
		{'default:diamondblock', 'default:diamondblock', 'default:diamondblock'},
	}
})

minetest.register_abm({
	nodenames = {'mineral_detector:materializer'},
	interval = 10000.0,
	chance = 1.0,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		pos.y = pos.y+1
		if minetest.registered_nodes[meta:get_string("search_item")] ~= nil then
			minetest.add_node(pos,{name=meta:get_string("search_item")})
		end
	end,
})

-- Materializer MKII

minetest.register_node("mineral_detector:materializer2", {
	description = "Item Materializer MKII",
	tile_images = {"mineral_materializer2.png", "default_steel_block.png"},
	inventory_image = "mineral_materializer2.png",
	is_ground_content = true,
	groups = {cracky=1, level=2},
	drop = 'mineral_detector:materializer2 1',
	metadata_name = "generic",
	on_construct = function(pos)
		--local n = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[text;;${text}]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		fields.text = fields.text or ""
		if fields.text == "" then
			return
		end
		UpdateMaterializerAll(pos, fields.text);
	end
})

minetest.register_craft({
	output = 'mineral_detector:materializer2 1',
	recipe = {
		{'mineral_detector:materializer', 'mineral_detector:materializer', 'mineral_detector:materializer'},
		{'mineral_detector:materializer', 'mineral_detector:materializer', 'mineral_detector:materializer'},
		{'mineral_detector:materializer', 'mineral_detector:materializer', 'mineral_detector:materializer'},
	}
})

minetest.register_abm({
	nodenames = {'mineral_detector:materializer2'},
	interval = 1000.0,
	chance = 1.0,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		pos.y = pos.y+1
		if minetest.registered_nodes[meta:get_string("search_item")] ~= nil then
			minetest.add_node(pos,{name=meta:get_string("search_item")})
		end
	end,
})

-- Mineral Sensor --
--
minetest.register_node("mineral_detector:sensor", {
	description = "Mineral Sensor",
	tile_images = {"mineral_sensor.png", "default_steel_block.png"},
	inventory_image = "mineral_sensor.png",
	is_ground_content = true,
	groups = {cracky=1, level=2},
	drop = 'mineral_detector:sensor 1',
	metadata_name = "generic",
	on_construct = function(pos)
		--local n = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[text;;${text}]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		fields.text = fields.text or ""
		if fields.text == "" then
			return
		end
		meta:set_string("search_item", fields.text)
		UpdateSensorAll(pos, meta:get_string("search_item"))
	end
})

minetest.register_craft({
	output = 'mineral_detector:sensor 1',
	recipe = {
		{'default:mese', 'default:steelblock', 'default:mese'},
		{'default:mese', 'default:copperblock', 'default:mese'},
		{'default:mese', 'default:steelblock', 'default:mese'},
	}
})
