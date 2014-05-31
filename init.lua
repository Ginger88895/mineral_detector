max_search_distance = 8
min_search_distance = 2
search_item = 'default:stone'

-- All type detector

minetest.register_node("mineral_detector:detector", {
	description = "Mineral Detector",
	tile_images = {"mineral_detector_none_none_none.png", "default_steel_block.png"},
	inventory_image = "mineral_detector_inv.png",
	is_ground_content = true,
	groups = {crumbly=3},
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
	local search_p = {x=0, y=0, z=0}

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

minetest.register_on_punchnode(function(pos, node, puncher)
	if string.match(node.name, "mineral_detector:") ~= nil then

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
	end
end
)

