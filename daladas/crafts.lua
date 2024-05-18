-- wing
if not minetest.settings:get_bool('ju52.disable_craftitems') then
    minetest.register_craftitem("daladas:wings",{
	    description = "daladas wings",
	    inventory_image = "daladas_wings.png",
    })
-- fuselage
    minetest.register_craftitem("daladas:body",{
	    description = "daladas body",
	    inventory_image = "daladas_body.png",
    })
end


-- plane
minetest.register_craftitem("daladas:daladas", {
	description = "Daladalas plane",
	inventory_image = "daladas.png",
    liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local pointed_pos = pointed_thing.under
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]
          

                local v = vector.new(pointed_pos.x, pointed_pos.y, pointed_pos.z)
                

		pointed_pos.y=pointed_pos.y+1.0
		local new_daladas = minetest.add_entity(pointed_pos, "daladas:daladas")
		if new_daladas and placer then
            local ent = new_daladas:get_luaentity()
            local owner = placer:get_player_name()
            ent.owner = owner
			new_daladas:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
            ent.object:set_acceleration({x=0,y=airutils.gravity,z=0})
            airutils.create_inventory(ent, ent._trunk_slots, owner)
		end
		
		

		return itemstack
	end,
})

--
-- crafting
--
if not minetest.settings:get_bool('ju52.disable_craftitems') and minetest.get_modpath("default") then
	--[[minetest.register_craft({
		output = "daladas:wings",
		recipe = {
			{"wool:bue", "default:steel_block", "wool:blue"},
			{"group:wood", "default:steel_block", "group:wood"},
			{"wool:white", "default:steel_block", "wool:white"},
		}
	})
	minetest.register_craft({
		output = "daladas:body",
		recipe = {
			{"default:steel_block", "default:steel_block", "default:steel_block"},
			{"default:wood", "default:glass", "default:wood"},
			{"default:steel_block", "group:wood",   "default:steel_block"},
		}
	})
	minetest.register_craft({
		output = "daladas:daladas",
		recipe = {
			{"daladas:wings",},
			{"daladas:body",},
		}
	})]]--
end
